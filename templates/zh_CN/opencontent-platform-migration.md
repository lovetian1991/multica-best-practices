# 将 zh_CN 模板接入 OpenContent Base Skill 的迁移执行方案

本文针对 `multica-best-practices/templates/zh_CN/`，以及工作区中的精简 OpenContent Skill（`oc-basic`）。目标是：保留 Multica 现有的角色、技能、小队流程，并由 Multica 自己负责 Issue 主记录、字段和评论，只把协作产物的落地与取回切到 OpenContent 指定目录。

## 当前采用的方案决策

- 不接入 Jira；Issue、字段、metadata、property 和评论全部保存在 Multica。
- 产物使用稳定文件名；首次 `UPLOAD`，后续同名目标使用 `UPDATE + majorUpgrade`。
- 多个产物由 artifact-sync 内部逐个调用单文件上传/更新。
- `file-internal-link` 是下游传递的主引用，正文通过 `download url=<internal_link>` 获取。
- 当前业务不读取历史版本，不使用 `fileVerId`；OpenContent 后台版本维护不影响业务契约。
- 根目录按“上游参数 → Issue metadata → Issue property → 配置默认值”解析，并经过允许列表和 `folder-info` 校验。

## 先明确能力边界

`oc-basic` 当前只提供 8 类基础能力：

- `file-list`：浏览文件夹直接子项
- `file-info`：读取文件信息
- `file-internal-link`：生成文件内部访问地址
- `folder-info`：读取文件夹信息
- `upload`：上传文件
- `download`：下载文件
- `create-folder`：新建文件夹
- `user-info`：读取当前用户

它不提供 Jira/Confluence 等价的 Issue 查询、状态流转、字段写入、排期、评论、搜索或 CI/CD 触发能力。因此不能只把 `multica-platform-jira` 改名为 OpenContent，就声称 Jira 已被替换。

正确的拆分是：

| 能力 | 推荐归属 |
| --- | --- |
| PRD、技术设计、API 契约、测试用例、测试报告、CI 日志等文件 | OpenContent `oc-basic` |
| Issue 的标题、范围、状态、负责人、排期、评论 | Multica Issue API、Issue metadata、Issue property 和评论 |
| CI/CD 构建和部署触发 | 现有 CI 平台，或另建 CI 适配器；`oc-basic` 只保存结果文件 |

本方案不把 Issue 再保存成 OpenContent Markdown/JSON；Issue 主数据留在 Multica，OpenContent 只保存协作产物文件。

## 推荐的三层结构

```text
角色 / 小队提示词
  只描述产出内容，调用 multica-artifact-*-sync
        ↓
artifact-sync 编排层
  生成草稿、确定文件名、调用平台层、回传引用
        ↓
OpenContent 平台层
  调用 oc-basic，负责 folderId、目录创建、上传、内部链接和下载
```

角色提示词不应出现 OpenContent URL、folder ID、`$CLI`、token 或具体目录路径。以后更换文件平台时，只替换平台层和编排层配置。

## OpenContent 目录和文件约定

OpenContent 的命令使用 `folderId`，不是本地路径。建议在企业库中预先指定一个根文件夹，并按工作区和 Issue 建立目录：

```text
<artifact-root-folder>
└── <workspace-slug>
    └── <issue-key>
        ├── requirements
        ├── design
        ├── api
        ├── test-cases
        ├── test-reports
        └── cicd
```

建议把根目录 ID 和各类子目录名放在新平台 Skill 的 `config.yaml`：

```yaml
opencontent:
  artifact_root_folder_id: "<OPENCONTENT_DEFAULT_ROOT_FOLDER_ID>"
  allowed_root_folder_ids:
    - "<OPENCONTENT_DEFAULT_ROOT_FOLDER_ID>"
  folders:
    requirements: "requirements"
    design: "design"
    api: "api"
    test_cases: "test-cases"
    test_reports: "test-reports"
    cicd: "cicd"
  upload:
    default_file_model: "UPLOAD"
    update_strategy: "majorUpgrade"
```

### 根目录来源与优先级

根目录可以由上游传递，也可以在创建 Issue 时写入 Multica，但不能接受未经校验的任意 `folderId`。推荐按以下优先级解析：

1. 本次 artifact-sync 上游显式传入的 `artifact_root_folder_id`。
2. Issue `metadata` 中的 `artifact_root_folder_id`。
3. Issue 自定义属性 `artifact_root_folder_id`（只有需要 UI 展示、筛选或人工维护时使用）。
4. 当前工作区/项目的 `config.yaml` 默认根目录。
5. 没有任何有效值时阻断任务，不要静默使用企业库根目录。

