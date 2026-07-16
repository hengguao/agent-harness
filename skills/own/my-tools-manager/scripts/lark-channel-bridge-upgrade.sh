#!/usr/bin/env bash
set -euo pipefail

BRIDGE_SRC="${BRIDGE_SRC:-$(pwd)}"
PROFILE="${PROFILE:-}"
FORK_REMOTE="${FORK_REMOTE:-origin}"
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"
DEVELOP_BRANCH="${DEVELOP_BRANCH:-develop}"
SCRIPT_PATH="${BASH_SOURCE[0]}"

cd "$BRIDGE_SRC"

if [[ ! -f package.json ]] || ! node -e "process.exit(require('./package.json').name === 'lark-channel-bridge' ? 0 : 1)" >/dev/null 2>&1; then
  echo "当前目录不是 lark-channel-bridge 源码。请在源码目录运行，或设置 BRIDGE_SRC。"
  exit 10
fi

restart_bridge() {
  if [[ -n "$PROFILE" ]]; then
    lark-channel-bridge restart --profile "$PROFILE"
    lark-channel-bridge status --profile "$PROFILE"
  else
    lark-channel-bridge restart
    lark-channel-bridge status
  fi
}

if [[ "${1:-}" == "--continue" ]]; then
  git diff --check
  if git diff --name-only --diff-filter=U | grep -q .; then
    echo "仍有未解决冲突，先解决冲突后再继续。"
    exit 20
  fi

  git add -A
  git commit --no-edit

  pnpm install
  pnpm test
  pnpm typecheck
  pnpm build

  git push "$FORK_REMOTE" "$DEVELOP_BRANCH"
  git pull --ff-only "$FORK_REMOTE" "$DEVELOP_BRANCH"

  npm install -g .

  lark-channel-bridge --version
  lark-channel-bridge --help >/dev/null
  command -v lark-channel-bridge
  restart_bridge
  lark-channel-bridge ps
  exit 0
fi

git status --short --branch
if [[ -n "$(git status --porcelain)" ]]; then
  echo "工作区存在未提交改动，先确认或提交后再升级。"
  exit 10
fi

git fetch --prune "$FORK_REMOTE" "$MAIN_BRANCH" "$DEVELOP_BRANCH"
git fetch --prune "$UPSTREAM_REMOTE" "$MAIN_BRANCH"

git switch "$MAIN_BRANCH"
git pull --ff-only "$FORK_REMOTE" "$MAIN_BRANCH"
git merge --ff-only "$UPSTREAM_REMOTE/$MAIN_BRANCH"
git push "$FORK_REMOTE" "$MAIN_BRANCH"
git fetch --prune "$FORK_REMOTE" "$MAIN_BRANCH"

git switch "$DEVELOP_BRANCH"
git pull --ff-only "$FORK_REMOTE" "$DEVELOP_BRANCH"
if ! git merge "$FORK_REMOTE/$MAIN_BRANCH"; then
  echo "merge 冲突已进入工作区。解决冲突后执行："
  echo "BRIDGE_SRC=\"$BRIDGE_SRC\" PROFILE=\"$PROFILE\" FORK_REMOTE=\"$FORK_REMOTE\" UPSTREAM_REMOTE=\"$UPSTREAM_REMOTE\" bash \"$SCRIPT_PATH\" --continue"
  exit 20
fi

pnpm install
pnpm test
pnpm typecheck
pnpm build

git push "$FORK_REMOTE" "$DEVELOP_BRANCH"
git pull --ff-only "$FORK_REMOTE" "$DEVELOP_BRANCH"

npm install -g .

lark-channel-bridge --version
lark-channel-bridge --help >/dev/null
command -v lark-channel-bridge
restart_bridge
lark-channel-bridge ps
