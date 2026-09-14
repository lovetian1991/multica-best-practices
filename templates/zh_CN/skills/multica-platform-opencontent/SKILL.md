---
name: multica-platform-opencontent
description: 通过本 Skill 内置的 oc.js 管理 Multica 协作产物的目录、上传、更新、内链和下载。用于 artifact-sync，不依赖其他 Skill。
---

# OpenContent 产物平台

本 Skill 是 artifact-sync 与内置 `cli/bin/oc.js` 之间的薄适配层。它只负责协作文件；Issue 标题、状态、负责人、排期、metadata、property 和评论仍由 Multica 自身保存。

## 能力边界

- 允许的底层命令：`folder-info`、`file-list`、`create-folder`、`upload`、`file-info`、`file-internal-link`、`download`。
- 不直接调用 OpenContent REST API，不拼接 URL，不维护 token。
- 不读取历史版本，不使用 `fileVerId`，不调用 `download ver_id=...`。
- `publish-artifact.py` 每次只处理一个文件；多个产物使用 `publish-artifacts.py`，由平台层内部循环调用单文件发布并保留每项结果。

## 配置

本 Skill 已内置 `cli/bin/oc.js`，脚本默认直接使用这份 CLI，不依赖其他 Skill。后续更新 CLI 时，直接覆盖本目录的 `cli/bin/oc.js` 即可。

复制 `.env.example` 到运行环境（不要提交 `.env`）。如需临时使用其它 CLI，可通过 `OC_CLI_PATH` 或 `OPENCONTENT_CLI_PATH` 指向兼容的 `oc.js` 可执行命令；未设置时始终使用本 Skill 内置 CLI。
运行时注入 `MULTICA_SERVER_URL`、`OPENCONTENT_APIKEY` 和当前 Issue 的 `MULTICA_KB_FOLDER_ID`。其中 `MULTICA_KB_FOLDER_ID` 自动作为 `artifact-root-folder`，优先级高于配置文件默认值；只有需要人工覆盖时才传 `--root-folder-id`。

`config.yaml` 的根目录只是默认值。运行时根目录优先级为：`--root-folder-id`、`MULTICA_KB_FOLDER_ID`、Issue metadata/property、配置默认值。所有值都必须出现在 `allowed_root_folder_ids`，并先通过 `folder-info`。

## 发布流程

```bash
python scripts/publish-artifact.py \
  --type requirement --workspace <workspace-slug> --issue <ISSUE-KEY> \
  --file docs/requirements/<ISSUE-KEY>/prd-login.md --json
```

脚本按 `<root>/<workspace>/<issue>/<artifact-type>` 建立目录。固定文件名首次使用 `fileModel=UPLOAD`；若 Issue metadata 已有文件引用，或目标目录中同名文件只有一个，自动使用 `fileModel=UPDATE strategy=majorUpgrade`。同名候选超过一个时返回 `BLOCKED`，不自动选择。

发布后脚本会调用 `file-internal-link`，输出真实 `internal_link`、`file_id`、`file_guid`、`folder_id`、metadata patch 和 comment 文本。上游必须把 metadata patch 和 comment 写入 Multica Issue；写入失败时阶段不得报告 PASS。

## 读取流程

```bash
python scripts/fetch-artifact.py \
  --internal-link "<OPENCONTENT_INTERNAL_LINK>" \
  --output docs/requirements/<ISSUE-KEY> --json
```

`internal_link` 是跨角色传递的主引用，也可以原样传给内置 `oc.js download url=...`。使用 `url` 时不要同时传 `fileIds`、`ver_id` 或 `folderIds`。

## 底层 CLI 约束

首次调用任一普通 `oc.js` 子命令前，必须先运行该命令的 `--help`。命令返回后先按实际 JSON 结构解析，再读取字段；不能猜测字段、伪造 URL 或把非 200 下载响应当成成功。
