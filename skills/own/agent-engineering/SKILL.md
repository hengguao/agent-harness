---
name: agent-engineering
description: 管理 agent-engineering 个人 Agent 工程资产库。用于导入、刷新、发布、整理或审计 skill、prompt、cli、mcp、hook、workflow、plugin、agent、ecosystem 等资产；区分 own 自有资产与 third 三方资产；维护 agent-engineering.yaml / agent-engineering.local.yaml 元数据；通过本地副本提交和推送远端仓库。
---

# Agent Engineering

## 核心定位

把 `https://gitee.com/hengguao/agent-engineering` 当作个人 Agent 工程资产库维护，而不是安装器。除非用户明确要求安装，否则不要把资产写入 `~/.codex`、`~/.claude`、`~/.gemini`、`~/.agents` 或项目级 Agent 运行目录。

资产按类型和来源分层：

```text
<资产类型>/own/<资产名>/
<资产类型>/third/<资产名>/
```

资产类型包括：`skill`、`prompt`、`cli`、`mcp`、`hook`、`workflow`、`plugin`、`agent`、`ecosystem`。

## 元数据

每个资产目录应包含提交到仓库的 `agent-engineering.yaml`。自有本地资产可以在同目录放一个不提交的 `agent-engineering.local.yaml`，用于记录当前机器上的本地来源路径。

```text
agent-engineering.yaml        # 提交，跨设备信息
agent-engineering.local.yaml  # 不提交，本机绝对路径
```

`agent-engineering.local.yaml` 只描述当前资产目录的本机路径：

```yaml
source:
  path: /absolute/path/to/local/asset
```

本文中的 `references/...` 都指本技能目录下的引用文件，例如 `/path/to/agent-engineering/references/metadata-schema.md`，不是资产库本地副本仓库根目录下的 `references/...`。

修改 `agent-engineering.yaml` 前读取本技能目录下的 `references/metadata-schema.md`。

整理目录或导入新资产类型前读取本技能目录下的 `references/asset-layout.md`。

## 本地副本

使用本技能维护数据时，始终通过本地副本（git 工作副本）操作仓库。不要区分“只读取”和“新增更新”两套路径。

本地副本路径记录在本技能目录同级的 `agent-engineering.local.yaml` 中：

```yaml
repository:
  path: /absolute/path/to/agent-engineering
```

每次执行本技能时先定位本地副本：

1. 读取本技能目录下的 `agent-engineering.local.yaml`。
2. 如果文件存在且 `repository.path` 指向有效的 git 仓库，进入该仓库操作。
3. 如果文件不存在，或 `repository.path` 为空、路径不存在、路径不是 agent-engineering 仓库，先向用户确认本地代码存放路径。
4. 用户确认后，更新本技能目录下的 `agent-engineering.local.yaml`，写入 `repository.path`。
5. 如果确认路径下还没有仓库，clone `https://gitee.com/hengguao/agent-engineering.git` 到该路径。
6. 后续执行都读取 `agent-engineering.local.yaml` 中的 `repository.path`。

不要把本地副本路径写入提交文件。`agent-engineering.local.yaml` 必须保持未跟踪。

## 工作流

### 扫描资产库

当用户询问仓库里有哪些资产、哪些缺元数据、目录是否规范时执行。

1. 先按“本地副本”规则进入本地仓库。
2. 检查所有资产类型目录。
3. 标记不在 `own/` 或 `third/` 下的资产。
4. 检查每个资产目录是否有 `agent-engineering.yaml`。
5. 确认没有 `agent-engineering.local.yaml` 被暂存或提交。
6. 按资产类型和来源汇总结果。

### 发布自有资产

当用户要把本地自有 Skill、prompt、hook、workflow、plugin、CLI 说明、MCP 配置或 agent 定义更新到仓库时执行。

1. 先按“本地副本”规则进入本地仓库。
2. 定位目标资产目录，例如 `skill/own/my-tools-manager`。
3. 读取 `agent-engineering.yaml`。
4. 读取同目录 `agent-engineering.local.yaml`。
5. 从 `source.path` 复制本地内容覆盖资产目录。
6. 保留 `agent-engineering.yaml`。
7. 不复制、不提交 `agent-engineering.local.yaml`。
8. 排除 `.DS_Store`、`.git`、`node_modules`、`__pycache__`、`dist`、`build`、日志和临时文件。
9. 提交前检查 diff。

如果 `agent-engineering.local.yaml` 不存在，停止并告诉用户要在对应资产目录创建的准确文件内容。

### 导入三方资产

当用户要收集三方 Skill、prompt、CLI、MCP、hook、workflow、plugin 或 agent 配置时执行。

1. 先按“本地副本”规则进入本地仓库。
2. 在 `<资产类型>/third/<资产名>` 下创建目录。
3. 尽量保留上游文件原貌。
4. 添加 `agent-engineering.yaml`，记录来源 URL、来源类型、ref/version、上游子路径和同步模式。
5. 如果做了本地整理，在 `sync.notes` 写明。
6. 保留上游 license、notice、attribution 等文件。

### 刷新三方资产

当用户要更新三方数据时执行。

1. 先按“本地副本”规则进入本地仓库。
2. 读取资产的 `agent-engineering.yaml`。
3. 拉取上游来源。
4. 对比当前仓库内容和上游内容。
5. 覆盖前先汇总 diff。
6. 适当更新 `sync.last_checked`、`sync.last_updated` 和版本/ref 字段。

`sync.mode: mirror` 时，默认跟随上游；`sync.mode: curated` 时，先展示差异并确认是否保留本地整理。

### 给现有资产补元数据

当资产已经存在但缺少 `agent-engineering.yaml` 时执行。

1. 先按“本地副本”规则进入本地仓库。
2. 从路径推断 `name`、`type`、`origin`。
3. `own` 资产设置 `source.kind: local`，不要在提交文件里写本机绝对路径。
4. `third` 资产先确认或发现上游来源。
5. 添加 `agent-engineering.yaml`。
6. 如果知道自有资产的本机路径，添加同目录 `agent-engineering.local.yaml`，但保持未跟踪。

## Git 规则

提交前必须：

1. 运行 `git status --short`。
2. 确认 `**/agent-engineering.local.yaml` 被忽略或未跟踪。
3. 确认 diff 只包含目标资产目录和必要仓库元数据。
4. 运行轻量验证，例如 YAML 解析、Skill 校验、空白检查。
5. commit message 写清资产和动作，例如 `Add agent-engineering skill`、`Refresh third-party web-design skill`。

## 安全默认值

- 不安装资产到本地 Agent 运行目录。
- 不把 MCP token、访问令牌、cookie 或本机绝对路径写入提交文件。
- 不在刷新三方资产时静默删除本地整理内容。
- 不在未确认的情况下把资产从 `own` 移到 `third`，或从 `third` 移到 `own`。
