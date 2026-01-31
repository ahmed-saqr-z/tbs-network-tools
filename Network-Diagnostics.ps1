# Network Diagnostics Tool (Cross-Platform)
# Performs parallel ping, tracert/traceroute, and pathping/mtr tests

# Detect operating system
$isWindows = $true
$isMacOS = $false
$isLinux = $false

if ($PSVersionTable.PSVersion.Major -ge 6) {
    $isWindows = $IsWindows
    $isMacOS = $IsMacOS
    $isLinux = $IsLinux
}

# Prompt for instance name
Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Network Diagnostics Tool" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Display OS info
if ($isWindows) {
    Write-Host "  Operating System: Windows" -ForegroundColor Gray
} elseif ($isMacOS) {
    Write-Host "  Operating System: macOS" -ForegroundColor Gray
} elseif ($isLinux) {
    Write-Host "  Operating System: Linux" -ForegroundColor Gray
}
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

# Create timestamp for file naming
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# Define test names and commands based on OS
$pingTestName = "Ping"
$traceTestName = if ($isWindows) { "Tracert" } else { "Traceroute" }
$pathTestName = if ($isWindows) { "Pathping" } else { "MTR" }

# Define output file paths
$pingFile = "$instanceName ping $timestamp.txt"
$traceFile = "$instanceName $($traceTestName.ToLower()) $timestamp.txt"
$pathFile = "$instanceName $($pathTestName.ToLower()) $timestamp.txt"

# Check for MTR on macOS/Linux
$runPathTest = $true
$pathTestMessage = ""
if (-not $isWindows) {
    $mtrCheck = Get-Command mtr -ErrorAction SilentlyContinue
    if (-not $mtrCheck) {
        $runPathTest = $false
        $pathTestMessage = "MTR not installed (install with: brew install mtr)"
    }
}

Write-Host "`nStarting tests...`n" -ForegroundColor Yellow
Start-Sleep -Seconds 1

# Start background jobs with OS-specific commands
if ($isWindows) {
    # Windows commands
    $pingJob = Start-Job -ScriptBlock {
        param($domain)
        ping -n 300 $domain
    } -ArgumentList $domain

    $traceJob = Start-Job -ScriptBlock {
        param($domain)
        tracert $domain
    } -ArgumentList $domain

    if ($runPathTest) {
        $pathJob = Start-Job -ScriptBlock {
            param($domain)
            pathping $domain
        } -ArgumentList $domain
    }
} else {
    # macOS/Linux commands
    $pingJob = Start-Job -ScriptBlock {
        param($domain)
        ping -c 300 $domain
    } -ArgumentList $domain

    $traceJob = Start-Job -ScriptBlock {
        param($domain)
        traceroute $domain
    } -ArgumentList $domain

    if ($runPathTest) {
        $pathJob = Start-Job -ScriptBlock {
            param($domain)
            sudo mtr -r -c 100 $domain
        } -ArgumentList $domain
    }
}

# Track start time
$startTime = Get-Date
$pingDuration = 300 # 5 minutes in seconds

# Progress display loop
$pingCompleted = $false
$traceCompleted = $false
$pathCompleted = if (-not $runPathTest) { $true } else { $false }

while (-not ($pingCompleted -and $traceCompleted -and $pathCompleted)) {
    # Clear screen for updated display
    Clear-Host

    # Calculate elapsed time
    $elapsed = (Get-Date) - $startTime
    $elapsedSeconds = [int]$elapsed.TotalSeconds
    $elapsedDisplay = "{0:D2}:{1:D2}" -f [int]($elapsedSeconds / 60), ($elapsedSeconds % 60)

    # Display header
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Network Diagnostics - $domain" -ForegroundColor Cyan
    if ($isWindows) {
        Write-Host "  Platform: Windows" -ForegroundColor Cyan
    } elseif ($isMacOS) {
        Write-Host "  Platform: macOS" -ForegroundColor Cyan
    } elseif ($isLinux) {
        Write-Host "  Platform: Linux" -ForegroundColor Cyan
    }
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

    # Traceroute status
    if ($traceJob.State -eq "Completed") {
        if (-not $traceCompleted) {
            $traceCompleted = $true
            $traceEndTime = Get-Date
            $traceDuration = ($traceEndTime - $startTime).TotalSeconds
        }
        $traceDurationDisplay = "{0:D2}:{1:D2}" -f [int]($traceDuration / 60), ([int]$traceDuration % 60)
        Write-Host "  $($traceTestName):   " -NoNewline
        Write-Host "[Completed]" -ForegroundColor Green -NoNewline
        Write-Host " ($traceDurationDisplay)"
    } else {
        Write-Host "  $($traceTestName):   " -NoNewline
        Write-Host "[Running...]" -ForegroundColor Yellow
    }

    # Pathping/MTR status
    if (-not $runPathTest) {
        Write-Host "  $($pathTestName):  " -NoNewline
        Write-Host "[Skipped]" -ForegroundColor Gray -NoNewline
        Write-Host " ($pathTestMessage)"
    } elseif ($pathJob.State -eq "Completed") {
        if (-not $pathCompleted) {
            $pathCompleted = $true
            $pathEndTime = Get-Date
            $pathDuration = ($pathEndTime - $startTime).TotalSeconds
        }
        $pathDurationDisplay = "{0:D2}:{1:D2}" -f [int]($pathDuration / 60), ([int]($pathDuration % 60))
        Write-Host "  $($pathTestName):  " -NoNewline
        Write-Host "[Completed]" -ForegroundColor Green -NoNewline
        Write-Host " ($pathDurationDisplay)"
    } else {
        $pathElapsed = "{0:D2}:{1:D2}" -f [int]($elapsedSeconds / 60), ($elapsedSeconds % 60)
        Write-Host "  $($pathTestName):  " -NoNewline
        Write-Host "[Running...]" -ForegroundColor Yellow -NoNewline
        Write-Host " $pathElapsed elapsed"
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
$traceOutput = Receive-Job -Job $traceJob
if ($runPathTest) {
    $pathOutput = Receive-Job -Job $pathJob
}

# Save outputs to files
$pingOutput | Out-File -FilePath $pingFile -Encoding UTF8
$traceOutput | Out-File -FilePath $traceFile -Encoding UTF8
if ($runPathTest) {
    $pathOutput | Out-File -FilePath $pathFile -Encoding UTF8
}

# Clean up jobs
Remove-Job -Job $pingJob
Remove-Job -Job $traceJob
if ($runPathTest) {
    Remove-Job -Job $pathJob
}

# Final summary
$totalTime = (Get-Date) - $startTime
$totalDisplay = "{0:D2}:{1:D2}" -f [int]($totalTime.TotalMinutes), ($totalTime.Seconds)

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Tests Completed!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "`n  Results saved to:" -ForegroundColor White
Write-Host "    - $pingFile" -ForegroundColor Cyan
Write-Host "    - $traceFile" -ForegroundColor Cyan
if ($runPathTest) {
    Write-Host "    - $pathFile" -ForegroundColor Cyan
} else {
    Write-Host "    - $pathFile (skipped - MTR not available)" -ForegroundColor Gray
}
Write-Host "`n  Total Duration: $totalDisplay" -ForegroundColor White
Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Green
