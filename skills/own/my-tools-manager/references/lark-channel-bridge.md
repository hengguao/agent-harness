# lark-channel-bridge 管理规则

## 工具信息

- 工具名：lark-channel-bridge
- 上游仓库：https://github.com/zarazhangrui/lark-coding-agent-bridge
- 本机定制 fork：https://github.com/hengguao/lark-coding-agent-bridge
- 中文 README：https://github.com/zarazhangrui/lark-coding-agent-bridge/blob/main/README.zh.md
- npm 包名：`lark-channel-bridge`
- CLI 命令：`lark-channel-bridge`
- npm bin：`lark-channel-bridge`
- 当前 npm latest 可用 `npm view lark-channel-bridge version` 查询
- Node 要求：`>=20.12.0`

用途：把飞书 / Lark 消息和本地 Claude Code 或 Codex CLI 打通，让用户在飞书私聊、群聊或文档评论里调用本机编程助手。

## 自更新流程

使用 `工具信息` 中的相关仓库、中文 README 和 npm 包信息核对最新规则。

自更新时重点检查：

1. Node.js 版本要求是否变化。
2. 官方原版安装命令是否仍是 `npm i -g lark-channel-bridge` / `pnpm add -g lark-channel-bridge`。
3. `npx` 是否仍只适合单次 `run`，服务层命令是否仍要求全局安装。
4. `run`、`start`、`status`、`stop`、`restart`、`unregister`、profile 命令是否变化。
5. `~/.lark-channel/` 数据目录、日志目录、secrets 文件和环境变量是否变化。
6. 权限模式映射、访问控制、lark-cli 身份策略是否变化。
7. 是否新增 MCP Server 启动方式；没有明确 MCP server 命令时，不生成 cc-switch `mcpServers` 配置。
8. 本机定制 fork 的 `develop` 分支是否仍能通过 `pnpm test`、`pnpm typecheck` 和 `pnpm build`。
9. 本机定制源码路径是否有效；无效则先确认新路径并更新本文。

## 前置条件

安装或启动前确认：

```bash
node -v
command -v claude || true
command -v codex || true
```

要求：

- Node.js `>=20.12.0`。
- 本机至少安装并登录一个 agent：Claude Code 的 `claude` 或 Codex CLI 的 `codex`。
- 有一个飞书 / Lark PersonalAgent 应用。首次启动扫码向导可以创建并绑定。

## 检查命令

```bash
command -v lark-channel-bridge || true
lark-channel-bridge --version
lark-channel-bridge --help
npm list -g lark-channel-bridge --depth=0
npm view lark-channel-bridge version bin engines repository
npm config get prefix
npm root -g
```

如果 `--version` 不可用，不要直接判定失败；用 `--help`、`command -v` 和 npm 包信息辅助验证。

## 本机源码路径

本机源码路径记录在本技能目录下的 `agent-engineering.local.yaml` 中：

```yaml
repository:
  path: /absolute/path/to/lark-coding-agent-bridge
```

执行本文命令时，先定位本机路径：

1. 读取本技能目录下的 `agent-engineering.local.yaml`。
2. 如果文件存在，确认 `repository.path` 指向有效的 `lark-coding-agent-bridge` git 仓库。
3. 如果文件不存在，或 `repository.path` 为空、路径不存在、路径不是 lark-coding-agent-bridge 仓库，先向用户确认新路径。
4. 用户确认后，更新本技能目录下的 `agent-engineering.local.yaml`，写入 `repository.path`。
5. 如果确认路径下还没有仓库，clone `https://github.com/hengguao/lark-coding-agent-bridge` 到该路径。
6. 后续执行都读取 `agent-engineering.local.yaml` 中的 `repository.path`。

然后把 `<BRIDGE_SRC>` 替换为本机实际路径，不依赖 shell 环境变量：

```text
BRIDGE_SRC=<absolute path to local lark-coding-agent-bridge checkout>
```

执行安装、升级或重装前，先确认本机定制源码存在：

```bash
test -d "<BRIDGE_SRC>"
```

## 安装来源判断

本机默认使用定制 fork 的 `develop` 分支作为安装和升级来源。即使当前全局 CLI 看起来来自 npm 官方包，也不要在这台机器上用官方 npm latest 覆盖当前定制版本，除非用户明确要求切回官方原版。

