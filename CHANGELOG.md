# Changelog / 更新日志

All notable changes to this project will be documented in this file.
本文件记录本项目的所有重要变更。新条目采用中英结合写法（Chinese-first, English alongside）。

## Unreleased - 2026-09-15 · 产品设计闭环回写知识库 / Product design KB write-back loop

### Changed / 变更

- 产品经理、UI/UE设计师和技术架构师每次补写共享 PRD 后，都必须通过 `multica-artifact-req-sync` 更新知识库中的同一文件，并回传最新稳定引用；产品总监只评审该最新引用指向的版本 / ProductManager, Designer, and Architect must update the same knowledge-base PRD via `multica-artifact-req-sync` after each append and return the latest stable reference; ProductLeader reviews the version pointed to by that reference
- 产品设计交接包新增知识库最新 PRD 链接、Issue metadata/comment 回写和设计后回写失败禁阻规则，中英文 Squad、Agent、Skill 与产物规范保持一致 / Product-design handoff now requires the latest knowledge-base PRD link, Issue metadata/comment write-back, and blocking on failed post-design write-back; bilingual Squad, Agent, Skill, and artifact conventions are aligned

## Unreleased - 2026-09-03 · 产品小队按需角色依赖 / Product Squad on-demand role dependencies

### Changed / 变更

- 解决产品小队“技术架构师必须等待 UI/UE设计师”与“技术架构师按需启用”之间的冲突：仅启用技术架构师时，产品经理完成后即可开始；UI/UE设计师 与技术架构师同时启用时，才按 UI/UE设计师 → 技术架构师 顺序补写同一份 PRD / Resolved the conflict between “Architect must wait for Designer” and on-demand staffing: Architect starts after ProductManager when Architect is the only downstream role, and waits for Designer only when both roles are enabled
- 统一产品小队、产品总监、技术架构师、需求分析 Skill 及中英文 README 的依赖规则，避免共享 PRD 并发修改和错误阻塞 / Aligned the dependency rules across the Product Squad, ProductLeader, Architect, requirement-analysis Skill, and bilingual READMEs to prevent concurrent edits and false blocking on the shared PRD

## Unreleased - 2026-09-02 · 产品小队单一 PRD 交付 / Product Squad single-PRD delivery

### Changed / 变更

- 纠正线上 `DevelopmentLeader` 的显示名和身份：统一为“研发总监”；开发小队及软件开发小队中的专属编排、门禁和交接职责不再写成通用“小队负责人” / Corrected the production `DevelopmentLeader` display name and identity to “研发总监”; development-specific staffing, gates, and handoff now consistently use the dedicated role instead of the generic Leader
- 中文化 Agent / Squad 名称、描述、教程、Issue 模板和 Skill 自然语言标题；`ProductLeader` 统一为“产品总监”，`Leader` 保留为“通用小队负责人” / Localized Agent and Squad names, descriptions, tutorials, Issue templates, and natural-language Skill headings; `ProductLeader` is “产品总监”, while `Leader` remains “通用小队负责人”
- `Designer` 线上显示名统一为“UI/UE设计师”；“界面与交互设计师”仅作为历史对象名称保留，不再作为新对象名称 / Standardized the production `Designer` display name as “UI/UE设计师”; “界面与交互设计师” remains only as a legacy object name and is never used for new objects
- 新增 `scripts/agent-names.ps1` 作为线上 Agent 显示名称的唯一标准配置；导入脚本按中文标准名复用对象，并可将旧逻辑名迁移为标准名 / Added `scripts/agent-names.ps1` as the single source of truth for production Agent display names; the importer reuses canonical Chinese objects and can rename legacy logical objects
- 产品小队统一使用按中文功能名称命名的唯一正式交付物 `prd-<功能名称>.md`，固定详细功能清单、前置条件、主流程、分支流程、异常流程、边界条件和 AC-；同一功能后续变更更新原文件 / The Product Design Squad now uses one official feature-named deliverable `prd-<feature-name>.md` with a short readable Chinese feature name, fixed feature inventory, preconditions, main / branch / error flows, boundary conditions, and ACs; later changes to the same feature update the existing file
- ProductManager、Designer、Architect 按 ProductLeader 指定顺序补写同一份功能 PRD，ProductLeader 只做最终统一评审 / ProductManager, Designer, and Architect append to the same feature PRD in ProductLeader's sequence, and ProductLeader performs the only final unified review
- 导入脚本支持线上中文 Agent / Squad 别名，更新已有“产品总监”“产品经理”“产品小队”等对象而不创建英文重复对象 / The import script resolves localized Agent / Squad aliases so existing objects such as “产品总监”, “产品经理”, and “产品小队” are updated without English duplicates
- 导入脚本按目标定义收敛小队 Agent 成员，移除“开发小队”和“软件开发小队”中历史归档的 `FrontendDev`、`BackendDev`、`Tester` 成员，并将最终统计改为实际对象数 / Squad import now converges Agent membership to the target definition, removing archived `FrontendDev`, `BackendDev`, and `Tester` members from “开发小队” and “软件开发小队”; final counts now report unique objects

## Unreleased - 2026-09-01 · 产品小队最终评审路由 / Product Squad final-review routing

### Changed / 变更

