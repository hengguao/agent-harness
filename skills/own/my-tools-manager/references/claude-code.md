# Claude Code 管理规则

## 工具信息

- 工具名：Claude Code
- 常用 CLI 命令：`claude`
- npm 包名：`@anthropic-ai/claude-code`
- 官方推荐新装方式：Native Installer 或 Homebrew cask
- 本机已知偏好：如果当前环境检测到 npm 安装，升级和重装默认沿用 npm，不自动迁移安装来源。

官方来源：

- https://code.claude.com/docs/en/quickstart
- https://code.claude.com/docs/en/setup

## 自更新流程

使用 `工具信息` 中的官方来源核对最新规则。

自更新时重点检查：

1. 官方是否仍推荐 Native Installer，或是否调整 npm/Homebrew 支持状态。
2. Node.js 版本要求是否变化。
3. macOS/Linux/Windows 安装命令是否变化。
4. 卸载或重装路径是否变化，尤其是 Native Installer 的目录。
5. `claude --version`、`claude --help` 等验证命令是否仍可用。
6. Claude Code 是否新增 MCP 配置方式；不要把 `claude` 当作 MCP Server。

保留本地策略：如果当前机器检测到 npm 安装，升级和重装默认沿用 npm，不主动迁移来源。

## 检查命令

```bash
command -v claude || true
claude --version
npm list -g @anthropic-ai/claude-code --depth=0
npm config get prefix
npm root -g
```

如系统有 Homebrew，可补充检查：

```bash
brew list --cask | rg '^claude-code$' || true
```

## 安装来源判断

按顺序判断：

1. `npm list -g @anthropic-ai/claude-code --depth=0` 成功：npm 来源。
2. `brew list --cask` 命中 `claude-code`：Homebrew cask 来源。
3. `command -v claude` 指向 `~/.local/bin/claude` 或官方 installer 目录：Native Installer 来源。
4. 无法判断时，先说明风险，不执行卸载或覆盖。

## 新装

如果用户没有指定安装来源，优先使用官方 Native Installer。

macOS / Linux / WSL：

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Windows PowerShell：

```powershell
irm https://claude.ai/install.ps1 | iex
```

Homebrew：

```bash
brew install --cask claude-code
```

npm 替代方式，要求 Node.js 18+：

```bash
npm install -g @anthropic-ai/claude-code
```

不要使用 `sudo npm install -g`。

## 升级

升级时沿用当前安装来源，不主动迁移。

npm 来源：

```bash
npm install -g @anthropic-ai/claude-code@latest
```

Homebrew 来源：

```bash
brew upgrade --cask claude-code
```

Native Installer 来源：重新运行官方 installer。

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

## 重装

重装必须先确认安装来源。不同来源不要交叉卸载。

npm 来源：

```bash
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code@latest
```

Homebrew 来源：

```bash
brew uninstall --cask claude-code
brew install --cask claude-code
```

Native Installer 来源：

```bash
rm -f ~/.local/bin/claude
rm -rf ~/.local/share/claude
curl -fsSL https://claude.ai/install.sh | bash
```

删除 Native Installer 目录前，明确告知会移除本地 Claude Code 安装文件；不要删除用户项目、聊天记录或其他未确认目录。

## 验证

```bash
claude --version
command -v claude
claude --help
```

npm 来源额外验证：

```bash
npm list -g @anthropic-ai/claude-code --depth=0
npm root -g
```

## 安装位置说明

- CLI 路径：以 `command -v claude` 为准。
- npm 包目录：`$(npm root -g)/@anthropic-ai/claude-code`。
- Homebrew 或 Native Installer 目录：通过 `command -v claude` 和 `ls -l` 确认。

## cc-switch MCP 配置提醒

Claude Code 是 Agent CLI，不是 MCP Server。不要把 `claude` 注册成 cc-switch 的 `mcpServers`。

如果用户问 MCP，应提醒：

- Claude Code 可以消费 MCP Server 配置。
- 具体 MCP Server 应按对应工具配置，例如 codegraph 使用 `codegraph serve --mcp`。
- 本 Skill 默认只管理 Claude Code CLI 本体，不自动修改 Claude Code 或 cc-switch 配置。
