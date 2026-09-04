---
name: multica-platform-jira
description: JIRA 读写：Issue 查询、Confluence 链接解析、Story 创建、流转、排期、描述回写、钉钉。平台 skill，与 Confluence 解耦。
metadata:
  credentials:
    priority:
      - ATLASSIAN_USER / ATLASSIAN_PASS
      - ATLASSIAN_USER / ATLASSIAN_PASS
      - JIRA_USER / JIRA_PASS
---

# 平台 · JIRA

## 用途

JIRA **读 + 写**能力：查询 Issue、从描述解析 Confluence 链接；写入 Story、状态流转、排期、**描述追加**（回写 Confluence 链接）、钉钉通知。与 `multica-platform-confluence` 解耦。

## 文件

```text
multica-platform-jira/
├── SKILL.md
├── config.yaml
├── .env.example
└── scripts/
    ├── credentials.sh
    ├── jira.sh
    └── validate.sh
```

## 读取（拉取 Issue / 定位上游 Confluence）

```bash
# Issue 详情（summary、description、fields）
bash scripts/jira.sh get-issue <ISSUE-KEY>

# 从 Issue 描述 / 远程链接解析 Confluence URL 或 pageId
bash scripts/jira.sh get-confluence-url <ISSUE-KEY> [text|json]

# JQL 搜索
bash scripts/jira.sh search "<JQL>" [max_results]
```

**典型链路**：`get-issue` 读验收标准 → `get-confluence-url` 取 PRD pageId → `multica-platform-confluence` `fetch-page` 拉正文。

## 写入（产物 / 工作流写入）

```bash
# 创建 Story（PRD 编排由 multica-artifact-req-sync 调用）
bash scripts/jira.sh create-story --project AAI --summary "..." ...

# 状态流转
bash scripts/jira.sh get-transitions <JIRA_ISSUE_KEY>
bash scripts/jira.sh transition <JIRA_ISSUE_KEY> 已评审

# 排期
bash scripts/jira.sh schedule <JIRA_ISSUE_KEY> <test_owner> 2026-05-28 2026-06-05

# 追加设计文档链接到描述（design-sync 编排调用）
bash scripts/jira.sh append-description <ISSUE_KEY> $'h3. 设计文档 (Design Document)\n* [分片上传设计 [AI]|http://confluence.../pages/viewpage.action?pageId=...]\n'

# 钉钉通知
bash scripts/jira.sh notify-story <JIRA_ISSUE_KEY> <confluence_page_id> aai
```

## JIRA Wiki 描述格式

追加块使用 Jira Wiki（非 Markdown）：`h3.` 标题、`*` 列表、`[text|url]` 链接。大括号需转义 `\{\}`。

## 流程 E：Confluence 阻塞降级（PRD）

Confluence 创建失败时，`multica-artifact-req-sync` 可将 PRD 全文写入 JIRA Story 描述（本 skill `create-story` / `append-description`），并标注「Confluence 降级」；恢复后再补建 Confluence 页面并更新描述链接。

## 与产物 skill 的关系

| 编排 skill | 调用本 skill |
| --- | --- |
| `multica-artifact-req-sync` | create-story / transition / schedule / notify / get-issue |
| `multica-artifact-design-sync` | append-description（回写设计 Confluence 链接） |

## 适配新团队

改 `config.yaml` 中 `jira.url`、`projects.*.fields`、field_options、`defaults`、`dingtalk.project_webhook_map`。

## 为什么有效

JIRA 自定义字段各团队差异大，独立 platform skill 后 Confluence / 设计发布变更不影响 JIRA 脚本；读写分离后对应小队负责人 / 技术架构师可稳定从 Issue 定位上游 Confluence 产物。