- ProductManager 完成后，ProductLeader 只判断是否继续启用 Designer / Architect；需要继续时不做中间正式评审，所有适用产物完成后只做一次最终统一评审 / After ProductManager finishes, ProductLeader only decides whether Designer / Architect are needed; when more work is needed there is no intermediate formal review, and one final unified review happens after all applicable outputs are complete
- 若不需要 Designer / Architect，ProductLeader 直接对 ProductManager 产物做最终评审并结束产品小队流程 / When no Designer / Architect is needed, ProductLeader directly performs the final review of the ProductManager output and ends the Product Squad flow

## Unreleased - 2026-09-01 · 产品小队首派顺序固化 / ProductManager-first dispatch ordering

### Changed / 变更

- 产品设计小队明确 ProductLeader 完成必要 P0 分诊后，第一时间只能派 ProductManager；产品定义通过 ProductLeader 评审前不得派 Designer、Architect 或开发小队 / Product Design Squad now hardens the first dispatch: after necessary P0 triage, ProductLeader must dispatch ProductManager first, and cannot dispatch Designer, Architect, or a development Squad before the product definition passes ProductLeader review
- 中英文产品设计 README 流程图同步展示 ProductManager 首站、按需启用 Designer / Architect 和 ProductLeader 最终统一 Review / Bilingual product-design README flow diagrams now show ProductManager first, on-demand Designer / Architect activation, and ProductLeader's final unified review

## Unreleased - 2026-09-01 · 产品需求固定前置 / ProductManager-first requirement flow

### Changed / 变更

- 产品、页面、按钮、流程和 UI 变化统一先经过 ProductManager，再由 Leader 进行 G0 评审，之后才允许 UI / 技术设计和开发；已有 PRD / Issue 只做轻量复用校验，不再作为跳过 ProductManager 的理由 / Product, page, button, workflow, and UI changes now always pass through ProductManager first, then Leader G0 review, before UI / technical design and development; existing PRD / Issue content is lightly reused and validated, not used to bypass ProductManager
- 开发小队明确只接收产品定义包、明确 Bug 或纯技术任务；未经过产品定义的产品 / UI 需求会 BLOCKED 并退回产品小队 / The Development Squad now accepts only product-definition packages, clearly bounded bugs, or pure technical tasks; undefined product / UI requests are BLOCKED and returned to the Product Squad
- 纯技术任务和明确 Bug 的 ProductManager 例外必须由 Leader 显式记录 `ProductManager N/A` 及理由，避免静默绕过流程 / The ProductManager exception for pure technical tasks and clear bugs must be explicitly recorded by the Leader as `ProductManager N/A` with a reason, preventing silent bypasses

## Unreleased - 2026-09-01 · 产品小队单一评审 / Product Squad single-review model

### Changed / 变更

- 产品小队移除 ProductReviewer、DesignReviewer、ArchReviewer，由 ProductLeader 统一评审产品定义、UI / 交互和技术方案 / Product Design Squad removes ProductReviewer, DesignReviewer, and ArchReviewer; ProductLeader now reviews the product definition, UI / interaction, and technical design
- 产品小队明确所有需求必须先经过 ProductManager，Designer / Architect 仅在 ProductLeader 判断需要时启用 / Product Design Squad now requires ProductManager first for every request; Designer / Architect activate only when ProductLeader decides they are needed
- 导入脚本会从现有 Product Design Squad 主动移除三个已退役 Reviewer 成员，降低调用次数、重复上下文和 Token 消耗 / The import script removes the three retired Reviewer members from an existing Product Design Squad, reducing calls, repeated context, and token usage

## Unreleased - 2026-08-31 · 取消任务补偿 / Cancellation compensation

### Added / 新增

- 新增 `scripts/watch-cancelled-issues.ps1`：轮询已取消 Issue，并调用官方 `multica issue cancel-task` 中断仍处于排队或运行中的任务；支持 `-Once` 单次检查 / Added `scripts/watch-cancelled-issues.ps1` to poll cancelled Issues and invoke the official `multica issue cancel-task` command for queued or running tasks; supports a one-shot `-Once` check

### Changed / 变更

- 产品、开发 Leader、ProductManager 和两个相关 Squad 模板增加取消保护：重新读取 Issue 状态，取消后不再派单、回写、恢复状态或触发后续流程 / Product and development Leaders, ProductManager, and the two related Squad templates now re-check Issue status and stop dispatch, writes, status revival, and downstream flow after cancellation
- 导入脚本优先使用 PATH 中可用的 `multica` CLI，再回退到默认安装路径，兼容自定义 CLI 安装位置 / The import script now prefers the `multica` CLI found on PATH and falls back to the default installation path, supporting custom CLI locations

## Unreleased - 2026-08-31 · 产品小队成本控制 / Product Squad Cost Control

### Changed / 变更

- 产品小队与 `ProductLeader` 增加按 L1 / L2 / L3 分档的调用策略：非活跃 Agent 不启动，简单任务不自动启用 Designer、Architect 及其 Reviewer / Product Squad and `ProductLeader` now use L1 / L2 / L3 call profiles: inactive Agents do not start, and simple tasks do not automatically activate Designer, Architect, or their Reviewers
- 增加任务摘要包与稳定引用规则，禁止每次派活默认复制完整聊天历史、完整 PRD 或无关产物；Reviewer 只检查本次变化及受影响的 AC- / Added task-capsule and stable-reference rules; dispatches no longer default to copying full chat history, full PRDs, or unrelated artifacts, and Reviewers inspect only the current delta and affected ACs
- 增加按复杂度的返工上限与受影响范围失效规则：L1 一轮、L2 两轮、L3 三轮，超限升级人类，避免 Agent 内部循环放大 token / Added complexity-based rework limits and impact-scoped invalidation: one round for L1, two for L2, and three for L3 before Human escalation, preventing internal Agent loops from multiplying token usage

