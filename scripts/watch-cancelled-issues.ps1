param(
    [int]$PollSeconds = 5,
    [switch]$Once
)

$ErrorActionPreference = 'Stop'

$cliCommand = Get-Command multica -ErrorAction SilentlyContinue
if ($null -eq $cliCommand) {
    $fallback = Join-Path $HOME '.multica\bin\multica.exe'
    if (-not (Test-Path -LiteralPath $fallback)) {
        throw "Multica CLI not found. Run 'multica login' first."
    }
    $cli = $fallback
}
else {
    $cli = $cliCommand.Path
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

function Get-ActiveTasks {
    param([string]$IssueIdentifier)

    $runs = @(Invoke-MulticaJson @(
        'issue', 'runs', $IssueIdentifier,
        '--output', 'json',
        '--full-id'
    ))

    return @(
        $runs | Where-Object {
            $_.status -in @('queued', 'pending', 'running', 'started')
        }
    )
}

do {
    try {
        $payload = Invoke-MulticaJson @(
            'issue', 'list',
            '--status', 'cancelled',
            '--limit', '200',
            '--output', 'json'
        )

        foreach ($issue in @($payload.issues)) {
            foreach ($task in @(Get-ActiveTasks -IssueIdentifier $issue.identifier)) {
                Write-Host "Cancelling $($issue.identifier) task $($task.id) ($($task.status))"
                try {
                    Invoke-MulticaJson @(
                        'issue', 'cancel-task', $task.id,
                        '--issue', $issue.identifier,
                        '--output', 'json'
                    ) | Out-Null
                    Write-Host "Cancelled $($issue.identifier) task $($task.id)"
                }
                catch {
                    Write-Warning "Could not cancel $($issue.identifier) task $($task.id): $($_.Exception.Message)"
                }
            }
        }
    }
    catch {
        Write-Warning "Cancellation watchdog poll failed: $($_.Exception.Message)"
    }

    if (-not $Once) {
        Start-Sleep -Seconds ([Math]::Max(1, $PollSeconds))
    }
} while (-not $Once)
