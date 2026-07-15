# GitHub CLI 管理规则

## 工具信息

- 工具名：GitHub CLI
- 官方网站：https://cli.github.com/
- 官方仓库：https://github.com/cli/cli
- 官方手册：https://cli.github.com/manual
- Homebrew formula：https://formulae.brew.sh/formula/gh
- CLI 命令：`gh`
- Homebrew formula：`gh`

用途：在终端中操作 GitHub，包括登录、查看认证状态、fork 仓库、创建 PR、查看 issue / workflow 等。

## 自更新流程

使用 `工具信息` 中的官方网站、官方仓库、官方手册和 Homebrew formula 核对最新规则。

自更新时重点检查：

1. macOS 推荐安装方式是否仍是 `brew install gh`。
2. `gh auth login`、`gh auth status`、`gh repo fork` 的参数和认证行为是否变化。
3. token 登录方式 `gh auth login --with-token` 和环境变量 `GH_TOKEN` / `GITHUB_TOKEN` 的建议是否变化。
4. Homebrew formula、安装目录、shell completion 和升级命令是否变化。
5. `GH_PROMPT_DISABLED`、`GH_BROWSER`、GitHub device flow 等非交互登录方式是否变化。
6. 是否新增 npm 官方安装方式；未明确前，不把 npm 同名包当作 GitHub 官方 CLI。

## 前置条件

macOS 使用 Homebrew 安装前确认：

```bash
command -v brew || true
brew --version
```

执行 GitHub 写操作前确认：

```bash
gh auth status
```

不要输出 token。不要使用 `gh auth status --show-token`，除非用户明确要求调试凭证，并已确认暴露风险。

如果后续要执行 `git push`、`git fetch` 或 `git clone`，还要确认命令行能访问 `github.com`；如果只用 `gh api`，确认 `api.github.com` 可访问即可：

```bash
curl -I --connect-timeout 10 https://github.com
curl -I --connect-timeout 10 https://api.github.com
```

## 检查命令

```bash
command -v gh || true
gh --version
gh --help
brew list --versions gh
brew info gh
```

如果 `gh auth status` 返回未登录，不代表安装失败；它只表示还没有 GitHub 认证状态。

## 安装来源判断

按顺序判断：

1. `brew list --versions gh` 成功：Homebrew 来源。
2. `command -v gh` 指向 `/opt/homebrew/bin/gh` 或 `/usr/local/bin/gh`，且 `brew info gh` 显示已安装：Homebrew 来源。
3. `command -v gh` 指向其他路径：先判断是否为手工二进制、系统包管理器或开发态；不要直接覆盖。
4. npm 上存在同名 `gh` 包，但它不是 GitHub 官方 CLI；不要用 npm 安装或升级 GitHub CLI。

## 新装

macOS 官方推荐 Homebrew：

```bash
brew install gh
```

安装后验证：

```bash
gh --version
gh --help
command -v gh
brew list --versions gh
brew info gh
```

## 升级

沿用当前安装来源，不主动迁移。

Homebrew 来源：

```bash
brew upgrade gh
```

升级后验证：

```bash
gh --version
command -v gh
brew list --versions gh
```

## 重装

重装前确认安装来源和认证状态。重装 CLI 不应默认删除 GitHub 凭证。

Homebrew 来源：

```bash
brew reinstall gh
```

如需完整卸载再安装：

```bash
brew uninstall gh
brew install gh
```

## 认证

交互式登录：

```bash
gh auth login
```

无浏览器或自动化场景可使用 token，但不要把 token 写进命令历史或日志：

```bash
gh auth login --with-token < mytoken.txt
```

也可以在当前 shell 中设置 `GH_TOKEN` 或 `GITHUB_TOKEN` 供 `gh` 使用。检查时只确认变量是否存在，不打印内容。

认证验证：

```bash
gh auth status
```