## Unreleased - 2026-08-31 · OP- 分级与阻塞控制 / OP- classification and blocking control

### Changed / 变更

- 产品小队、`ProductLeader`、`ProductManager`、`ProductReviewer` 和 `multica-requirement-analysis` 现在要求将 OP- 分为阻塞项与非阻塞跟进项；只有影响当前范围、业务规则、权限 / 数据口径、AC- 或安全合规的事项才阻塞评审 / 交接 / Product Design and its product roles now classify OP- items as blocking or non-blocking follow-ups; only issues affecting current scope, business rules, permission / data definitions, AC-, or security/compliance block review or handoff
- 非阻塞跟进项仍需显式记录负责人和后续时点（如适用），但不会因为 OP- 未全部关闭而让整份 PRD 或轻量产品变更说明 FAIL / Non-blocking follow-ups remain visible with an owner and timing when applicable, but an artifact no longer fails merely because every OP- is not closed

## Unreleased - 2026-08-31 · 产品小队渐进式澄清 / Progressive Product Triage

### Changed / 变更

- `ProductLeader` 与 Product Design Squad 改为“先复用、再补缺、按复杂度展开”：L1 使用精简产品变更说明并保留独立评审，L2 / L3 才按需展开完整 PRD；每轮最多追问 3 个阻塞问题，不相关字段不再阻塞 / ProductLeader and Product Design Squad now reuse existing requirements, fill only blocking gaps, and expand by complexity: L1 uses a compact reviewed change note, while L2 / L3 expand the applicable PRD sections; each round asks at most three blocking questions and irrelevant fields do not block

## Unreleased - 2026-08-31 · 专属领域 Leader / Domain-specific Leaders

### Added / 新增

- 新增 `ProductLeader` 与 `DevelopmentLeader` Agent Instructions，分别面向产品范围收敛 / 产品评审，以及开发分诊 / 技术编排 / 开发交接 / Added dedicated ProductLeader and DevelopmentLeader Agent Instructions for product convergence and review, and development triage, technical staffing, and handoff

### Changed / 变更

- 导入脚本现在会同步两个专属 Leader 的 Instructions、描述和 Skills，并从目标小队移除旧通用 Leader 成员；`Product Design` 使用 `ProductLeader`，`Development` 与 `Software Development` 使用 `DevelopmentLeader`，通用 `Leader` 保留给其他小队 / The import script now syncs both dedicated Leaders and removes the old generic Leader from target Squads; Product Design uses ProductLeader, Development and Software Development use DevelopmentLeader, while the generic Leader remains available to other Squads
- 双语 README、Starter README 与 AGENTS 结构说明同步更新 Agent 数量和各小队 Leader 归属 / Bilingual READMEs, Starter READMEs, and the AGENTS structure now document the Agent count and per-Squad Leader ownership

## Unreleased - 2026-08-31 · 聚焦开发小队 / Development-focused Squad

### Added / 新增

- 新增 `templates/zh_CN|en_US/squad/development` Starter：复用现有 Leader、Architect、FrontendDev、BackendDev，专注开发阶段 / Added a development-focused Starter reusing the existing Leader, Architect, FrontendDev, and BackendDev
- 新增 Leader 动态编排规则：按 L1/L2/L3 复杂度按需启用成员，完成开发交接后交给测试或部署运维小队 / Added Leader-driven L1/L2/L3 staffing with downstream handoff after development
- 新增 `templates/zh_CN|en_US/squad/product-design` Starter：复用 ProductManager、Designer、Architect 及对应专属 Reviewer，设计各种产品功能 / Added a product-feature-design Starter reusing ProductManager, Designer, Architect, and their dedicated Reviewers
- 新增产品产物双层评审：Leader 通用门禁 + ProductReviewer / DesignReviewer / ArchReviewer 专业评审 / Added two-layer product artifact review with a Leader general gate and dedicated professional Reviewers

### Changed / 变更

- 根 README、双语 adapt-and-scale 方法论、AGENTS 结构和 ROADMAP 增加 Development 与 Product Design Starter 入口 / Added the Development and Product Design Starters to root READMEs, bilingual adapt-and-scale guidance, AGENTS structure, and ROADMAP

## Unreleased - 2026-08-28 · Multica Agent 中文备注 / Chinese Agent descriptions

### Changed / 变更

- `scripts/import-to-multica.ps1`：将导入的 15 个 Agent 默认备注改为中文，并同步更新目标工作区中的对应 Agent 描述 / Changes the default descriptions for the 15 imported Agents to Chinese and syncs them to the target workspace
- `scripts/import-to-multica.ps1`：将三套正式 Squad 的默认备注改为中文 / Changes the default descriptions for the three official Squads to Chinese

## v0.0.10 - 2026-08-22 · 全量 Review 修复：一致性/双语文档同步 / Full-review fixes: consistency & bilingual sync

### Changed / 变更

