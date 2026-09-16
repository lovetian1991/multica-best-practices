---
name: multica-artifact-design-sync
description: 将技术设计 Markdown 上传或更新到 OpenContent，并回传稳定 internal_link 供实现与测试消费。
metadata:
  orchestrates:
    - multica-platform-opencontent
  landing:
    local_draft: "docs/design/<ISSUE-KEY>/design.md"
---

# 产物 · 技术设计同步

## 用途

编排本地技术设计稿到 `multica-platform-opencontent`。不调用 Confluence 或 Jira；Issue metadata 和评论由 Multica 调用方写入。

前置草稿：`docs/design/<ISSUE-KEY>/design.md`。

## 发布

```bash
python "$MULTICA_SKILLS_ROOT/multica-platform-opencontent/scripts/publish-artifact.py" \
  --type design \
  --file docs/design/<ISSUE-KEY>/design.md --root-folder-id <ROOT_FOLDER_ID> --json
```

固定文件名首次 `UPLOAD`，后续同名文件 `UPDATE + majorUpgrade`。命令返回真实 `internal_link`、文件标识、`metadata_patch` 和 `comment`；调用方必须把后两者写入 Multica Issue，失败时返回 `BLOCKED`。

下游使用返回的 `internal_link`，或原样执行 `oc-basic download url=<internal_link> outputPath=<dir>` 获取当前正文。

## 内容规范

设计稿仍按 `multica-technical-design` 输出理解、最小改动、受影响组件、实现步骤、验证计划及 RISK-。本 Skill 只负责落地和引用，不改变设计内容或门禁语义。
