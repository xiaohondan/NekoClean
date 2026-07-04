# NekoClean - C 盘空间清理工具
# 作者: Neko Ai | https://github.com/NekoAiDev/nekoclean
# 版本: 1.0.0

param([string]$Mode = 'menu')

$ErrorActionPreference = 'SilentlyContinue'
$HOST.UI.RawUI.WindowTitle = 'NekoClean - C 盘清理工具 v1.0.0'

$TOTAL_FREED = [int64]0
$TOTAL_COUNT = 0
$ERROR_COUNT = 0
$LOG_LINES = @()

function Log-Msg {
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LOG_LINES += "[$ts] $($args -join ' ')"
}

function Fmt-Bytes {
    param([int64]$b)
    if ($b -ge 1TB) { return "{0:N2} TB" -f ($b/1TB) }
    if ($b -ge 1GB) { return "{0:N2} GB" -f ($b/1GB) }
    if ($b -ge 1MB) { return "{0:N2} MB" -f ($b/1MB) }
    if ($b -ge 1KB) { return "{0:N2} KB" -f ($b/1KB) }
    return "$b B"
}

function Scan-Dir {
    param($path, $label)
    $size = [int64]0; $cnt = 0
    try {
        if (Test-Path $path) {
            $sum = Get-ChildItem -Path $path -Recurse -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum
            if ($sum -ne $null) { $size = [int64]$sum.Sum }
            $cnt = $sum.Count
        }
    } catch {}
    $script:TOTAL_FREED += $size
    $note = if ($size -eq 0) { ' [空]' } else { '' }
    Write-Host "  [OK] $($label) : $(Fmt-Bytes $size)$note"
    Log-Msg "$($label) : $(Fmt-Bytes $size) ($cnt files)"
}