- `bug-fix/squad.md`（中英）：【团队】段移除 `@Architect` / `@Designer`，与「Bug 修复不经过 Architect」的核心设计一致；影响端只有前端 / 后端，不再误列设计端 / Bug squad removes Architect & Designer from the team list to match the "no Architect" design
- `bug-fix/squad.md`（中英）+ `software-development/squad.md`（中英）：第一步/需求就绪补充「链接型 Issue 按 `<ISSUE-KEY>` 或链接去外部系统取回需求/范围/验收标准」的取数指引，与 issue.md 的「来源二选一」对齐 / Squad instructions now pull requirements for linked Issues from the external system
- `README.md` / `README.en.md`：Issue 模板描述由「含 Git 分支」改为「来源支持链接型 / 全量自包含二选一」（issue.md 已在 v0.0.9 删除 Git 分支章）/ Root READMEs drop the stale "Git branch" claim
- `en_US/squad/software-development/README.md`：目录表「Shared Skills」数量由遗留的 6 修正为 16，与正文一致 / en starter README fixes the stale "6 Skills" count
- `software-development/issue.md`（中英）+ `bug-fix/issue.md`（中英）：「为什么这么写」字段列举与模板实际章节（参考资料 / 备注、References / Notes）对齐；bug-fix 补「常见失败」段，与 software-development 体例一致 / Issue "why" sections list the real sections; bug-fix adds a "common failure modes" section
- `agents/devops.md`（中英）+ `skills/multica-platform-jenkins/SKILL.md`（中英）：移除对已删除的 Issue「Git 分支」区块的引用，deploy branch 改为「由 Issue 来源与涉及端确定，链接型以外部系统分支为准」/ DevOps & Jenkins skill drop the stale reference to the removed Issue "Git Branch" block
- `agents/backend-developer.md`（中英）：「为什么有效」补「契约由后端 owner、架构师只给方案与步骤」的分工说明；并将「自证」改为「自查证据」，明确用 `multica-verification` 跑的是自查、判门权只在 Leader / Backend Dev doc clarifies the contract-owner split and that self-check ≠ Leader gate

### Why / 背景

- 全量 Review 发现上述文档在多次演进后留下数字遗漏、与已删除章节不符的声称、以及 Squad 指令未接入轻量链接型用法等问题；本次集中修正，保证「复制即运行」不踩坑 / Full-review sweep fixed leftover counts, stale claims, and Squad instructions lagging behind the lightweight Issue mode

## v0.0.9 - 2026-08-22 · Issue 模板支持双形态（Jira/Tapd 链接型轻量填写）/ Issue template dual-form: lightweight Jira/Tapd link mode

### Changed / 变更

- `software-development/issue.md`（中英）新增「Issue 来源（必填，二选一）」块：支持「外部系统链接（轻量）」只填链接 + 涉及端 + 一句话摘要，或「全量自包含」完整填写；底部「为什么这么写」补充来源分流说明 / Issue template adds "Issue source (pick one)" — lightweight external-link mode vs fully self-contained
- `bug-fix/issue.md`（中英）同步新增「Issue 来源（必填，二选一）」块 / Bug issue template gets the same "Issue source (pick one)" block
- `software-development/README.md`（中英）文件清单与 Step 4、根 `README.md` / `README.en.md` Step 4 描述更新，反映链接型轻量用法 / Starter READMEs + root READMEs updated to mention link-style filling
- `software-development/issue.md`（中英）修正角色错配：需求追踪矩阵改标「提 Issue 留空、由 Tester 回填」；技术上下文改选填（Architect 在 G1 补全）；约束拆「业务约束（PM 填）/ 工程约束（Architect 补）」；验证方式降为「期望验证维度（示意，Leader/Tester 定）」；根 README 流程补「需求收敛(G0)」阶段 / Issue template fixes role mismatch: matrix is Tester-backfilled, context is optional, constraints split, verification is indicative; root README flow adds G0
- `software-development/issue.md`（中英）进一步精简：删除「需求追踪矩阵 / 技术上下文 / 约束 / 验证方式 / Git 分支」五章，仅保留背景/目标/范围(含涉及端)/非目标/验收标准/来源/参考资料/备注，模板回到纯需求契约 / Issue template trimmed: drop matrix/context/constraints/verification/Git-branch; keep requirement-contract sections only

### Why / 背景

- Issue 真实形态有两种：Jira/Tapd 链接（全量需求在外部系统）与全量自包含 Markdown。原模板默认全量、对链接型过重；新增来源分流后，链接型只需「链接 + 涉及端 + 摘要」即可驱动 G0 路由与 multica-verification 门禁，两种形态共用同一 `<ISSUE-KEY>` / Issues come in two real forms; the source selector lightens link-type Issues while keeping gates intact
- 提 Issue 者通常是 PM（一个 Issue 即一个需求），而追踪矩阵/技术上下文/工程约束/验证方式属下游角色产物。前置成 PM 必填会凭空编 ID 或写入过期信息；Issue 应只作需求契约（为什么做 / 做什么 / 验收 / 非目标），其余由 Squad 运行中回填 / The filer is usually a PM; matrix/context/constraints/verification are downstream artifacts, not requirement inputs

## v0.0.8 - 2026-08-20 · CI/CD gate + Tester three-phase + DevOps role + platform shells / CI/CD 门禁、Tester 三阶段、DevOps 角色与平台层占位壳

