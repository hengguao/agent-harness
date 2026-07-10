---
name: weekly-report
description: >-
  周报生成技能：基于 git commit + 飞书项目数据，生成草稿→卡片确认→飞书 Wiki 归档。
  使用前需在 skill 同目录创建 config.yaml 配置个人参数。
---

# 周报生成技能

当用户要求生成周报时，按本技能执行。本技能只固化**通用流程**，不把任何人的项目、飞书空间、归档位置写死。个人差异由同目录 `config.yaml` 配置。

> **使用前必读：** 复制本技能文件到 `~/.claude/skills/weekly-report/SKILL.md`，并在同目录创建 `config.yaml`（见下文"配置模板"）。不创建配置则无法执行。

---

## 一、核心概念（重要！）

### 1. "本周"的定义

> **"本周"是以当前会话日期为基准的、包含今天的自然工作周。**
>
> - 统计周期：本周周一 → 本周周五
> - 文档日期：本周周五，格式 `YYYY-MM-DD`
> - 每次生成周报，都必须**按今天的日期重新计算**本周范围，不能沿用之前会话的周期
>
> 例：今天周四 2026/06/11 → 本周为 6/8（周一）至 6/12（周五），文档名 `2026-06-12`

### 2. "上周遗留事项"的格式

对照**上周已发布的周报**中的"下周计划"逐项填写，固定格式：
```text
- 上周计划 1：<上周周报中的计划条目>
  - 完成情况：已完成 | 进行中 | 未开始
  - 结果说明：<结合本周 commit / 飞书任务说明完成度>
- 上周计划 2：
  - 完成情况：
  - 结果说明：
```

### 3. "下周计划"的推断规则

> **优先从飞书项目管理中当前用户的未完成任务提取**，而不是基于本周 commit 写延续事项。
>
> 查询条件：`current_status_operator` 包含当前用户、且 `work_item_status != '已完成'` 的任务。
> 过滤口径：`待验收` 状态不写入"本周完成"、"进行中事项"或"下周计划"；仅当它用于承接上周周报里的计划时，才写入"上周计划完成情况/上周遗留事项"。
>
> 如果本周完成的工作属于某个大型需求（如"麓豆会员等级"）的子任务，下周计划就写该大型需求下其余待推进的子任务。

---

## 二、触发条件

用户提到以下任一意图时触发：

- 输出周报 / 本周周报 / 生成周报 / 写周报
- 周报草稿 / 发起周报 / 提交周报 / 发布周报

---

## 三、流程总览

```
阶段一（草稿）                    阶段二（归档）
  │                                 │
  ├─ 读取 config.yaml               ├─ 用户点击"发布"按钮
  ├─ 计算本周日期范围                │   或明确说：确认/提交/发布/归档
  ├─ 拉取 git commit                │
  ├─ 拉取飞书项目数据                ├─ 读取模板结构
  ├─ 读取上周已发布周报               ├─ 基于草稿创建文档
  ├─ 读取模板结构                    ├─ bot 优先→user 回退
  ├─ 合并生成草稿                    ├─ 写入正文
  ├─ 发发布卡到当前会话               ├─ 验证位置+内容非空
  │   （仅一个"发布"按钮）            └─ 返回文档链接
  └─ 等用户修改 or 点发布
```

---

## 四、阶段一：草稿生成

### 步骤 1：读取配置

读取 skill 同目录下的 `config.yaml`。如果文件不存在，提示用户先创建配置，不自行猜测。

### 步骤 2：计算统计周期

```python
# 伪代码逻辑
today = date.today()
# 本周一
monday = today - timedelta(days=today.weekday())
# 本周五
friday = monday + timedelta(days=4)
# 文档名称
doc_title = friday.strftime("%Y-%m-%d")
```

### 步骤 3：收集 git commit

从配置中的仓库列表逐一拉取本周真实 commit：

```bash
AUTHOR=$(git -C "<repo_path>" config user.name)
git -C "<repo_path>" log \
  --since="<本周一> 00:00" \
  --until="<本周五> 23:59" \
  --author="$AUTHOR" \
  --date=short \
  --pretty=format:"%ad %h %s"
```

### 步骤 4：收集飞书项目数据

