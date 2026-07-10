# lark-channel-bridge 本地定制改造：按群免 @

这台机器有一个本地定制需求：在全局 `requireMentionInGroup` 之外，增加 `access.bypassMentionChats` 白名单，允许指定群在不 @ bot 的情况下也能触发回复。

这个改造当前是直接改已安装包的编译产物：

```text
/opt/homebrew/lib/node_modules/lark-channel-bridge/dist/cli.js
```

因此每次执行 `npm i -g lark-channel-bridge@latest` 之后，这个改造都会丢失。后续升级时，除了常规升级与重启，还要补做“代码复核 + 重新改造”。

## 先复核，再改造

不要按历史行号盲改。升级后先对照新版本代码，确认下面核心锚点仍然存在且职责没变：

```bash
rg -n "function normalizeAccess|function getRequireMentionInGroup|async function saveAccessConfig|getRequireMentionInGroup\\(controls\\.cfg\\)|function configFormCard|function configSavedCard|async function showConfigForm|async function submitConfig" \
  /opt/homebrew/lib/node_modules/lark-channel-bridge/dist/cli.js -n -S
```

只有在下面条件仍成立时，才按既有方案重做：

1. `normalizeAccess` 仍负责把 `access` 配置规范化。
2. `getRequireMentionInGroup` 仍负责决定群消息是否必须 @ bot。
3. `saveAccessConfig` 的 legacy 分支仍会把 `access` 回写到旧格式配置。
4. 消息 intake 仍通过 `getRequireMentionInGroup(controls.cfg)` + `!msg.mentionedBot` 决定是否跳过群消息。
5. `configFormCard` 仍负责 `/config` 表单卡片结构。
6. `showConfigForm` 仍负责给 `configFormCard` 传入访问控制数据和 `knownChats`。
7. `submitConfig` 仍负责处理 `/config` 表单提交并写配置。

如果任何一个锚点消失、职责变化、参数变化，或消息入口逻辑已重构，就不要沿用旧补丁；必须基于升级后的新代码重新设计改造点。

## 当前 0.5.3 已核对通过的改造点

基于 `lark-channel-bridge 0.5.3`，下面改造逻辑是成立的：

1. `normalizeAccess`
   新增 `bypassMentionChats` 规范化。这里优先沿用现有风格，使用 `stringArray(...)`，不要直接用 `Array.isArray(...) ? raw : []`，避免把非字符串值带进配置。
2. `getRequireMentionInGroup`
   改为接收 `chatId`，并在 `cfg.access.bypassMentionChats` 命中时直接返回 `false`。
3. `saveAccessConfig`
   仅 legacy / `!root` 分支需要额外透传 `bypassMentionChats`；当前 v2 profile 分支本来就会把整个 `access` 对象写回 `root.profiles[profile].access`，这里不需要额外补字段。
4. 消息分发入口
   把 `getRequireMentionInGroup(controls.cfg)` 改成 `getRequireMentionInGroup(controls.cfg, msg.chatId)`。
5. `/config` 表单
   在“访问控制”折叠面板下方新增独立的“🧩 用户自定义（点击展开）”折叠面板，默认收起，展示当前 `access.bypassMentionChats`。
6. `/config` 新增 / 移除
   “新增免 @ 群”使用 `knownChats`（bot 当前所在群聊）作为候选；提交时同步写入 `allowedChats` 和 `bypassMentionChats`，保证新增后该群会响应且免 @。“移除免 @ 群”只从 `bypassMentionChats` 中删除，不移出 `allowedChats`。
7. `/config` 保存结果
   保存成功卡片里的“用户自定义”区域展示更新后的免 @ 群数量。

## 0.5.3 可复用的改造片段

修改 `normalizeAccess`：

```javascript
function normalizeAccess(access3, legacyRequireMentionInGroup) {
  return {
    allowedUsers: stringArray(access3?.allowedUsers),
    allowedChats: stringArray(access3?.allowedChats),
    admins: stringArray(access3?.admins),
    bypassMentionChats: stringArray(access3?.bypassMentionChats),
    requireMentionInGroup: access3?.requireMentionInGroup ?? legacyRequireMentionInGroup ?? true
  };
}
```

修改 `getRequireMentionInGroup`：

```javascript
function getRequireMentionInGroup(cfg, chatId) {
  if (chatId && Array.isArray(cfg.access?.bypassMentionChats) && cfg.access.bypassMentionChats.includes(chatId)) {
    return false;
  }
  if (cfg.preferences?.requireMentionInGroup !== void 0) {
    return cfg.preferences.requireMentionInGroup !== false;
  }
  const profileAccess = cfg.access;
  if (profileAccess?.requireMentionInGroup !== void 0) {
    return profileAccess.requireMentionInGroup;
  }
  return true;
}
```

修改 `saveAccessConfig` 的 legacy 透传分支：

```javascript
ctx.controls.cfg.preferences = {
  ...ctx.controls.cfg.preferences ?? {},
  access: {
    allowedUsers: access4.allowedUsers,
    allowedChats: access4.allowedChats,
    admins: access4.admins,
    bypassMentionChats: access4.bypassMentionChats
  },
  requireMentionInGroup: access4.requireMentionInGroup
};
```