### Added / 新增

- 新增 `DevOps` 角色（`templates/zh_CN/agents/devops.md`）：G2 PASS 且代码已 push 后触发 CI/CD、回传部署环境 URL，不写业务代码 / New `DevOps` agent: triggers CI/CD after G2, returns deploy URL, no business code
- 新增 5 个平台层占位壳 skill（不带内网地址/凭据，仅占位）：`multica-platform-confluence`、`multica-platform-jira`、`multica-platform-jenkins`、`multica-artifact-cicd-sync`、`multica-test-automation` / Added 5 platform-layer shell skills (no internal URLs/credentials, placeholder only)
- 新增 `docs/zh_CN/cicd-and-test-pipeline.md`：G2.5 与 Tester T1/T2/T3 方法论、deploy branch 模型 / New `docs/zh_CN/cicd-and-test-pipeline.md` methodology
- `artifact-conventions.md`（中英）新增「三层架构：内容/编排/平台」与 PM/Architect 双 skill 标准用法 / `artifact-conventions.md` (zh/en) adds three-layer architecture + dual-skill usage
- 角色计数 8 → 9（新增 DevOps）；Skill 11 → 16（新增 5 平台层壳）/ Roles 8 → 9 (DevOps); Skills 11 → 16 (5 platform shells)

### Changed / 变更

- `gates-and-evidence.md`（中英）门禁表新增 **G2.5（CI/CD 部署）** 行 + 走查示例 / `gates-and-evidence.md` (zh/en) adds **G2.5** row + walkthrough
- `tester.md`（中英）升级为 **T1/T2/T3 三阶段**（T1 用例、T2 覆盖率、T3 部署后自动化），移除具体平台绑定 / `tester.md` (zh/en) upgraded to T1/T2/T3 three-phase
- `leader.md`（中英）路由新增 PM 首派、Tester 三阶段路由、DevOps/G2.5 路由 / `leader.md` (zh/en) routing adds PM-first, Tester three-phase, DevOps/G2.5
- `product-manager.md`（中英）增加「先 `multica-requirement-analysis` 结构化，再 `multica-artifact-req-sync` 落地」双 skill 句式 / `product-manager.md` (zh/en) gains dual-skill pattern
- `software-development/squad.md` 与 `issue.md`（中英）阶段表加入 G2.5 与 deploy branch 声明；issue 模板新增「Git 分支」区块 / Squad & issue add G2.5 + deploy branch
- AGENTS.md 结构图更新为 9 角色 + 平台层占位壳 + 三层模型说明 / AGENTS.md structure updated to 9 roles + platform shells + three-layer model

### Removed / 移除

- 无真实内网地址/凭据进入公开仓库：所有 platform skill 仅占位壳，接入时由团队填 `config.yaml` / No real internal URLs/credentials enter the public repo; platform skills are placeholder shells only

## v0.0.7 - 2026-08-17 · Artifact platform decoupled into skills / 产物平台对接下沉到 skill

### Added / 新增

- 新增 5 个产物对接 skill（中英，每个默认平台可替换）：`multica-artifact-req-sync`（PRD→Confluence）、`multica-artifact-ui-sync`（UI→Figma）、`multica-artifact-design-sync`（技术设计→Git/Confluence）、`multica-artifact-api-sync`（API 契约→Apifox）、`multica-artifact-test-sync`（用例→本地 XMind 转 Jira）/ Added 5 artifact-sync skills (zh/en, swappable default platform each)
- 新增 `artifact-conventions.md`（中英）重写为「产物内容规范 + 对接 skill」：内容归角色、平台归 skill，角色提示词不写平台名；换公司只换 skill / Rewrote `artifact-conventions.md` (zh/en) into "content spec + sync skill": content belongs to role, platform to skill; no platform name in prompts
- `README.md` / `README.en.md` Skill 表加 5 个 `multica-artifact-*-sync` 条目，计数 6→11 / README skill tables add the 5 artifact-sync skills, count 6→11

### Changed / 变更

- 全部 8 个角色指令（中英）：「我产出什么 / WHAT I PRODUCE/OWN/DELIVER」改为"用 `multica-artifact-*-sync` skill 落地并回传稳定链接"，去掉写死的 `artifacts/<issue-id>/xxx.md` 与本地产平台名（如 Designer 的 Figma）/ All 8 agent instructions (zh/en): outputs now "land via multica-artifact-*-sync and return a stable link", dropping hard-coded local paths and platform names
- `templates/zh_CN|en_US/squad/software-development/squad.md`：阶段表与产物流水线改为"角色经 skill 回传链接"，【产物落盘】段改为【产物落盘与取回】，不再写死本地路径 / Squad stage map & pipeline now say "role returns link via skill"; 【ARTIFACT LANDING】 becomes landing+retrieval, no hard-coded local paths

## v0.0.6 - 2026-08-17 · Artifact landing conventions / 协作产物落盘约定

### Added / 新增

