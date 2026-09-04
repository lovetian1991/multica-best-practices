param(
    [string]$RuntimeId = 'd4b16b09-a23c-4fb1-a7af-a1ebdd16473a',
    [string]$WorkspaceSlug = 'tanyo',
    [switch]$SkipSquads,
    [switch]$AgentsOnly
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'agent-names.ps1')

$cliCommand = Get-Command multica -ErrorAction SilentlyContinue
if ($null -ne $cliCommand) {
    $cli = $cliCommand.Path
}
else {
    $cli = Join-Path $HOME '.multica\bin\multica.exe'
    if (-not (Test-Path -LiteralPath $cli)) {
        throw "Multica CLI not found. Install the CLI and run 'multica login' first."
    }
}

function Invoke-MulticaJson {
    param([string[]]$Arguments)

    $result = & $cli @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "multica $($Arguments -join ' ') failed:`n$($result -join "`n")"
    }

    $text = ($result -join "`n").Trim()
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }
    return $text | ConvertFrom-Json
}

function Invoke-MulticaRestPut {
    param(
        [string]$Path,
        [hashtable]$Body
    )

    $configPath = Join-Path $HOME '.multica\config.json'
    if (-not (Test-Path -LiteralPath $configPath)) {
        throw "Multica config not found at $configPath. Run 'multica login' first."
    }

    $config = Get-Content -Raw -LiteralPath $configPath -Encoding UTF8 | ConvertFrom-Json
    $headers = @{
        Authorization = "Bearer $($config.token)"
        'X-Workspace-Slug' = $WorkspaceSlug
        'Content-Type' = 'application/json; charset=utf-8'
    }
    $json = $Body | ConvertTo-Json -Depth 20 -Compress
    $bodyBytes = [Text.Encoding]::UTF8.GetBytes($json)
    return Invoke-RestMethod -Method Put -Uri "$($config.server_url)$Path" -Headers $headers -Body $bodyBytes
}

function As-Array {
    param($Value)
    if ($null -eq $Value) {
        return @()
    }
    return @($Value)
}

function Get-MarkdownCodeBlock {
    param(
        [string]$Path,
        [string]$Language = 'text'
    )

    $raw = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
    $pattern = '(?s)```' + [regex]::Escape($Language) + '\s*(.*?)\s*```'
    $match = [regex]::Match($raw, $pattern)
    if (-not $match.Success) {
        throw "No ```$Language code block found in $Path."
    }
    return $match.Groups[1].Value.Trim()
}

function Get-SkillMetadata {
    param([string]$Path)

    $raw = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
    $match = [regex]::Match($raw, '(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$')
    if (-not $match.Success) {
        throw "Skill front matter not found in $Path."
    }

    $frontMatter = $match.Groups[1].Value
    $body = $match.Groups[2].Value.Trim()
    $nameMatch = [regex]::Match($frontMatter, '(?m)^name:\s*(.+?)\s*$')
    $descriptionMatch = [regex]::Match($frontMatter, '(?m)^description:\s*(.+?)\s*$')
    if (-not $nameMatch.Success -or -not $descriptionMatch.Success) {
        throw "Skill name or description missing in $Path."
    }

    [pscustomobject]@{
        Name = $nameMatch.Groups[1].Value.Trim()
        Description = $descriptionMatch.Groups[1].Value.Trim()
        Body = $body
    }
}

function Add-IfMissing {
    param(
        [hashtable]$ByName,
        [string]$Name,
        [scriptblock]$Create
    )

    if ($ByName.ContainsKey($Name)) {
        Write-Host "SKIP existing: $Name"
        return $ByName[$Name]
    }

    $created = & $Create
    $ByName[$Name] = $created
    Write-Host "CREATED: $Name"
    return $created
}

function Ensure-Skill {
    param(
        [hashtable]$ByName,
        [pscustomobject]$Metadata
    )

    $tempContent = [IO.Path]::GetTempFileName()
    try {
        [IO.File]::WriteAllText($tempContent, $Metadata.Body, [Text.Encoding]::UTF8)
        if ($ByName.ContainsKey($Metadata.Name)) {
            $existing = $ByName[$Metadata.Name]
            Invoke-MulticaJson @(
                'skill', 'update', $existing.id,
                "--description=$($Metadata.Description)",
                "--content-file=$tempContent",
                '--output=json'
            ) | Out-Null
            $existing.description = $Metadata.Description
            Write-Host "SYNCED: $($Metadata.Name)"
            return $existing
        }

        $created = Invoke-MulticaJson @(
            'skill', 'create',
            "--name=$($Metadata.Name)",
            "--description=$($Metadata.Description)",
            "--content-file=$tempContent",
            '--output=json'
        )
        $ByName[$Metadata.Name] = $created
        Write-Host "CREATED: $($Metadata.Name)"
        return $created
    }
    finally {
        Remove-Item -LiteralPath $tempContent -Force -ErrorAction SilentlyContinue
    }
}