无论根目录来自上游参数、Issue metadata/property 还是配置默认值，都必须经过允许列表校验（`allowed_root_folder_ids`），并用 `folder-info` 确认它确实是当前用户可访问的文件夹。校验失败时返回 `BLOCKED`，不创建或上传文件。

选择建议：

| 保存位置 | 适用场景 |
| --- | --- |
| `config.yaml` | 所有工作区共用一个根目录，最简单、最稳定 |
| 上游参数 | 同一流程临时指定不同项目/环境目录；必须由编排器传递，角色不直接填写 |
| Issue `metadata` | 不想创建属性定义，只需保存一个机器可读的 folder ID |
| Issue 自定义 `property` | 需要在 Multica UI 中展示、筛选或由用户维护；需先创建属性定义 |

推荐默认使用工作区/项目配置，Issue `metadata` 作为覆盖值；只有确实需要用户可见和可筛选时，才建立自定义 property。无论来源是什么，最终都应把本次解析出的 `root_folder_id` 写入交接包，便于审计。

本地草稿仍可沿用现有约定，例如 `docs/requirements/<ISSUE-KEY>/`、`docs/design/<ISSUE-KEY>/`；这些是 staging 路径，不是最终的 OpenContent 路径。OpenContent CLI 自己的 `outputs/` 目录也只是 CLI 保存大输出或下载结果的运行目录，不应当当作业务产物目录。

## 内部链接是产物传递的主契约

`file-internal-link` 生成 OpenContent 的内部访问地址，适合作为 Multica 产物的稳定引用。它不是公开分享链接，也不是由适配层自行拼接的 URL；必须使用 CLI 返回的真实 `url` 字段。

下游有两种合法用法：

1. 把内部链接作为文档引用传递给下游智能体，由其在有权限的 OpenContent 环境中打开。
2. 把同一个内部链接直接传给下载命令，获取文件正文：

```bash
$CLI download url="<OPENCONTENT_INTERNAL_LINK>" outputPath="<local-output-dir>"
```

`download` 支持从内部/预览地址解析文件标识。传入 `url` 时，不要同时传 `fileIds`、`ver_id` 或 `folderIds`。适配层应保留原始链接，不要改写域名、路径或查询参数。

推荐的产物引用字段如下：

```json
{
  "artifact_type": "requirement",
  "issue_key": "<ISSUE-KEY>",
  "file_name": "prd-login.md",
  "internal_link": "<OPENCONTENT_INTERNAL_LINK>",
  "file_id": "<OPENCONTENT_FILE_ID>",
  "file_guid": "<OPENCONTENT_FILE_GUID>",
  "folder_id": "<OPENCONTENT_FOLDER_ID>"
}
```

其中 `internal_link` 是下游传递和下载的首选字段；`file_id`/`file_guid` 是更新定位和审计辅助字段。`fileVerId` 即使由上传接口返回，也不进入当前业务契约；除非未来明确需要历史版本，否则不读取、不传递、不调用 `download ver_id=...`。CLI 的真实返回字段可能因输入类型而不同，适配层必须先检查 JSON，再映射字段，不能伪造缺失的 ID 或 URL。

## 产物引用保存到 Multica Issue

不使用 Jira 时，Multica Issue 本身作为工作项主记录。建议把当前产物引用写入 Issue `metadata`，把每次发布/更新结果追加为 Issue 评论：

```text
artifact_requirement_internal_link
artifact_requirement_file_id
artifact_design_internal_link
artifact_design_file_id
artifact_api_internal_link
artifact_test_cases_internal_link
artifact_test_report_internal_link
artifact_cicd_internal_link
artifact_root_folder_id
```

`metadata` 适合机器读取，值保持为字符串、数字或布尔值；评论只记录“谁在何时发布了哪个产物、当前内部链接是什么、是否成功”。如果需要在 Multica UI 中展示、筛选或由用户维护根目录，再创建类型明确的 Issue 自定义 `property`；不应为了保存链接而重复建立一组属性定义。

artifact-sync 发布成功后应按以下顺序完成：

```text
OpenContent upload
  -> file-internal-link
  -> 写入 Issue metadata（当前链接和 file_id）
  -> 追加 Issue comment（发布结果）
  -> 回传同一 internal_link 给下游
```

如果 metadata 写入失败，产物上传已经发生，编排器必须返回 `BLOCKED` 并报告“文件已上传但 Issue 指针未更新”，不得宣称整个阶段完成。

## 文件更新和版本策略