**已完成任务（用于"本周完成"）：**
```sql
SELECT `name`, `work_item_status`, `current_status_operator`,
       `finish_time`, `updated_at`, `points`
FROM `<space_name>`.`<task_type>`
WHERE `work_item_status` = '已完成'
  AND array_contains(`current_status_operator`, '<id:USER_KEY>')
  AND `finish_time` between '<本周一>' and '<本周五>'
ORDER BY `finish_time` DESC
LIMIT 50
```

**未完成任务（用于"下周计划"推断）：**
```sql
SELECT `name`, `work_item_status`
FROM `<space_name>`.`<task_type>`
WHERE `work_item_status` != '已完成'
  AND `work_item_status` != '待验收'
  AND array_contains(`current_status_operator`, '<id:USER_KEY>')
ORDER BY `updated_at` DESC
LIMIT 50
```

**父需求匹配（了解大需求归属）：**
```sql
-- 确认任务所属的父需求
SELECT `name` FROM `<space_name>`.`任务`
WHERE any_relation_match(
  relation_field_chain('__父工作项'),
  x -> x.`name<target:all>` = '<父需求名称>'
)
```

### 步骤 5：读取上周已发布周报

从归档 Wiki 节点下列出子节点，找到上一周（上周五日期）的文档，读取其"下周计划"章节内容，用于填写"上周遗留事项"。

### 步骤 6：读取模板

从配置的 `template_wiki` 读取文档结构。模板结构大致为：

```markdown
一、上周工作回顾
  1. 上周计划完成情况
  2. 上周遗留事项
  3. 上周问题跟进
二、本周完成
三、进行中事项
四、问题与风险
五、下周计划
六、需要支持
```

### 步骤 7：合并生成正文草稿

**合并规则：**

- git commit 和飞书任务能对应的，合并成一条自然工作成果
- 同一模块、同一业务目标的多条 commit 要归并
- 英文 commit 输出中文描述
- 本周完成格式：
  ```text
  - [项目别名] 完成了<归并后的业务事项>。（M.DD）
  - [项目别名] 完成了<归并后的业务事项>。（M.DD-M.DD）  // 跨多日
  ```
- 空章节保留标题，正文按模板要求写"暂无"
- 涉及大型需求的子任务，描述中写明"完成<需求名>下的<子任务>"
- `待验收` 状态数据不纳入"本周完成"、"进行中事项"、"下周计划"；除非它是在回顾上周计划完成情况
- 不编造没有依据的工作，不写"可能""大概"等猜测语气

**数据交叉验证：**

| 场景 | 处理方法 |
|------|----------|
| commit 有 + 飞书任务有 | 合并成一条，用业务语言描述 |
| commit 有，飞书任务无 | 归入"其他开发事项"或对应业务模块 |
| 飞书任务有，commit 不明显 | 可写任务完成，不扩展技术细节 |
| commit 和任务都没有 | 不写 |

### 步骤 8：发草稿到当前会话

**关键规则：不反复文字询问"这个版本如何"。**

直接发一张飞书交互卡片（CardKit 2.0），包含草稿正文和一个**唯一的"发布"按钮**：

```json
{
  "schema": "2.0",
  "body": {
    "elements": [
      { "tag": "markdown", "content": "..." },
      {
        "tag": "button",
        "text": { "tag": "plain_text", "content": "发布" },
        "type": "primary",
        "behaviors": [{
          "type": "callback",
          "value": { "__claude_cb": true, "action": "publish" }
        }]
      }
    ]
  }
}
```

- 不使用 `tag: "action"` 容器（CardKit 2.0 不支持），按钮直接在 `elements` 层级
- 用户如需修改，直接在会话里发消息说明，不提供"继续修改"按钮
- 卡片用 `--as bot` 发送，如 bot 无 `im:message` 权限则提示用户补充 scope

---

## 五、阶段二：发布归档

用户点击"发布"按钮或明确说"确认/发布/归档"后执行。

### 步骤 1：确定归档位置

归档完整路径格式（由 config.yaml 配置）：

```
<空间根目录> > <子目录> > ... > <归档父节点> > YYYY-MM-DD
```

### 步骤 2：创建文档节点

优先级：**bot 优先 → user 回退**

