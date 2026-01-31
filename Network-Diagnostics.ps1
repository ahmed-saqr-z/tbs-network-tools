# Network Diagnostics Tool
# Performs parallel ping, tracert, and pathping tests

# Prompt for instance name
Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Network Diagnostics Tool" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$instanceName = Read-Host "Enter instance name (e.g., adq)"

# Validate input
if ([string]::IsNullOrWhiteSpace($instanceName)) {
    Write-Host "`nError: Instance name cannot be empty!" -ForegroundColor Red
    exit 1
}

# Construct domain
$domain = "$instanceName.aswat.co"
Write-Host "`nTarget domain: $domain" -ForegroundColor Green

# Create timestamp for file naming
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# Define output file paths
$pingFile = "$instanceName ping $timestamp.txt"
$tracertFile = "$instanceName tracert $timestamp.txt"
$pathpingFile = "$instanceName pathping $timestamp.txt"

Write-Host "`nStarting tests...`n" -ForegroundColor Yellow
Start-Sleep -Seconds 1

# Start background jobs
$pingJob = Start-Job -ScriptBlock {
    param($domain)
    ping -n 300 $domain
} -ArgumentList $domain

$tracertJob = Start-Job -ScriptBlock {
    param($domain)
    tracert $domain
} -ArgumentList $domain

$pathpingJob = Start-Job -ScriptBlock {
    param($domain)
    pathping $domain
} -ArgumentList $domain

# Track start time
$startTime = Get-Date
$pingDuration = 300 # 5 minutes in seconds

# Progress display loop
$pingCompleted = $false
$tracertCompleted = $false
$pathpingCompleted = $false

while (-not ($pingCompleted -and $tracertCompleted -and $pathpingCompleted)) {
    # Clear screen for updated display
    Clear-Host

    # Calculate elapsed time
    $elapsed = (Get-Date) - $startTime
    $elapsedSeconds = [int]$elapsed.TotalSeconds
    $elapsedDisplay = "{0:D2}:{1:D2}" -f [int]($elapsedSeconds / 60), ($elapsedSeconds % 60)

    # Display header
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Network Diagnostics - $domain" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

    # Ping status
    if ($pingJob.State -eq "Completed") {
        if (-not $pingCompleted) {
            $pingCompleted = $true
            $pingEndTime = Get-Date
            $pingDurationActual = ($pingEndTime - $startTime).TotalSeconds
        }
        $pingDurationDisplay = "{0:D2}:{1:D2}" -f [int]($pingDurationActual / 60), ([int]$pingDurationActual % 60)
        Write-Host "  Ping:      " -NoNewline
        Write-Host "[Completed]" -ForegroundColor Green -NoNewline
        Write-Host " ($pingDurationDisplay)"
    } else {
        $pingRemaining = $pingDuration - $elapsedSeconds
        if ($pingRemaining -lt 0) { $pingRemaining = 0 }
        $pingRemainingDisplay = "{0:D2}:{1:D2}" -f [int]($pingRemaining / 60), ($pingRemaining % 60)
        $pingProgress = [Math]::Min(100, ($elapsedSeconds / $pingDuration) * 100)
        $pingBarLength = 20
        $pingFilled = [Math]::Floor($pingBarLength * $pingProgress / 100)
        $pingBar = ("#" * $pingFilled).PadRight($pingBarLength, "-")

        Write-Host "  Ping:      " -NoNewline
        Write-Host "[$pingBar]" -ForegroundColor Yellow -NoNewline
        Write-Host " $pingRemainingDisplay remaining"
    }

    # Tracert status
    if ($tracertJob.State -eq "Completed") {
        if (-not $tracertCompleted) {
            $tracertCompleted = $true
            $tracertEndTime = Get-Date
            $tracertDuration = ($tracertEndTime - $startTime).TotalSeconds
        }
        $tracertDurationDisplay = "{0:D2}:{1:D2}" -f [int]($tracertDuration / 60), ([int]$tracertDuration % 60)
        Write-Host "  Tracert:   " -NoNewline
        Write-Host "[Completed]" -ForegroundColor Green -NoNewline
        Write-Host " ($tracertDurationDisplay)"
    } else {
        Write-Host "  Tracert:   " -NoNewline
        Write-Host "[Running...]" -ForegroundColor Yellow
    }

    # Pathping status
    if ($pathpingJob.State -eq "Completed") {
        if (-not $pathpingCompleted) {
            $pathpingCompleted = $true
            $pathpingEndTime = Get-Date
            $pathpingDuration = ($pathpingEndTime - $startTime).TotalSeconds
        }
        $pathpingDurationDisplay = "{0:D2}:{1:D2}" -f [int]($pathpingDuration / 60), ([int]($pathpingDuration % 60))
        Write-Host "  Pathping:  " -NoNewline
        Write-Host "[Completed]" -ForegroundColor Green -NoNewline
        Write-Host " ($pathpingDurationDisplay)"
    } else {
        $pathpingElapsed = "{0:D2}:{1:D2}" -f [int]($elapsedSeconds / 60), ($elapsedSeconds % 60)
        Write-Host "  Pathping:  " -NoNewline
        Write-Host "[Running...]" -ForegroundColor Yellow -NoNewline
        Write-Host " $pathpingElapsed elapsed"
    }

    # Total elapsed time
    Write-Host "`n  Total Elapsed: $elapsedDisplay" -ForegroundColor White
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan

    # Wait before next update
    Start-Sleep -Seconds 1
}

# All jobs completed - collect results
Write-Host "`n`nCollecting results..." -ForegroundColor Yellow

# Get job outputs
$pingOutput = Receive-Job -Job $pingJob
$tracertOutput = Receive-Job -Job $tracertJob
$pathpingOutput = Receive-Job -Job $pathpingJob

# Save outputs to files
$pingOutput | Out-File -FilePath $pingFile -Encoding UTF8
$tracertOutput | Out-File -FilePath $tracertFile -Encoding UTF8
$pathpingOutput | Out-File -FilePath $pathpingFile -Encoding UTF8

# Clean up jobs
Remove-Job -Job $pingJob
Remove-Job -Job $tracertJob
Remove-Job -Job $pathpingJob

# Final summary
$totalTime = (Get-Date) - $startTime
$totalDisplay = "{0:D2}:{1:D2}" -f [int]($totalTime.TotalMinutes), ($totalTime.Seconds)

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Tests Completed!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "`n  Results saved to:" -ForegroundColor White
Write-Host "    - $pingFile" -ForegroundColor Cyan
Write-Host "    - $tracertFile" -ForegroundColor Cyan
Write-Host "    - $pathpingFile" -ForegroundColor Cyan
Write-Host "`n  Total Duration: $totalDisplay" -ForegroundColor White
Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Green
