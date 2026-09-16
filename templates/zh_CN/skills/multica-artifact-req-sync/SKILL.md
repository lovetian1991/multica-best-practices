---
name: multica-artifact-req-sync
description: PRD 产物编排：调用 multica-platform-opencontent 上传、更新和读取需求文件，并回传稳定内链。
metadata:
  orchestrates:
    - multica-platform-opencontent
---

# 产物 · 需求同步（编排）

## 用途

本 Skill 只负责把唯一的功能 PRD 文件交给 `multica-platform-opencontent`。Issue 标题、状态、负责人、排期、metadata、property 和评论由 Multica 自身负责，不调用 Jira。

产品设计小队维护一份稳定命名的 `prd-<功能名称>.md`。首次发布上传文件，产品经理、UI/UE设计师或技术架构师每次补写后都必须通过本 Skill 更新同一文件；OpenContent 自己维护版本，业务流程不读取历史版本。

## 流程

```text
1. multica-requirement-analysis  — 结构化 PRD
2. multica-artifact-req-sync     — 上传/更新 PRD 并回传 internal_link
3. Multica Issue API              — 写入 metadata 和发布评论
```

UI / UX 或技术章节补写完成后，不得只回传设计平台 / 技术草稿链接；必须先把引用写回同一份 PRD，再重复执行本 Skill 更新知识库，并把最新 `internal_link`、metadata patch 和 comment 交给编排器写回 Issue。

补写同步的固定顺序：重新读取 Issue 最新状态和 metadata → 用最新 `internal_link` 取回当前 PRD → 只追加本角色负责的章节 → 保持原文件名并通过 `--reference` 更新 → 写回 Issue metadata/comment。任一步失败都返回 `BLOCKED`，不得进入最终评审或交接。

发布一个文件：

```bash
python "$MULTICA_SKILLS_ROOT/multica-platform-opencontent/scripts/publish-artifact.py" \
  --type requirement \
  --file docs/requirements/<ISSUE-KEY>/prd-<功能名称>.md --json
```

如果 Issue metadata 中已有 `artifact_requirement_file_id` 或 `artifact_requirement_internal_link`，通过 `--reference` 传入；没有时平台层会在唯一同名文件上自动更新，多候选则 `BLOCKED`。

## 交接要求

发布命令返回 `internal_link`、`file_id`、`file_guid`、`folder_id`、`metadata_patch` 和 `comment`。编排器必须把 metadata patch 和 comment 写入当前 Multica Issue；任一写入失败都返回 `BLOCKED`，不能宣称当前 PRD 更新或产品设计阶段完成。

下游读取时原样使用 `internal_link`，或调用：

```bash
oc-basic download url="<OPENCONTENT_INTERNAL_LINK>" outputPath="<local-dir>"
```

## 内容边界

PRD 的结构和编号由 `multica-requirement-analysis` 定义。本 Skill 不改变 G-/KPI-/FR-/BR-/AC-/OP-/RISK- 规范，也不创建 UI PRD、技术 PRD 等并列最终文件。
