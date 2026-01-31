# Network Diagnostics Tool for Windows
# Performs parallel ping, tracert, and pathping tests

# Detect operating system and ensure Windows-only
$isWindows = $true
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $isWindows = $IsWindows
}

if (-not $isWindows) {
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  Error: This script is for Windows only!" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "`nFor macOS/Linux, please use:" -ForegroundColor Yellow
    Write-Host 'bash <(curl -s https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.sh)' -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Prompt for instance name
Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Network Diagnostics Tool" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
Write-Host "  Operating System: Windows" -ForegroundColor Gray
Write-Host ""

$instanceName = Read-Host "Enter instance name"

# Validate input
if ([string]::IsNullOrWhiteSpace($instanceName)) {
    Write-Host "`nError: Instance name cannot be empty!" -ForegroundColor Red
    exit 1
}

# Construct domain
$domain = "$instanceName.aswat.co"
Write-Host "`nTarget domain: $domain" -ForegroundColor Green

# Test if domain is reachable (quick DNS check)
try {
    $null = [System.Net.Dns]::GetHostEntry($domain)
} catch {
    Write-Host "`nWarning: Unable to resolve $domain" -ForegroundColor Yellow
    Write-Host "The tests will continue, but may show connection failures.`n" -ForegroundColor Yellow
    $continue = Read-Host "Press Enter to continue or Ctrl+C to cancel"
}

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
    try {
        ping -n 300 $domain
    } catch {
        "Error running ping: $_"
    }
} -ArgumentList $domain

$tracertJob = Start-Job -ScriptBlock {
    param($domain)
    try {
        tracert $domain
    } catch {
        "Error running tracert: $_"
    }
} -ArgumentList $domain

$pathpingJob = Start-Job -ScriptBlock {
    param($domain)
    try {
        pathping $domain
    } catch {
        "Error running pathping: $_"
    }
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
    Write-Host "  Platform: Windows" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

    # Ping status
    if ($pingJob.State -eq "Completed" -or $pingJob.State -eq "Failed") {
        if (-not $pingCompleted) {
            $pingCompleted = $true
            $pingEndTime = Get-Date
            $pingDurationActual = ($pingEndTime - $startTime).TotalSeconds
        }
        $pingDurationDisplay = "{0:D2}:{1:D2}" -f [int]($pingDurationActual / 60), ([int]$pingDurationActual % 60)
        if ($pingJob.State -eq "Failed") {
            Write-Host "  Ping:      " -NoNewline
            Write-Host "[Failed]" -ForegroundColor Red -NoNewline
            Write-Host " ($pingDurationDisplay)"
        } else {
            Write-Host "  Ping:      " -NoNewline
            Write-Host "[Completed]" -ForegroundColor Green -NoNewline
            Write-Host " ($pingDurationDisplay)"
        }
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
    if ($tracertJob.State -eq "Completed" -or $tracertJob.State -eq "Failed") {
        if (-not $tracertCompleted) {
            $tracertCompleted = $true
            $tracertEndTime = Get-Date
            $tracertDuration = ($tracertEndTime - $startTime).TotalSeconds
        }
        $tracertDurationDisplay = "{0:D2}:{1:D2}" -f [int]($tracertDuration / 60), ([int]$tracertDuration % 60)
        if ($tracertJob.State -eq "Failed") {
            Write-Host "  Tracert:   " -NoNewline
            Write-Host "[Failed]" -ForegroundColor Red -NoNewline
            Write-Host " ($tracertDurationDisplay)"
        } else {
            Write-Host "  Tracert:   " -NoNewline
            Write-Host "[Completed]" -ForegroundColor Green -NoNewline
            Write-Host " ($tracertDurationDisplay)"
        }
    } else {
        Write-Host "  Tracert:   " -NoNewline
        Write-Host "[Running...]" -ForegroundColor Yellow
    }

    # Pathping status
    if ($pathpingJob.State -eq "Completed" -or $pathpingJob.State -eq "Failed") {
        if (-not $pathpingCompleted) {
            $pathpingCompleted = $true
            $pathpingEndTime = Get-Date
            $pathpingDuration = ($pathpingEndTime - $startTime).TotalSeconds
        }
        $pathpingDurationDisplay = "{0:D2}:{1:D2}" -f [int]($pathpingDuration / 60), ([int]($pathpingDuration % 60))
        if ($pathpingJob.State -eq "Failed") {
            Write-Host "  Pathping:  " -NoNewline
            Write-Host "[Failed]" -ForegroundColor Red -NoNewline
            Write-Host " ($pathpingDurationDisplay)"
        } else {
            Write-Host "  Pathping:  " -NoNewline
            Write-Host "[Completed]" -ForegroundColor Green -NoNewline
            Write-Host " ($pathpingDurationDisplay)"
        }
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

# Get job outputs with error handling
try {
    $pingOutput = Receive-Job -Job $pingJob -ErrorAction Stop
    if ([string]::IsNullOrWhiteSpace($pingOutput)) {
        $pingOutput = "Ping test completed but returned no output. The domain may not be reachable."
    }
} catch {
    $pingOutput = "Ping test failed: $_"
}

try {
    $tracertOutput = Receive-Job -Job $tracertJob -ErrorAction Stop
    if ([string]::IsNullOrWhiteSpace($tracertOutput)) {
        $tracertOutput = "Tracert test completed but returned no output. The domain may not be reachable."
    }
} catch {
    $tracertOutput = "Tracert test failed: $_"
}

try {
    $pathpingOutput = Receive-Job -Job $pathpingJob -ErrorAction Stop
    if ([string]::IsNullOrWhiteSpace($pathpingOutput)) {
        $pathpingOutput = "Pathping test completed but returned no output. The domain may not be reachable."
    }
} catch {
    $pathpingOutput = "Pathping test failed: $_"
}

# Save outputs to files
$pingOutput | Out-File -FilePath $pingFile -Encoding UTF8
$tracertOutput | Out-File -FilePath $tracertFile -Encoding UTF8
$pathpingOutput | Out-File -FilePath $pathpingFile -Encoding UTF8

# Clean up jobs
Remove-Job -Job $pingJob -Force
Remove-Job -Job $tracertJob -Force
Remove-Job -Job $pathpingJob -Force

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