当前 `oc-basic` 的 `upload` 已支持更新已有文件，不应再把 OpenContent 描述成“只能上传、不能更新”。本方案统一只使用 `majorUpgrade`，更新时传入：

```text
fileId=<已有文件的 ID、GUID 或内部/预览地址>
fileModel=UPDATE
strategy=majorUpgrade
```

例如：

```bash
$CLI upload \
  filePaths="docs/requirements/ABC-12/prd-login.md" \
  folderId="<REQUIREMENTS_FOLDER_ID>" \
  fileId="<EXISTING_FILE_ID_OR_INTERNAL_LINK>" \
  fileModel=UPDATE \
  strategy=majorUpgrade
```

更新返回的 `fileId`（以及服务端可能返回的版本信息）应记录到本次交接结果；然后再次调用 `file-internal-link fileId=<fileId>`，把同一文件的内部链接作为最新引用。内部链接定位的是文件身份，下载时取得当前可用版本。当前业务不读取历史版本，也不调用 `download ver_id=...`。

不要仅根据文件名判断“新建还是更新”。适配层应保存每类产物的 `fileId`/`fileGuid`，首次发布使用普通 `UPLOAD`，后续发布使用 `UPDATE`；若 ID 丢失，必须先通过明确的 `file-list` 结果或已保存的内部链接确认目标文件，不能自动取目录第一项。

不要求额外维护 OpenContent `latest.json`：当前版本的 `internal_link` 和 `file_id` 以 Multica Issue metadata 为主索引，发布/更新记录以 Issue 评论为审计记录。只有需要跨 Issue 汇总或脱离 Issue 读取时，才增加 OpenContent manifest。文件使用稳定名称，OpenContent 负责内部版本维护。

### 多文件产物

一个阶段可能同时产生多个文件，但 `fileModel=UPDATE` 的目标是单文件。artifact-sync 必须在内部逐项循环：

```text
for artifact in artifacts:
  解析该产物的目标文件和 folderId
  upload 一个文件（UPLOAD 或 UPDATE + majorUpgrade）
  生成该文件的 internal_link
  写入对应的 Issue metadata
```

每个文件独立返回成功/失败结果；部分文件失败时，阶段整体返回 `BLOCKED`，同时保留已成功上传的链接和失败文件清单，不把部分成功汇总成整体 PASS。

## 应修改的文件

### 1. 新增 OpenContent 平台 Skill

新增目录：

```text
templates/zh_CN/skills/multica-platform-opencontent/
├── SKILL.md
├── config.yaml
├── .env.example
└── scripts/
    ├── publish-artifact.*
    ├── fetch-artifact.*
    ├── resolve-folder.*
    └── validate.*
```

该 Skill 只编排 `oc-basic` 已声明的命令，不直接复制 OpenContent REST 调用。它应定义统一输入输出，例如：

```text
publish-artifact --type requirement --workspace <slug> --issue <key> --file <local-file>
update-artifact --type requirement --file-id <id-or-internal-link> --file <local-file> --strategy majorUpgrade
fetch-artifact --internal-link <opencontent-internal-link> --output <local-dir>
```

首次发布调用 `upload` 的默认 `fileModel=UPLOAD`；已有文件更新必须传 `fileId`、`fileModel=UPDATE` 和 `strategy=majorUpgrade`。返回值必须来自 `oc-basic` 的实际 JSON，至少保留服务端返回的名称、`folderId`、`fileId`/`fileGuid` 和 `url`；`fileVerId` 可作为诊断信息保留，但不进入当前业务契约。发布或更新后调用 `file-internal-link` 生成 `internal_link`；取回正文时接收 `internal_link` 并调用 `download url=...`。首次调用每个普通子命令前必须先运行该命令的 `--help`；拿到 JSON 后先检查实际层级，再读取字段。

### 2. 修改 artifact 编排 Skill

修改这些目录中的 `SKILL.md`、`README.md`、`config.yaml` 和脚本：

| 文件 | 修改重点 |
| --- | --- |
| `multica-artifact-req-sync` | 去掉 Confluence 创建页面和 Jira Story 回写；首次上传 PRD，后续用 `fileModel=UPDATE` 更新，生成并回传 OpenContent `internal_link`；Issue 关联由 Multica Issue API 另行完成 |
| `multica-artifact-design-sync` | 去掉 Confluence 发布和 Jira 描述追加；首次上传或更新 `design` 文件，生成并回传 `internal_link` |
| `multica-artifact-api-sync` | 将默认 Apifox 改成 API 契约文件上传/更新；回传 `internal_link`，保留端点、schema、错误码、鉴权和 BR- 追溯内容要求 |
| `multica-artifact-test-sync` | 去掉 XMind 转 Jira；上传或更新用例/报告到 `test-cases`/`test-reports`，回传 `internal_link` |
| `multica-artifact-cicd-sync` | 不把 OpenContent 当 CI；保留 CI 触发适配器，把构建日志、报告和环境信息上传或更新到 `cicd`，回传 `internal_link` |