function Ensure-Agent {
    param(
        [hashtable]$ByName,
        [string]$Name,
        [string]$Instructions,
        [string]$Description
    )

    $displayName = $Name
    if ($standardAgentNames.Contains($Name)) {
        $displayName = $standardAgentNames[$Name]
    }

    $existing = $null
    $lookupNames = @($displayName, $Name)
    if ($legacyAgentNames.ContainsKey($Name)) {
        $lookupNames += $legacyAgentNames[$Name]
    }
    foreach ($lookupName in ($lookupNames | Select-Object -Unique)) {
        if ($ByName.ContainsKey($lookupName) -and $null -eq $ByName[$lookupName].archived_at) {
            $existing = $ByName[$lookupName]
            break
        }
    }

    # Multica keeps archived names reserved. If the canonical display-name
    # object was archived during an earlier migration, restore that exact
    # object so it can be updated in place instead of creating a name conflict.
    if ($null -eq $existing -and
        $ByName.ContainsKey($displayName) -and
        $null -ne $ByName[$displayName].archived_at) {
        $existing = $ByName[$displayName]
        Invoke-MulticaJson @(
            'agent', 'restore', $existing.id,
            '--output=json'
        ) | Out-Null
        $existing.archived_at = $null
        Write-Host "RESTORED: $displayName"
    }

    if ($null -eq $existing) {
        $created = Invoke-MulticaJson @(
            'agent', 'create',
            "--name=$displayName",
            "--runtime-id=$RuntimeId",
            "--instructions=$Instructions",
            "--description=$Description",
            '--model=gpt-5.6-sol',
            '--visibility=private',
            '--output=json'
        )
        $ByName[$Name] = $created
        $ByName[$displayName] = $created
        Write-Host "CREATED: $Name"
        return $created
    }

    Invoke-MulticaJson @(
        'agent', 'update', $existing.id,
        "--name=$displayName",
        "--instructions=$Instructions",
        "--description=$Description",
        '--output=json'
    ) | Out-Null
    $existing.name = $displayName
    $existing.instructions = $Instructions
    $existing.description = $Description
    $ByName[$Name] = $existing
    $ByName[$displayName] = $existing
    Write-Host "SYNCED: $displayName"
    return $existing
}

Write-Host "Checking Multica login and current workspace..."
$agents = @{}
foreach ($agent in (As-Array (Invoke-MulticaJson @('agent', 'list', '--include-archived', '--output', 'json')))) {
    $agents[$agent.name] = $agent
}

$skills = @{}
foreach ($skill in (As-Array (Invoke-MulticaJson @('skill', 'list', '--output', 'json')))) {
    $skills[$skill.name] = $skill
}

$squads = @{}
foreach ($squad in (As-Array (Invoke-MulticaJson @('squad', 'list', '--output', 'json')))) {
    if (-not $squads.ContainsKey($squad.name)) {
        $squads[$squad.name] = $squad
    }
}

# The production workspace uses localized display names. Resolve every
# logical role through the canonical name list, then use old names only to
# migrate active objects. Archived objects must never be reused.
$agentAliases = @{}
foreach ($logicalName in $standardAgentNames.Keys) {
    $aliases = @($standardAgentNames[$logicalName], $logicalName)
    if ($legacyAgentNames.ContainsKey($logicalName)) {
        $aliases += $legacyAgentNames[$logicalName]
    }
    $agentAliases[$logicalName] = @($aliases | Select-Object -Unique)
}

$squadAliases = @{
    'Software Development' = @('软件开发小队', 'Software Development')
    'Software Development Reviewed' = @('软件开发评审小队', 'Software Development Reviewed')
    'Product Design' = @('产品设计小队', 'Product Design', '产品小队')
    'Development' = @('开发小队', 'Development')
    'Bug Fix' = @('Bug 修复小队', 'Bug Fix', 'Bug修正小队')
}

