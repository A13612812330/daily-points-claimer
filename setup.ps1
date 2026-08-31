param(
    [string]$WorkBuddyPath,
    [string]$TraeWorkPath,
    [ValidatePattern('^([01]\d|2[0-3]):[0-5]\d$')]
    [string]$Time = '09:00'
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $scriptRoot 'config.json'
$scriptPath = Join-Path $scriptRoot 'daily-points.ps1'

function Resolve-AppPath([string]$Provided, [string[]]$Candidates, [string]$DisplayName) {
    if ($Provided) {
        if (-not (Test-Path -LiteralPath $Provided)) { throw "$DisplayName 路径不存在：$Provided" }
        return (Resolve-Path -LiteralPath $Provided).Path
    }
    foreach ($candidate in $Candidates) {
        if (Test-Path -LiteralPath $candidate) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    $inputPath = Read-Host "请输入 $DisplayName 的 exe 完整路径"
    if (-not (Test-Path -LiteralPath $inputPath)) { throw "$DisplayName 路径不存在：$inputPath" }
    return (Resolve-Path -LiteralPath $inputPath).Path
}

$workbuddy = Resolve-AppPath $WorkBuddyPath @(
    'E:\Workbuddy\WorkBuddy.exe',
    "$env:LOCALAPPDATA\WorkBuddy\WorkBuddy.exe",
    "$env:ProgramFiles\WorkBuddy\WorkBuddy.exe"
) 'Workbuddy'
$traework = Resolve-AppPath $TraeWorkPath @(
    'E:\TRAE SOLO CN\TRAE SOLO CN.exe',
    "$env:LOCALAPPDATA\Programs\TRAE SOLO CN\TRAE SOLO CN.exe",
    "$env:ProgramFiles\TRAE SOLO CN\TRAE SOLO CN.exe"
) 'TraeWork'

$config = Get-Content -LiteralPath (Join-Path $scriptRoot 'config.example.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$config.scheduleTime = $Time
$config.workbuddy.exePath = $workbuddy
$config.traework.exePath = $traework
$config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $configPath -Encoding UTF8

$taskName = 'Komo-DailyPoints'
$taskCommand = '"{0}" -NoProfile -ExecutionPolicy Bypass -File "{1}"' -f (Join-Path $PSHOME 'powershell.exe'), $scriptPath
& schtasks.exe /Create /TN $taskName /TR $taskCommand /SC DAILY /ST $Time /RL LIMITED /IT /F | Out-Host
if ($LASTEXITCODE -ne 0) { throw "创建计划任务失败，退出码：$LASTEXITCODE" }

Write-Host "配置完成：$configPath"
Write-Host "计划任务：$taskName，每日 $Time"
Write-Host "请先确认两个软件已登录，再运行："
Write-Host "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -DryRun"
