# multica-artifact-req-sync

PRD 落地编排 skill：调用 **`multica-platform-confluence`** + **`multica-platform-jira`**，不重复维护 REST 脚本。

## 快速开始

1. 复制本目录 + 两个平台层技能到 Multica 技能目录（或设置 `MULTICA_SKILLS_ROOT` 指向 `templates/skills/`）。
2. 配置凭据（workspace 域账号优先）：

```bash
cp ../multica-platform-confluence/.env.example ../multica-platform-confluence/.env
cp ../multica-platform-jira/.env.example ../multica-platform-jira/.env
```

3. 团队落点：
- Confluence PRD 父页面：`multica-platform-confluence/config.yaml`
- JIRA 字段 / 项目：`multica-platform-jira/config.yaml`

## 编排脚本

```bash
export MULTICA_SKILLS_ROOT="/path/to/templates/skills"
bash scripts/publish-prd.sh --project <PROJECT_A> --summary "标题" --html-file prd.html \
  -- --need-user user --background "..."
```

## 文档

见 `SKILL.md`；平台层命令详见 `multica-platform-confluence` 与 `multica-platform-jira` 的 SKILL.md（按技能名挂载，勿写死路径）。