- 新增 `artifact-conventions.md`（中英）：规定所有阶段产物统一落 `artifacts/<issue-id>/`，文件名固定（PRD=`prd.md`、技术设计=`design-tech.md`、UI 设计=`design-ui.md`、API 契约=`api-contract.md`、功能用例=`cases-feature.md`、接口用例=`cases-api.md`、测试报告=`test-report.md`、验收=`acceptance.md`）；下游用相对路径定位，绝不写绝对路径 / 不泄露 workspace / 不靠搜索 / 引用必须显式传路径 / 冲突以哪份为准 / 产物变更路径不变内容更新 / 门禁据此重判 / 文档表与常见错误同步 / Added `artifact-conventions.md` (zh/en): all stage artifacts land under `artifacts/<issue-id>/` with fixed filenames; downstream locates by relative path
- `where-to-put-things.md`（中英）加一行：协作产物放哪 → `artifacts/<issue-id>/`（见 artifact-conventions）/ where-to-put-things gains an artifact-landing row
- `README.md` / `README.en.md` 文档表加 `artifact-conventions` 条目 / README doc tables add the artifact-conventions entry

### Changed / 变更

- `templates/zh_CN|en_US/squad/software-development/squad.md`：阶段表与产物流水线每个产物标注落盘路径；新增【产物落盘】段，要求 Leader 派活时显式给出产物路径 / Squad stage map & artifact pipeline now annotate each artifact's landing path; added 【ARTIFACT LANDING】 rule requiring explicit path in dispatch
- 全部 8 个角色指令（中英）的「我产出什么 / WHAT I PRODUCE/OWN/DELIVER」补落盘路径与"读取上游 `artifacts/<issue-id>/...`"的硬指示，下游据此定位上游产物 / Every agent instruction (zh/en) now states its artifact landing path and reads upstream via `artifacts/<issue-id>/...`

## v0.0.5 - 2026-08-17 · Add ProductManager role + AI-readable requirement discipline / 新增产品经理角色与需求 AI 可读纪律

### Added / 新增

- 新增 `ProductManager` 角色指令（`templates/zh_CN|en_US/agents/product-manager.md`）：把想法 / 诉求 / 会议结论整理成可评审、可设计、可开发、可测试的 PRD（含 G-/FR-/BR-/AC-/KPI-/RISK-/OP- 编号、六类读者对准、需求类型→产物形态、AI 可读纪律、协作偏好）/ New `ProductManager` agent instructions: turns ideas / asks / meeting notes into reviewable PRDs
- 角色词表加入 `ProductManager`，`naming-conventions.md`（中英）第 2 条同步 / Role vocabulary now includes `ProductManager` in `naming-conventions.md` (zh/en)
- 软件开发展望 Starter 接入 PM：团队段加 @ProductManager，阶段表加 S0 需求产出 @ProductManager → G0 范围确定（基于 PRD），产物流水线加第 0 步；无 PM 时 Issue 直接视为就绪范围、跳过 S0 / software-development Squad wires in PM: S0 requirement @ProductManager → G0 scope; without PM, Issue is the ready scope
- `gates-and-evidence.md`（中英）新增「需求 / 设计类产物的 AI 可读纪律」：稳定标题、稳定表格字段、规则编号、待确认集中（OP- 未关闭不进开发）、文档互链、冲突指明准绳、禁用模糊词、规则文字化；违反任一条 G0/G1 判 REJECTED / Added "AI-readable discipline for requirement / design artifacts" to `gates-and-evidence.md` (zh/en)
- Starter 角色计数 7 → 8（`templates/zh_CN|en_US/squad/software-development/README.md`）/ Starter role count 7 → 8

### Changed / 变更

- @Designer / @Architect（中英）的「产品需求」来源改为以 @ProductManager 的 PRD 为主（无 PM 退化到 Issue / @Architect 说明），并明确产品范围 / 业务规则 / 字段口径归 PM、无 PM 归 Leader 收敛 / Designer & Architect now take PRD from @ProductManager as the primary source; product scope / business rules / field definitions belong to PM (or Leader without PM)

## v0.0.4 - 2026-08-17 · Three-segment naming (role + project + member-id) / 命名升级为三段式

### Changed / 变更

- 命名规范从「角色 + 实例」升级为「角色 + 项目 + 成员标识」`<角色>-<项目>-<成员标识>`，解决「真实姓名 vs 角色名」冲突：同项目同角色多人时靠成员标识（工号/花名，不用真实姓名全称）唯一区分 / Upgraded naming from `role + instance` to `role + project + member-id` `<role>-<project>-<member-id>` to resolve the "real name vs role name" collision: same project + same role + multiple people are disambiguated by the member-id (employee number / nickname, never a full real name)
- 角色前缀通配解析同步扩为三段：`@角色` → 指挥按 `@角色-<本小队 suffix>-<本小队 member>` 精确 @mention（suffix 对应 `<项目>` 段，member 对应 `<成员标识>` 段）/ Role-prefix wildcard resolution extended to three segments: `@role` → orchestrator dispatches `@role-<squad suffix>-<squad member>`
- 同步更新 `docs/zh_CN|en_US/naming-conventions.md`、`templates/zh_CN|en_US/squad/{software-development,bug-fix}/squad.md` 与 `templates/zh_CN|en_US/agents/leader.md` 的前缀解析段/精确派活描述，以及 README（中英文）、AGENTS.md、adapt-and-scale.md（中英文）、各 squad README 的命名标题引用 / Synced all references in README (zh/en), AGENTS.md, adapt-and-scale.md (zh/en), and each squad README

### Removed / 移除

- 未采纳「私有小队 Profile」机制（用户判定过于复杂，不引入）/ Did not adopt the "private squad Profile" mechanism (deemed too complex by the user)