```bash
# 1. 尝试 bot
lark-cli wiki +node-create --as bot \
  --parent-node-token "<parent_node_token>" \
  --title "YYYY-MM-DD" \
  --obj-type docx

# 2. 如果 bot 报 131006 permission denied，回退到 user
lark-cli wiki +node-create --as user \
  --parent-node-token "<parent_node_token>" \
  --title "YYYY-MM-DD" \
  --obj-type docx
```

### 步骤 3：写入正文

将草稿内容转为 XML 格式，用 `docs +update` 写入：

```bash
lark-cli docs +update --as user --api-version v2 \
  --doc "<obj_token>" \
  --command overwrite \
  --content @./content.xml \
  --new-title "YYYY-MM-DD"
```

### 步骤 4：验证

归档完成后必须验证两个条件：

1. **父节点确认** — 新文档的 `parent_node_token` 确实是指定父节点
2. **正文非空** — `docs +fetch` 获取内容，长度 > 50 字符

### 步骤 5：返回结果

返回文档链接，并清理临时文件。

---

## 六、配置模板

在 skill 同目录创建 `config.yaml`，按实际填写：

```yaml
weekly_report:
  # === 负责人 ===
  owner:
    name: "姓名"                     # 显示名称
    feishu_user_key: ""              # 飞书 user_key（可从飞书个人资料获取）
    git_author: "auto"               # auto = 每个仓库读取 git config user.name

  # === 日期周期 ===
  period:
    type: "work_week"                # work_week | calendar_week | custom
    start_day: "monday"
    end_day: "friday"
    document_date: "friday"          # 文档使用周五日期
    date_format: "YYYY-MM-DD"

  # === 输出 ===
  output:
    draft_target: "chat"             # chat | file
    confirmation_required: true       # 是否需要在草稿后确认
    archive_target: "feishu_wiki"    # feishu_wiki | file | none

  # === 飞书项目 ===
  feishu:
    enabled: true
    project_key: ""                  # 空间 projectKey
    space_name: ""                   # 空间名称
    task_type: "任务"                 # 中文名
    task_type_key: "sub_task"        # 工作项类型 key
    owner_field: "current_status_operator"
    status_field: "work_item_status"
    finish_time_field: "finish_time"
    point_field: "points"
    done_value: "已完成"
    parent_filters: []               # 可选，限定父需求
    template_wiki: ""                # 模板 Wiki URL
    archive_wiki: ""                 # 归档父节点 Wiki URL

  # === Git 仓库 ===
  git:
    enabled: true
    repos:
      - path: "/path/to/repo1"
        alias: "项目别名"             # 周报中显示的别名
        author: "auto"

  # === 模板 ===
  template:
    source: "feishu_wiki"            # feishu_wiki | default
    keep_empty_sections: true

  # === 样式 ===
  style:
    language: "zh-CN"
    concise: true
    group_by_business: true
```

---

## 七、技能成功标准

### 草稿阶段

- [ ] 已读取配置或明确告知缺失配置
- [ ] 统计周期按今天日期正确计算
- [ ] 已拉取 git commit 和飞书项目数据
- [ ] 已参考上周已发布周报填写"上周遗留事项"
- [ ] 已按模板结构生成正文
- [ ] 未在未确认时执行归档
- [ ] 以卡片形式发送（仅一个"发布"按钮），而非文字询问

### 归档阶段

- [ ] 用户已确认（点发布按钮或文字确认）
- [ ] 节点已创建在指定父节点下
- [ ] 正文已写入且非空
- [ ] 已返回可访问的文档链接
- [ ] 如失败，已说明失败原因

---

## 八、常见问题处理

| 问题 | 处理方式 |
|------|----------|
| bot 无 wiki 编辑权限 | 回退到 `--as user` 执行 |
| bot 无发消息权限 | 提示用户运行 `lark-cli auth login --scope "im:message.send_as_user im:message"` |
| 飞书项目查不到数据 | 逐层检查：project_key → work_item_type → field 名 → user_key |
| 上周周报不存在 | "上周遗留事项"写"暂无"，并说明未找到上周周报 |
| 用户对草稿有修改 | 直接在会话中接收修改要求，更新草稿后重新发卡 |
