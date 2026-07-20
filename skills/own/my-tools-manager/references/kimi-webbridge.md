# kimi-webbridge 管理规则

## 工具信息

- 工具名：kimi-webbridge
- 官方页面：https://www.kimi.com/zh-cn/features/webbridge
- 官方帮助中心：https://www.kimi.com/zh-cn/help/kimi-webbridge
- 官方安装脚本：https://cdn.kimi.com/webbridge/install.sh
- 推荐安装命令：`curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash`
- 安装目录：`~/.kimi-webbridge`
- CLI 路径：`~/.kimi-webbridge/bin/kimi-webbridge`
- Skill 常见目录：`~/.codex/skills/kimi-webbridge`

用途：通过本地桥接服务和浏览器扩展，让 Agent 控制用户正在使用的 Chrome 或 Edge 浏览器，完成导航、点击、截图、读取页面等操作。官网说明执行都在本地完成，登录态和网页内容不会离开设备。

## 自更新流程

使用 `工具信息` 中的官方页面、帮助中心和官方安装脚本核对最新规则。

自更新时重点检查：

1. 官网是否仍推荐同一个安装脚本。
2. 安装脚本是否仍下载到 `~/.kimi-webbridge/bin/kimi-webbridge`。
3. 安装脚本参数是否变化：当前支持 `--no-start`、`--no-skill`、`-h/--help`。
4. 环境变量是否变化：当前支持 `KIMI_WEBBRIDGE_VERSION=v0.3.0` 这类固定版本安装。
5. CLI 命令是否变化：当前包含 `start`、`stop`、`restart`、`status`、`logs`、`install-skill`、`upgrade`、`uninstall`。
6. Skill 安装目标是否变化。
7. daemon 数据目录、日志路径、pid/identity 文件是否变化。
8. 官网是否新增浏览器扩展、Kimi 桌面版重启或连接指令要求。

更新 reference 前先汇总差异；不要直接删除 `~/.kimi-webbridge/` 或 `~/.codex/skills/kimi-webbridge`。

## 前置条件

官方页面说明 Kimi WebBridge 由本地桥接服务和浏览器扩展协同工作。安装和使用前确认：

- 用户已安装 Chrome 或 Edge。
- 用户已安装 Kimi WebBridge 浏览器插件。
- 需要时在 Kimi Work 中重新发送并运行连接指令。
- 运行连接指令后可能需要重启 Kimi 桌面版。
- 系统为 macOS 或 Linux，架构为 arm64/aarch64 或 x86_64/amd64；安装脚本当前只支持这些平台。

安装脚本依赖：

```bash
command -v curl
command -v mktemp
command -v uname
```

## 检查命令

不要只用 `command -v kimi-webbridge` 判断是否安装，因为官方脚本默认安装到 `~/.kimi-webbridge/bin/kimi-webbridge`，不一定加入 PATH。

```bash
test -x ~/.kimi-webbridge/bin/kimi-webbridge && echo installed || true
~/.kimi-webbridge/bin/kimi-webbridge --help
~/.kimi-webbridge/bin/kimi-webbridge status
~/.kimi-webbridge/bin/kimi-webbridge logs
ls -la ~/.kimi-webbridge
ls -la ~/.kimi-webbridge/bin
find ~/.codex/skills -maxdepth 3 \( -iname '*kimi*' -o -iname '*webbridge*' \) -print
```

如果用户 shell 已配置 PATH，也可补充：

```bash
command -v kimi-webbridge || true
kimi-webbridge --help
kimi-webbridge status
```

## 安装

默认安装最新版本、启动 daemon、安装 skill：

```bash
curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash
```

只安装二进制和 skill，不启动 daemon：

```bash
curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash -s -- --no-start
```

只安装二进制并启动 daemon，跳过 skill：

```bash
curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash -s -- --no-skill
```

固定版本：

```bash
KIMI_WEBBRIDGE_VERSION=v0.3.0 curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash
```

安装脚本行为：

1. 检测 OS/arch：macOS/Linux，arm64/amd64。
2. 解析版本：默认 `latest`，也可用 `KIMI_WEBBRIDGE_VERSION` 固定。
3. 下载二进制到 `~/.kimi-webbridge/bin/kimi-webbridge` 并 `chmod +x`。
4. 启动 daemon，除非传 `--no-start`。
5. 安装 skills 到检测到的 AI agent runtime，除非传 `--no-skill`。

## 升级

CLI 自带升级命令，优先使用：