官方源码仓库只作为上游输入：先让远端定制 fork 的 `main` 同步官方仓库的 `main`，再把远端定制 fork 最新 `main` 合并到 `develop`，最终从 `develop` 构建并全局安装。

先确认全局 CLI 和定制源码：

```bash
command -v lark-channel-bridge || true
npm list -g lark-channel-bridge --depth=0
npm root -g
git -C "<BRIDGE_SRC>" status --short --branch
git -C "<BRIDGE_SRC>" remote -v
```

判断规则：

1. 默认视为本机定制来源：从本地源码 checkout 构建后 `npm install -g .`。
2. 用户提到“官方源码有新功能”时，理解为需要先同步远端定制 fork 的 `main`，再评估并合入 `develop`，不是直接安装官方 npm 包。
3. 如果全局安装来源不清楚，先用 `npm list -g`、`npm root -g` 和 `command -v` 确认；不要直接覆盖。
4. 后续定制改造都先提交到 fork 的 `develop` 分支，再从该分支构建安装；不要手改全局 `dist` 文件。
5. 如果用户明确要求安装官方原版，才使用 `npm i -g lark-channel-bridge` 或 `pnpm add -g lark-channel-bridge`。

## 安装

服务层命令必须先全局安装，不能依赖 `npx` 临时缓存。当前机器默认安装定制 fork 的 `develop` 分支。

本机定制版本：

```bash
cd "<BRIDGE_SRC>"
git switch develop
git pull --ff-only origin develop
pnpm install
pnpm test
pnpm typecheck
pnpm build
npm install -g .
```

只有用户明确要求官方原版时，才使用 npm registry：

```bash
npm i -g lark-channel-bridge
```

官方原版如需使用 pnpm：

```bash
pnpm add -g lark-channel-bridge
```

## 升级

当前机器默认从远端定制 fork `hengguao/lark-coding-agent-bridge` 的 `develop` 分支升级。官方仓库只作为上游输入：先让远端定制 fork 的 `main` 同步官方仓库 `zarazhangrui/lark-coding-agent-bridge` 的 `main`，再把远端定制 fork 最新 `main` 合并到 `develop`；本地仓库拉取远端定制 fork 的 `develop`，验证通过后从 `develop` 全局安装。

升级处理过程：

1. 进入 `<BRIDGE_SRC>`，确认工作区干净；如果有未提交改动，先停止并说明。
2. 同步远端定制 fork 的 `main`，使其跟上官方仓库的 `main`。
3. 切回 `develop`，拉取远端定制 fork 的 `develop`，再把远端定制 fork 最新 `main` 合并进来。
4. 如果没有冲突，直接安装依赖并执行验证。
5. 如果有冲突，先在源码层面解决冲突；解决后继续验证。
6. 如果解决冲突会改变官方提供的新功能，或会破坏 `develop` 上已有的本机改造能力，立即停止，不安装到全局，并说明冲突点、受影响功能和建议取舍。
7. 合并后检查 `develop` 上的改造是否仍有必要：官方已提供的能力不要重复改造；官方未提供但本机仍需要的能力，基于最新官方代码保留或重新实现。
8. 验证通过前不要安装到全局；最终只从远端定制 fork 的 `develop` 拉取后执行 `npm install -g .`。

执行升级时使用 Skill 内置脚本。先确认两个路径：

- `<SKILL_DIR>`：当前 `my-tools-manager` Skill 目录。
- `<BRIDGE_SRC>`：本机 `lark-coding-agent-bridge` 源码目录。

```bash
SKILL_DIR="<SKILL_DIR>" \
BRIDGE_SRC="<BRIDGE_SRC>" \
PROFILE="claude" \
FORK_REMOTE="origin" \
UPSTREAM_REMOTE="upstream" \
MAIN_BRANCH="main" \
DEVELOP_BRANCH="develop" \
bash "$SKILL_DIR/scripts/lark-channel-bridge-upgrade.sh"
```

默认重启 `claude` profile。只有用户主动要求其他 profile 时，才修改 `PROFILE`。
只有确认仓库远端或分支名不是 `origin` / `upstream` / `main` / `develop` 时，才修改 `FORK_REMOTE`、`UPSTREAM_REMOTE`、`MAIN_BRANCH`、`DEVELOP_BRANCH`。

