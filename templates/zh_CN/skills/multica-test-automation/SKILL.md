---
name: multica-test-automation
description: 测试专家 T3 自动化：G2.5 部署环境就绪后，用 Apifox CLI 执行场景用例。Python 封装，Windows / Linux 通用。
metadata:
  credentials:
    priority:
      - APIFOX_ACCESS_TOKEN
  runtime:
    python: ">=3.10"
    external:
      - apifox-cli  # npm install -g apifox-cli
---

# 测试自动化（Apifox CLI · T3）

## 用途

测试专家 **T3**：G2.5 拿到 `deploy_base_url` 后，用 Apifox CLI 跑自动化并产出 G3 输入。

> **跨平台**：`python scripts/run_apifox.py`；Apifox 本体为 Node CLI（`npm install -g apifox-cli`），Windows / Linux 相同。

## 安装

```bash
pip install -r scripts/requirements.txt
npm install -g apifox-cli
```

## 流程

```bash
set APIFOX_ACCESS_TOKEN=<token>

python scripts/run_apifox.py \
  --issue <JIRA_ISSUE_KEY> \
  --base-url "https://sit-projectmanagement.example.com" \
  --scenario-id <APIFOX_SCENARIO_ID> \
  --environment-id <APIFOX_ENV_ID> \
  --json
```

或仅指定 Issue（从 `config.yaml` 读 scenario / environment）：

```bash
python scripts/run_apifox.py --issue <JIRA_ISSUE_KEY> --base-url "%DEPLOY_URL%" --json
```

## 为什么有效

Python 负责配置与 subprocess 调用 Apifox；不依赖 bash，与 测试专家 T3 在 Windows 开发机上可直接跑通。

