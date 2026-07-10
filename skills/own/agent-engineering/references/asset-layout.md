# 资产目录规范

本仓库是个人 Agent 工程资产库。资产维护和运行时安装是两件事，默认只维护仓库内容，不安装到本机 Agent。

## 顶层资产类型

使用这些顶层目录：

```text
agent/
cli/
ecosystem/
hook/
mcp/
plugin/
prompt/
skill/
workflow/
```

每个类型目录下都按来源拆分：

```text
<type>/own/<asset-name>/
<type>/third/<asset-name>/
```

## 来源含义

- `own`：自己创建或主动维护的资产。
- `third`：从上游镜像、收集或轻度整理的三方资产。

不要在同一个资产目录里混放自有内容和三方内容。

## 资产目录

一个资产目录通常包含：

```text
资产文件...
agent-engineering.yaml
agent-engineering.local.yaml  # 可选，git 忽略
```

`agent-engineering.local.yaml` 只用于本机绝对路径和机器相关覆盖配置。它要放在对应资产目录内，和 `agent-engineering.yaml` 同级，避免维护一个中心映射文件。

普通自有资产用 `source.path` 记录本机来源路径。`agent-engineering` 技能自身用 `repository.path` 记录本地副本路径。

## 文件清理

发布或刷新资产时排除：

```text
.DS_Store
.git/
node_modules/
__pycache__/
dist/
build/
*.log
*.tmp
```

三方资产要保留上游 license、notice、attribution 等文件。