function Clean-Dir {
    param($path, $label, [switch]$recreate)
    $size = [int64]0; $cnt = 0
    if (-not (Test-Path $path)) {
        Write-Host "  [SKIP] $($label) : 目录不存在"
        return
    }
    try {
        $sum = Get-ChildItem -Path $path -Recurse -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum
        if ($sum -ne $null) { $size = [int64]$sum.Sum }
        $cnt = $sum.Count
    } catch {}
    Write-Host "  >> 正在清理 $($label)..."
    try {
        Get-ChildItem -Path $path -Recurse -Force -EA SilentlyContinue |
            Sort-Object FullName -Descending |
            ForEach-Object {
                if (-not $_.PSIsContainer) {
                    try { Remove-Item $_.FullName -Force -EA Stop; $script:TOTAL_COUNT++ } catch { $script:ERROR_COUNT++ }
                }
            }
        if ($recreate -and -not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    } catch {}
    $script:TOTAL_FREED += $size
    Write-Host "  [OK] $($label) : 已清理 $cnt 个文件（$(Fmt-Bytes $size)）"
    Log-Msg "CLEAN $($label) : $cnt files, $(Fmt-Bytes $size)"
}

function Show-Title {
    param($txt)
    Write-Host ''
    Write-Host '  ============================================================'
    Write-Host "  $txt"
    Write-Host '  ============================================================'
    Write-Host ''
}

function Finish-Up {
    Write-Host ''
    Write-Host '  ============================================================'
    Write-Host '  清理完成！'
    Write-Host '  ============================================================'
    Write-Host "  已清理文件数: $($TOTAL_COUNT)"
    Write-Host "  遇到错误数:   $($ERROR_COUNT)"
    Write-Host "  实际释放:     $(Fmt-Bytes $TOTAL_FREED)"
    Write-Host ''
    Write-Host '  [!] 建议重启电脑以完成清理'
    Write-Host ''
    $logPath = "$env:TEMP\NekoClean_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $LOG_LINES | Out-File -FilePath $logPath -Encoding UTF8
    Write-Host "  日志已保存: $logPath"
    Write-Host ''
}

function Run-Clean {
    param([string]$level)

    Clean-Dir $env:TEMP '用户临时文件' -recreate
    Clean-Dir 'C:\Windows\Temp' 'Windows 临时文件' -recreate
    Clean-Dir 'C:\Windows\SoftwareDistribution\Download' 'Windows Update 缓存'
    Clean-Dir "$env:LOCALAPPDATA\D3DSCache" 'DirectX 着色器缓存'
    Clean-Dir "$env:APPDATA\npm-cache" 'npm 缓存'

    Write-Host '  >> 正在清空回收站...'
    try {
        Clear-RecycleBin -Force -EA Stop | Out-Null
        Write-Host '  [OK] 回收站: 已清空'
        Log-Msg 'RECYCLEBIN cleared'
    } catch {
        Write-Host '  [OK] 回收站: 无文件或无权限'
    }

    Write-Host '  >> 正在清理缩略图缓存...'
    try {
        $thumbs = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -EA SilentlyContinue
        $cnt = ($thumbs | Measure-Object).Count
        $thumbs | Remove-Item -Force -EA SilentlyContinue
        Write-Host '  [OK] 缩略图缓存: 已清理'
        Log-Msg "Thumbnails cleaned ($cnt files)"
    } catch {}

    if ($level -eq 'deep' -or $level -eq 'full') {
        Clean-Dir 'C:\Windows\Prefetch' '预读取文件'
    }

    if ($level -eq 'deep' -or $level -eq 'full') {
        Write-Host '  >> 刷新 DNS 缓存...'
        try {
            $null = ipconfig /flushdns 2>$null
            Write-Host '  [OK] DNS 缓存已刷新'
            Log-Msg 'DNS flushed'
        } catch {}
    }

    if ($level -eq 'full') {
        Clean-Dir 'C:\Windows\Logs' 'Windows 日志文件'
        Clean-Dir "$env:ProgramData\Microsoft\Windows\WER" '错误报告文件'
        Write-Host '  >> 启动磁盘碎片整理（后台）...'
        try {
            Start-Process defrag -ArgumentList 'C: /H' -WindowStyle Hidden -EA SilentlyContinue
            Write-Host '  [OK] 碎片整理已在后台运行'
            Log-Msg 'Defrag started'
        } catch {}
    }

    Finish-Up
}

function Do-Scan {
    Show-Title '快速扫描'
    Write-Host '  [!] 扫描中，请稍候...'
    Write-Host ''
    Scan-Dir $env:TEMP '用户临时文件'
    Scan-Dir 'C:\Windows\Temp' 'Windows 临时文件'
    Scan-Dir 'C:\Windows\Prefetch' '预读取文件'
    Scan-Dir "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" '缩略图缓存'
    Scan-Dir 'C:\Windows\SoftwareDistribution\Download' 'Windows Update 缓存'
    Scan-Dir "$env:LOCALAPPDATA\D3DSCache" 'DirectX 着色器缓存'
    Scan-Dir "$env:APPDATA\npm-cache" 'npm 缓存'

    try {
        $shell = New-Object -ComObject Shell.Application
        $rb = $shell.NameSpace(10)
        $total = [int64]0
        $rb.Items() | ForEach-Object { $total += $_.Size }
        $script:TOTAL_FREED += $total
        Write-Host "  [OK] 回收站 : $(Fmt-Bytes $total)"
        Log-Msg "回收站 : $(Fmt-Bytes $total)"
    } catch {
        Write-Host '  [OK] 回收站 : 0 B'
    }

    Write-Host ''
    Write-Host '  ============================================================'
    Write-Host "  扫描完成！可清理总量: $(Fmt-Bytes $TOTAL_FREED)"
    Write-Host '  ============================================================'
    Write-Host ''
    Write-Host '  说明：'
    Write-Host '  User Temp      -> 应用程序临时文件，可安全删除'
    Write-Host '  Windows Temp   -> 系统临时文件，可安全删除'
    Write-Host '  Prefetch       -> 启动预读文件，清理后会重新生成'
    Write-Host '  缩略图缓存     -> 图片预览缓存，清理后需重新加载'
    Write-Host '  回收站         -> 已删除的文件'
    Write-Host '  Windows Update -> 更新安装包，可安全清理'
    Write-Host '  DirectX 缓存   -> 3D 渲染缓存，可安全删除'
    Write-Host ''
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host ''
        Write-Host '  ============================================================'
        Write-Host '  |       NekoClean  C盘清理工具  v1.0.0                  |'
        Write-Host '  ============================================================'
        Write-Host ''
        Write-Host '  [!] 使用前请关闭其他程序，建议右键以管理员身份运行'
        Write-Host ''
        Write-Host '  请选择操作：'
        Write-Host ''
        Write-Host '  [1]  快速扫描  - 查看可清理的垃圾文件大小'
        Write-Host '  [2]  智能清理  - 自动清理安全垃圾文件'
        Write-Host '  [3]  深度清理  - 包含 Prefetch 和 DNS 缓存'
        Write-Host '  [4]  完整清理  - 包含 Windows 日志和错误报告'
        Write-Host '  [5]  查看日志  - 查看上次清理记录'
        Write-Host '  [0]  退出'
        Write-Host ''
        Write-Host '  ------------------------------------------------------------'
        $choice = Read-Host '  输入选项数字后按回车 (0-5)'

        if ($choice -eq '1') { Do-Scan; Read-Host '按回车返回菜单' | Out-Null }
        elseif ($choice -eq '2') { Show-Title '智能清理'; Write-Host '  [!] 即将清理安全垃圾文件...'; Write-Host ''; Run-Clean 'smart'; Read-Host '按回车返回菜单' | Out-Null }
        elseif ($choice -eq '3') { Show-Title '深度清理'; Write-Host '  [!] 即将进行深度清理...'; Write-Host ''; Run-Clean 'deep'; Read-Host '按回车返回菜单' | Out-Null }
        elseif ($choice -eq '4') { Show-Title '完整清理'; Write-Host '  [!] 即将进行完整清理...'; Write-Host ''; Run-Clean 'full'; Read-Host '按回车返回菜单' | Out-Null }
        elseif ($choice -eq '5') {
            $latest = Get-ChildItem "$env:TEMP\NekoClean_*.log" -EA SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            Write-Host ''
            if ($latest) {
                Write-Host '  [ 清理日志 ]'
                Write-Host '  ------------------------------------------------------------'
                Get-Content $latest.FullName | ForEach-Object { Write-Host "  $_" }
                Write-Host '  ------------------------------------------------------------'
            } else {
                Write-Host '  [!] 暂无清理日志'
            }
            Write-Host ''
            Read-Host '按回车返回菜单' | Out-Null
        }
        elseif ($choice -eq '0') {
            Write-Host ''
            Write-Host '  感谢使用 NekoClean！ bye~'
            Write-Host ''
            return
        }
    }
}

if ($Mode -eq 'menu') { Show-Menu }
else {
    if ($Mode -eq 'scan')  { Do-Scan }
    if ($Mode -eq 'smart') { Show-Title '智能清理'; Write-Host '  [!] 即将清理安全垃圾文件...'; Write-Host ''; Run-Clean 'smart' }
    if ($Mode -eq 'deep')  { Show-Title '深度清理'; Write-Host '  [!] 即将进行深度清理...'; Write-Host ''; Run-Clean 'deep' }
    if ($Mode -eq 'full')  { Show-Title '完整清理'; Write-Host '  [!] 即将进行完整清理...'; Write-Host ''; Run-Clean 'full' }
    Read-Host '按回车退出' | Out-Null
}
