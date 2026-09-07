---
name: multica-artifact-api-sync
description: 将 API 契约 Markdown/JSON 上传或更新到 OpenContent，并回传稳定 internal_link 供前端和测试消费。
metadata:
  orchestrates:
    - multica-platform-opencontent
---

# 产物 · API 契约同步

API 契约至少包含端点、请求/响应 schema、错误码、鉴权、状态机边界及 BR- 追溯。把契约写入本地文件后，使用 `multica-platform-opencontent` 的 `--type api` 发布。

```bash
python "$MULTICA_SKILLS_ROOT/multica-platform-opencontent/scripts/publish-artifact.py" \
  --type api --workspace <WORKSPACE_SLUG> --issue <ISSUE-KEY> \
  --file docs/api/<ISSUE-KEY>/api-contract.md --root-folder-id <ROOT_FOLDER_ID> --json
```

同名目标自动 `UPDATE + majorUpgrade`；下游使用返回的真实 `internal_link` 或 `oc-basic download url=...` 读取当前正文。Issue metadata 和评论由 Multica 调用方保存。