## v0.0.3 - 2026-08-17 · Squad instructions re-leveled to Squad scope / Squad 指令重构为 Squad 级

### Changed / 变更

- Squad 指令（`templates/zh_CN/squad/software-development/squad.md` 与 `templates/en_US/...`，以及 `templates/zh_CN/squad/bug-fix/squad.md` 与 `templates/en_US/...`）改为真正的「Squad 级」：开场定义 Squad 目标 / 事实来源与待确认项 / 编号规范（G-/U-/FR-/BR-/AC-/KPI-/OP-/RISK-，software-development）/ 沟通风格 / 禁止事项（software-development），对所有角色成立；原「你是 Leader」内容下移为独立的 `【Leader 角色】` 段，明确 Leader 仅编排、推进权与判门权在 Leader。借鉴了通用写法但去掉了任何具体项目、工具链与智能体人名的绑定，保持可复制 / Re-leveled the Squad instructions to true squad scope (both `software-development` and `bug-fix`, in zh_CN and en_US): the opening now defines the Squad goal, fact-source & TBD policy, numbering convention (software-development), communication style, and prohibited list (software-development), valid for every role; the former "you are the Leader" content moved into a standalone `【Leader Role】` section stating the Leader only orchestrates and holds advancing/gating authority. Borrowed generic patterns but dropped any binding to specific projects, toolchains, or agent names to stay copy-paste-ready

### Added（追加 · 门禁纪律增强 / Gate discipline enhancements）

- 在 Squad 级规则中补充三条判门纪律（中英文 squad.md 均落地）：(1) 范围内某产物判定为「不适用（N/A）」必须显式标注 + 理由 + Leader 确认，禁止静默跳过；(2) 任一产物被修改后下游门禁立即失效必须重判，不得沿用旧 PASS（不仅实现变更，设计 / API 契约 / 用例变更同样失效）；(3) 同一产物判门连续 3 次 FAIL 强制升级人类，而非无限返工 / Added three gate disciplines to the Squad-level rules (both zh_CN and en_US squad.md): (1) an in-scope artifact judged N/A must be marked explicitly with reason + Leader confirmation — never silently skipped; (2) once any artifact is modified its downstream gates are invalidated and must be re-judged, never carry over an old PASS (not just implementation — design / API contract / case changes also invalidate downstream); (3) the same artifact failing the gate 3 times in a row escalates to Human instead of endless rework
- 同步 `docs/zh_CN` 与 `docs/en_US` 的 `gates-and-evidence.md`（扩展门禁失效原则，覆盖上游产物修改与 N/A 不静默跳过）和 `common-mistakes.md`（新增第 9 条「静默把范围内产物当 N/A 跳过」错误示范，并扩展诊断清单）/ Synced `gates-and-evidence.md` (extended gate-invalidation principle to upstream changes and non-silent N/A) and `common-mistakes.md` (new pitfall #9 on silently skipping in-scope artifacts as N/A, plus expanded diagnostic checklist) in both `docs/zh_CN` and `docs/en_US`

### Added（追加 · 借鉴邻方案的四项增强 / Borrowed enhancements）

- **角色前缀通配解析**（解决「workspace 内多个同角色实例如何锁定本小队」）：新增 `docs/zh_CN|en_US/naming-conventions.md` 的「小队实例后缀与前缀通配」规则——Squad 指令只写角色前缀（@FrontendDev 等），小队启动时声明实例后缀 suffix，指挥按 `@角色-<本小队 suffix>` 精确 @mention；并在两个 `squad.md`（中英文）+ `agents/leader.md`（中英文）补「角色前缀解析」段与精确派活规则 / **Role-prefix wildcard resolution** (solves "how to pin this squad's agent among multiple same-role instances in a workspace"): added "Squad instance suffix & prefix wildcard" to `docs/zh_CN|en_US/naming-conventions.md` — Squad instructions write only the role prefix, the squad declares a suffix at startup, and the orchestrator dispatches `@role-<squad suffix>`; also added a "role prefix resolution" section and precise-dispatch rule to both `squad.md` (zh_CN/en_US) and `agents/leader.md` (zh_CN/en_US)
- **门禁结论四值与汇合门禁 + 判门不改产物**（落到 `docs/zh_CN|en_US/gates-and-evidence.md`）：新增 APPROVED / APPROVED_NA / REJECTED / BLOCKED 四值（APPROVED_NA 区别于普通 PASS 的下游差异由 Leader 写明）；明确汇合门禁「并行分支须全 PASS 才开放下游」；判门者只给结论与修改清单、不代替作者改产物 / **Four verdict values, join gates, gatekeeper-doesn't-edit** added to `docs/zh_CN|en_US/gates-and-evidence.md`: APPROVED / APPROVED_NA / REJECTED / BLOCKED (APPROVED_NA's different downstream is stated by the Leader); join gates require every parallel branch PASS; the gatekeeper only gives a verdict + fix list and never edits the artifact
- **阶段-门禁对照表**（落到 `templates/zh_CN|en_US/squad/software-development/squad.md` 顶部）：以 `@角色` 占位、不写死人数/人名的 S0–G4 流水线一览，缺层即跳过对应行 / **Stage-gate map** added atop `templates/zh_CN|en_US/squad/software-development/squad.md`: a S0–G4 pipeline overview using `@role` placeholders (no hardcoded counts/names), skipping the line for any missing layer
- **需求追踪矩阵**（落到 `templates/zh_CN|en_US/squad/software-development/issue.md`）：建议 REQ → DESIGN → API → CODE → CASE → TEST 映射，保证验收标准无断链 / **Requirements traceability matrix** added to `templates/zh_CN|en_US/squad/software-development/issue.md`: suggested REQ → DESIGN → API → CODE → CASE → TEST mapping to prevent broken links
- **判门不改产物**同步进 squad.md 推进规则与 bug-fix 规则（中英文）及 leader.md 第 9 条 / **Gatekeeper-doesn't-edit** also synced into the advance rules of both squad.md (zh_CN/en_US, software-development + bug-fix) and leader.md rule #9 (zh_CN/en_US)

