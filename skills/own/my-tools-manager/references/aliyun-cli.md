# Aliyun CLI 管理规则

## 工具信息

- 工具名：Aliyun CLI / 阿里云 CLI
- 官方文档：https://help.aliyun.com/zh/cli/
- 安装与更新文档：https://help.aliyun.com/zh/cli/install-update-alibaba-cloud-cli
- 凭证配置文档：https://help.aliyun.com/zh/cli/configure-credentials
- GitHub Releases：https://github.com/aliyun/aliyun-cli/releases
- Homebrew formula：https://formulae.brew.sh/formula/aliyun-cli
- CLI 命令：`aliyun`
- Homebrew formula：`aliyun-cli`
- SLS 插件名：`aliyun-cli-sls`

用途：在终端中调用阿里云 OpenAPI，管理云资源；麓客+ SLS 日志查询依赖 `aliyun sls get-logs-v2`。

## 自更新流程

使用 `工具信息` 中的官方文档、安装与更新文档、凭证配置文档、GitHub Releases 和 Homebrew formula 核对最新规则。

自更新时重点检查：

1. macOS 推荐安装方式是否仍包含 `brew install aliyun-cli`。
2. `aliyun version`、`aliyun configure list`、`aliyun configure --mode AK --profile default` 的行为是否变化。
3. 官方是否仍要求低于 `3.3.0` 的版本迁移到插件版 CLI。
4. Homebrew formula、安装目录、升级命令和卸载命令是否变化。
5. SLS 查询是否仍使用插件版命令，插件安装名是否仍是 `aliyun-cli-sls` 或官方文档中是否改为别名 `sls`。
6. `get-logs-v2`、`GetLogsV2` 权限、SLS 插件安装方式和自动插件安装策略是否变化。
7. OAuth、AK、STS、RAM Role、CloudSSO 等凭证配置方式是否变化；不要把任何凭证示例写入 reference。

## 前置条件

macOS 使用 Homebrew 安装前确认：

```bash
command -v brew || true
brew --version
```

使用 SLS 查询前确认：

```bash
command -v jq || true
jq --version
aliyun plugin list
aliyun sls get-logs-v2 help
```

凭证检查只看状态，不打印 AK/SK、token 或完整配置内容：

```bash
aliyun configure list
```

如果没有配置凭证，引导用户在本机可见终端执行配置。不要让用户把 AK/SK 发到聊天里。

## 检查命令

```bash
command -v aliyun || true
aliyun version
aliyun help
brew list --versions aliyun-cli
brew info aliyun-cli
aliyun plugin list
aliyun plugin search sls
aliyun sls get-logs-v2 help
```

`aliyun configure list` 返回失败不一定表示 CLI 安装失败；它通常表示没有凭证配置或配置不可用。

## 安装来源判断

按顺序判断：

1. `brew list --versions aliyun-cli` 成功：Homebrew 来源。
2. `command -v aliyun` 指向 `/opt/homebrew/bin/aliyun` 或 `/usr/local/bin/aliyun`，且 `brew info aliyun-cli` 显示已安装：Homebrew 来源。
3. `command -v aliyun` 指向 `/usr/local/bin/aliyun` 但 Homebrew 未记录：可能是官方 Bash 脚本、TGZ 或 PKG 安装；不要直接覆盖，先确认来源。
4. 其他路径：先判断是否为手工二进制、项目脚本、容器内工具或系统包管理器；不要直接删除或覆盖。

## 新装

macOS 优先使用官方推荐的 Homebrew：

```bash
brew install aliyun-cli
```

安装后验证：

```bash
aliyun version
aliyun help
command -v aliyun
brew list --versions aliyun-cli
brew info aliyun-cli
```

如果 Homebrew bottle 下载长时间卡在 `ghcr.io`，先确认临时下载文件是否仍在增长；只要仍在增长就等待命令完成。不要直接删除 Homebrew 缓存或锁。

## 升级

沿用当前安装来源，不主动迁移。

Homebrew 来源：

```bash
brew update
brew upgrade aliyun-cli
```

官方文档也提供 `aliyun upgrade`，但该命令适用于非 Homebrew 安装方式；当前来源是 Homebrew 时，优先用 Homebrew 升级，避免包管理器状态不一致。

升级后验证：

```bash
aliyun version
command -v aliyun
brew list --versions aliyun-cli
aliyun plugin list
```

## 重装

重装前确认安装来源和凭证状态。重装 CLI 不应默认删除 `~/.aliyun` 凭证配置。

Homebrew 来源：

```bash
brew reinstall aliyun-cli
```

如需完整卸载再安装：

```bash
brew uninstall aliyun-cli
brew install aliyun-cli
```

如果检测到非 Homebrew 来源，先按官方安装与更新文档确认对应卸载或覆盖方式；不要凭路径猜测删除二进制。

## SLS 插件

