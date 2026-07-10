# agent-engineering.yaml 规范

元数据保持小而稳定。不要把本机绝对路径写入提交文件。

## 自有资产

```yaml
name: my-tools-manager
type: skill
origin: own

source:
  kind: local

sync:
  mode: manual
  last_checked:
  last_updated:
  version:
  notes: 本机工具生命周期管理 Skill。
```

自有本地资产的本机路径写到同目录、被 git 忽略的 `agent-engineering.local.yaml`：

```yaml
source:
  path: /Users/example/.codex/skills/my-tools-manager
```

## agent-engineering 技能自身的本地配置

`skill/own/agent-engineering/agent-engineering.local.yaml` 用来记录本地副本路径，不使用 `source.path`，避免和普通资产来源路径混淆：

```yaml
repository:
  path: /Users/example/.agents/repos/agent-engineering
```

如果该文件不存在，或 `repository.path` 指向的路径不存在，应先向用户确认本地代码存放路径，再写入该文件并 clone 仓库。

## 三方 Git 资产

```yaml
name: web-design-guidelines
type: skill
origin: third

source:
  kind: git
  url: https://github.com/vercel-labs/agent-skills
  ref: main
  path: skills/web-design-guidelines

sync:
  mode: mirror
  last_checked:
  last_updated:
  version:
  notes:
```

## 三方 URL 资产

```yaml
name: example-prompt
type: prompt
origin: third

source:
  kind: url
  url: https://example.com/prompt.md

sync:
  mode: curated
  last_checked:
  last_updated:
  version:
  notes: 本地保留了格式调整，刷新前先看 diff。
```

## 字段说明

- `name`：资产名称。默认和目录名一致。
- `type`：`skill`、`prompt`、`cli`、`mcp`、`hook`、`workflow`、`plugin`、`agent` 或 `ecosystem`。
- `origin`：`own` 或 `third`。
- `source.kind`：`local`、`git`、`npm` 或 `url`。
- `source.url`：三方来源 URL。
- `source.ref`：Git 分支、tag 或 commit。
- `source.path`：上游来源内部路径。提交文件里不要用这个字段记录本机绝对路径。
- `sync.mode`：`manual`、`mirror` 或 `curated`。
- `sync.last_checked`：最近一次检查上游的日期或时间戳。
- `sync.last_updated`：最近一次更新仓库内容的日期或时间戳。
- `sync.version`：上游版本、tag、commit、包版本或其它稳定标记。
- `sync.notes`：本地整理、限制或更新策略的简短说明。

## 同步模式

- `manual`：只在用户明确发布或编辑时更新。
- `mirror`：刷新时优先跟随上游。
- `curated`：跟踪上游，但保留本地整理，覆盖前需要确认。
