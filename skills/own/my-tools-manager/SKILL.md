---
name: my-tools-manager
description: 用于管理本机命令行工具、MCP 工具或开发辅助工具的安装、升级、重装、卸载前检查、版本验证、安装路径确认与配置提醒。用户要求安装、更新、升级、重装、检查安装状态、修复 PATH、确认工具装到哪里，或提到 codegraph、Claude Code、Codex CLI、Gemini CLI、GitHub CLI、gh、kimi-webbridge、飞书 CLI、lark-cli、lark-channel-bridge、lark-coding-agent-bridge、botmux 等工具生命周期管理时使用。
---

# My Tools Manager

## 核心目标

把“某个工具是否已安装、该安装还是升级、是否需要重装、装到哪里、配置是否要更新”处理成稳定流程。优先使用工具官方推荐方式和本机已验证路径；不要凭记忆对未知工具写死安装命令。

## 执行流程

1. 明确目标工具和用户动作：
   - 用户明确说“重装”：执行重装流程。
   - 用户明确说“只检查/不要改”：只检查，不安装、不升级、不写配置。
   - 未安装：执行安装流程。
   - 已安装：执行升级流程。
2. 读取对应工具 reference：
   - `codegraph`：读取 `references/codegraph.md`。
   - `Claude Code` / `claude`：读取 `references/claude-code.md`。
   - `Codex CLI` / `codex`：读取 `references/codex-cli.md`。
   - `Gemini CLI` / `gemini`：读取 `references/gemini-cli.md`。
   - `GitHub CLI` / `gh`：读取 `references/github-cli.md`。
   - `kimi-webbridge`：读取 `references/kimi-webbridge.md`。
   - `lark-cli` / 飞书 CLI：读取 `references/lark-cli.md`。
   - `lark-channel-bridge` / `lark-coding-agent-bridge`：读取 `references/lark-channel-bridge.md`。
   - `botmux`：读取 `references/botmux.md`。
   - 未收录工具：按“未知工具处理”执行。
   - 用户要求刷新、核对或自更新某个工具规则时，读取对应 reference 的 `自更新流程`。
3. 执行前先检查：
   - 可执行命令是否存在：`command -v <cmd>`
   - 当前版本：优先 `<cmd> --version`、`<cmd> -v` 或工具 reference 指定命令。
   - 安装来源：npm、brew、pipx、二进制、项目脚本或其他渠道。
   - 包管理器根目录或二进制真实路径。
4. 执行安装/升级/重装：
   - 使用 reference 中已验证的命令。
   - reference 不存在或信息不足时，先查官方文档、包管理器元信息或本地项目说明，再执行。
   - 重装必须先确认卸载目标是同一安装来源，避免误删其他来源安装。
5. 执行后验证：
   - 版本命令能正常返回。
   - `command -v <cmd>` 能定位到可执行文件。
   - 能确认实际安装目录。
   - 如工具提供 `--help`，用它做轻量启动验证；若命令进入交互，读取输出后及时结束。
6. 输出结论：
   - 动作：安装、升级、重装或只检查。
   - 当前版本。
   - CLI 路径。
   - 实际包/二进制目录。
   - 验证结果和限制项。
   - 是否需要更新 MCP、PATH、shell 配置或其他外部配置。

## 配置处理规则

- 如果用户使用 cc-switch 管理 MCP：默认只提醒是否需要更新配置，并给出具体配置项；不要擅自写 cc-switch 配置。
- 只有用户明确要求“帮我更新配置/写入配置/修改 cc-switch”时，才修改配置文件。
- 发现命令不在 PATH 时，配置里的 `command` 使用绝对路径，并提醒用户是否要修 PATH。
- 不删除项目数据、索引、缓存或配置目录，除非用户明确要求并确认影响范围。

## 自更新规则

当用户要求“刷新工具规则”“自更新 Skill”“核对某工具最新安装方式”时：

1. 读取对应 reference 的 `工具信息` 和 `自更新流程`。
2. 使用 `工具信息` 中已有的官方文档、官网、GitHub、安装脚本或包元信息地址；不要在 `自更新流程` 里复制维护第二份官方地址。
3. 拉取官方来源并核对安装、升级、重装、卸载、验证、运行、配置、数据目录和风险提示是否变化。
4. 先向用户汇总差异和建议改动，不直接写文件。
5. 保留本地经验策略，例如“当前机器 npm 安装则升级沿用 npm”；只有用户明确要求迁移安装来源时才改。
6. 写入后运行 `quick_validate.py`，并检查 TODO、占位和明显过期内容。

## 未知工具处理

对未收录工具执行保守发现流程：

1. 询问或从上下文识别工具的官方名称、仓库、包名和期望安装方式。
2. 优先检查本机已有来源：`command -v`、包管理器列表、项目 README、官方文档。
3. 若信息可能过期或会影响用户环境，必须查官方来源确认最新安装方式。
4. 安装前说明将使用的安装渠道和目标位置。
5. 完成后把稳定命令和验证方式建议沉淀到新的 reference 文件。

## 输出模板

```text
已完成：<安装/升级/重装/检查> <工具名>

- 当前版本：<version>
- CLI 路径：<path>
- 安装目录：<dir>
- 验证：<通过/部分通过，说明限制>

配置提醒：
<是否需要更新 MCP/PATH/其他配置；如需要，给出具体配置片段。>
```

## reference 维护规则

当需要把新经验、稳定命令、验证方式或风险提示沉淀到 `references/*.md` 时：

1. 写入前先对比同目录同类 reference 的章节大纲。
2. 把新增规则归入已有流程节点，例如检查命令、安装来源判断、安装、升级、重装、验证、安装位置说明、配置提醒。
3. 同一条经验只放在它所属的流程节点：来源识别放安装来源判断，执行异常放安装/升级/重装，完成判定放验证。
4. 避免随手新增“经验/提醒/注意事项”类孤立章节；只有同类 reference 已有对应章节，或该工具确实需要独立风险入口时，才新增同级章节。
5. 写入后检查重复段落和章节结构是否与同类 reference 保持一致。