foreach ($logicalName in $agentAliases.Keys) {
    $candidates = @(
        foreach ($candidateName in $agentAliases[$logicalName]) {
            if ($agents.ContainsKey($candidateName)) {
                $agents[$candidateName]
            }
        }
    )
    $resolved = $candidates | Where-Object { $null -eq $_.archived_at } | Select-Object -First 1
    if ($null -ne $resolved) {
        $agents[$logicalName] = $resolved
    }
}

# Migrate an existing logical/legacy object to the canonical display name.
# If the canonical object already exists, alias resolution above selected it,
# so this never merges or deletes duplicate objects.
foreach ($logicalName in $standardAgentNames.Keys) {
    if (-not $agents.ContainsKey($logicalName)) {
        continue
    }

    $agent = $agents[$logicalName]
    $displayName = $standardAgentNames[$logicalName]
    if ($agent.name -eq $displayName) {
        continue
    }

    if ($null -ne $agent.archived_at) {
        Write-Host "SKIP archived rename: $logicalName -> $displayName"
        continue
    }

    Invoke-MulticaJson @(
        'agent', 'update', $agent.id,
        "--name=$displayName",
        '--output=json'
    ) | Out-Null
    $agent.name = $displayName
    $agents[$displayName] = $agent
    Write-Host "RENAMED: $logicalName -> $displayName"
}

foreach ($logicalName in $squadAliases.Keys) {
    foreach ($candidateName in $squadAliases[$logicalName]) {
        if ($squads.ContainsKey($candidateName)) {
            $squads[$logicalName] = $squads[$candidateName]
            break
        }
    }
}

$agentNames = @{
    'architect.md' = 'Architect'
    'arch-reviewer.md' = 'ArchReviewer'
    'backend-developer.md' = 'BackendDev'
    'backend-reviewer.md' = 'BackendReviewer'
    'designer.md' = 'Designer'
    'design-reviewer.md' = 'DesignReviewer'
    'devops.md' = 'DevOps'
    'frontend-developer.md' = 'FrontendDev'
    'frontend-reviewer.md' = 'FrontendReviewer'
    'development-leader.md' = 'DevelopmentLeader'
    'leader.md' = 'Leader'
    'product-manager.md' = 'ProductManager'
    'product-leader.md' = 'ProductLeader'
    'product-reviewer.md' = 'ProductReviewer'
    'reviewer.md' = 'Reviewer'
    'tester.md' = 'Tester'
    'test-reviewer.md' = 'TestReviewer'
}

$agentDescriptions = @{
    Architect = '负责技术架构分析与方案设计。'
    ArchReviewer = '独立评审技术架构设计产物。'
    BackendDev = '负责后端实现与 API 契约设计。'
    BackendReviewer = '独立评审后端实现与 API 契约。'
    Designer = '负责界面与交互设计。'
    DesignReviewer = '独立评审 UI 与交互设计。'
    DevOps = '负责 CI/CD 构建、部署与环境证据。'
    DevelopmentLeader = '负责开发任务分诊、技术人员编排、开发门禁与交付交接。'
    FrontendDev = '负责前端实现与 API 对接。'
    FrontendReviewer = '独立评审前端实现。'
    Leader = '负责小队协调、任务路由、门禁与交付推进。'
    ProductManager = '负责需求分析与产品文档整理。'
    ProductLeader = '负责产品范围收敛、需求编排、产品评审门禁与开发交接。'
    ProductReviewer = '独立评审需求与 PRD 产物。'
    Reviewer = '独立进行业务与验收评审。'
    Tester = '负责测试设计、执行、回归与证据整理。'
    TestReviewer = '独立评审测试用例与测试报告。'
}

Write-Host "`nImporting Agents..."
$agentFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'templates\zh_CN\agents') -Filter '*.md' -File | Sort-Object Name
foreach ($file in $agentFiles) {
    $name = $agentNames[$file.Name]
    if ([string]::IsNullOrWhiteSpace($name)) {
        throw "No agent name mapping for $($file.Name)."
    }

    $instructions = Get-MarkdownCodeBlock -Path $file.FullName
    Ensure-Agent -ByName $agents -Name $name -Instructions $instructions -Description $agentDescriptions[$name] | Out-Null
}

if ($AgentsOnly) {
    Write-Host "`nAgent-only sync complete. Skills and Squads were not changed."
    exit 0
}