```bash
~/.kimi-webbridge/bin/kimi-webbridge upgrade
~/.kimi-webbridge/bin/kimi-webbridge restart
~/.kimi-webbridge/bin/kimi-webbridge status
```

如果升级命令失败，或需要按官方脚本重新覆盖安装：

```bash
curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash
~/.kimi-webbridge/bin/kimi-webbridge status
```

升级后如 Skill 未更新，可单独安装 Skill：

```bash
~/.kimi-webbridge/bin/kimi-webbridge install-skill -y
```

## 重装

用户明确说“重装 kimi-webbridge”时，按以下顺序处理。

1. 先检查当前状态：

```bash
~/.kimi-webbridge/bin/kimi-webbridge status || true
~/.kimi-webbridge/bin/kimi-webbridge logs || true
ls -la ~/.kimi-webbridge 2>/dev/null || true
find ~/.codex/skills -maxdepth 3 \( -iname '*kimi*' -o -iname '*webbridge*' \) -print 2>/dev/null
```

2. 使用官方卸载命令停止 daemon 并移除 `~/.kimi-webbridge/`：

```bash
~/.kimi-webbridge/bin/kimi-webbridge uninstall
```

3. 删除旧 Skill。默认只删除明确匹配的 Codex Skill 目录：

```bash
rm -rf ~/.codex/skills/kimi-webbridge
```

如果还检测到其他 agent runtime 的 kimi-webbridge skill，先列出路径并请用户确认，不要批量猜删。

4. 重新运行官方安装脚本：

```bash
curl -fsSL https://cdn.kimi.com/webbridge/install.sh | bash
```

5. 验证：

```bash
~/.kimi-webbridge/bin/kimi-webbridge status
~/.kimi-webbridge/bin/kimi-webbridge --help
find ~/.codex/skills -maxdepth 3 \( -iname '*kimi*' -o -iname '*webbridge*' \) -print
```

注意：`uninstall` 会移除 `~/.kimi-webbridge/`，其中可能包含 daemon 状态、identity 和日志。执行前要明确告诉用户影响范围。

## daemon 管理

```bash
~/.kimi-webbridge/bin/kimi-webbridge start
~/.kimi-webbridge/bin/kimi-webbridge stop
~/.kimi-webbridge/bin/kimi-webbridge restart
~/.kimi-webbridge/bin/kimi-webbridge status
~/.kimi-webbridge/bin/kimi-webbridge logs
```

常见文件：

```text
~/.kimi-webbridge/bin/kimi-webbridge
~/.kimi-webbridge/daemon.pid
~/.kimi-webbridge/identity.json
~/.kimi-webbridge/logs/daemon.log
```

## Skill 管理

安装脚本默认会执行：

```bash
~/.kimi-webbridge/bin/kimi-webbridge install-skill -y
```

单独重装 Skill：

```bash
rm -rf ~/.codex/skills/kimi-webbridge
~/.kimi-webbridge/bin/kimi-webbridge install-skill -y
```

如果检测到 Claude、Codex、Cursor 或其他 runtime 的 Skill 目录，先列出并确认范围，再删除或重装。

## PATH 处理

官方安装脚本安装到 `~/.kimi-webbridge/bin/kimi-webbridge`，不保证写入 shell PATH。

执行工具时优先使用绝对路径：

```bash
~/.kimi-webbridge/bin/kimi-webbridge status
```

如果用户明确希望添加 PATH，再按当前 shell 写入：

```bash
export PATH="$HOME/.kimi-webbridge/bin:$PATH"
```

不要未经用户确认修改 `~/.zshrc`、`~/.bashrc` 或其他 shell 配置。

## 安全和浏览器边界

- WebBridge 会通过本地桥接服务和浏览器扩展控制用户浏览器。
- 登录态和网页内容按官网说明保留在本机，但 Agent 能读取和操作当前浏览器页面。
- 涉及登录、支付、提交表单、删除数据、发送消息等操作前必须让用户确认。
- 排障时不要输出敏感网页内容、cookie、token、身份文件或日志中的密钥。
- `identity.json` 不要提交、复制或展示。

## 配置提醒

`kimi-webbridge` 是浏览器桥接 daemon + Skill，不是需要手写到 cc-switch 的普通 MCP Server。不要默认生成 `mcpServers` 配置。

如果用户问 MCP：

- 先检查安装脚本或官方帮助是否新增 MCP Server 启动方式。
- 没有明确 `stdio` MCP Server 命令时，不生成 cc-switch 配置。
- 通常应通过安装脚本安装 Skill 和 daemon，然后由对应 Agent Skill 调用本地桥接能力。
