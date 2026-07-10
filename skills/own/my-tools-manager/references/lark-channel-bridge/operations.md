# lark-channel-bridge 升级后重启 / 迁移 SOP

不要把“升级后重启”一律等同于直接 `restart`。先判断当前是不是“旧运行态 + 新 CLI”混跑，再决定是否需要显式迁移。

先做交叉检查，不只看单一命令：

```bash
lark-channel-bridge ps
pgrep -af lark-channel-bridge || true
launchctl list | rg 'lark-channel-bridge|ai\.lark-channel-bridge' || true
```

如果同时满足下面任一类特征，按“显式迁移重启”处理，不直接执行 `restart`：

1. `ps` / `status` 与系统真实运行状态不一致。
2. 根目录 `~/.lark-channel/processes.json` 里是旧 entry，缺少 `profileName`、`agentKind`。
3. `~/.lark-channel/config.json` 仍是 legacy 单配置结构，没有 `schemaVersion: 2`、`profiles`、`activeProfile`。

显式迁移重启顺序：

1. 先确认迁移目标 profile 目录不存在冲突。
2. 停掉旧 daemon，避免 v2 迁移被活动旧进程阻塞。
3. 显式执行迁移。
4. 确认 `active-profile`、`profiles/<profile>/`、`config.json.bak` 已生成，且旧 `sessions` / `workspaces` / `logs` / `media` / `secrets` 已迁走。
5. 用新版 profile 服务启动。
6. 用 `ps`、`status --profile <name>`、系统服务状态三方交叉验证。

macOS 上推荐命令顺序：

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.lark-channel-bridge.bot.plist
lark-channel-bridge migrate --profile claude --agent claude
lark-channel-bridge start --profile claude
lark-channel-bridge ps
lark-channel-bridge status --profile claude
launchctl list | rg 'lark-channel-bridge|ai\.lark-channel-bridge' || true
```

如果已经确认是 v2 正常运行态，再执行普通重启：

```bash
lark-channel-bridge restart --profile <name>
lark-channel-bridge status --profile <name>
```
