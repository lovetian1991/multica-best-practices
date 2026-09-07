# Skills 索引（zh_CN）

本目录收录可直接挂载到 [Multica](https://github.com/multica-ai/multica) 的共享 Skill。每个子目录即一个 Skill，`SKILL.md` 是给 智能体 读的技能说明；带脚本的 Skill 另附 `README.md` 给出人类视角的快速上手。

## 一、平台层（含公司基建 URL / 凭据的占位外壳）

| Skill | 用途 | 主要入口 |
|---|---|---|
| `multica-platform-opencontent` | 通过 oc-basic 管理产物目录、上传、更新、内链和下载 | `scripts/publish-artifact.py`、`scripts/fetch-artifact.py` |
| `multica-platform-jenkins` | 触发 Jenkins 构建 / 发布 / 晋级 | `scripts/trigger_env.py`、`scripts/build_sit.py`、`scripts/promote_prod.py` |

> 平台层只放 URL / 凭据的占位外壳，不含任何真实地址。Issue 数据由 Multica 保存；OpenContent 凭据仅由 `oc-basic` 运行环境读取。

## 二、编排层（调用平台层把产物落地到团队平台）

| Skill | 用途 | 主要入口 |
|---|---|---|
| `multica-artifact-req-sync` | PRD / 需求 → OpenContent 文件 + Multica Issue 引用 | `scripts/publish-prd.sh` |
| `multica-artifact-cicd-sync` | 代码评审结论 → 触发 Jenkins CICD | `scripts/trigger_cicd.py` |
| `multica-artifact-api-sync` | API 文档 → 团队 API 平台 | （纯编排） |
| `multica-artifact-design-sync` | 设计文档 → 团队设计平台 | （纯编排） |
| `multica-artifact-test-sync` | 测试用例 → 团队测试平台 | （纯编排） |
| `multica-artifact-ui-sync` | UI 规范 → 团队 UI 平台 | （纯编排） |

## 三、通用方法论 / 角色 / 评审（纯 Markdown，无脚本）

| 技能 | 用途 |
|---|---|
| `multica-implementation` | 实现阶段方法论 |
| `multica-requirement-analysis` | 需求分析 |
| `multica-technical-design` | 技术设计 |
| `multica-verification` | 通用门禁 |
| `multica-test-design` | 测试设计 |
| `multica-test-automation` | 测试自动化 |
| `multica-gate-setup` | CI 硬门禁模板 |
| `multica-review-architect` | 架构评审 |
| `multica-review-backend` | 后端评审 |
| `multica-review-product` | 产品评审 |
| `multica-review-test` | 测试评审 |
| `multica-manage-skills` | 通过 Multica API 管理 Skill |

## 四、怎么挂载到 Multica

1. 把需要的 Skill 目录整体拷到你的 Multica workspace 的 `skills/` 下（目录名即 Skill 名，需与 `SKILL.md` 里的 `name` 字段一致）。
2. 含脚本的 Skill：先按对应 README 配置运行时环境；OpenContent 只需设置 `OC_CLI_PATH`、`MULTICA_SERVER_URL` 和 `OPENCONTENT_APIKEY`，不要提交 `.env`。
3. 平台层的 URL / 凭据**永远不要提交真实值**——保留 `.env.example` 占位即可。

## 五、命名约定

- 统一 `multica-` 前缀 + 小写连字符。
- 平台层只放占位外壳；真实基建信息由使用方在 `.env` 提供。
