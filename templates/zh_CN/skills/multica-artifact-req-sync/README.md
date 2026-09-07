# multica-artifact-req-sync

PRD 文件编排 Skill：调用 `multica-platform-opencontent` 上传或更新文件，并回传 `internal_link`。Issue 数据和评论保存在 Multica，不依赖 Jira。

## 快速开始

1. 挂载本目录和 `multica-platform-opencontent`，设置 `MULTICA_SKILLS_ROOT`。
2. 配置平台 Skill 的 `OC_CLI_PATH`、`MULTICA_SERVER_URL` 和 `OPENCONTENT_APIKEY`。
3. 在 `multica-platform-opencontent/config.yaml` 设置根目录和允许列表。

```bash
python "$MULTICA_SKILLS_ROOT/multica-platform-opencontent/scripts/publish-artifact.py" \
  --type requirement --workspace <WORKSPACE_SLUG> --issue <ISSUE-KEY> \
  --file docs/requirements/<ISSUE-KEY>/prd-login.md \
  --root-folder-id <ROOT_FOLDER_ID> --json
```

返回 JSON 中的 `metadata_patch` 写入 Issue metadata，`comment` 追加为 Issue 评论。更新固定使用 `fileModel=UPDATE` 和 `strategy=majorUpgrade`。
