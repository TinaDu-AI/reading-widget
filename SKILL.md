---
name: reading-widget
description: 在 macOS 桌面上放一个微信读书数据小卡片，自动显示连续阅读天数、今日/本月阅读时长、本月目标进度、当前在读、年度读完本数和当下金句。安装后通过 Chrome --app 模式打开成无边框窗口贴在屏幕角落。触发：用户说"装阅读 widget"、"做个读书桌面小卡片"、"reading widget"、"放个微信读书的桌面 widget"、"我想 track 我的阅读"。
version: 1.0.0
---

# Reading Widget — 微信读书桌面小卡片

把当前用户的微信读书数据渲染成一个 268px 宽的暗色小卡片，放在桌面上。卡片每 5 分钟自动刷新一次。

## 安装流程（Claude 按顺序执行）

### Step 1 — 确认前置依赖

1. 检查 `WEREAD_API_KEY` 是否已设置：
   - 先看 `~/.claude/settings.json` 的 `env` 字段
   - 再看当前 shell 环境变量
2. **如果没有 API key**：
   - 告诉用户 key 格式是 `wrk-xxxxxxxx`，绑定用户身份（vid）
   - 让用户参考微信读书官方 skill 包获取：`https://cdn.weread.qq.com/skills/weread-skills.zip`，解压后看 `SKILL.md` 的"鉴权"章节
   - 拿到 key 后写进 `~/.claude/settings.json` 的 `env` 字段（不要写进 shell rc，避免泄露到其它进程），格式：
     ```json
     { "env": { "WEREAD_API_KEY": "wrk-xxxxxxxx" } }
     ```
3. 检查 `python3` 是否可用（`which python3`）。macOS 自带；如缺失提示装 Xcode Command Line Tools。

### Step 2 — 安装到桌面

1. 创建 `~/Desktop/reading-widget/` 目录
2. 从 skill 目录复制三个文件过去：
   - `update.py` → 抓数据+渲染
   - `template.html` → 模板
   - `config.default.json` → 重命名为 `config.json`
3. 跑一次 `WEREAD_API_KEY=xxx python3 ~/Desktop/reading-widget/update.py` 生成首版 `widget.html`
4. 如果脚本报错（key 无效、网络等），把错误原样给用户看，不要瞎猜原因

### Step 3 — 一键打开 widget

用 Chrome `--app` 模式打开，得到一个无边框小窗，可拖到屏幕角落：

```bash
open -na "Google Chrome" --args --app="file:///Users/$USER/Desktop/reading-widget/widget.html" --window-size=320,640
```

如果用户没装 Chrome，退化方案：`open ~/Desktop/reading-widget/widget.html`（用默认浏览器打开，但是有地址栏）。

### Step 4（可选）— 后台自动刷新

如果用户想让数据自动更新（不只是 HTML 每 5 分钟 meta refresh，而是源数据也定期重抓），装一个 launchd plist：

```xml
<!-- ~/Library/LaunchAgents/com.user.reading-widget.plist -->
<plist version="1.0">
<dict>
  <key>Label</key><string>com.user.reading-widget</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/python3</string>
    <string>/Users/USERNAME/Desktop/reading-widget/update.py</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>WEREAD_API_KEY</key><string>wrk-xxxxxxxx</string>
  </dict>
  <key>StartInterval</key><integer>300</integer>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
```

加载：`launchctl load ~/Library/LaunchAgents/com.user.reading-widget.plist`

## 自定义

- **月度目标**：编辑 `~/Desktop/reading-widget/config.json` 的 `goal_hours`，或者直接在 widget 卡片上点那个数字改（会存 localStorage，下次刷新不丢）
- **刷新间隔**：改 `refresh_seconds`（HTML meta refresh）和 launchd 的 `StartInterval`
- **配色/尺寸**：直接改 `template.html` 的 CSS，重跑 `update.py` 生效

## 卡片显示了什么

| 模块 | 数据源 |
|------|--------|
| 连续阅读天数 | `/readdata/detail` weekly 桶往前翻，阈值 60 秒/天 |
| 今日分钟 | weekly 桶里今天的值 |
| 本月小时 + 日均 | `/readdata/detail` monthly |
| 上月小时 | monthly + 上月时间戳 |
| 本月目标进度 | `config.json.goal_hours` |
| 正在读 + 进度% | `/shelf/sync` 找最近未读完的书，`/book/getprogress` 拿 progress |
| 今年读完本数 / 累计小时 / 笔记数 | `/readdata/detail` annually 的 `readStat` |
| 金句 | `/book/bestbookmarks` 拿当前在读书的热门划线，按日期轮换 |

## 触发用户调用本 skill 的场景

- 安装/重装：用户说"装这个 widget"、"让我也用上"
- 排错：widget 数据没刷新、卡片打不开、API 报 401
- 改样式/改目标：用户想调小、换色、改月度目标
- 卸载：删 `~/Desktop/reading-widget/`，卸 launchd，从 `settings.json` 拿掉 key