麓客+ SLS 日志查询依赖：

```bash
aliyun sls get-logs-v2
```

先检查本地插件：

```bash
aliyun plugin list
aliyun plugin search sls
```

本机远程索引返回的插件名是 `aliyun-cli-sls`，安装命令：

```bash
aliyun plugin install --name aliyun-cli-sls
```

安装后验证：

```bash
aliyun plugin list
aliyun plugin show --name aliyun-cli-sls
aliyun sls get-logs-v2 help
```

如果官方文档或远程索引改为支持别名 `sls`，可按最新文档使用：

```bash
aliyun plugin install --names sls
```

但不要在未确认远程索引支持前，把 `sls` 当作唯一稳定插件名。

## 凭证配置

优先使用用户本机已有的 `aliyun configure` 配置或环境变量。检查环境变量时只输出存在性，不输出值。

常见环境变量检查：

```bash
for k in ALIBABA_CLOUD_ACCESS_KEY_ID ALIBABA_CLOUD_ACCESS_KEY_SECRET ALIYUN_ACCESS_KEY_ID ALIYUN_ACCESS_KEY_SECRET ALICLOUD_ACCESS_KEY ALICLOUD_SECRET_KEY; do
  if [ -n "$(printenv "$k")" ]; then echo "$k=present"; else echo "$k=missing"; fi
done
```

交互式 AK 配置：

```bash
aliyun configure --mode AK --profile default
```

麓客+ SLS 使用时，Region 填：

```text
cn-chengdu
```

如果在 Codex 后台 PTY 中无法让用户输入凭证，打开本机可见 Terminal：

```bash
osascript -e 'tell application "Terminal" to activate' -e 'tell application "Terminal" to do script "aliyun configure --mode AK --profile default"'
```

OAuth 配置可尝试：

```bash
aliyun configure --mode OAuth --profile default
```

如果 OAuth 回调返回 `ERROR: code not found` 或浏览器无法完成回调，改用用户本机 Terminal 手动输入 AK/SK。不要让用户把 AK/SK 粘贴到聊天里。

配置后验证：

```bash
aliyun configure list
```

只报告命令是否成功、配置文件是否存在和 profile 状态；不要打印完整配置内容。

## 麓客+ SLS 验证

`luxelakes-sls-query` 的最小验证命令：

```bash
bash /Users/wanhua/.skillstack/skills/luxelakes-sls-query/sls.sh topics --last 1h
```

成功时会把 topic 列表缓存到：

```text
~/.cache/luxelakes-sls/topics.txt
```

如果返回 Unauthorized，确认当前账号或 RAM 用户是否具备：

```text
log:GetLogStoreLogs
log:GetIndex
```

目标项目和 Logstore：

```text
project: luxelakes-server-logs
logstore: luke-server-logs
region: cn-chengdu
```

## 安全规则

- AK/SK、STS token、Bearer token、OAuth code、RAM Role 临时凭证和 `~/.aliyun/config.json` 内容都属于敏感信息，不要输出、记录或提交。
- 默认只检查 `aliyun configure list` 的返回状态，不打印完整内容。
- 不要把 AK/SK 写进 shell 命令、日志、Skill reference 或 cc-switch 配置。
- 查询 SLS 是只读操作，但会访问线上日志；用户明确要求查某环境、服务、关键词或 traceId 后再执行。
- 遇到权限错误时，只报告缺少的权限和目标资源，不推测或输出账号身份细节。

## 安装位置说明

- CLI 路径：以 `command -v aliyun` 为准。
- Homebrew Apple Silicon 默认安装目录通常是 `/opt/homebrew/Cellar/aliyun-cli/<version>`，可用 `brew info aliyun-cli` 或 `brew --prefix aliyun-cli` 确认。
- Homebrew Intel 默认安装目录通常是 `/usr/local/Cellar/aliyun-cli/<version>`。
- Homebrew 会把 `/opt/homebrew/bin/aliyun` 或 `/usr/local/bin/aliyun` 链接到 Cellar 里的实际二进制。
- 阿里云 CLI 用户配置通常位于 `~/.aliyun`，不要在重装或升级时删除。
- 麓客+ SLS topic 缓存位于 `~/.cache/luxelakes-sls/topics.txt`，不要在工具管理流程里默认删除。

## 配置提醒

Aliyun CLI 是本机命令行工具，不是 MCP Server。不要默认生成 cc-switch `mcpServers` 配置。

如果某个 MCP 或 Skill 需要调用 `aliyun`，优先确认：

```bash
command -v aliyun
aliyun version
aliyun configure list
aliyun sls get-logs-v2 help
```

发现 `aliyun` 不在 PATH 时，外部配置中的 `command` 使用绝对路径，并提醒用户是否要修 PATH。当前 Homebrew Apple Silicon 常见路径是：

```text
/opt/homebrew/bin/aliyun
```
