---
name: multica-artifact-req-sync
description: PRD 产物编排：调用 multica-platform-confluence + multica-platform-jira 落地需求。用于 @产品经理 上传 PRD、回传链接。
metadata:
  orchestrates:
    - multica-platform-confluence
    - multica-platform-jira
  credentials:
    priority:
      - ATLASSIAN_USER / ATLASSIAN_PASS
      - ATLASSIAN_USER / ATLASSIAN_PASS
---

# 产物 · 需求同步（编排）

## 用途

**PRD 专用编排 skill**——不重复实现 Confluence / JIRA 脚本，而是调用两个独立 platform skill：

产品设计小队只维护一份按功能命名的最终 PRD 文件 `prd-<功能名称>.md`。本 skill 负责把这份文档及其后续 UI / UX、技术约束补充同步到需求平台，不为不同角色创建多份独立最终文档。

| 平台层技能 | 职责 |
| --- | --- |
| `multica-platform-confluence` | PRD HTML 页面、Markdown 设计发布、页面拉取 |
| `multica-platform-jira` | Story 创建、流转、排期、描述、钉钉、Issue 读取 |

> 内容结构由 `multica-requirement-analysis` 负责；本 skill 只编排同一份功能 PRD 文件的落地和更新。

## 单一 PRD 规则

- 产品经理 首次创建 `prd-<功能名称>.md`，并完成详细功能清单、需求设计、业务规则和 AC-。功能名称必须使用简短、稳定、可读的中文名称，例如 `用户邀请`、`订单退款`；禁止使用笼统的 `prd.md`。
- UI/UE设计师 与 技术架构师 后续按 产品总监 指定顺序补写同一份功能 PRD 文件，UI / UX 和技术章节使用稳定引用关联。
- 更新时优先更新已有 PRD 页面或其版本，不创建“UI PRD”“技术 PRD”或同一功能的同义 PRD 等并列最终文档。
- 回传给对应小队负责人的稳定链接必须指向这份合并后的功能 PRD 文件；独立设计稿或技术稿只能作为其中的引用。

## @产品经理 标准流程

```text
1. multica-requirement-analysis  — 结构化 PRD
2. multica-artifact-req-sync     — 本 skill：Confluence + JIRA + 可选钉钉
   └─ 内部调用 multica-platform-confluence + multica-platform-jira
```

## 流程 A：完整 PRD（推荐）

1. 结构化 PRD 后，创建或更新同一份功能 PRD 文件对应的 Confluence 页面（或直接调用 platform skill）：

```bash
bash scripts/confluence.sh create-page \
  "<title>" "<parent_id>" "<html>" "<space>"
# ↑ 脚本位于 multica-platform-confluence；路径由 MULTICA_SKILLS_ROOT 解析
```

2. 创建或更新 JIRA Story（描述含同一份功能 PRD 文件的 Confluence 链接）：

```bash
bash scripts/jira.sh create-story \
  --project <KEY> --summary "<title>" --description "..." ...
# ↑ 脚本位于 multica-platform-jira
```

3. 可选钉钉：`multica-platform-jira` → `notify-story`

或使用本目录编排脚本（需 platform skills 可解析）：

```bash
export MULTICA_SKILLS_ROOT="/path/to/templates/skills"   # Multica 按名挂载时建议设置
bash scripts/publish-prd.sh --project AAI --summary "..." --html-file prd.html \
  -- --need-user <user> --background "..." ...
```

## 流程 B–E

状态流转、排期、Confluence 阻塞降级（流程 E：PRD 全文写入 JIRA）等——**直接使用 `multica-platform-jira` / `multica-platform-confluence` 的 SKILL.md**，本 skill 不再重复维护。

## 配置

- PRD 父页面 / space：`multica-platform-confluence/config.yaml`
- JIRA 字段 / 项目：`multica-platform-jira/config.yaml`
- 本目录 `config.yaml` 保留团队 PRD 默认值与钉钉映射（向后兼容；新团队以 platform config 为准）

## 用法（角色侧）

```text
先用 multica-requirement-analysis 结构化 PRD，
再用 multica-artifact-req-sync 落地并回传链接。
```

## 为什么有效

JIRA 与 Confluence 拆成独立 platform skill 后，技术架构师的设计发布与 PM 的 PRD 落地共用同一套能力；编排脚本通过 skill 名称 + `MULTICA_SKILLS_ROOT` 定位，不依赖固定相对路径。

