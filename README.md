# TBS Network Diagnostics Tool

A cross-platform network troubleshooting tool that runs comprehensive diagnostics tests in parallel and saves results to timestamped files.

## Overview

This tool helps troubleshoot network connectivity issues by running three diagnostic tests simultaneously:

**Windows:**
- **Ping** (5 minutes, 300 packets)
- **Tracert** (network path mapping)
- **Pathping** (comprehensive path analysis with 25 queries per hop)

**macOS/Linux:**
- **Ping** (5 minutes, 300 packets)
- **Traceroute** (network path mapping)
- **MTR** (My Traceroute - comprehensive analysis, optional, requires sudo)

All tests run in parallel with a live progress dashboard, and results are **saved immediately** as each test completes for fault tolerance.

## Features

✅ **Cross-platform** - Works on Windows, macOS, and Linux
✅ **Parallel execution** - All tests run simultaneously
✅ **Live progress dashboard** - Real-time status with countdown timers
✅ **Fault-tolerant** - Results saved immediately as each test completes
✅ **Automatic file naming** - Timestamped output files
✅ **No installation required** - Uses native OS tools
✅ **Clean, professional output** - Easy to read and share

## Requirements

**Windows:**
- Windows 10/11 or Windows Server
- PowerShell 5.1 or later (pre-installed)
- Administrator privileges (recommended)

**macOS/Linux:**
- macOS 10.14+ or modern Linux distribution
- Bash shell (pre-installed)
- Sudo access (optional, for MTR performance)

## Quick Start

### Windows

**One-Line Command (Recommended):**

Open PowerShell as Administrator and run:

```powershell
powershell -ExecutionPolicy Bypass -Command "iex (irm https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.ps1)"
```

**Alternative: Download and Run**

```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.ps1" -OutFile "Network-Diagnostics.ps1"

# Run it
powershell -ExecutionPolicy Bypass -File ".\Network-Diagnostics.ps1"
```

### macOS/Linux

**One-Line Command (Recommended):**

Open Terminal and run:

```bash
bash <(curl -s https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.sh)
```

**Notes:**
- If MTR is installed, you'll be prompted to use sudo for optimal performance
- MTR is optional - install with: `brew install mtr` (macOS) or `apt install mtr` (Linux)

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

**Windows:** Creates three files in the current directory:
- `[instance] ping [timestamp].txt` - Ping test results (300 pings)
- `[instance] tracert [timestamp].txt` - Traceroute results
- `[instance] pathping [timestamp].txt` - Pathping analysis results (25 queries/hop)

**macOS/Linux:** Creates three files in the current directory:
- `[instance] ping [timestamp].txt` - Ping test results (300 pings)
- `[instance] traceroute [timestamp].txt` - Traceroute results
- `[instance] mtr [timestamp].txt` - MTR analysis results (if available)

**Example filenames:**
```
example ping 2026-01-31_143045.txt
example tracert 2026-01-31_143045.txt
example pathping 2026-01-31_143045.txt
```

**Important:** Files are **saved immediately** as each test completes. If you cancel the script or it crashes, any completed tests will have already been saved.

## What Each Test Does

### Ping (Both Platforms)
- Sends 300 ICMP echo requests (1 per second)
- Measures packet loss and latency
- Shows minimum, maximum, and average response times
- **Duration:** Exactly 5 minutes

### Tracert / Traceroute
- Maps the network path to the destination
- Shows each hop (router) along the way
- Identifies where delays or failures occur
- Limited to 30 hops with 2-second timeout per hop
- **Duration:** 30 seconds - 2 minutes (variable)

### Pathping (Windows) / MTR (macOS/Linux)
**Pathping (Windows):**
- Combines ping and traceroute functionality
- Uses 25 queries per hop for reliable statistics
- Computes packet loss at each hop
- Provides comprehensive path statistics
- **Duration:** 10-15 minutes

**MTR (macOS/Linux):**
- Advanced traceroute with integrated ping functionality
- Uses sudo for optimal performance (0.5s interval)
- Falls back gracefully if sudo is declined
- 50 cycles for comprehensive statistics
- **Duration:** 25-50 seconds (depending on sudo)
- **Optional:** Skipped if not installed or sudo declined

## Troubleshooting

### Windows Issues

**"Execution Policy" Error:**
Run PowerShell as Administrator and use:
```powershell
powershell -ExecutionPolicy Bypass -File ".\Network-Diagnostics.ps1"
```

**Script Won't Download:**
- Check your internet connection
- Verify the GitHub URL is correct
- Try using the alternative download method
- Check if your firewall blocks raw.githubusercontent.com

**Pathping Seems Stuck:**
- Pathping takes 10-15 minutes - this is normal
- As long as elapsed time increases, it's working
- Don't close PowerShell while tests are running

### macOS/Linux Issues

**MTR Errors:**
- If you see "Failure to open sockets", MTR needs sudo
- The script will prompt for sudo upfront if MTR is installed
- You can decline sudo - MTR will be skipped gracefully
- Install MTR: `brew install mtr` (macOS) or `apt install mtr` (Linux)

**Traceroute Taking Too Long:**
- Traceroute is limited to 30 hops with 2-second timeouts
- Should complete in under 2 minutes
- If it takes longer, the domain may be unreachable

### Common Issues (Both Platforms)

**"Request timed out" in Results:**
- This indicates network connectivity issues - that's what we're diagnosing!
- Review tracert/traceroute output to see where the connection fails
- Check pathping/MTR results for packet loss percentages
- Results are still useful for troubleshooting

**Domain Not Reachable:**
- Verify the instance name is correct
- Check that you have network connectivity
- The tests will still run and save useful diagnostic information

## Best Practices

1. **Run as Administrator** (Windows) or with sudo for MTR (macOS/Linux) for best results
2. **Close VPNs** if testing general connectivity (unless VPN is required)
3. **Disable other network tools** while testing to avoid interference
4. **Keep results** for comparison over time or sharing with support
5. **Run multiple times** if results are inconsistent
6. **Don't interrupt** - Let all tests complete for comprehensive results

## Sharing Results with Support

After tests complete, the tool displays:

```
═══════════════════════════════════════════════════════
  Next Steps
═══════════════════════════════════════════════════════

  Please share the results with ZIWO Support Team by
  replying to the same ticket with the files attached or
  send the files to support@ziwo.io
```

Attach all three generated `.txt` files to your support ticket or email them to **support@ziwo.io**.

## Support

For issues or questions about this tool:
- **Email:** support@ziwo.io
- **Repository:** https://github.com/ahmed-saqr-z/tbs-network-tools

## Version

**Current Version:** 1.0.0
**Last Updated:** 2026-01-31

---

*This tool is designed for network diagnostics and troubleshooting. All tests are non-destructive and read-only.*
