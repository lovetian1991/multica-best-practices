# 同步中文模板到 Multica

使用 [`scripts/import-to-multica.ps1`](../../scripts/import-to-multica.ps1) 将 `templates/zh_CN` 下的 Skill、Agent 和启用中的 Squad 同步到指定 Multica workspace。

脚本按名称复用线上对象，可重复执行。已有对象会更新，不会重复创建。

## 同步范围

- `templates/zh_CN/skills/*`：导入每个包含 `SKILL.md` 的完整 Skill 目录，包括 `scripts/`、`references/`、CLI 和配置模板。
- `templates/zh_CN/agents/*.md`：同步 17 个 Agent，名称和描述使用脚本内的中文定义。
- Agent Skills：按脚本中的 `$skillAssignments` 执行 replace-all，确保 Agent 的能力列表与模板依赖一致。
- Skill 的 `metadata.orchestrates` 只记录编排关系，不会在 Agent 运行时自动注入依赖；脚本会把实际依赖闭包显式挂到 Agent 上。
- Squad：只同步 `bug-fix`、`development`、`product-design`，线上显示名分别为 `Bug 修复小队`、`开发小队`、`产品设计小队`。

以下 Squad 已停用，脚本不会创建或更新：

- `software-development`
- `software-development-reviewed`

## 前置条件

1. 安装可执行的 `multica` CLI。
2. token 对目标 workspace 具有管理 Skill、Agent 和 Squad 的权限。
3. 目标 workspace 至少有一个可用 Runtime，或提供每个新 Agent 的 Runtime 映射。
4. 在仓库根目录执行 PowerShell 命令。

列出 workspace 和 Runtime：

```powershell
$env:MULTICA_TOKEN = '<multica-cli-token>'
$env:MULTICA_SERVER_URL = '<multica-api-url>'

multica workspace list --output json
multica --workspace-id '<workspace-id>' runtime list --output json
```

`MULTICA_SERVER_URL` 应填写 API 地址，不是浏览器中的 workspace 页面地址。

## 执行同步

```powershell
$env:MULTICA_TOKEN = '<multica-cli-token>'
$env:MULTICA_SERVER_URL = '<multica-api-url>'
$env:MULTICA_WORKSPACE_SLUG = '<workspace-slug>'

.\scripts\import-to-multica.ps1
```

也可以全部通过参数传入，但 token 仍必须使用环境变量：

```powershell
$env:MULTICA_TOKEN = '<multica-cli-token>'

.\scripts\import-to-multica.ps1 `
  -ServerUrl '<multica-api-url>' `
  -WorkspaceSlug '<workspace-slug>' `
  -RuntimeId '<runtime-id>'
```

`-RuntimeId` 不是必填项。脚本会先保留已有 Agent 自己的 `runtime_id`；如果没有指定默认 Runtime 且 workspace 只有一个在线 Runtime，会自动使用它。workspace 有多个在线 Runtime 时，可用 JSON 文件按 Agent 角色分别指定：

```json
{
  "Architect": "<runtime-id-for-architect>",
  "Tester": "<runtime-id-for-tester>"
}
```

执行：

```powershell
.\scripts\import-to-multica.ps1 `
  -ServerUrl '<multica-api-url>' `
  -WorkspaceSlug '<workspace-slug>' `
  -RuntimeMapFile '.\runtime-map.json'
```

映射键使用脚本中的逻辑角色名（例如 `Architect`、`FrontendDev`、`Tester`）。未出现在映射文件中的新 Agent 使用 `-RuntimeId`；两者都未提供时，多个在线 Runtime 会明确报错，不会随机选择。已有 Agent 不会因同步而切换 Runtime。

默认不指定模型，Agent 使用 Runtime 默认模型。如需为新建 Agent 指定模型：

```powershell
.\scripts\import-to-multica.ps1 `
  -ServerUrl '<multica-api-url>' `
  -WorkspaceSlug '<workspace-slug>' `
  -Model '<model-id>'
```

可选模式：

```powershell
# 只同步 Agent
.\scripts\import-to-multica.ps1 -AgentsOnly

# 同步 Agent 和 Skill，但不处理 Squad
.\scripts\import-to-multica.ps1 -SkipSquads
```

## 部分导入

同步全部 Skill 会重写 26 个 Skill 对象，并连带执行 Agent 能力 replace-all 和 Squad 更新。只改了几个 Skill 时，用 `-SkillName` 指定要导入的 Skill，其余对象完全不碰。

```powershell
# 只导入指定的 Skill，不处理 Agent / 能力绑定 / Squad
.\scripts\import-to-multica.ps1 -SkillName multica-platform-opencontent,multica-artifact-req-sync

# 导入全部 Skill，但不处理 Agent / 能力绑定 / Squad
.\scripts\import-to-multica.ps1 -SkillsOnly
```

规则：

- `-SkillName` 的取值是 `templates/zh_CN/skills/*/SKILL.md` 中 `name:` 字段的值。名字不存在时脚本在**任何写入之前**报错，不会静默同步 0 个对象。
- `-SkillName` 与 `-SkillsOnly` 都隐含「只动 Skill」：不创建或更新 Agent，不执行 `$skillAssignments` 的 replace-all，也不更新 Squad。因为这三者都是整体覆盖写，与部分 Skill 列表同时执行会改写调用方没要求的对象。
- `-SkillName` 可与 `-SkillsOnly` 以外的参数共存，但不能和 `-AgentsOnly` 一起用；`-AgentsOnly` 与 `-SkillsOnly` 互斥。
- 校验只覆盖本次作用域内的对象。部分导入不会因为未同步的 Skill 或 Agent 而报错。
- 兼容 `-SkillName a,b` 和 `-SkillName a -SkillName b` 两种写法。

## 同步顺序

1. 验证 token、API 地址和 workspace slug，并解析 workspace ID。
2. 按中文标准名称创建或更新 Agent。
3. 将每个 Skill 目录临时打包，通过 `skill import --on-conflict overwrite` 完整导入。
4. 按 `$skillAssignments` 将 Skill ID 写入各 Agent 的能力列表。
5. 创建或更新 3 个启用中的 Squad，写入中文名称、中文描述、Instructions 和成员列表。
6. 输出 Agent、Skill 和 Squad 数量。

脚本使用 ZIP API 写入 `/` 分隔的 Skill 文件路径。不要改回 PowerShell `Compress-Archive` 的直接输出方式；Windows 生成的反斜杠路径会被 Daemon 的 bundle 校验拒绝，表现为 `resolve skill bundle returned invalid bundle`。

## 同步后检查

```powershell
multica agent list --output json
multica skill list --output json
multica squad list --output json
```

重点确认：

- 自定义 Agent 数量与 `templates/zh_CN/agents/*.md` 一致。
- Skill 数量与包含 `SKILL.md` 的目录数量一致。
- 每个 Agent 的 `skills` 与脚本中的 `$skillAssignments` 一致。
- 本脚本管理的 Squad 为 `Bug 修复小队`、`开发小队`、`产品设计小队`，且不包含两个已停用模板。
- Squad 的 Instructions 非空，成员列表与 `$squadDefinitions` 一致。

## 安全要求

- 不要把 token、内部 URL、真实 workspace 或 Runtime ID写入仓库。
- token 只放在当前进程环境变量 `MULTICA_TOKEN` 中。
- 同步完成后可执行 `Remove-Item Env:MULTICA_TOKEN` 清除当前终端中的 token。
- 执行前先核对 `workspace list` 的 slug，避免写入错误 workspace。
