---
name: multica-artifact-test-sync
description: 将测试用例和测试报告文件上传或更新到 OpenContent，并回传稳定 internal_link 供验收消费。
metadata:
  orchestrates:
    - multica-platform-opencontent
---

# 产物 · 测试用例同步

用例需覆盖正常、边界、异常、空态和无权限态，并逐条对应 PRD 的 AC-。将用例和报告分别写入本地文件，单文件调用平台层：

```bash
python "$MULTICA_SKILLS_ROOT/multica-platform-opencontent/scripts/publish-artifacts.py" \
  --type test-cases \
  --file docs/test-cases/<ISSUE-KEY>/cases.md --root-folder-id <ROOT_FOLDER_ID> --json
python "$MULTICA_SKILLS_ROOT/multica-platform-opencontent/scripts/publish-artifacts.py" \
  --type test-reports \
  --file docs/test-reports/<ISSUE-KEY>/report.md --root-folder-id <ROOT_FOLDER_ID> --json
```

多个文件由本 Skill 内部逐个调用，部分失败返回 `BLOCKED` 并保留成功项。更新固定使用 `fileModel=UPDATE` 和 `strategy=majorUpgrade`；不使用 Jira、XMind 导入或历史版本读取。Issue metadata/comment 由 Multica 保存。
