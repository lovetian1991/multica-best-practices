---
name: multica-artifact-cicd-sync
description: CI/CD 产物编排：G2 PASS 且代码已 push 后调用 multica-platform-jenkins 触发 dev/sit 构建，回写 JIRA 并回传部署 URL。Python 实现，Windows / Linux 通用。
metadata:
  orchestrates:
    - multica-platform-jenkins
    - multica-platform-jira
  runtime:
    python: ">=3.10"
---

# 产物 · CI/CD 同步（编排）

## 用途

G2 PASS + push 后，调用 `multica-platform-jenkins` 触发 dev/sit Job。**参数由 Jenkins API 自动发现**，编排层不硬编码参数名。

## 智能体 流程

```text
1. discover-only（推荐先跑，检查 missing）：
   python scripts/trigger_cicd.py --issue <ISSUE_KEY> --env sit --branch release/<ISSUE_KEY>-slug --discover-only --json
2. 触发（**只用 Issue deploy branch，不用 feature 分支**）：
   python scripts/trigger_cicd.py --issue <ISSUE_KEY> --env sit --branch release/<ISSUE_KEY>-slug --json
3. missing 参数：追加 --param name=value（trigger_cicd 需扩展传参时走 trigger_env --param）
```

## 参数解析策略

默认（`use_last_success=true`）：

1. 读取 `lastSuccessfulBuild` 的全部构建参数
2. **仅**将分支类参数（branchName / branch / gitBranch …）替换为 `--branch`
3. `--param` 可覆盖任意项；`--no-last-success` 关闭此行为

---

## 流程 A：dev 部署

```bash
python scripts/trigger_cicd.py \
  --issue <ISSUE_KEY> \
  --env dev \
  --service <service> \
  --branch release/<ISSUE_KEY>-slug \
  --json
```

## 流程 B：sit 部署（G2.5 → 测试专家 T3）

```bash
python scripts/trigger_cicd.py \
  --issue <ISSUE_KEY> \
  --env sit \
  --branch release/<ISSUE_KEY>-slug \
  --json
```

`<ISSUE_PREFIX_A>` / `<ISSUE_PREFIX_B>` / `<ISSUE_PREFIX_C>` / `<ISSUE_PREFIX_D>` 等前缀已在 `config.yaml` → `issue_service_map` 配置，可省略 `--service`。

## 流程 C：多服务

```bash
python scripts/trigger_cicd.py --env sit --service <service1>,<service2> --branch release/<ISSUE_KEY>-xxx --json
```

## 用法（角色侧）

```text
G2 PASS 且代码已 push 后，用 multica-artifact-cicd-sync 触发 Jenkins 并回传部署链接。
```

## 为什么有效

编排层只依赖 Python；Issue 前缀自动映射到 `jobs-catalog.yaml` 中的 logical service。



