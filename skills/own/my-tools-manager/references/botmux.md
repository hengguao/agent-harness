# botmux 管理规则

## 工具信息

- 工具名：botmux
- 官方仓库：https://github.com/deepcoldy/botmux
- CLI 命令：`botmux`
- npm 包名：`botmux`
- 本机已验证版本：`2.104.0`
- 本机已验证 CLI 路径：`/opt/homebrew/bin/botmux`
- 本机已验证安装来源：npm 全局安装，实际包目录在 `/opt/homebrew/lib/node_modules/botmux`

用途：IM ↔ AI 编程 CLI 桥接，支持 daemon、会话管理、飞书消息、定时任务、workflow、skills 注入等。

## 自更新流程

使用 `工具信息` 中的官方仓库和 npm 包信息核对最新规则。

自更新时重点检查：

1. npm 包名、CLI 命令和 Node.js 要求是否变化。
2. `setup`、`start`、`stop`、`restart`、`status`、`upgrade`、`logs`、`autostart`、`skills injection` 等命令是否变化。
3. 配置目录 `~/.botmux/` 是否变化。
4. 本机安装来源是否仍是 npm 全局安装。
5. 是否新增 Homebrew 或其他官方安装方式；未确认前沿用本机 npm 来源。

## 前置条件

安装或启动前确认：

```bash
node -v
npm -v
```

如果要桥接 Claude Code、Codex CLI、Gemini CLI 等，还要确认对应 CLI 已安装并可用。

## 检查命令

```bash
command -v botmux || true
botmux --version
botmux --help
npm list -g botmux --depth=0
npm root -g
ls -l "$(command -v botmux)"
```

如果 `--version` 不可用，不要直接判定失败；用 `--help`、`command -v` 和 npm 包信息辅助验证。

## 安装来源判断

按顺序判断：

1. `npm list -g botmux --depth=0` 成功：npm 全局来源。
2. `command -v botmux` 指向 npm 全局 bin，且 symlink 进入 `node_modules/botmux`：npm 全局来源。
3. 如果指向其他路径，先确认来源；不要直接覆盖。

## 安装

默认使用 npm 全局安装，除非官方文档或用户明确要求其他来源：

```bash
npm install -g botmux
```

安装后验证：

```bash
botmux --version
botmux --help
command -v botmux
npm list -g botmux --depth=0
```

## 升级

沿用当前安装来源。

botmux 自带升级命令时可优先使用：

```bash
botmux upgrade
```

如果需要按 npm 来源升级：

```bash
npm install -g botmux@latest
```

升级后验证：

```bash
botmux --version
botmux status
```

如果 daemon 已运行，升级后按需重启：

```bash
botmux restart
botmux status
```

## 重装

重装前确认是否有 daemon、autostart 和已有配置。

npm 来源：

```bash
npm uninstall -g botmux
npm install -g botmux@latest
```

不要默认删除 `~/.botmux/`。它包含 botmux 配置、机器人配置、凭证或会话相关状态。只有用户明确要求清理状态，并确认影响后，才删除或迁移。

## 常用命令

```text
botmux setup
botmux start
botmux stop
botmux restart
botmux status
botmux logs --lines 100
botmux list --plain
botmux dashboard
botmux autostart status
botmux skills injection
```

多数子命令支持：

```bash
botmux <subcommand> --help
```

## 安全规则

- 不输出或提交 `~/.botmux/` 下的密钥、token、bot 配置敏感字段或 dashboard 一次性登录 URL。
- `dashboard` 会生成新的 Web Dashboard 一次性登录 URL，并使旧 token 失效；只有用户明确要求时再执行。
- `setup`、`start`、`restart`、`autostart enable`、`upgrade` 都会改变本机或外部连接状态；用户明确要求时再执行。

## 安装位置说明

- CLI 路径：以 `command -v botmux` 为准。
- npm 全局根目录：以 `npm root -g` 为准。
- 当前本机已验证：`/opt/homebrew/bin/botmux` 指向 `/opt/homebrew/lib/node_modules/botmux/dist/cli.js`。

## 配置提醒

`botmux` 是 IM ↔ AI 编程 CLI 桥接工具，不是 MCP Server。不要默认生成 cc-switch `mcpServers` 配置，除非官方文档明确提供 MCP server 启动方式。
