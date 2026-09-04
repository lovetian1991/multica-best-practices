# 软件开发小队启动模板

> 开箱即用的 Multica 小队，用于常规软件功能开发。
> **复制 → 粘贴 → 运行**，5 分钟起步。

## 团队

```text
                研发总监
                  │
    ┌─────────────┼─────────────┐
    ↓             ↓             ↓
技术架构师  前端开发专家  后台开发专家
    │             │             │
    └──────┬──────┴──────┬──────┘
           ↓             ↓
        测试专家（用例左移）   ↓
        业务评审（业务评审）
```

## 工作流

按 Issue 范围裁剪，任意角色可缺失：

```text
  Issue
    ↓ 产品经理 产出 / 校验 PRD（已有内容只复用增量）
    ↓ G0 研发总监评审并确定范围（UI? 技术设计? 前端? 后端?）── 范围含糊 → 回写 Issue / 问人类
    ↓
[设计] G0 PASS 后按需派 技术架构师 / UI/UE设计师 ── G1：研发总监（multica-verification skill）对齐验收标准 + 业务评审 ── FAIL → 回对应设计角色
  ↓ PASS
[并行]
  ├─ [后端] 后台开发专家：API 契约 → 研发总监判门
  └─ [测试] 测试专家：功能用例 → 研发总监判门
  ↓
[实现]（并行互不等待）
  ├─ [前端] 前端开发专家（对接 UI 设计）→ G2：研发总监复跑验证命令
  └─ [后端] 后台开发专家 → G2：研发总监复跑验证命令
  ↓
[测试] 测试专家：接口测试用例 → 执行 → 测试报告
  ↓ G3：研发总监复核是否逐条覆盖验收标准 ── FAIL → 回对应实现者
  ↓ PASS
人类（G4 人类验收）
  ↓
完成
```

> `[xxx]` = 范围包含该角色才执行；缺失的角色直接跳过对应行，门禁链不断。

## 产物与门禁

| 产物 | 产出者（按范围） | 门禁 |
| --- | --- | --- |
| 产品需求 / 需求就绪 | 产品经理（复用已有 PRD / Issue） | G0（研发总监评审范围 + 目标 + 验收标准） |
| 设计 | 技术架构师 | G1（研发总监用 multica-verification skill + 业务评审） |
| API 契约 | 后台开发专家 | 研发总监判门（前端 / 测试的并行输入） |
| 功能用例 | 测试专家 | 研发总监判门 |
| 前端实现 | 前端开发专家 | G2（研发总监复跑验证命令） |
| 后端实现 | 后台开发专家 | G2（研发总监复跑验证命令） |
| 接口测试用例 | 测试专家 | 研发总监判门 |
| 测试报告 | 测试专家 | G3（研发总监复核逐条对照） |
| 验收 | 人类 | G4（交付决策） |

## 何时使用

- 新功能 / 小到中型改动
- API、后端、前端开发（前后端可拆分，按 Issue 范围路由）
- 需求清晰的重构

## 何时不用

- 生产事故紧急修复 → 用 [`bug-fix`](../bug-fix) Starter
- 大型架构迁移
- 高度模糊的产品探索

## 5 分钟上手

### 第 1 步：创建智能体

在 Multica 创建 智能体（按你的范围决定建哪些；命名遵循 [`docs/naming-conventions.md`](../../../../docs/zh_CN/naming-conventions.md) 的「角色+项目+成员标识」）。最小可用集合：

```text
技术架构师
前端开发专家
后台开发专家
测试专家
业务评审
```

范围含 CI/CD 时再加 `部署运维专家`。产品、页面、按钮、流程和 UI 变化必须配置 `产品经理`；已有 PRD / Issue 也只由产品经理轻量校验复用。纯技术任务或明确 Bug 且不改变产品范围、业务规则和 UI 时，可由研发总监显式记录 `产品经理 N/A`。把 [`../../agents/`](../../agents/) 下对应文件的代码块分别复制到各智能体的提示词。

> 研发总监不需要单独建智能体：`squad.md` 就是研发总监的行为配置（Multica 的小队提示词只注入研发总监）。

### 第 2 步：创建 Skill

在 Multica 创建 16 个 Skill：

