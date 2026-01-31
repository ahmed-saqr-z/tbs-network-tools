# TBS Network Diagnostics Tool

A PowerShell-based network troubleshooting tool that runs comprehensive diagnostics tests in parallel and saves results to timestamped files.

## Overview

This tool helps troubleshoot network connectivity issues by running three diagnostic tests simultaneously:
- **Ping** (5 minutes)
- **Tracert** (traceroute)
- **Pathping** (comprehensive path analysis)

All tests run in parallel with a live progress dashboard, and results are saved to separate text files for easy review and sharing.

## Features

✅ Parallel execution of all tests for comprehensive diagnostics
✅ Live progress dashboard with countdown timers
✅ Automatic file naming with timestamps
✅ Tests against your configured domain
✅ No installation required - runs directly
✅ Clean, professional output

## Requirements

- Windows OS (Windows 10/11 or Windows Server)
- PowerShell 5.1 or later (pre-installed on modern Windows)
- Network connectivity to target domain
- Administrator privileges (recommended for best results)

## Quick Start

### One-Line Installation & Run

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -Command "iex (irm https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Network-Diagnostics.ps1)"
```

> **Note:** Replace `YOUR_USERNAME/YOUR_REPO` with your actual GitHub repository path.

### Alternative: Download and Run

```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Network-Diagnostics.ps1" -OutFile "Network-Diagnostics.ps1"

# Run it
powershell -ExecutionPolicy Bypass -File ".\Network-Diagnostics.ps1"
```

## Usage

1. Run the script using one of the methods above
2. When prompted, enter your instance name
3. The script will automatically construct the full domain (instancename.aswat.co)
4. Watch the live progress dashboard as tests run
5. Wait for all tests to complete (typically 10-15 minutes for pathping)
6. Find your results in the same directory

### Example Session

```
═══════════════════════════════════════════════════════
  Network Diagnostics Tool
═══════════════════════════════════════════════════════

Enter instance name (e.g., example): example

Target domain: example.aswat.co

Starting tests...

═══════════════════════════════════════════════════════
  Network Diagnostics - example.aswat.co
═══════════════════════════════════════════════════════

  Ping:      [##########----------] 2:34 remaining
  Tracert:   [Completed] (0:45)
  Pathping:  [Running...] 3:12 elapsed

  Total Elapsed: 3:45

═══════════════════════════════════════════════════════
```

## Output Files

The script creates three files in the current directory:

- `[instance] ping [timestamp].txt` - Ping test results (300 pings)
- `[instance] tracert [timestamp].txt` - Traceroute results
- `[instance] pathping [timestamp].txt` - Pathping analysis results

**Example filenames:**
```
example ping 2026-01-31_143045.txt
example tracert 2026-01-31_143045.txt
example pathping 2026-01-31_143045.txt
```

## What Each Test Does

### Ping (5 minutes)
- Sends 300 ICMP echo requests (1 per second)
- Measures packet loss and latency
- Shows minimum, maximum, and average response times
- **Duration:** Exactly 5 minutes

### Tracert (Traceroute)
- Maps the network path to the destination
- Shows each hop (router) along the way
- Identifies where delays or failures occur
- **Duration:** 30 seconds - 2 minutes (variable)

### Pathping
- Combines ping and traceroute functionality
- Computes packet loss at each hop
- Provides comprehensive path statistics
- **Duration:** 10-15 minutes (variable, runs full course)

## Troubleshooting

### "Execution Policy" Error
If you see an error about execution policies, run PowerShell as Administrator and use:
```powershell
powershell -ExecutionPolicy Bypass -File ".\Network-Diagnostics.ps1"
```

### Script Won't Download
- Check your internet connection
- Verify the GitHub URL is correct
- Try using the alternative download method
- Check if your firewall blocks raw.githubusercontent.com

### Tests Stuck or Not Progressing
- Pathping can take 10+ minutes - this is normal
- If ping shows no response, the domain may be unreachable
- Check that the instance name is correct
- Verify network connectivity to the target domain

### "Request timed out" in Results
- This indicates network connectivity issues
- Review tracert output to see where the connection fails
- Check pathping results for packet loss percentages

## Best Practices

1. **Run as Administrator** for best results
2. **Close VPNs** if testing general connectivity (unless VPN is required)
3. **Disable other network tools** while testing to avoid interference
4. **Keep results** for comparison over time or sharing with support
5. **Run multiple times** if results are inconsistent

## Support

For issues or questions about this tool, contact your support team.

## Version

**Current Version:** 1.0.0
**Last Updated:** 2026-01-31

---

*This tool is designed for network diagnostics and troubleshooting. All tests are non-destructive and read-only.*
