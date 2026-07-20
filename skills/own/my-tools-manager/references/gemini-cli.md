# Gemini CLI 管理规则

## 工具信息

- 工具名：Gemini CLI
- 常用 CLI 命令：`gemini`
- npm 包名：`@google/gemini-cli`
- 官方安装方式：npm、Homebrew、MacPorts、Anaconda，也支持 `npx @google/gemini-cli`
- Node 要求：Node.js 20.0.0+
- 本机已知偏好：如果当前环境检测到 npm 安装，升级和重装默认沿用 npm，不自动迁移安装来源。

官方来源：

- https://geminicli.com/docs/get-started/installation/
- https://geminicli.com/docs/resources/uninstall/
- https://developers.google.com/gemini-code-assist/docs/gemini-cli

## 自更新流程

使用 `工具信息` 中的官方来源核对最新规则。

自更新时重点检查：

1. Gemini CLI 与 Antigravity CLI 的替代关系和日期提示是否变化。
2. Node.js 版本要求是否变化。
3. npm、Homebrew、MacPorts、Anaconda、npx 安装方式是否仍受支持。
4. npm `latest`、`preview`、`nightly` 标签是否变化。
5. 卸载和 npx 缓存清理规则是否变化。
6. Gemini CLI 的 MCP 消费配置是否变化；不要把 `gemini` 当作 MCP Server。

保留本地策略：如果当前机器检测到 npm 安装，升级和重装默认沿用 npm，不主动迁移来源。

## 重要提醒

官方安装页提示：未付费层和 Google One 用户将在 2026-06-18 被 Antigravity CLI 替代。安装或升级前，如果用户属于这类使用场景，先提醒此风险；若只是管理当前已安装 npm 包，可按用户要求继续。

## 检查命令

```bash
command -v gemini || true
gemini --version
node -v
npm list -g @google/gemini-cli --depth=0
npm config get prefix
npm root -g
```

如系统有 Homebrew 或 MacPorts，可补充检查：

```bash
brew list | rg '^gemini-cli$' || true
port installed | rg 'gemini-cli' || true
```

## 安装来源判断

按顺序判断：

1. `npm list -g @google/gemini-cli --depth=0` 成功：npm 来源。
2. `brew list` 命中 `gemini-cli`：Homebrew 来源。
3. `port installed` 命中 `gemini-cli`：MacPorts 来源。
4. 仅通过 `npx @google/gemini-cli` 使用：非持久安装。
5. 无法判断时，先说明风险，不执行卸载或覆盖。

## 新装

如果用户没有指定安装来源，优先在 macOS 上使用 npm 或 Homebrew；若用户当前环境偏好 npm，则使用 npm。

npm：

```bash
npm install -g @google/gemini-cli
```

Homebrew：

```bash
brew install gemini-cli
```

MacPorts：

```bash
sudo port install gemini-cli
```

临时运行，不持久安装：

```bash
npx @google/gemini-cli
```

## 升级

升级时沿用当前安装来源，不主动迁移。

npm stable：

```bash
npm install -g @google/gemini-cli@latest
```

npm preview：

```bash
npm install -g @google/gemini-cli@preview
```

npm nightly：

```bash
npm install -g @google/gemini-cli@nightly
```

Homebrew：

```bash
brew upgrade gemini-cli
```

MacPorts：

```bash
sudo port selfupdate
sudo port upgrade gemini-cli
```

## 重装

重装必须先确认安装来源。不同来源不要交叉卸载。

npm 来源：

```bash
npm uninstall -g @google/gemini-cli
npm install -g @google/gemini-cli@latest
```

Homebrew 来源：

```bash
brew uninstall gemini-cli
brew install gemini-cli
```

MacPorts 来源：

```bash
sudo port uninstall gemini-cli
sudo port install gemini-cli
```

npx 临时运行清理：按官方卸载说明清理 npm `_npx` 缓存；不要盲删整个 npm cache，除非用户明确同意。

## 验证

```bash
gemini --version
command -v gemini
gemini --help
node -v
```

npm 来源额外验证：

```bash
npm list -g @google/gemini-cli --depth=0
npm root -g
```

确认 `node -v` 满足 Node.js 20.0.0+。首次运行可能需要 Google 登录或 API key；不要在输出中暴露 token 或敏感环境变量。

## 安装位置说明

- CLI 路径：以 `command -v gemini` 为准。
- npm 包目录：`$(npm root -g)/@google/gemini-cli`。
- Homebrew 或 MacPorts 目录：通过 `command -v gemini` 和 `ls -l` 确认。

## 配置提醒

Gemini CLI 是 Agent CLI，不是 MCP Server。不要把 `gemini` 注册成 cc-switch 的 `mcpServers`。

如果用户问 MCP，应提醒：

- Gemini CLI 可以消费 MCP Server 配置。
- 具体 MCP Server 应按对应工具配置，例如 codegraph 使用 `codegraph serve --mcp`。
- 本 Skill 默认只管理 Gemini CLI 本体，不自动修改 Gemini 或 cc-switch 配置。