### Added（追加 · 新增 Designer 角色 / New Designer role）

- 新增 `Designer` 角色，专做 UI / 交互设计、对接 Figma 出视觉与标注，与 `Architect`（技术架构设计）明确分离；新建 `templates/zh_CN|en_US/agents/designer.md` / Added a **Designer** role for UI / interaction design working with Figma, separated from `Architect` (technical design); new `templates/zh_CN|en_US/agents/designer.md`
- `docs/zh_CN|en_US/naming-conventions.md` 角色词表加入 `Designer`，并注明 Architect ≠ Designer / `docs/zh_CN|en_US/naming-conventions.md` role vocabulary now includes `Designer`, noting Architect ≠ Designer
- 两个 `squad.md`（中英文）的【团队】段加入 `@Designer`；software-development 的阶段-门禁对照表拆分为 S1a 技术设计(@Architect) / S1b UI 设计(@Designer) 双线，并明确 @FrontendDev 同时依赖二者；bug-fix 团队段也加入 @Designer（UI bug 场景）/ Both `squad.md` (zh_CN/en_US) gained `@Designer` in the team section; software-development's stage-gate map splits into S1a technical design (@Architect) / S1b UI design (@Designer) with @FrontendDev depending on both; bug-fix team section also lists @Designer
- `frontend-developer.md`（中英文）明确 UI 来源为 @Designer 的 Figma 产出，缺位时回退设计文档或 mock / `frontend-developer.md` (zh_CN/en_US) now names @Designer's Figma output as the UI source, falling back to a design doc or mock when absent
- 同步角色计数：README / README.en / ROADMAP / AGENTS.md / software-development README 由 6 角色更新为 7 或 5→6 Agent / Synced role counts in README / README.en / ROADMAP / AGENTS.md / software-development README (6→7 roles, or 5→6 agents)

## v0.0.2 - 2026-08-16 · Template correctness fixes / 模板正确性修复

### Changed / 变更

- 修复 CI 门禁模板：结构化结论现在会输出实际 PASS / FAIL；分支保护脚本不再生成残缺请求体 / Fixed the CI gate templates so the structured verdict emits the actual PASS / FAIL value and the branch-protection script no longer produces a truncated request body
- 修复 Squad 路由：Bug Fix 会派发 Tester；软件开发中的接口测试用例与实现并行推进 / Fixed Squad routing so Bug Fix dispatches the Tester and API test cases advance in parallel with implementation
- 同步路线图中的 Skill 数量，并说明团队级审批应使用 CODEOWNERS 或 GitHub Rulesets / Synchronized the Skill count in the roadmap and clarified that team-level approval requires CODEOWNERS or GitHub Rulesets
- 调整项目定位表述，使真实任务验证状态与 ROADMAP 保持一致 / Aligned the project-positioning language with the real-task validation status in the ROADMAP

## v0.0.1 - 2026-08-15 · Initial release / 初始版本

历史演进（0.1.0–0.14.0）已压缩合并为本版本：一套可直接复制运行的 Multica 模板库。
Historical iterations (0.1.0–0.14.0) are condensed into this release: a copy-paste-ready Multica template library.

### Added / 新增

- **Agent 模板 / Agent templates**：6 个共享角色（Leader / Architect / FrontendDev / BackendDev / Tester / Reviewer），位于 `templates/zh_CN/agents/` 与 `templates/en_US/agents/`
- **Skill 模板 / Skill templates**：6 个共享 Skill（`multica-verification` 判门 / `multica-gate-setup` CI 硬门禁 / `multica-test-design` / `multica-requirement-analysis` / `multica-technical-design` / `multica-implementation`），统一 `multica-` 前缀，按名称挂载
- **Squad Starter / Squad starters**：`software-development`（推荐）与 `bug-fix`（实验性），各含 README / squad / issue 三件套
- **方法论 / Methodology**：`docs/` 5 篇（指令归属 / 门禁与证据 / 常见错误 / 裁剪扩展 / 命名规范）
- **CI 硬门禁 / CI hard gates**：`delivery-gate.yml` / `branch-protection.json` / `apply-branch-protection.sh` 随 `multica-gate-setup` skill 自包含
- **国际化 / i18n**：`README.md` ↔ `README.en.md` 顶部互挂切换链接；`templates/` 与 `docs/` 按 `zh_CN/` / `en_US/` 双目录存放；根文档（AGENTS / CHANGELOG / ROADMAP / SECURITY / CONTRIBUTING）单文件化并采用中英结合写法

### Changed / 变更

- 无（本版本为压缩合并后的初始版本）。No changes — this is the initial condensed release.