如果脚本返回 `20`，说明 merge 冲突已停在源码工作区。按上面的冲突处理规则解决后继续：

```bash
SKILL_DIR="<SKILL_DIR>" \
BRIDGE_SRC="<BRIDGE_SRC>" \
PROFILE="claude" \
FORK_REMOTE="origin" \
UPSTREAM_REMOTE="upstream" \
MAIN_BRANCH="main" \
DEVELOP_BRANCH="develop" \
bash "$SKILL_DIR/scripts/lark-channel-bridge-upgrade.sh" --continue
```

只有用户明确要求升级官方原版时，才使用 npm registry：

```bash
npm i -g lark-channel-bridge@latest
```

如果后台服务已注册，升级后提醒用户重启对应 profile：

```bash
lark-channel-bridge restart --profile <name>
lark-channel-bridge status --profile <name>
```

默认 profile 可省略 `--profile`。

## 升级后处理

不要把“升级后重启”一律等同于直接 `restart`。先判断当前是不是“旧运行态 + 新 CLI”混跑，再决定是否需要显式迁移。

先做交叉检查，不只看单一命令：

```bash
lark-channel-bridge ps
pgrep -af lark-channel-bridge || true
launchctl list | rg 'lark-channel-bridge|ai\.lark-channel-bridge' || true
```

如果同时满足下面任一类特征，按“显式迁移重启”处理，不直接执行 `restart`：

1. `ps` / `status` 与系统真实运行状态不一致。
2. 根目录 `~/.lark-channel/processes.json` 里是旧 entry，缺少 `profileName`、`agentKind`。
3. `~/.lark-channel/config.json` 仍是 legacy 单配置结构，没有 `schemaVersion: 2`、`profiles`、`activeProfile`。

显式迁移重启顺序：

1. 先确认迁移目标 profile 目录不存在冲突。
2. 停掉旧 daemon，避免 v2 迁移被活动旧进程阻塞。
3. 显式执行迁移。
4. 确认 `active-profile`、`profiles/<profile>/`、`config.json.bak` 已生成，且旧 `sessions` / `workspaces` / `logs` / `media` / `secrets` 已迁走。
5. 用新版 profile 服务启动。
6. 用 `ps`、`status --profile <name>`、系统服务状态三方交叉验证。