| Skill | 来源 | 挂给谁 |
| --- | --- | --- |
| `multica-verification`（判门，必备） | [`../../skills/multica-verification/SKILL.md`](../../skills/multica-verification/SKILL.md) | **研发总监** |
| `multica-gate-setup` | [`../../skills/multica-gate-setup/SKILL.md`](../../skills/multica-gate-setup/SKILL.md) | 研发总监（集成 CI 硬门禁时） |
| `multica-test-design` | [`../../skills/multica-test-design/SKILL.md`](../../skills/multica-test-design/SKILL.md) | 测试专家 |
| `multica-requirement-analysis` | [`../../skills/multica-requirement-analysis/SKILL.md`](../../skills/multica-requirement-analysis/SKILL.md) | 研发总监 / 技术架构师 |
| `multica-technical-design` | [`../../skills/multica-technical-design/SKILL.md`](../../skills/multica-technical-design/SKILL.md) | 技术架构师 |
| `multica-implementation` | [`../../skills/multica-implementation/SKILL.md`](../../skills/multica-implementation/SKILL.md) | 前端开发专家 / 后台开发专家 |
| `multica-artifact-req-sync` | [`../../skills/multica-artifact-req-sync/SKILL.md`](../../skills/multica-artifact-req-sync/SKILL.md) | 产品经理 |
| `multica-artifact-ui-sync` | [`../../skills/multica-artifact-ui-sync/SKILL.md`](../../skills/multica-artifact-ui-sync/SKILL.md) | UI/UE设计师 |
| `multica-artifact-design-sync` | [`../../skills/multica-artifact-design-sync/SKILL.md`](../../skills/multica-artifact-design-sync/SKILL.md) | 技术架构师 |
| `multica-artifact-api-sync` | [`../../skills/multica-artifact-api-sync/SKILL.md`](../../skills/multica-artifact-api-sync/SKILL.md) | 后台开发专家 |
| `multica-artifact-test-sync` | [`../../skills/multica-artifact-test-sync/SKILL.md`](../../skills/multica-artifact-test-sync/SKILL.md) | 测试专家 |
| `multica-artifact-cicd-sync` | [`../../skills/multica-artifact-cicd-sync/SKILL.md`](../../skills/multica-artifact-cicd-sync/SKILL.md) | 部署运维专家 |
| `multica-test-automation` | [`../../skills/multica-test-automation/SKILL.md`](../../skills/multica-test-automation/SKILL.md) | 测试专家（T3） |
| `multica-platform-jenkins` | [`../../skills/multica-platform-jenkins/SKILL.md`](../../skills/multica-platform-jenkins/SKILL.md) | 平台层占位壳（CI/CD） |
| `multica-platform-jira` | [`../../skills/multica-platform-jira/SKILL.md`](../../skills/multica-platform-jira/SKILL.md) | 平台层占位壳（Issue） |
| `multica-platform-confluence` | [`../../skills/multica-platform-confluence/SKILL.md`](../../skills/multica-platform-confluence/SKILL.md) | 平台层占位壳（Wiki） |

> 16 个 Skill 全部共享放在 [`../../skills/`](../../skills/)，统一 `multica-` 前缀命名空间，分三类：判门/设计类、产物编排类（`multica-artifact-*-sync`）、平台层占位壳（唯一允许出现内网地址/凭据的地方，公开仓库只给占位壳）。Skill 靠**名称**挂载，谁需要就在自己的 提示词 里写「用 xxx skill」，与仓库路径无关。

### 第 3 步：创建小队

创建一个小队，把 [`squad.md`](./squad.md) 的代码块复制到小队提示词。

### 第 4 步：创建 Issue

把 [`issue.md`](./issue.md) 的模板复制到新 Issue，填上你的需求。

### 第 5 步：分配

把 Issue 分配给这个小队。

### 第 6 步：运行

小队会自动按上面的「工作流」走完：

```text
  Issue → 产品经理 → G0 → [UI / 技术设计] → [并行产物] → [实现] → [测试] → 人类
```

每个产物的门禁由研发总监用 multica-verification skill 判门，PASS 才放行；范围里没有的角色直接跳过。
就这些。先跑一个真实需求，再按你的团队调整。

## 重要提醒

这个流程是**协调指引**，不是硬性约束。它不能替代：

- CI 硬门禁（见 [`../../skills/multica-gate-setup/`](../../skills/multica-gate-setup/)）
- 分支保护 / PR 评审
- 人类审批

multica-verification skill 是智能体世界的**软门禁**（由研发总监执行判门），「必须通过」的硬约束请放在工程系统里强制执行，不要只依赖「智能体被要求这样做」。

## 目录

| 文件 | 用途 |
| --- | --- |
| `squad.md` | 小队提示词（条件路由 + 产物门禁 + 证据要求） |
| `issue.md` | 标准 Issue 模板（精简为需求契约：来源二选一 + 背景/目标/范围含涉及端/非目标/验收标准，仅此） |
| `README.md` | 本文件（工作流 + 产物门禁 + 上手步骤） |
| [`../../agents/`](../../agents/) | 共享 智能体 提示词（architect / frontend-developer / backend-developer / tester / reviewer / devops / leader） |
| [`../../skills/`](../../skills/) | 共享 Skill（统一 multica- 前缀：判门 / 集成 CI / 测试设计 / 需求分析 / 技术设计 / 实现 / 产物落地 / 平台层占位壳） |

## 为什么有效

这个启动模板有 9 个角色：研发总监负责编排与判门，产品经理（产品需求 / PRD）是产品需求固定首站，技术架构师（技术架构）/ UI/UE设计师（UI）/ 前端开发专家 / 后台开发专家 / 测试专家（T1/T2/T3 三阶段）/ 部署运维专家（G2.5 触发 CI/CD）各管一段产物，**业务评审做业务评审**。若使用 `software-development-reviewed` 或 `bug-fix` 等通用小队，则对应使用线上显示名“通用小队负责人”。
判门动作标准化为 [`../../skills/multica-verification/SKILL.md`](../../skills/multica-verification/SKILL.md)，由不产出的研发总监执行（执行者与判门者不同源）；客观验证能机器化就升级到 CI 硬门禁（见 [`../../skills/multica-gate-setup/`](../../skills/multica-gate-setup/)）。
**门禁锚定产物而不是角色**：Issue 的「涉及端」决定路由，缺失角色对应产物跳过、门禁链不断——无设计 / 无前端 / 无后端 / 全栈都是同一套指令的排列组合。
路由逻辑只写一次（小队），不复制进每个 智能体；每个 智能体 职责很窄，可以原样照搬。

## 常见失败

- 给每个 智能体 都塞一遍完整流程 → 冗余且互相矛盾。
- 让产出者自己判自己「通过」→ 作者会本能地为自己找理由，等于没查。
- 需求没写验收标准 / 没勾「涉及端」就开工 → 小队会卡在 G0，等于白跑。