对于原本声明 `metadata.orchestrates` 的 Skill，更新该字段，使文档产物依赖指向 `multica-platform-opencontent`；CI/CD 如仍使用 Jenkins，则保留独立的 `multica-platform-jenkins`。不要给没有平台编排依赖的 Skill 强行增加 metadata。

编排脚本继续通过 `MULTICA_SKILLS_ROOT` 或按技能名定位依赖，不要写死 `templates/zh_CN/skills` 的相对路径。

### 2.1 新增平台名后，哪些引用必须改

新增 `multica-platform-opencontent` 后，**不需要全库机械替换**。只改直接依赖或会误导执行者的引用：

| 文件/目录 | 是否必须改 | 修改内容 |
| --- | --- | --- |
| `multica-artifact-req-sync/SKILL.md` | 是 | `metadata.orchestrates`、Confluence 命令、页面/space 说明改为 OpenContent 文件上传/读取；移除 Jira Story 创建和回写 |
| `multica-artifact-req-sync/README.md`、`CLAUDE.md`、`AGENTS.md`、`config.yaml` | 是 | 安装、委托关系和配置路径改为 OpenContent |
| `multica-artifact-design-sync/SKILL.md` 及其脚本 | 是 | Confluence 发布、父页面、`publish_design.py`、Jira 描述回写改为 OpenContent 引用流程 |
| `multica-technical-design/SKILL.md` | 是 | 如果继续引用 Confluence 模板、父页面或发布命令，改为引用 `multica-artifact-design-sync` 和稳定产物引用 |
| `multica-requirement-analysis/SKILL.md` | 是 | 如果继续写“Confluence 页面 + Jira Story”，改为描述内容分析与 artifact-sync 的职责边界 |
| `templates/zh_CN/agents/leader.md` | 建议改 | “Jira / Confluence 链接”改成“外部 Issue 或上游产物链接”；不写 OpenContent 细节 |
| `templates/zh_CN/squad/software-development/README.md`、`templates/zh_CN/skills/README.md` | 是 | 平台 Skill 索引、链接和默认平台描述更新 |
| `squad.md` 中的 `Git/Confluence`、`Apifox`、`Jira` 示例 | 建议改 | 改成通用的“稳定产物引用”；这类文字不是运行时依赖，但会让用户误以为平台固定 |
| `agents/`、`squad/` 其余文件 | 否 | 只要只调用 `multica-artifact-*-sync`，无需调整角色路由和小队流程 |

换句话说，角色和 Squad 不需要因为新增平台 Skill 而整体重写；只有其中直接写死平台名或平台链接格式的个别句子需要清理。

### 3. 原有平台壳的处理

不再作为默认依赖：

- `multica-platform-confluence`
- `multica-platform-jenkins`

`multica-platform-confluence` 和 `multica-platform-jira` 可以暂时保留为 legacy 兼容目录，但所有默认 artifact 流程都不再挂载它们；其 `SKILL.md` 应标明“非 OpenContent 默认流程”。只有未来明确接入外部平台时，才重新启用对应壳。

### 4. 角色、小队和 Issue 模板

大多数角色和小队文件不应修改，因为它们已经通过 `multica-artifact-*-sync` 解耦平台。仅修改仍硬编码平台的内容：

- `templates/zh_CN/squad/*/issue.md` 中的 `https://jira.example.com/...` 示例，改成 `<ISSUE_URL>` 或 Multica Issue 引用。
- `templates/zh_CN/squad/*/squad.md` 中“从 Jira/Confluence 拉取”的硬编码步骤，改成“按 Issue 引用读取上游内容”。
- `templates/zh_CN/agents/*.md` 中若出现具体平台名、Wiki 语法或 Jira 字段，改成“读取 artifact-sync 回传的稳定引用”。目前已知需要重点检查 `agents/leader.md`。

不要把 OpenContent 实现细节写入角色职责、门禁规则或小队路由。

### 5. 方法论文档与索引

同步更新：

- `docs/zh_CN/artifact-conventions.md`
- `docs/zh_CN/where-to-put-things.md`
- `docs/zh_CN/cicd-and-test-pipeline.md`
- 根目录 `README.md`
- 各 artifact Skill 的 `README.md`
- `CHANGELOG.md`

