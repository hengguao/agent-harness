# GitLab CLI 管理规则

## 工具信息

- 工具名：GitLab CLI
- 官方仓库：https://gitlab.com/gitlab-org/cli
- 官方文档：https://docs.gitlab.com/cli/
- Release 页面：https://gitlab.com/gitlab-org/cli/-/releases
- Homebrew formula：https://formulae.brew.sh/formula/glab
- CLI 命令：`glab`
- Homebrew formula：`glab`

用途：在终端中操作 GitLab，包括登录、查看认证状态、创建和管理 Merge Request、查看 issue、pipeline、job、release、repo 等。

## 自更新流程

使用 `工具信息` 中的官方仓库、官方文档、Release 页面和 Homebrew formula 核对最新规则。

自更新时重点检查：

1. macOS 推荐安装方式是否仍包含 `brew install glab`。
2. `glab auth login`、`glab auth status`、`glab mr create`、`glab pipeline list` 的参数和认证行为是否变化。
3. token 登录方式、环境变量和自建 GitLab hostname 参数建议是否变化。
4. Homebrew formula、安装目录、shell completion 和升级命令是否变化。
5. GitLab.com 与自建 GitLab 实例的认证差异是否变化。
6. `glab` 的 MCP、Duo、stacked diffs 等实验命令是否仍为实验性质；不要把实验能力当作默认稳定能力。

## 前置条件

macOS 使用 Homebrew 安装前确认：

```bash
command -v brew || true
brew --version
```

执行 GitLab 写操作前确认：

```bash
glab auth status
```

不要输出 token、OAuth code 或一次性验证码。不要把 token 直接写在会进入 shell history 的命令里。

如果目标是自建 GitLab，优先显式带 hostname：

```bash
glab auth login --hostname <host>
glab auth status --hostname <host>
```

## 检查命令

```bash
command -v glab || true
glab --version
glab --help
brew list --versions glab
brew info glab
```

如果 `glab auth status` 返回未登录，不代表安装失败；它只表示还没有 GitLab 认证状态。

## 安装来源判断

按顺序判断：

1. `brew list --versions glab` 成功：Homebrew 来源。
2. `command -v glab` 指向 `/opt/homebrew/bin/glab` 或 `/usr/local/bin/glab`，且 `brew info glab` 显示已安装：Homebrew 来源。
3. `command -v glab` 指向其他路径：先判断是否为手工二进制、系统包管理器或开发态；不要直接覆盖。
4. npm 上可能存在同名或相近包；未确认官方推荐前，不用 npm 安装或升级 GitLab CLI。

## 新装

macOS 优先使用 Homebrew：

```bash
brew install glab
```

安装后验证：

```bash
glab --version
glab --help
command -v glab
brew list --versions glab
brew info glab
```

如果 Homebrew bottle 下载长时间卡在 `ghcr.io`，先等待命令完成或明确失败；不要直接删除 Homebrew 缓存或锁。需要切换到 Release 二进制安装时，先从官方 Release 页面确认当前平台包名、校验方式和目标安装目录。

## 升级

沿用当前安装来源，不主动迁移。

Homebrew 来源：

```bash
brew upgrade glab
```

升级后验证：

```bash
glab --version
command -v glab
brew list --versions glab
```

## 重装

重装前确认安装来源和认证状态。重装 CLI 不应默认删除 GitLab 凭证。

Homebrew 来源：

```bash
brew reinstall glab
```

如需完整卸载再安装：

```bash
brew uninstall glab
brew install glab
```

## 认证

GitLab.com 交互式登录：

```bash
glab auth login
```

自建 GitLab 交互式登录：

```bash
glab auth login --hostname <host>
```

认证验证：

```bash
glab auth status
glab auth status --hostname <host>
```

在 Codex 这类非完整交互终端中，如果登录流程需要打开浏览器或输入 token，优先让用户在本机终端自行完成认证；不要在对话或日志中展示 token。

## 常用 GitLab 仓库操作

查看 Merge Request：

```bash
glab mr list
glab mr view
```

创建 Merge Request：

```bash
glab mr create
```

查看 GitLab CI：

```bash
glab pipeline list
glab job list
```

执行具体仓库操作前，先确认当前目录的 Git remote 指向目标 GitLab 实例：

```bash
git remote -v
```

## 安全规则

- GitLab token、OAuth device code、SSH 私钥、cookie 和一次性验证码都属于敏感信息，不要输出、记录或提交。
- 对自建 GitLab 执行写操作前，确认 `glab auth status --hostname <host>` 与当前仓库 remote host 一致。
