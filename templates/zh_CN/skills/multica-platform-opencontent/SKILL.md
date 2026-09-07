---
name: multica-platform-opencontent
description: 通过 oc-basic 管理 Multica 协作产物的目录、上传、更新、内链和下载。用于 artifact-sync，不负责 Issue 状态、字段或评论。
metadata:
  orchestrates:
    - oc-basic
---

# OpenContent 产物平台

本 Skill 是 artifact-sync 与 `oc-basic` 之间的薄适配层。它只负责协作文件；Issue 标题、状态、负责人、排期、metadata、property 和评论仍由 Multica 自身保存。

## 能力边界

- 允许的底层命令：`folder-info`、`file-list`、`create-folder`、`upload`、`file-info`、`file-internal-link`、`download`。
- 不直接调用 OpenContent REST API，不拼接 URL，不维护 token。
- 不读取历史版本，不使用 `fileVerId`，不调用 `download ver_id=...`。
- `publish-artifact.py` 每次只处理一个文件；多个产物使用 `publish-artifacts.py`，由平台层内部循环调用单文件发布并保留每项结果。

## 配置

复制 `.env.example` 到运行环境（不要提交 `.env`）。`OC_CLI_PATH` 指向 `oc-basic` 可执行命令或 `oc.js`；也可使用 `OPENCONTENT_CLI_PATH`。

`config.yaml` 的根目录只是默认值。运行时根目录优先级为：上游参数、Issue metadata、Issue property、配置默认值。所有值都必须出现在 `allowed_root_folder_ids`，并先通过 `folder-info`。

## 发布流程

```bash
python scripts/publish-artifact.py \
  --type requirement --workspace <workspace-slug> --issue <ISSUE-KEY> \
  --file docs/requirements/<ISSUE-KEY>/prd-login.md \
  --root-folder-id <ROOT_FOLDER_ID> --json
```

脚本按 `<root>/<workspace>/<issue>/<artifact-type>` 建立目录。固定文件名首次使用 `fileModel=UPLOAD`；若 Issue metadata 已有文件引用，或目标目录中同名文件只有一个，自动使用 `fileModel=UPDATE strategy=majorUpgrade`。同名候选超过一个时返回 `BLOCKED`，不自动选择。

发布后脚本会调用 `file-internal-link`，输出真实 `internal_link`、`file_id`、`file_guid`、`folder_id`、metadata patch 和 comment 文本。上游必须把 metadata patch 和 comment 写入 Multica Issue；写入失败时阶段不得报告 PASS。

## 读取流程

```bash
python scripts/fetch-artifact.py \
  --internal-link "<OPENCONTENT_INTERNAL_LINK>" \
  --output docs/requirements/<ISSUE-KEY> --json
```

`internal_link` 是跨角色传递的主引用，也可以原样传给 `oc-basic download url=...`。使用 `url` 时不要同时传 `fileIds`、`ver_id` 或 `folderIds`。

## 底层 CLI 约束

首次调用任一普通 `oc-basic` 子命令前，必须先运行该命令的 `--help`。命令返回后先按实际 JSON 结构解析，再读取字段；不能猜测字段、伪造 URL 或把非 200 下载响应当成成功。
