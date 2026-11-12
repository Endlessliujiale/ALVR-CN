<#
    ALVR-CN 一键构建脚本
    克隆官方 ALVR v20.14.1 -> 应用汉化补丁 -> 编译 Dashboard 与 Launcher

    用法：在仓库根目录执行
        powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1
    可选参数：
        -WorkDir  工作目录（默认 .\_build）
        -OutDir   产物输出目录（默认 .\dist\ALVR-CN）
#>
param(
    [string]$WorkDir = "$PSScriptRoot\..\_build",
    [string]$OutDir  = "$PSScriptRoot\..\dist\ALVR-CN"
)

$ErrorActionPreference = 'Stop'
$root  = Resolve-Path "$PSScriptRoot\.."
$patch = Join-Path $root '源码补丁\alvr-zh-cn.patch'
$src   = Join-Path $WorkDir 'ALVR'

if (-not (Test-Path $patch)) { throw "找不到补丁：$patch" }

Write-Host "[1/4] 克隆官方 ALVR v20.14.1 ..." -ForegroundColor Cyan
if (Test-Path $src) {
    Write-Host "      已存在，跳过克隆：$src" -ForegroundColor DarkGray
} else {
    New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
    git clone --branch v20.14.1 --recursive https://github.com/alvr-org/ALVR $src
    if ($LASTEXITCODE -ne 0) { throw "克隆失败。检查网络或代理。" }
}

Write-Host "[2/4] 应用汉化补丁 ..." -ForegroundColor Cyan
Push-Location $src
try {
    git apply --check -p2 $patch
    if ($LASTEXITCODE -ne 0) { throw "补丁无法应用，确认源码版本是 v20.14.1。" }
    git apply -p2 $patch
    if ($LASTEXITCODE -ne 0) { throw "应用补丁失败。" }
} finally { Pop-Location }

Write-Host "[3/4] 编译（首次约 10-25 分钟）..." -ForegroundColor Cyan
Push-Location $src
try {
    cargo build --release -p alvr_dashboard -p alvr_launcher
    if ($LASTEXITCODE -ne 0) { throw "编译失败。" }
} finally { Pop-Location }

Write-Host "[4/4] 收集产物到 $OutDir ..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path (Join-Path $OutDir 'streamer'), (Join-Path $OutDir 'launcher') | Out-Null
Copy-Item "$src\target\release\alvr_dashboard.exe" (Join-Path $OutDir 'streamer\ALVR Dashboard.exe') -Force
Copy-Item "$src\target\release\alvr_launcher.exe"  (Join-Path $OutDir 'launcher\ALVR Launcher.exe')  -Force
Copy-Item (Join-Path $root '使用说明.txt') $OutDir -Force

Write-Host ""
Write-Host "完成。产物：$OutDir" -ForegroundColor Green
Write-Host "注意：安装路径必须是纯英文，否则 SteamVR 驱动读不到 session.json。" -ForegroundColor Yellow