修改消息分发入口：

```javascript
if (msg.chatType !== "p2p" && getRequireMentionInGroup(controls.cfg, msg.chatId) && !msg.mentionedBot) {
```

`/config` 表单新增辅助方法：

```javascript
function chatSelectOptions(chatIds, knownChats, emptyLabel) {
  const nameMap = new Map(knownChats.map((chat) => [chat.id, chat.name]));
  return [
    { text: { tag: "plain_text", content: emptyLabel }, value: "__none__" },
    ...chatIds.map((id) => ({
      text: { tag: "plain_text", content: `${nameMap.get(id) ?? "(未知群)"}（...${id.slice(-6)}）` },
      value: id
    }))
  ];
}
```

`configFormCard` 中新增“用户自定义”折叠面板：

```javascript
const bypassMentionChats = opts.bypassMentionChats ?? [];
const bypassMentionChatSet = new Set(bypassMentionChats);
const knownChatIds = opts.knownChats.map((chat) => chat.id);
const addableBypassMentionChats = knownChatIds.filter((chatId) => !bypassMentionChatSet.has(chatId));
const customElements = [
  {
    tag: "markdown",
    content: `**免 @ 群**（共 ${opts.bypassMentionChats?.length ?? 0} 个）
${chatList(opts.bypassMentionChats ?? [], opts.knownChats)}

_这些群里不需要 @ bot 也会触发回复。其他群仍按「群里需要 @ bot」的全局设置处理。_`
  },
  { tag: "hr" },
  {
    tag: "markdown",
    content: "**新增免 @ 群**\n_只能从我所在群聊里选。_"
  },
  {
    tag: "select_static",
    name: "bypass_mention_add_chat",
    initial_option: "__none__",
    options: chatSelectOptions(addableBypassMentionChats, opts.knownChats, "不新增")
  },
  {
    tag: "markdown",
    content: "\n**移除免 @ 群**"
  },
  {
    tag: "select_static",
    name: "bypass_mention_remove_chat",
    initial_option: "__none__",
    options: chatSelectOptions(bypassMentionChats, opts.knownChats, "不移除")
  }
];
```

把“用户自定义”面板放在“访问控制”面板下方：

```javascript
collapsedAccessPanel("🔒 **访问控制**（点击展开）", accessElements),
collapsedAccessPanel("🧩 **用户自定义**（点击展开）", customElements),
```

`showConfigForm` 和 `configSavedCard` 调用都需要传入：

```javascript
bypassMentionChats: access3.bypassMentionChats,
```

`submitConfig` 中处理新增 / 移除：

```javascript
const rawBypassMentionAddChat = String(fv.bypass_mention_add_chat ?? "").trim();
const rawBypassMentionRemoveChat = String(fv.bypass_mention_remove_chat ?? "").trim();
const addBypassMentionChat = rawBypassMentionAddChat && rawBypassMentionAddChat !== "__none__" ? rawBypassMentionAddChat : "";
const removeBypassMentionChat = rawBypassMentionRemoveChat && rawBypassMentionRemoveChat !== "__none__" ? rawBypassMentionRemoveChat : "";
if (addBypassMentionChat || removeBypassMentionChat) {
  nextAccess = await saveAccessConfig(ctx, (current) => {
    const allowedChats = new Set(current.allowedChats);
    const bypassMentionChats = new Set(current.bypassMentionChats ?? []);
    if (addBypassMentionChat) {
      allowedChats.add(addBypassMentionChat);
      bypassMentionChats.add(addBypassMentionChat);
    }
    if (removeBypassMentionChat) {
      bypassMentionChats.delete(removeBypassMentionChat);
    }
    return {
      ...current,
      allowedChats: [...allowedChats],
      bypassMentionChats: [...bypassMentionChats]
    };
  });
}
```

## 升级 + 改造执行顺序

1. 升级 CLI。
2. 先按主文档“升级后重启 / 迁移 SOP”完成服务切换。
3. 对照新版本代码复核核心锚点。
4. 只有确认仍适用，才重做本地编译产物改造。
5. 改造后再次重启对应 profile。
6. 验证：
   - `node --check /opt/homebrew/lib/node_modules/lark-channel-bridge/dist/cli.js` 通过。
   - `lark-channel-bridge --version` 能返回当前版本。
   - `lark-channel-bridge restart --profile <name>` 成功，`ps` 显示新版本后台进程。
   - 在 `bypassMentionChats` 里的已授权群，不 @ bot 也会回复。
   - 在已授权但不在 `bypassMentionChats` 的群里，不 @ bot 不回复。
   - `/config` 中“访问控制”下方出现“🧩 用户自定义（点击展开）”；展开后能看到当前免 @ 群、新增免 @ 群、移除免 @ 群。
   - 新增免 @ 群的候选来自 bot 当前所在群聊；提交后该群同时进入 `allowedChats` 和 `bypassMentionChats`。
   - 私聊、@ bot、授权白名单逻辑没有回归。