Write-Host "`nImporting Skills..."
$skillFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'templates\zh_CN\skills') -Directory |
    ForEach-Object { Join-Path $_.FullName 'SKILL.md' } |
    Where-Object { Test-Path -LiteralPath $_ } |
    Sort-Object

foreach ($skillFile in $skillFiles) {
    $metadata = Get-SkillMetadata -Path $skillFile
    Ensure-Skill -ByName $skills -Metadata $metadata | Out-Null
}

Write-Host "`nAssigning Skills to imported Agents..."
$skillAssignments = @{
    Architect = @('multica-technical-design', 'multica-artifact-design-sync')
    ArchReviewer = @('multica-review-architect')
    BackendDev = @('multica-implementation', 'multica-artifact-api-sync')
    BackendReviewer = @('multica-review-backend')
    Designer = @('multica-artifact-ui-sync')
    DesignReviewer = @('multica-review-designer')
    DevOps = @('multica-artifact-cicd-sync', 'multica-gate-setup')
    DevelopmentLeader = @('multica-verification', 'multica-requirement-analysis')
    FrontendDev = @('multica-implementation')
    FrontendReviewer = @('multica-review-frontend')
    Leader = @('multica-verification')
    ProductManager = @('multica-requirement-analysis', 'multica-artifact-req-sync')
    ProductLeader = @('multica-verification', 'multica-requirement-analysis')
    ProductReviewer = @('multica-review-product')
    Reviewer = @()
    Tester = @('multica-test-design', 'multica-test-automation', 'multica-artifact-test-sync')
    TestReviewer = @('multica-review-test')
}

foreach ($name in $skillAssignments.Keys) {
    if (-not $agents.ContainsKey($name)) {
        Write-Host "SKIP skills for missing agent (no create): $name"
        continue
    }
    if ($null -ne $agents[$name].archived_at) {
        Write-Host "SKIP skills for archived agent: $name"
        continue
    }

    $skillIds = @(
        foreach ($skillName in $skillAssignments[$name]) {
            if (-not $skills.ContainsKey($skillName)) {
                throw "Skill $skillName is missing; cannot assign it to $name."
            }
            $skills[$skillName].id
        }
    )

    if ($skillIds.Count -gt 0) {
        Invoke-MulticaJson @(
            'agent', 'skills', 'set', $agents[$name].id,
            "--skill-ids=$($skillIds -join ',')",
            '--output=json'
        ) | Out-Null
        Write-Host "BOUND: $name -> $($skillAssignments[$name] -join ', ')"
    }
}

