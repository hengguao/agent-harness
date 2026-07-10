# codegraph 管理规则

## 工具信息

- npm 包名：`@colbymchenry/codegraph`
- CLI 命令：`codegraph`
- 官方仓库：https://github.com/colbymchenry/codegraph
- 官方文档：https://colbymchenry.github.io/codegraph/
- npm 包：https://www.npmjs.com/package/@colbymchenry/codegraph
- 推荐安装渠道：全局 npm
- 常见全局前缀：通过 `npm config get prefix` 动态确认
- 常见包目录：通过 `npm root -g` 动态确认

## 自更新流程

使用 `工具信息` 中的官方仓库、官方文档和 npm 包地址核对最新规则。

自更新时重点检查：

1. README / 文档是否仍推荐 `npm i -g @colbymchenry/codegraph@latest` 或出现新的推荐 installer。
2. `codegraph install` 是否改变 agent/MCP 配置行为。
3. `serve --mcp` 的启动参数是否变化。
4. MCP 配置 JSON 是否仍使用 `command: "codegraph"` 和 `args: ["serve", "--mcp"]`。
5. 项目索引目录 `.codegraph/` 的创建、删除、同步规则是否变化。
6. npm latest、CLI 版本、bin 路径和 Node 要求是否变化。

更新 reference 前先汇总差异；不要删除任何项目里的 `.codegraph/` 索引目录规则，除非官方文档和用户确认都要求调整。

## 检查命令

```bash
command -v codegraph || true
codegraph --version
npm list -g @colbymchenry/codegraph --depth=0
npm config get prefix
npm root -g
```

## 安装

```bash
npm i -g @colbymchenry/codegraph@latest
```

## 升级

```bash
npm i -g @colbymchenry/codegraph@latest
```

## 重装

```bash
npm uninstall -g @colbymchenry/codegraph
npm i -g @colbymchenry/codegraph@latest
```

## 验证

```bash
codegraph --version
command -v codegraph
npm root -g
npm list -g @colbymchenry/codegraph --depth=0
codegraph --help
```

若 `codegraph --help` 短时间没有退出，等待输出；确认不是后台服务后结束会话，避免遗留进程。

## 安装位置说明

- CLI 路径：以 `command -v codegraph` 为准。
- npm 包目录：`$(npm root -g)/@colbymchenry/codegraph`。
- 若 CLI 是符号链接，可用 `ls -l "$(command -v codegraph)"` 说明真实指向。

## cc-switch MCP 配置提醒

用户使用 cc-switch 管理 MCP 时，默认不要直接修改配置。处理完安装/升级/重装后，主动提醒是否需要更新 MCP 配置，并给出配置项。

如果 `codegraph` 在 PATH 中：

```json
{
  "mcpServers": {
    "codegraph": {
      "type": "stdio",
      "command": "codegraph",
      "args": ["serve", "--mcp"]
    }
  }
}
```

如果 `codegraph` 不在 PATH 中，把 `command` 改为实际绝对路径，例如：

```json
{
  "mcpServers": {
    "codegraph": {
      "type": "stdio",
      "command": "/opt/homebrew/bin/codegraph",
      "args": ["serve", "--mcp"]
    }
  }
}
```

## 注意事项

- 不要删除任何项目里的 `.codegraph/` 索引目录，除非用户明确要求。
- `codegraph install` 会写 agent/MCP 配置；只有用户明确要求配置 agent 时才执行。
- 初始化项目索引使用 `codegraph init -i <path>`，仅在用户明确要求为某个项目启用索引时执行。
