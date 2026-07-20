# 飞书 lark-cli 管理规则

## 工具信息

- 工具名：lark-cli
- 官方仓库：https://github.com/larksuite/cli
- 中文 README：https://github.com/larksuite/cli/blob/main/README.zh.md
- npm 包名：`@larksuite/cli`
- CLI 命令：`lark-cli`
- npm bin：`lark-cli`
- 推荐安装方式：`npx @larksuite/cli@latest install`

## 自更新流程

使用 `工具信息` 中的官方仓库和中文 README 地址核对最新规则。

自更新时重点检查：

1. AI Agent 快速开始流程是否仍使用 `npx @larksuite/cli@latest install`。
2. `config init --new`、`auth login --recommend`、`auth status` 是否变化。
3. 安装器是否仍负责安装 CLI 和 Agent Skills。
4. 升级、卸载、重装是否新增官方命令；若仍缺失卸载说明，保留待确认风险。
5. 认证、授权链接、后台运行和输出格式说明是否变化。
6. 是否新增 MCP Server 启动方式；没有明确 MCP Server 命令时，不生成 cc-switch `mcpServers` 配置。

## 环境要求

- npm/npx 安装需要 Node.js。
- 只有源码构建才需要 Go `v1.23+` 和 Python 3。
- 不要把源码构建依赖当作普通安装前置条件。

## 检查命令

```bash
command -v lark-cli || true
lark-cli --help
npm view @larksuite/cli version bin
npm list -g @larksuite/cli --depth=0
npm config get prefix
npm root -g
```

若 `lark-cli --version` 可用，再用它确认版本；如果不可用，不要把缺少 version 命令当作安装失败，改用 `--help`、npm 包信息和实际命令路径验证。

## 安装

按官方 README，AI Agent 直接使用：

```bash
npx @larksuite/cli@latest install
```

源码安装仅在用户明确要求从源码构建时使用：

```bash
git clone https://github.com/larksuite/cli.git
cd cli
make install
npx skills add larksuite/cli -y -g
```

源码构建前必须确认 Go `v1.23+` 和 Python 3 已安装。

## 升级

官方 README 没有单独给出升级命令。默认按官方 installer 重新执行：

```bash
npx @larksuite/cli@latest install
```

执行前后都要验证 `command -v lark-cli` 和 `lark-cli --help`。若检测到它实际是 npm 全局包安装，可补充检查 `npm list -g @larksuite/cli --depth=0`，但不要在未确认 installer 行为前擅自改用 `npm install -g`。

## 重装

官方 README 没有明确卸载/清理命令，标记为待确认风险。

重装时：

1. 先确认当前安装来源和 `command -v lark-cli` 指向。
2. 不要凭猜测删除文件或目录。
3. 若用户只是想修复安装，优先重新运行：

```bash
npx @larksuite/cli@latest install
```

4. 若用户明确要求清理后重装，先查官方最新卸载说明或询问用户提供内部安装约定，再执行。

待确认风险：缺少官方卸载命令时，不能主动删除 `lark-cli` 二进制、skills、凭证或配置目录。

## AI Agent 快速开始

官方 README 要求 AI Agent 使用以下流程。涉及浏览器授权的命令需要后台运行，提取授权链接发给用户。

第 1 步，安装：

```bash
npx @larksuite/cli@latest install
```

第 2 步，配置应用凭证：

```bash
lark-cli config init --new
```

将命令输出中的授权链接发给用户；用户在浏览器完成配置后，命令会自动退出。

第 3 步，登录：

```bash
lark-cli auth login --recommend
```

同样提取授权链接发给用户。

第 4 步，验证：

```bash
lark-cli auth status
```

## 认证命令

```bash
lark-cli auth login
lark-cli auth logout
lark-cli auth status
lark-cli auth check
lark-cli auth scopes
lark-cli auth list
```

常用登录方式：

```bash
lark-cli auth login --recommend
lark-cli auth login --domain calendar,task
lark-cli auth login --scope "calendar:calendar:read"
```

Agent 模式：

```bash
lark-cli auth login --domain calendar --no-wait
lark-cli auth login --device-code <DEVICE_CODE>
```

## 使用与验证

快捷命令：

```bash
lark-cli calendar +agenda
lark-cli im +messages-send --chat-id "oc_xxx" --text "Hello"
```

API 命令：

```bash
lark-cli calendar calendars list
```

通用 API：

```bash
lark-cli api GET /open-apis/calendar/v4/calendars
```

Schema 自省：

```bash
lark-cli schema
lark-cli schema calendar.events.instance_view
```

输出格式：

```bash
--format json
--format pretty
--format table
--format ndjson
--format csv
```

分页：

```bash
--page-all
--page-limit 5
--page-delay 500
```

对有副作用命令，优先 dry-run：

```bash
lark-cli im +messages-send --chat-id oc_xxx --text "hello" --dry-run
```

## 安全规则

- 授权后，AI Agent 会以用户身份在授权范围内操作飞书/Lark。
- 存在敏感数据泄露、越权操作、模型幻觉和提示词注入风险。
- 不要主动修改默认安全配置。
- 不要输出、记录或提交 token、授权码、密钥、cookie、租户敏感信息。
- 对发送消息、写文档、改表格、删数据、审批等副作用操作，优先使用 `--dry-run` 或先向用户确认。

## 安装位置说明

- CLI 路径：以 `command -v lark-cli` 为准。
- npm 包元信息：用 `npm view @larksuite/cli version bin` 查询。
- 若能确认 npm 全局安装，包目录通常是 `$(npm root -g)/@larksuite/cli`。
- 若是 installer 写入的二进制或脚本，以 `command -v lark-cli` 和 `ls -l` 实际结果为准。

## 配置提醒

`lark-cli` 是飞书官方 CLI 和 Agent Skills 工具，不要默认当作 MCP Server 注册到 cc-switch 的 `mcpServers`。

如果用户问 MCP：

- 先确认官方文档是否提供 MCP Server 启动方式。
- 没有明确 MCP Server 命令时，不生成 `mcpServers` 配置。
- 可以提醒用户它更像“Agent 可调用 CLI + skills”，不是 `stdio` MCP 服务。
