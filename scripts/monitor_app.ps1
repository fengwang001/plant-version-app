# 应用监控脚本
# 监控Flutter应用的日志输出，帮助诊断卡死问题

param(
    [string]$Duration = "30"  # 监控时长（秒）
)

Write-Host "🔍 开始监控Flutter应用..." -ForegroundColor Cyan
Write-Host "监控时长: $Duration 秒" -ForegroundColor Yellow
Write-Host "按 Ctrl+C 提前停止监控" -ForegroundColor Yellow
Write-Host ""

# 启动flutter logs并设置超时
$job = Start-Job -ScriptBlock {
    flutter logs
}

# 监控指定时长
$timeout = [datetime]::Now.AddSeconds($Duration)
$lastOutput = [datetime]::Now

while ([datetime]::Now -lt $timeout) {
    # 检查job状态
    $output = Receive-Job -Job $job -ErrorAction SilentlyContinue
    
    if ($output) {
        $lastOutput = [datetime]::Now
        Write-Host $output -ForegroundColor Green
        
        # 检查关键词
        if ($output -match "卡死|timeout|error|exception") {
            Write-Host "⚠️ 检测到可能的问题: $output" -ForegroundColor Red
        }
        
        if ($output -match "✅|成功|完成") {
            Write-Host "✅ 检测到成功状态: $output" -ForegroundColor Green
        }
    }
    
    # 检查是否长时间无输出
    $timeSinceLastOutput = ([datetime]::Now - $lastOutput).TotalSeconds
    if ($timeSinceLastOutput -gt 10) {
        Write-Host "⚠️ 已有 $([math]::Round($timeSinceLastOutput)) 秒无日志输出" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 1
}

# 清理
Stop-Job -Job $job -ErrorAction SilentlyContinue
Remove-Job -Job $job -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🏁 监控完成" -ForegroundColor Cyan