macOS 上推荐命令顺序：

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.lark-channel-bridge.bot.plist
lark-channel-bridge migrate --profile claude --agent claude
lark-channel-bridge start --profile claude
lark-channel-bridge ps
lark-channel-bridge status --profile claude
launchctl list | rg 'lark-channel-bridge|ai\.lark-channel-bridge' || true
```

如果已经确认是 v2 正常运行态，再执行普通重启：

```bash
lark-channel-bridge restart --profile <name>
lark-channel-bridge status --profile <name>
```

## 重装

重装前必须确认安装来源、是否存在后台服务、是否需要保留 `~/.lark-channel/` 数据。

本机定制版本：

```bash
npm uninstall -g lark-channel-bridge
cd "<BRIDGE_SRC>"
git switch develop
git pull --ff-only origin develop
pnpm install
pnpm test
pnpm typecheck
pnpm build
npm install -g .
```

官方原版 npm 来源：

```bash
npm uninstall -g lark-channel-bridge
npm i -g lark-channel-bridge@latest
```

若有后台服务，先停止或注销服务：

```bash
lark-channel-bridge stop --profile <name>
lark-channel-bridge unregister --profile <name>
```

不要默认删除 `~/.lark-channel/`。它包含配置、profiles、会话、日志、secrets、附件缓存和 lark-cli 目录。只有用户明确要求清理状态，并确认影响后，才删除或迁移。

## 功能改造

当用户要求改造 `lark-channel-bridge` 功能时：

1. 先确认本机源码路径 `<BRIDGE_SRC>`，不要修改全局 npm 安装目录或 `dist`。
2. 所有代码改造都在 fork 的 `develop` 分支完成。
3. 改造前确认工作区状态；如果有未提交改动，先说明并判断是否相关。相关改动继续基于现状处理，无关改动不要回滚。
4. 如改造依赖官方新功能，先按“升级”流程把远端定制 fork 的 `main` 同步官方 `main`，再合入 `develop`。
5. 实现时优先在原代码结构上做最小必要修改，不大范围重构。
6. 改造时若发现旧逻辑和预期不一致，立即停止并回滚已修改，并向用户确认后再继续。
7. 验证顺序：优先相关测试，再执行 `pnpm typecheck`；风险较高或合并官方代码后执行 `pnpm test && pnpm typecheck && pnpm build`。
8. 验证通过后，提交并推送到远端 `develop`：

   ```bash
   git status --short
   git add <本次改动文件>
   git commit -m "<commit message>"
   git push origin develop
   ```

9. 推送成功后，从 `develop` 执行全局安装：

   ```bash
   git switch develop
   npm install -g .
   ```

10. 如果后台服务已运行，按“升级后处理”判断是否重启 profile。

## 安装位置说明

- CLI 路径：以 `command -v lark-channel-bridge` 为准。
- npm 全局根目录：以 `npm root -g` 为准。
- 全局安装后的运行文件来自 npm 全局目录；源码改造必须先进入 fork 的 `develop` 分支，再重新 `npm install -g .`。

## 首次启动和初始化

前台运行，适合首次配置和调试：

```bash
lark-channel-bridge run
```

首次运行会进入扫码向导：

1. 终端渲染二维码。
2. 用户用飞书 App 扫码。
3. 选择或创建 PersonalAgent 应用。
4. 如果终端提示，选择本次要初始化的 agent。
5. 成功后配置写入 `~/.lark-channel/config.json`。

已有 PersonalAgent app 时：

```bash
lark-channel-bridge run --app-id cli_xxx
lark-channel-bridge start --app-id cli_xxx
```

Lark 国际版应用：

```bash
lark-channel-bridge run --tenant lark
```

没有指定项目目录也可以启动。启动后可在飞书里发送 `/cd <path>` 切到实际项目。

## 后台服务

前台调试确认可收发消息后，用系统服务常驻后台：

```bash
lark-channel-bridge start
lark-channel-bridge status
lark-channel-bridge stop
```

服务层命令必须使用全局安装的 CLI，不要用 npx 临时路径。daemon 的 launchd plist / systemd unit / Windows 任务会记录 CLI 路径；如果来自 npm 临时缓存，缓存清理后 daemon 会无法启动。

profile 级服务：

```bash
lark-channel-bridge start --profile <name>
lark-channel-bridge stop --profile <name>
lark-channel-bridge restart --profile <name>
lark-channel-bridge status --profile <name>
lark-channel-bridge unregister --profile <name>
```

平台映射：

- macOS：launchd 用户代理 `ai.lark-channel-bridge.bot.<profile>`
- Linux：systemd 用户单元 `lark-channel-bridge.bot.<profile>.service`
- Windows：Task Scheduler 任务 `LarkChannelBridge.Bot.<profile>`

daemon 日志：

```text
~/.lark-channel/profiles/<profile>/logs/daemon/
```

## 多 profile

仅在需要同时连接多个 PersonalAgent 应用，或分别运行 Claude 和 Codex 时，创建多个 profile。

```bash
lark-channel-bridge start --profile claude --agent claude
lark-channel-bridge start --profile codex --agent codex
lark-channel-bridge restart --profile codex
lark-channel-bridge status --profile codex
```

profile 管理：

```bash
lark-channel-bridge profile create claude --agent claude
lark-channel-bridge profile create codex --agent codex
lark-channel-bridge profile list
lark-channel-bridge profile use <name>
lark-channel-bridge profile remove <name>
lark-channel-bridge profile remove <name> --purge --yes
lark-channel-bridge profile export <name> [--output ./profile.json] [--force]
lark-channel-bridge profile export <name> --include-secrets --yes
```

`profile remove` 默认归档本地状态；只有 `--purge --yes` 才永久删除。`profile export` 默认脱敏 app secret；只有 `--include-secrets --yes` 才导出敏感配置。

## 常用宿主命令

```text
lark-channel-bridge run [--profile <name>] [--agent claude|codex] [--workspace <path>] [-c <config>]
lark-channel-bridge migrate [--profile <name>] [--agent claude|codex]
lark-channel-bridge ps
lark-channel-bridge kill <id|#>
lark-channel-bridge --help
```

## 飞书内命令

常用斜杠命令：

```text
/new 或 /reset
/cd <path>
/ws list
/ws save <name>
/ws use <name>
/ws remove <name>
/resume
/status
/config
/invite user @某人
/invite admin @某人
/invite group
/invite all group
/remove user @某人
/remove admin @某人
/remove group
/stop
/timeout [N|off|default]
/ps
/exit <id|#>
/reconnect
/doctor [描述]
/help
```

私聊不需要 @。群和话题群默认必须 `@bot`；`@all` 会被忽略。支持的云文档评论里 @bot 会触发回复。

## lark-cli 身份策略

每个 profile 使用自己的 lark-cli 目录：

```text
~/.lark-channel/profiles/<profile>/lark-cli
```

agent 子进程会收到 `LARKSUITE_CLI_CONFIG_DIR`，所以一个 profile 里的个人授权不会共享给另一个 profile。

默认策略是 `bot-only`：lark-cli 使用应用 / bot 身份，不访问个人资源。当用户为了日历、邮箱、云盘等个人资源完成授权后，当前 profile 可切到 `user-default`。

## 工作目录和权限模式

每个 profile 可有默认工作目录 `workspaces.default`。新建 profile 时可传：

```bash
lark-channel-bridge start --workspace <path>
```

bridge 会拒绝 `/`、Home 根、系统目录或临时目录根等过大范围。工作目录只是 agent run 的当前目录，不是文件系统 sandbox。

权限映射：

| Bridge access | Claude permission mode | Codex mode |
|---|---|---|
| `full` | `bypassPermissions` | `danger-full-access` |
| `workspace` | `acceptEdits` | `workspace-write` |
| `read-only` | `plan` | `read-only` |

新 profile 默认 `permissions.defaultAccess` 和 `permissions.maxAccess` 都是 `full`。如需收紧，可改成 `workspace` 或 `read-only`，但本地工具执行、登录授权流程、文件写入能力可能受限。

## 数据目录

默认状态目录：

```text
~/.lark-channel/
```

关键路径：

```text
~/.lark-channel/config.json
~/.lark-channel/active-profile
~/.lark-channel/profiles/<profile>/sessions.json
~/.lark-channel/profiles/<profile>/sessions.json.catalog.json
~/.lark-channel/profiles/<profile>/workspaces.json
~/.lark-channel/profiles/<profile>/secrets.enc
~/.lark-channel/profiles/<profile>/lark-cli/
~/.lark-channel/profiles/<profile>/media/
~/.lark-channel/profiles/<profile>/logs/
~/.lark-channel/registry/processes.json
~/.lark-channel/registry/locks/
```

可用环境变量迁移状态目录：

```bash
LARK_CHANNEL_HOME=/path/to/state lark-channel-bridge start
```

日志保留：

```bash
LARK_CHANNEL_LOG_DAYS=14 lark-channel-bridge start
```

## 访问控制和安全

- 默认只有创建 / 拥有 PersonalAgent 应用的人能使用 bot。
- 允许同事私聊：`/invite user @某人`
- 允许当前群：`/invite group`
- 添加管理员：`/invite admin @某人`
- 移除访问：使用 `/remove ...`
- 配置下一条消息生效；手改配置后需要重启或 `/reconnect`。

安全注意：

- 该工具把飞书消息接入本机 Claude/Codex，可能触发读文件、改代码、执行工具等行为。
- 不要把含敏感权限的 bot 暴露到不可信群。
- 不要输出或提交 `~/.lark-channel/profiles/<profile>/secrets.enc`、导出的 secrets、App Secret、token 或 cookie。
- `profile export --include-secrets --yes` 会导出敏感配置，只有用户明确要求时才执行。
- 删除 profile 或清理状态前，必须明确影响范围。

## 遥测

默认不上报任何数据。只有用户主动设置 `LARK_CHANNEL_TELEMETRY_MODULE` 时才加载外部遥测模块：

```bash
LARK_CHANNEL_TELEMETRY_MODULE=your-telemetry-package lark-channel-bridge start
```

## cc-switch MCP 配置提醒

`lark-channel-bridge` 是飞书消息到本地 Claude Code / Codex CLI 的桥接 bot，不是 MCP Server。不要默认生成 cc-switch `mcpServers` 配置。

如果用户问 MCP：

- 说明它通过飞书消息驱动本机 agent，不通过 MCP stdio 暴露工具。
- 只有 README 或官方文档明确提供 MCP server 启动方式时，才生成 MCP 配置。
- 当前规则只管理安装、运行、后台服务、profile 和数据目录。
