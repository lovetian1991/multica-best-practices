---
name: multica-platform-confluence
description: Confluence 读写：页面拉取、PRD HTML 创建、Markdown 设计发布。平台 skill，与 JIRA 解耦；由产物编排 skill 调用。
metadata:
  credentials:
    priority:
      - ATLASSIAN_USER / ATLASSIAN_PASS
      - ATLASSIAN_USER / ATLASSIAN_PASS
      - CONFLUENCE_USER / CONFLUENCE_PASS
  landing:
    prd_parent_page_id: config confluence.default_parent_page_id
    design_parent_page_id: "<CONFLUENCE_DESIGN_PAGE_ID>"
    design_local_draft: docs/design/<ISSUE-KEY>/design.md
---

# 平台 · Confluence

## 用途

Confluence **读 + 写**能力：拉取已有页面供 智能体 消费，把 PRD / 设计等产物落地并回传**稳定页面链接**。与 `multica-platform-jira` 解耦——只负责 Confluence，不负责 JIRA 字段写入。

> 角色提示词不写 Confluence URL / pageId；换 Wiki / 语雀 / 飞书只换本 skill。

## 默认落点

| 产物类型 | Confluence 父页面 | 本地草稿（智能体 先写） |
| --- | --- | --- |
| PRD | `config.yaml` → `confluence.default_parent_page_id` | 由 `multica-requirement-analysis` 结构化后交 req-sync 编排 |
| 技术设计 | **`<CONFLUENCE_DESIGN_PAGE_ID>`**（`confluence.design_parent_page_id`） | `docs/design/<ISSUE-KEY>/design.md` |

设计文档父页面：[pageId=<CONFLUENCE_DESIGN_PAGE_ID>](http://<CONFLUENCE_URL>/pages/viewpage.action?pageId=<CONFLUENCE_DESIGN_PAGE_ID>)

## 文件

```text
multica-platform-confluence/
├── SKILL.md
├── config.yaml
├── spaces.json
├── .env.example
└── scripts/
    ├── credentials.sh
    ├── confluence.sh        # Read/Write CLI
    ├── fetch_page.py        # Confluence → local Markdown
    ├── publish_design.py    # Markdown 设计 upsert
    ├── lib/md_to_confluence.py
    ├── lib/html_to_md.py
    ├── lib/resolve_skills.sh
    ├── requirements.txt
    └── templates/
        ├── prd-template.md
        └── design-template.md
```

## 读取（下游 / 对应小队负责人拉取上游产物）

```bash
# 按 pageId 拉取为 Markdown（可选写入 docs/design/<ISSUE-KEY>/ 或自定义目录）
bash scripts/confluence.sh fetch-page <page_id> [output_dir] [jira_key]

# 获取页面元数据 / 原始 storage（调试）
bash scripts/confluence.sh get-page <page_id>

# 按标题搜索
bash scripts/confluence.sh find-page "<title>" [space_key]
```

**典型链路**：JIRA Issue 描述含 Confluence 链接 → 用 `multica-platform-jira` 的 `get-confluence-url` 解析 pageId → 本 skill `fetch-page` 拉取 PRD / 设计正文。

## 写入（产物落地）

### PRD 页面（HTML）

```bash
bash scripts/confluence.sh create-page "<title>" "<parent_page_id>" "<html>" "<space_key>"
```

由 `multica-artifact-req-sync` 编排调用；Confluence 不可用时见 req-sync 流程 E（全文降级到 JIRA 描述）。

### 技术设计（Markdown → Confluence）

1. @技术架构师 用 `multica-technical-design` 写本地：`docs/design/<ISSUE-KEY>/design.md`（基线见 `scripts/templates/design-template.md`）。
2. 发布到设计父页面下：

```bash
pip install -r scripts/requirements.txt   # 首次；可选 pip install markdownify 提升 HTML→MD 质量
python scripts/publish_design.py <ISSUE-KEY> docs/design/<ISSUE-KEY>/design.md \
  [--space SPACE] [--parent PAGE_ID] [--title "标题"] [--json]
```

3. 回传 JSON 中的 `url` / `page_id`；`multica-artifact-design-sync` 再调用 `multica-platform-jira` 把链接写入 JIRA。

**Upsert 规则**：同 space + 同 title 则更新版本；title 自动加 `[AI]` 后缀。

## 智能体兼容性

- 凭据优先级见 frontmatter `metadata.credentials`；禁止打印密码。
- 外部写入前确认：space、parent pageId、标题。
- 优先用 `scripts/`，不要裸调 REST。
- 编排脚本通过 `MULTICA_SKILLS_ROOT` 或同级 `templates/skills/` 定位本 skill（见 `scripts/lib/resolve_skills.sh`）。

## 适配新团队

1. 改 `config.yaml`：`confluence.url`、`default_space`、`*_parent_page_id`。
2. 设计文档父页面 ID 改为团队 Confluence 目录页。
3. 新项目追加 `projects.<JIRA-PREFIX>.confluence_space` / `design_parent_page_id`。
4. 空间列表维护在 `spaces.json`。

## 为什么有效

Confluence 认证、space、父页面各团队不同；独立 platform skill 后，JIRA / 钉钉 / Git 变更不影响 Confluence 脚本，PRD 与设计共用同一套读写能力。


