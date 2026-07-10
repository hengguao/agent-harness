# Codex CLI 管理规则

## 工具信息

- 工具名：OpenAI Codex CLI
- 常用 CLI 命令：`codex`
- npm 包名：`@openai/codex`
- 官方推荐新装方式：OpenAI standalone installer
- 其他官方安装方式：npm、Homebrew cask、GitHub Release 二进制
- 本机已知偏好：如果当前环境检测到 npm 安装，升级和重装默认沿用 npm，不自动迁移安装来源。

官方来源：

- https://developers.openai.com/codex/cli
- https://github.com/openai/codex

## 自更新流程

使用 `工具信息` 中的官方来源核对最新规则。

自更新时重点检查：

1. 官方 standalone installer URL 是否变化。
2. npm、Homebrew、GitHub Release 安装方式是否仍受支持。
3. 非交互安装参数是否变化。
4. 卸载或重装说明是否新增，尤其是 standalone 来源。
5. `codex --version`、`codex --help` 等验证命令是否仍可用。
6. Codex CLI 的 MCP 消费配置是否变化；不要把 `codex` 当作 MCP Server。

保留本地策略：如果当前机器检测到 npm 安装，升级和重装默认沿用 npm，不主动迁移来源。

## 检查命令

```bash
command -v codex || true
type -a codex || true
codex --version
npm list -g @openai/codex --depth=0
npm config get prefix
npm root -g
```

如系统有 Homebrew，可补充检查：

```bash
brew list --cask | rg '^codex$' || true
```

## 安装来源判断

按顺序判断：

1. `npm list -g @openai/codex --depth=0` 成功：npm 来源。
2. `brew list --cask` 命中 `codex`：Homebrew cask 来源。
3. `command -v codex` 指向非 npm/brew 路径：先判断具体来源；其中 `/Applications/Codex.app/Contents/Resources/codex` 是 Codex Desktop App 内置 CLI，不等同于 npm 全局安装成功，官方 standalone 安装目录或其他独立二进制才按 standalone/二进制来源处理。
4. 无法判断时，先说明风险，不执行卸载或覆盖。

## 新装

如果用户没有指定安装来源，优先使用官方 standalone installer。

macOS / Linux：

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

非交互：

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

npm 替代方式：

```bash
npm install -g @openai/codex
```

Homebrew：

```bash
brew install --cask codex
```

## 升级

升级时沿用当前安装来源，不主动迁移。

npm 来源：

```bash
npm install -g @openai/codex@latest
```

如果 npm 升级被中断或出现 `ENOTEMPTY`，先检查是否存在只属于 `@openai/codex` 的 npm 临时残留，再决定是否清理；不要删除用户配置、项目数据、缓存或 Desktop App 资源目录。

```bash
find "$(npm root -g)/@openai" -maxdepth 1 -name '.codex-*' -print 2>/dev/null || true
find "$(npm config get prefix)/bin" -maxdepth 1 -name '.codex-*' -print 2>/dev/null || true
ls -l "$(npm config get prefix)/bin/codex" 2>/dev/null || true
ls -d "$(npm root -g)/@openai/codex/node_modules/@openai"/codex-* 2>/dev/null || true
```

Homebrew 来源：

```bash
brew upgrade --cask codex
```

standalone 来源：重新运行官方 installer。

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

## 重装

重装必须先确认安装来源。不同来源不要交叉卸载。

npm 来源：

```bash
npm uninstall -g @openai/codex
npm install -g @openai/codex@latest
```

Homebrew 来源：

```bash
brew uninstall --cask codex
brew install --cask codex
```

standalone 来源：优先查官方卸载说明；若无明确卸载命令，不要凭路径猜测删除，先提示用户确认安装目录。

## 验证

```bash
codex --version
command -v codex
type -a codex
codex --help
```

npm 来源额外验证：

```bash
npm list -g @openai/codex --depth=0
npm root -g
ls -l "$(npm config get prefix)/bin/codex"
test -d "$(npm root -g)/@openai/codex"
ls -d "$(npm root -g)/@openai/codex/node_modules/@openai"/codex-* 2>/dev/null
```

如果是 macOS npm 来源，`codex --version` 成功但 `npm list -g @openai/codex --depth=0` 为空，不能判定升级成功；这通常表示命中了 Desktop App 内置 CLI 或其他路径上的二进制。必须让 `command -v codex`、`npm list -g`、npm 包目录和平台依赖同时匹配。

首次运行可能需要 ChatGPT 账号或 API key 登录；不要在输出中暴露 token 或敏感环境变量。

## 安装位置说明

- CLI 路径：以 `command -v codex` 为准。
- npm 包目录：`$(npm root -g)/@openai/codex`。
- Homebrew 或 standalone 目录：通过 `command -v codex` 和 `ls -l` 确认。

## cc-switch MCP 配置提醒

Codex CLI 是 Agent CLI，不是 MCP Server。不要把 `codex` 注册成 cc-switch 的 `mcpServers`。

如果用户问 MCP，应提醒：

- Codex CLI 可以消费 MCP Server 配置。
- 具体 MCP Server 应按对应工具配置，例如 codegraph 使用 `codegraph serve --mcp`。
- 本 Skill 默认只管理 Codex CLI 本体，不自动修改 Codex 或 cc-switch 配置。
