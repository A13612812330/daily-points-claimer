param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $scriptRoot 'logs'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$logFile = Join-Path $logDir ("daily-points-{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class DailyPointsNative {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);
}
'@

function Write-Log([string]$Message) {
    $line = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    $line | Tee-Object -FilePath $logFile -Append
}

function Get-AppWindow([string]$ProcessName, [string]$ExecutablePath) {
    $deadline = (Get-Date).AddSeconds(15)
    do {
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne 0 } |
            Select-Object -First 1
        if ($process) { return $process }

        $existing = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $existing) {
            Write-Log "启动 $ProcessName"
            Start-Process -FilePath $ExecutablePath
        }
        Start-Sleep -Seconds 1
    } while ((Get-Date) -lt $deadline)

    throw "未找到 $ProcessName 的可操作窗口。请先确认软件已登录且桌面未锁定。"
}

function Get-WindowRect([Diagnostics.Process]$Process) {
    $rect = New-Object DailyPointsNative+RECT
    if (-not [DailyPointsNative]::GetWindowRect($Process.MainWindowHandle, [ref]$rect)) {
        throw "无法读取 $($Process.ProcessName) 的窗口位置。"
    }
    return $rect
}

function Click-Relative([Diagnostics.Process]$Process, [double]$X, [double]$Y, [string]$Label) {
    [DailyPointsNative]::ShowWindowAsync($Process.MainWindowHandle, 3) | Out-Null
    [DailyPointsNative]::SetForegroundWindow($Process.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 400

    $rect = Get-WindowRect $Process
    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    if ($width -lt 1200 -or $height -lt 700) {
        throw "$($Process.ProcessName) 窗口尺寸异常：${width}x${height}。"
    }

    $clickX = [int]($rect.Left + $width * $X)
    $clickY = [int]($rect.Top + $height * $Y)
    Write-Log ("{0}: {1} ({2},{3})" -f $Process.ProcessName, $Label, $clickX, $clickY)
    if ($DryRun) { return }

    [DailyPointsNative]::SetCursorPos($clickX, $clickY) | Out-Null
    [DailyPointsNative]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 80
    [DailyPointsNative]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 700
}

function Invoke-WorkBuddy {
    $app = Get-AppWindow 'WorkBuddy' 'E:\Workbuddy\WorkBuddy.exe'
    Click-Relative $app 0.052 0.955 '打开账户菜单'
    Click-Relative $app 0.090 0.540 '打开 Buddy 加油站'
    Click-Relative $app 0.047 0.910 '领取每日积分（若已领取则按钮无效）'
    Write-Log 'WorkBuddy 流程完成。'
}

function Invoke-TraeWork {
    $app = Get-AppWindow 'TRAE SOLO CN' 'E:\TRAE SOLO CN\TRAE SOLO CN.exe'
    Click-Relative $app 0.070 0.955 '打开账户菜单'
    Click-Relative $app 0.102 0.610 '每日签到领 200 积分（若已签到则按钮无效）'
    Write-Log 'TraeWork 流程完成。'
}

Add-Type -AssemblyName System.Windows.Forms
$originalPosition = [System.Windows.Forms.Cursor]::Position
try {
    Write-Log ("开始执行。模式：{0}" -f $(if ($DryRun) { '演练，不点击' } else { '实际点击' }))
    Invoke-WorkBuddy
    Invoke-TraeWork
    Write-Log '全部流程执行结束。请在软件内确认“今日已领/今日已签”状态。'
    exit 0
}
catch {
    Write-Log ("失败：{0}" -f $_.Exception.Message)
    exit 1
}
finally {
    [DailyPointsNative]::SetCursorPos($originalPosition.X, $originalPosition.Y) | Out-Null
}
