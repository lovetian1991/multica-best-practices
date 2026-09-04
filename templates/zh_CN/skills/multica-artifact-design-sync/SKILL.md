---
name: multica-artifact-design-sync
description: 把技术设计文档落地到 Confluence（默认父页面 <CONFLUENCE_DESIGN_PAGE_ID>）并回写 JIRA 链接。用于 @技术架构师 发布设计，供实现与测试下游消费。
metadata:
  orchestrates:
    - multica-platform-confluence
    - multica-platform-jira
  landing:
    confluence_parent_page_id: "<CONFLUENCE_DESIGN_PAGE_ID>"
    local_draft: "docs/design/<ISSUE-KEY>/design.md"
---

# 产物 · 技术设计同步

## 用途

编排 **Confluence 发布 + JIRA 描述回写**，把 @技术架构师的技术设计变成下游可引用的稳定链接。

> 平台能力在 `multica-platform-confluence` 与 `multica-platform-jira`；本 skill 只管「设计产物」编排，不换平台时不动 技术架构师 提示词。

## 前置

- 内容已通过 `multica-technical-design` 写入本地：`docs/design/<ISSUE-KEY>/design.md`
- 凭据：`ATLASSIAN_USER` / `ATLASSIAN_PASS`（见 SECURITY.md）
- 可选：`export MULTICA_SKILLS_ROOT="/path/to/templates/skills"`

## 默认落点

| 步骤 | 平台 | 位置 |
| --- | --- | --- |
| 发布 | Confluence | 父页面 **`<CONFLUENCE_DESIGN_PAGE_ID>`** 下 upsert 子页面 |
| 回写 | JIRA | Issue 描述追加「设计文档」Wiki 块 + 链接 |

设计目录页：[pageId=<CONFLUENCE_DESIGN_PAGE_ID>](http://<CONFLUENCE_URL>/pages/viewpage.action?pageId=<CONFLUENCE_DESIGN_PAGE_ID>)

## 流程（来自 dev-workflow design publish）

1. **发布 Markdown → Confluence**（同 title 则更新版本，title 加 `[AI]` 后缀）：

```bash
export MULTICA_SKILLS_ROOT="<path-to>/templates/skills"
pip install -r "$MULTICA_SKILLS_ROOT/multica-platform-confluence/scripts/requirements.txt"
python "$MULTICA_SKILLS_ROOT/multica-platform-confluence/scripts/publish_design.py" \
  <ISSUE-KEY> docs/design/<ISSUE-KEY>/design.md --json
```

2. 从 JSON 取 `url` 与 `title`。

3. **回写 JIRA 描述**：

```bash
bash "$MULTICA_SKILLS_ROOT/multica-platform-jira/scripts/jira.sh" append-description \
  <ISSUE-KEY> $'h3. 设计文档 (Design Document)\n* [<title>|<url>]\n* _Auto-published from: design.md_\n'
```

4. 向对应小队负责人回传 **Confluence 链接**（稳定引用）。

或使用本 skill 编排脚本：

```bash
bash scripts/publish-design.sh <ISSUE-KEY> docs/design/<ISSUE-KEY>/design.md
```

## 产物内容规范

依据 `multica-technical-design`：当前架构、最小改动、受影响组件、实现步骤、验证计划、风险；保留稳定标题。

## 用法（角色侧只写这一句）

> @技术架构师：「先用 `multica-technical-design` 写 `docs/design/<ISSUE-KEY>/design.md`，再用本 skill 发布到 Confluence 并回传链接。」

## 替换平台

换 Wiki / 语雀时改 `multica-platform-confluence` 实现；JIRA 回写改 `multica-platform-jira`；本 skill 编排步骤不变。

## 为什么有效

dev-workflow 已验证「本地 md → Confluence upsert → JIRA 挂链接」链路；platform skill 按名挂载 + `MULTICA_SKILLS_ROOT`，PRD / 设计 / API 文档可复用 Confluence 能力而不重复脚本。


