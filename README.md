# 每日积分领取

`daily-points.ps1` 仅在当前 Windows 用户已登录、桌面未锁定、WorkBuddy 与 TraeWork 均保留登录态时使用。

## 给 Codex 的使用方式

把本仓库链接交给你的 Codex，并发送：

> 请读取这个 GitHub 仓库的 README 和 CODEX_PROMPT.md，帮我在当前 Windows 电脑配置 Workbuddy 和 TraeWork 每日积分自动领取。先检查两个软件是否已安装并已登录，确认 exe 路径和每日运行时间，再征得我同意后运行 setup.ps1。不要读取或保存密码，不要代办验证码。安装后先用 DryRun 演练，并检查日志和截图证据；不要把“脚本运行成功”直接当成积分领取成功。

## 手动配置

1. 下载或克隆仓库。
2. 在两个软件中完成登录，保持桌面可操作。
3. 运行配置脚本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

也可以明确指定路径和时间：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1 `
  -WorkBuddyPath 'E:\Workbuddy\WorkBuddy.exe' `
  -TraeWorkPath 'E:\TRAE SOLO CN\TRAE SOLO CN.exe' `
  -Time '09:00'
```

4. 先运行演练，不执行点击：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\daily-points.ps1 -DryRun
```

5. 配置成功后，Windows 任务计划程序会创建 `Komo-DailyPoints`，每天按设定时间运行。

- 每日计划任务：`Komo-DailyPoints`
- 执行时间：每天 `09:00`
- 日志目录：`logs\daily-points-YYYY-MM-DD.log`
- 截图证据：`evidence\YYYYMMDD-HHmmss-traework-*.png`
- 演练模式：`powershell -NoProfile -ExecutionPolicy Bypass -File .\daily-points.ps1 -DryRun`

脚本按相对窗口位置执行，开始时会最大化目标软件。TraeWork 的签到按钮位于账户菜单签到行的右侧。每次执行会保存点击前后截图，避免只凭脚本返回码判断成功。界面布局、分辨率或软件版本发生明显变化后，应先使用演练模式复核日志，再恢复实际运行。

每台电脑都会生成自己的 `config.json`，该文件已被 Git 忽略，不会上传到仓库。
