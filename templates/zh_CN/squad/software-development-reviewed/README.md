# 软件开发评审小队

在 `software-development` 基础上，为**除通用小队负责人、部署运维专家 外的每个常规产出角色**配备**专属评审员**，形成「通用门禁 + 专业产出物评审」两层质量保证。

## 什么时候用

- 你需要的不只是「流程走完了」，还要「产物本身专业、经得起推敲」。
- 团队对架构设计、UI、需求、前端/后端实现、测试产物有较高的专业把关要求。
- 希望专业评审意见**独立于实现者**，并由 通用小队负责人 统一收敛、指派修改、循环复审。

如果你只想要轻量流程，用 `software-development`（仅通用小队负责人触发 multica-verification 通用门禁即可）。

## 与 software-development 的差异

| 维度 | software-development | software-development-reviewed |
| --- | --- | --- |
| 门禁层数 | 1 层：通用小队负责人通用门禁（multica-verification） | 2 层：通用门禁 + 专属评审员 专业评审 |
| 业务评审 定位 | 仅 G1 业务评审（单点） | 每角色专属评审员，做 per-artifact 专业评审 |
| 评审触发 | 通用小队负责人触发 | 通用小队负责人在通用门禁 PASS 后派发 |
| 评审结论去向 | 直接进设计判门 | 汇报通用小队负责人 → 通用小队负责人指派作者修改 → 复审（≤3 轮） |
| 适用场景 | 通用协作 | 高专业把关要求 |

## 角色与专属评审员 映射

| 产出角色 | 专属评审员 | 评审 Skill | 评审关注点 |
| --- | --- | --- | --- |
| @产品经理（PRD） | @产品评审 | multica-review-product | 范围/目标/验收标准是否清晰可测、是否遗漏关键约束 |
| @技术架构师（设计） | @架构评审 | multica-review-architect | 架构合理性、扩展性、与验收对齐、技术风险 |
| @UI/UE设计师（UI） | @设计评审 | multica-review-designer | 交互合理性、可访问性、与设计系统/验收一致 |
| @前端开发专家（前端实现） | @前端评审 | multica-review-frontend | 与 UI/API 契约吻合度、组件质量、单测是否合理充分 |
| @后台开发专家（后端实现 + API 契约） | @后端评审 | multica-review-backend | 契约质量、与设计吻合度、错误处理、单测是否合理充分 |
| @测试专家（用例 / 测试报告） | @测试评审 | multica-review-test | 用例覆盖深度、覆盖率文档合理性、与验收逐条对应 |

> 通用小队负责人 与 部署运维专家 **不配**专属评审员：通用小队负责人 是编排者（既判门又评审会同源）；部署运维专家 产出是部署 URL，已由 CI 硬门禁覆盖。

## 两层门禁怎么走

```
产出角色完成产物
   → 通用小队负责人通用门禁：multica-verification skill 复跑验收标准/流程（只管对不对）
   → 若 PASS：派对应专属评审员 用 multica-review-* skill 做专业分析（只管专不专业）
       → 若评审 PASS：产物放行，推进下一阶段
       → 若评审 FAIL：专属评审员 输出结论+修改清单，汇报通用小队负责人
            → 通用小队负责人指派对应产出角色修改
            → 修改完再审专属评审员（同一人）
            → 最多 3 轮；第 3 轮仍不通过 → 升级人类判定
   → 若 FAIL：退回作者，按通用门禁 FAIL 计数（连续 3 次升级人类）
```

两层任一 FAIL 都退回，**轮次独立计数但共用「3 次上限」阈值**。

## 关键约束

- 专属评审员 **不代替作者修改**，只输出结论与修改清单，并汇报给通用小队负责人。
- 通用小队负责人 **不得用自己的评审结论替代通用门禁**，也不得代替专属评审员批准。
- 专属评审员 与产出角色**不同源**；同一产物复审必须由同一专属评审员 执行。
- 其余路由 / 阶段门禁 / 证据 / 失败处理 / 升级人类规则，与 `software-development` 完全一致。

## 配套文件

- `squad.md`：完整 小队指令（含两层门禁与专业评审子循环）。
- `issue.md`：Issue 模板（同 software-development，无需为评审额外增填字段）。
- 专属评审员智能体：`arch-reviewer` / `design-reviewer` / `product-reviewer` / `frontend-reviewer` / `backend-reviewer` / `test-reviewer`。
- 专属评审 Skill：`multica-review-architect` / `multica-review-designer` / `multica-review-product` / `multica-review-frontend` / `multica-review-backend` / `multica-review-test`。
