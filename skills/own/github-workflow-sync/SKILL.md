---
name: github-workflow-sync
description: 创建或维护 GitHub Actions 跨仓库目录同步 Workflow。用于把源仓库中的指定目录镜像到目标仓库的指定目录，支持删除同步、无变更不提交、跨仓库 token/secret 配置、手动触发 workflow、排查 workflow scope 或 PAT 权限问题。
---

# GitHub Workflow Sync

## 核心定位

使用 GitHub Actions 把一个仓库中的目录镜像同步到另一个仓库。适合“私有仓库维护源数据，公开仓库发布最新文件”的场景。

默认保持方案简单：checkout 源仓库和目标仓库，删除目标目录，复制源目录，`git add -A`，有变更才提交并推送。

## 先确认

开始前确认这些信息：

- 源仓库和分支，例如 `hengguao/agent-engineering` 的 `master`
- 目标仓库和分支，例如 `hengguao/agent-harness` 的默认分支
- 源目录和目标目录映射，例如 `skill/own -> skills/own`
- workflow 文件位置，例如 `.github/workflows/sync-skills.yml`
- 目标仓库是否已存在
- 源仓库是否已有可写目标仓库的 secret
- workflow 是否运行在 GitHub 源仓库。GitHub Actions 只响应 GitHub 仓库事件；如果日常维护源在 Gitee，Gitee push 不会自动触发 GitHub Actions，除非另有 Gitee 到 GitHub 的同步。

## Token 和 Secret

跨仓库写入不能依赖默认 `GITHUB_TOKEN`。默认 token 通常只能写当前运行 workflow 的仓库。

推荐做法：

1. 在 GitHub 账号设置中创建 Fine-grained PAT。
2. Repository access 只选择目标仓库。
3. Repository permissions 设置 `Contents: Read and write`。
4. 把 PAT 保存到源仓库的 Actions secret，例如 `PUBLIC_REPO_TOKEN`。

secret 放在源仓库，因为 workflow 在源仓库运行，只能读取当前仓库的 secrets。PAT 的权限作用到目标仓库。

Fine-grained PAT 通常需要用户在 GitHub 页面手动创建。不要声称已创建 Fine-grained PAT，除非用户明确提供 token 或确认已创建。

区分两类 token：

- 推送 workflow 文件到 GitHub 的 token：新增或修改 `.github/workflows/*.yml` 时需要 `workflow` scope。
- workflow 运行时写目标仓库的 PAT：保存为源仓库 secret，例如 `PUBLIC_REPO_TOKEN`，需要目标仓库 `Contents: Read and write`。

## Workflow 模板

根据仓库名、分支和目录映射改下面模板：

如果用户要求“每次提交后同步”，不要加 `paths` 过滤。只有用户明确要求“仅目录变更时同步”，才添加 `paths`。

```yaml
name: Sync skills to agent-harness

on:
  push:
    branches:
      - master
  workflow_dispatch:

permissions:
  contents: read

jobs:
  sync-skills:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source repository
        uses: actions/checkout@v4
        with:
          path: source

      - name: Checkout target repository
        uses: actions/checkout@v4
        with:
          repository: owner/target-repo
          token: ${{ secrets.PUBLIC_REPO_TOKEN }}
          path: target

      - name: Sync directories
        run: |
          set -euo pipefail

          rm -rf target/skills
          mkdir -p target/skills

          cp -a source/skill/own target/skills/own
          cp -a source/skill/third target/skills/third

      - name: Commit and push changes
        working-directory: target
        run: |
          set -euo pipefail

          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

          git add -A skills

          if git diff --cached --quiet; then
            echo "No changes to sync."
            exit 0
          fi

          git commit -m "Sync skills from source repository"
          git push
```

## 实施步骤

1. 在源仓库创建或更新 `.github/workflows/<name>.yml`。
2. 按目标默认分支调整 `on.push.branches`，例如 `master` 或 `main`。
3. 按实际目录改 `rm -rf`、`mkdir -p` 和 `cp -a`。
4. 确认目标仓库存在。
5. 确认源仓库的 `PUBLIC_REPO_TOKEN` secret 存在且能写目标仓库。
6. 提交 workflow 到源仓库并推送到 GitHub。
7. 用 `workflow_dispatch` 手动触发一次。
8. 检查目标仓库是否产生同步提交。

## 验证命令

优先做轻量验证：

```bash
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/sync-skills.yml"); puts "OK"'
```

如果有 GitHub CLI：

```bash
gh workflow run sync-skills.yml -R owner/source-repo --ref master
gh run list -R owner/source-repo --workflow sync-skills.yml --limit 3
gh run view <run-id> -R owner/source-repo --json status,conclusion,url,jobs
```

检查目标仓库：

```bash
gh repo view owner/target-repo --json defaultBranchRef --jq '.defaultBranchRef.name'
gh api 'repos/owner/target-repo/contents/skills?ref=<target-branch>' --jq '.[].path'
gh api repos/owner/target-repo/commits/<target-branch> --jq '.sha + " " + .commit.message'
```

## 常见问题

- `refusing to allow an OAuth App to create or update workflow`：推送 workflow 的 GitHub token 缺少 `workflow` scope。
- `Resource not accessible by integration`：使用了默认 `GITHUB_TOKEN` 写其它仓库，改用源仓库 secret 中的 PAT。
- 源仓库在 Gitee 推送后没有触发：GitHub Actions 只监听 GitHub 上的仓库事件，先确认变更已同步到 GitHub 源仓库。
- 找不到 `Run workflow` 按钮：确认 workflow 文件已在 GitHub 的目标分支上，且包含 `workflow_dispatch`。
- 同步后旧文件还在：确认脚本先 `rm -rf` 目标目录，再复制源目录。
- 无变更也提交：确认提交前使用 `git diff --cached --quiet` 判断 staged diff。
