# 每日积分领取

`daily-points.ps1` 仅在当前 Windows 用户已登录、桌面未锁定、WorkBuddy 与 TraeWork 均保留登录态时使用。

- 每日计划任务：`Komo-DailyPoints`
- 执行时间：每天 `09:00`
- 日志目录：`logs\daily-points-YYYY-MM-DD.log`
- 演练模式：`powershell -NoProfile -ExecutionPolicy Bypass -File .\daily-points.ps1 -DryRun`

脚本按相对窗口位置执行，开始时会最大化目标软件。界面布局、分辨率或软件版本发生明显变化后，应先使用演练模式复核日志，再恢复实际运行。