文档中的默认平台表应改为“OpenContent 文件适配层”；同时保留“Issue 系统”和“CI 系统”是独立能力的说明。仓库要求中英文目录同步时，再更新对应 `en_US` 文件；当前本迁移说明仅存在于 `zh_CN`，新增英文镜像时应保持同一结构。

## 不应修改的内容

- `multica-*` Skill 名称和角色引用名
- `agents/` 的角色分工
- `squad/` 的阶段顺序和门禁责任
- `multica-requirement-analysis`、`multica-technical-design`、`multica-test-design` 的内容规范
- `multica-verification` 的验收和证据规则

平台替换的目标是改变“文件如何落地和读取”，不是改变 PRD、设计、开发、测试和门禁的业务语义。

## 推荐实施顺序

1. 在 OpenContent 企业库创建根目录，确认 `OPENCONTENT_SITE`、`OPENCONTENT_APIKEY` 和 `MULTICA_SERVER_URL` 通过运行环境注入；不要提交 `.env`。
2. 先按 `oc-basic` 文档逐个验证 `user-info`、`file-list`、`create-folder`、`upload`、`file-info`、`file-internal-link`、`download`。
3. 实现 `multica-platform-opencontent`，用一个测试 Issue 跑通“解析根目录 → 首次上传 → 生成内部链接 → 更新同一文件 → 下载当前版本”。多个产物由适配层循环调用单文件上传/更新。
4. 迁移 `req-sync` 和 `design-sync`，确认首次发布、同一文件更新、内部链接回传和下游下载都能跑通。
5. 迁移 `api-sync` 和 `test-sync`，验证 `majorUpgrade` 更新、Issue metadata 指针、AC 追溯和报告读取。
6. 最后处理 CI/CD 证据；触发系统和文件存储保持职责分离。
7. 更新文档、示例和平台依赖索引，执行全库检索。确认默认的产物流程不再调用 Confluence/Jira，Issue 生命周期全部通过 Multica 自身完成。

## 验收标准

- [ ] 角色和小队无需知道 OpenContent 的 URL、folder ID 或 CLI 名称。
- [ ] 每类产物都有固定的 OpenContent 子目录和命名规则。
- [ ] 同一 Issue 重跑会根据已保存的 `fileId`/内部链接执行明确的 `UPDATE`，而不是误创建重复文件。
- [ ] 所有更新统一使用 `fileModel=UPDATE` + `strategy=majorUpgrade`，不依赖历史版本读取。
- [ ] 下游使用上游回传的真实 `internal_link`，并可将其直接传给 `download url=...` 获取正文。
- [ ] `internal_link` 未被改写为伪造 URL，也未被误当成公开分享链接。
- [ ] 当前产物 `internal_link` 和 `file_id` 已写入 Multica Issue metadata，发布结果已追加 Issue 评论。
- [ ] 根目录来源遵循“上游参数 → Issue metadata/property → 配置默认值”的优先级，并通过允许列表和 `folder-info` 校验。
- [ ] 同名文件只有一个明确目标时自动更新；出现多个候选时直接 `BLOCKED`，不自动取第一项，也不要求在流程中人工确认后继续。
- [ ] 每个普通 `oc-basic` 子命令首次调用前执行过 `--help`，并按实际 JSON 解析。
- [ ] Issue 状态、字段、排期和评论均由 Multica 自身保存和读取，不依赖 Jira。
- [ ] CI/CD 仍由 CI 适配器触发，OpenContent 仅保存证据文件。
- [ ] 模板和 Git 中没有 token、真实内网地址或本机绝对路径。
- [ ] `multica-artifact-req-sync`、`multica-artifact-design-sync` 的直接平台依赖已切换；其余角色/Squad 仅保留通用 artifact-sync 引用。
- [ ] `technical-design`、`requirement-analysis`、`leader` 以及 README/索引中的平台泄漏已按需清理。

## 最小可行改动

若只先迁移“产物写入和读取”，第一阶段只做：

1. 新增 `multica-platform-opencontent`。
2. 修改 `multica-artifact-req-sync`、`multica-artifact-design-sync`、`multica-artifact-api-sync`、`multica-artifact-test-sync`。
3. 不接入 `multica-platform-jira`；通过 Multica Issue API、Issue metadata、property 和评论保存工作项信息及产物指针。
4. 暂不改 CI 触发，只在后续把 CI 证据文件上传到 OpenContent。

这样可以在不重写角色、小队和门禁的前提下，先验证 OpenContent 的目录、上传、读取链路。
