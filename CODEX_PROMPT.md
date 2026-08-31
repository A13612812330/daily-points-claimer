# 给 Codex 的部署提示

请把本仓库当作一个 Windows 桌面自动化项目处理：

1. 先阅读 `README.md`、`setup.ps1`、`daily-points.ps1` 和 `config.example.json`。
2. 检查 Workbuddy 与 TraeWork 是否已安装，并确认用户已经在软件内登录。
3. 向用户确认两个 exe 的实际路径和计划运行时间，默认使用每天 09:00。
4. 未经用户确认，不创建或修改 Windows 计划任务。
5. 用户确认后运行 `setup.ps1`，生成本机专用的 `config.json`。
6. 先运行 `daily-points.ps1 -DryRun`，确认窗口大小和点击坐标；不要读取密码，不要代办验证码。
7. 实际运行后检查 `logs/` 和 `evidence/`，只有看到软件界面显示已领取/已签到，才能报告成功。
8. 如果界面布局、分辨率或软件版本不同，暂停并要求重新校准坐标，不要盲目点击。