if (-not $SkipSquads) {
    Write-Host "`nCreating Squads..."
    $squadDefinitions = @(
        @{
            Key = 'Software Development'
            Name = '软件开发小队'
            Description = '基于中文模板的常规产品开发小队。'
            Template = 'software-development'
            Leader = 'DevelopmentLeader'
            Members = @('ProductManager', 'Architect', 'Designer', 'FrontendDev', 'BackendDev', 'Tester', 'Reviewer', 'DevOps')
        }
        @{
            Key = 'Software Development Reviewed'
            Name = '软件开发评审小队'
            Description = '配备专属专业评审员的产品开发小队。'
            Template = 'software-development-reviewed'
            Leader = 'Leader'
            Members = @('ProductManager', 'ProductReviewer', 'Architect', 'ArchReviewer', 'Designer', 'DesignReviewer', 'FrontendDev', 'FrontendReviewer', 'BackendDev', 'BackendReviewer', 'Tester', 'TestReviewer', 'DevOps')
        }
        @{
            Key = 'Bug Fix'
            Name = 'Bug 修复小队'
            Description = '用于复现、定位根因、修复和回归验证的精简 Bug 修复小队。'
            Template = 'bug-fix'
            Leader = 'Leader'
            Members = @('FrontendDev', 'BackendDev', 'Tester', 'Reviewer')
        }
        @{
            Key = 'Development'
            Name = '开发小队'
            Description = '由研发总监动态编排技术架构师、前端开发专家和后台开发专家的开发小队。'
            Template = 'development'
            Leader = 'DevelopmentLeader'
            Members = @('Architect', 'FrontendDev', 'BackendDev')
        }
        @{
            Key = 'Product Design'
            Name = '产品设计小队'
            Description = '设计各种产品功能，由产品经理先行、产品总监统一评审。'
            Template = 'product-design'
            Leader = 'ProductLeader'
            Members = @('ProductManager', 'Designer', 'Architect')
        }
    )

    foreach ($definition in $squadDefinitions) {
        $leaderName = $definition['Leader']
        if (-not $agents.ContainsKey($leaderName)) {
            throw "Leader agent $leaderName is missing; cannot configure squad $($definition['Name'])."
        }
        if ($null -ne $agents[$leaderName].archived_at) {
            Write-Host "SKIP squad with archived leader: $($definition['Name'])"
            continue
        }
        $leaderId = $agents[$leaderName].id
        if ($squads.ContainsKey($definition['Key'])) {
            $squad = $squads[$definition['Key']]
            Write-Host "UPDATE existing squad: $($definition['Name'])"
        }
        else {
            $squad = Invoke-MulticaJson @(
                'squad', 'create',
                "--name=$($definition['Name'])",
                "--leader=$leaderId",
                "--description=$($definition['Description'])",
                '--output=json'
            )
            $squads[$definition['Key']] = $squad
            Write-Host "CREATED squad: $($definition['Name'])"
        }

        Invoke-MulticaJson @(
            'squad', 'update', $squad.id,
            "--name=$($definition['Name'])",
            "--leader=$leaderId",
            "--description=$($definition['Description'])",
            '--output=json'
        ) | Out-Null

        $squadFile = Join-Path $repoRoot "templates\zh_CN\squad\$($definition['Template'])\squad.md"
        $instructions = Get-MarkdownCodeBlock -Path $squadFile
        Invoke-MulticaRestPut -Path "/api/squads/$($squad.id)" -Body @{
            instructions = $instructions
        } | Out-Null

        $existingMembers = As-Array (Invoke-MulticaJson @('squad', 'member', 'list', $squad.id, '--output', 'json'))
        $genericLeaderId = $agents['Leader'].id
        if ($leaderName -ne 'Leader' -and $existingMembers.member_id -contains $genericLeaderId) {
            Invoke-MulticaJson @(
                'squad', 'member', 'remove', $squad.id,
                "--member-id=$genericLeaderId",
                '--type=agent',
                '--output=json'
            ) | Out-Null
            Write-Host "REMOVED generic Leader from: $($definition['Name'])"
        }

        # Keep the production Squad membership equal to the local definition.
        # This removes archived English role objects and any other stale Agent
        # memberships left by earlier imports; non-Agent memberships are left
        # untouched because this script does not own them.
        $desiredMemberNames = @($leaderName) + @($definition.Members)
        $desiredMemberIds = @(
            foreach ($memberName in $desiredMemberNames) {
                if ($agents.ContainsKey($memberName)) {
                    $agents[$memberName].id
                }
            }
        )
        foreach ($existingMember in $existingMembers) {
            if ($existingMember.member_type -ne 'agent') {
                continue
            }
            if ($desiredMemberIds -contains $existingMember.member_id) {
                continue
            }
            Invoke-MulticaJson @(
                'squad', 'member', 'remove', $squad.id,
                "--member-id=$($existingMember.member_id)",
                '--type=agent',
                '--output=json'
            ) | Out-Null
            $staleName = $existingMember.member_id
            $staleAgent = $agents.Values | Where-Object { $_.id -eq $existingMember.member_id } | Select-Object -First 1
            if ($null -ne $staleAgent) {
                $staleName = $staleAgent.name
            }
            Write-Host "REMOVED stale Agent $staleName from: $($definition['Name'])"
        }

        foreach ($memberName in $desiredMemberNames) {
            if (-not $agents.ContainsKey($memberName)) {
                Write-Host "SKIP missing member $memberName for: $($definition['Name'])"
                continue
            }
            $memberId = $agents[$memberName].id
            if ($null -ne $agents[$memberName].archived_at) {
                Write-Host "SKIP archived member $memberName for: $($definition['Name'])"
                continue
            }
            if ($existingMembers.member_id -contains $memberId) {
                continue
            }
            Invoke-MulticaJson @(
                'squad', 'member', 'add', $squad.id,
                "--member-id=$memberId",
                '--type=agent',
                '--role=member',
                '--output=json'
            ) | Out-Null
        }
        Write-Host "READY squad: $($definition['Name'])"
    }
}

Write-Host "`nImport complete."
Write-Host "Agents: $(@($agents.Values | Sort-Object id -Unique).Count)"
Write-Host "Skills: $($skills.Count)"
Write-Host "Squads: $(@($squads.Values | Sort-Object id -Unique).Count)"