在 Codex 这类非完整交互终端中，`gh auth login --web` 的 TUI 提示可能卡在确认项上。需要网页登录但不想让 `gh` 自动打开浏览器时，优先使用 device flow 输出验证码和链接：

```bash
GH_PROMPT_DISABLED=1 GH_BROWSER=echo gh auth login --hostname github.com --git-protocol https --web
```

流程：

1. 把命令输出的一次性 code 和 `https://github.com/login/device` 发给用户。
2. 让用户在浏览器完成账号选择、输入 code 和授权确认。
3. 等待命令返回 `Authentication complete`。
4. 再运行 `gh auth status` 验证登录账号和 Git protocol。

如果返回 `failed to authenticate via web browser`，并且错误是连接 `https://github.com/login/oauth/access_token` 超时，通常是 `github.com` 临时网络问题；先用 `curl -I https://github.com` 验证连通性，恢复后重新生成 device code。旧 code 不要复用。

## 常用 GitHub 仓库操作

创建远端 fork，不克隆：

```bash
gh repo fork OWNER/REPO --clone=false
```

创建 fork 并克隆：

```bash
gh repo fork OWNER/REPO --clone
```

在已有本地仓库中添加 fork remote：

```bash
gh repo fork --remote --remote-name fork
```

如果要指定组织或 fork 名称：

```bash
gh repo fork OWNER/REPO --org ORG --fork-name NAME --clone=false
```

推送分支：

```bash
git push -u origin <branch>
```

如果 HTTPS push 失败并出现 `Error in the HTTP2 framing layer`，先用 HTTP/1.1 重试：

```bash
git -c http.version=HTTP/1.1 push -u origin <branch>
```

如果 `git push` 仍因 `github.com:443` 超时失败，但 `api.github.com` 可访问，可以用 GitHub Git Data API 创建分支和提交。执行前必须确认：

1. 远端 fork 的 base branch SHA 与本地改造基线一致。
2. 只上传本次改动文件。
3. 不通过 API 上传 token、secrets、构建产物或无关文件。

常用检查：

```bash
gh api repos/OWNER/REPO/git/ref/heads/main --jq '.object.sha'
git rev-parse HEAD^
git diff --name-only HEAD^ HEAD
gh api repos/OWNER/REPO/compare/main...BRANCH --jq '{status: .status, ahead_by: .ahead_by, behind_by: .behind_by, files: [.files[].filename]}'
```

注意：通过 GitHub API 创建的远端提交 SHA 会不同于本地 `git commit` SHA；必须用 compare API 校验文件列表和 ahead/behind 状态。

## 安全规则

- GitHub token、OAuth device code、SSH 私钥、cookie 和一次性验证码都属于敏感信息，不要输出、记录或提交。
- 创建 fork、push 分支、创建 PR、修改 issue、触发 workflow 都是外部副作用；用户明确要求时再执行。
- `gh auth status --show-token` 会显示 token，默认禁止使用。
- 如果用户要求“不要使用浏览器方式”，优先使用 `gh auth login --with-token`、`GH_TOKEN` / `GITHUB_TOKEN` 或已存在的 `gh` 登录态。

## 安装位置说明

- CLI 路径：以 `command -v gh` 为准。
- Homebrew Apple Silicon 默认安装目录通常是 `/opt/homebrew/Cellar/gh/<version>`，可用 `brew info gh` 确认。
- Homebrew Intel 默认安装目录通常是 `/usr/local/Cellar/gh/<version>`。
- zsh completion 由 Homebrew 安装到 Homebrew 的 zsh site-functions 目录。

## 配置提醒

`gh` 是 GitHub 官方 CLI，不是 MCP Server。不要默认生成 cc-switch `mcpServers` 配置。

如果用户要让其他工具使用 GitHub 认证，优先确认该工具是否支持读取系统 Git credential、SSH agent、`GH_TOKEN` 或 `GITHUB_TOKEN`；不要把 token 写入仓库、Skill reference 或明文配置。
