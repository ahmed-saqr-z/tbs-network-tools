# Network Diagnostics Tool - Client Instructions

## Choose Your Operating System

- [Windows Instructions](#windows-instructions)
- [macOS/Linux Instructions](#macos-linux-instructions)

---

## Windows Instructions

### Quick Start (3 Easy Steps)

### Step 1: Open PowerShell as Administrator

**Windows 10/11:**
1. Click the **Start** button
2. Type `PowerShell`
3. **Right-click** on "Windows PowerShell"
4. Select **"Run as administrator"**
5. Click **"Yes"** if prompted by User Account Control

### Step 2: Run the Diagnostic Tool

Copy and paste this command into PowerShell, then press **Enter**:

```powershell
powershell -ExecutionPolicy Bypass -Command "iex (irm https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.ps1)"
```

> **Note:** The command is one long line - make sure to copy it completely.

### Step 3: Enter Your Instance Name

When prompted, type your instance name and press **Enter**:

```
Enter instance name (e.g., example): [TYPE YOUR INSTANCE NAME HERE]
```

## What Happens Next

The tool will:
1. Display a progress dashboard showing real-time status
2. Run three network tests in parallel:
   - **Ping** (5 minutes)
   - **Tracert** (1-2 minutes)
   - **Pathping** (10-15 minutes)
3. Save results to three text files in your current directory

**Total time:** Approximately 10-15 minutes

## Understanding the Progress Display

You'll see a live dashboard like this:

```
═══════════════════════════════════════════════════════
  Network Diagnostics - yourinstance.aswat.co
═══════════════════════════════════════════════════════

  Ping:      [##########----------] 2:34 remaining
  Tracert:   [Completed] (0:45)
  Pathping:  [Running...] 3:12 elapsed

  Total Elapsed: 3:45

═══════════════════════════════════════════════════════
```

- **Ping** shows time remaining (counts down from 5:00)
- **Tracert** shows "Running" or "Completed"
- **Pathping** shows elapsed time (this takes the longest)
- **Total Elapsed** shows overall time since tests started

## Finding Your Results

After completion, you'll see:

```
═══════════════════════════════════════════════════════
  Tests Completed!
═══════════════════════════════════════════════════════

  Results saved to:
    - yourinstance ping 2026-01-31_143045.txt
    - yourinstance tracert 2026-01-31_143045.txt
    - yourinstance pathping 2026-01-31_143045.txt

  Total Duration: 12:34

═══════════════════════════════════════════════════════
```

The three files will be saved in the directory where you ran the command.

## Sending Results to Support

1. Locate the three `.txt` files created by the tool
2. Attach all three files to your support email
3. Include a brief description of the issue you're experiencing

## Troubleshooting

### "Cannot be loaded because running scripts is disabled"

**Solution:** Make sure you're using the full command with `-ExecutionPolicy Bypass`:
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (irm YOUR_URL)"
```

### "The term 'irm' is not recognized"

**Solution:** Your PowerShell version might be old. Use the longer version:
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (Invoke-RestMethod YOUR_URL)"
```

### Script doesn't download

**Check:**
- You have internet connection
- You can access GitHub (not blocked by firewall)
- The URL is copied correctly (no extra spaces)

**Alternative:** Download manually:
1. Go to: `https://github.com/ahmed-saqr-z/tbs-network-tools`
2. Click on `Network-Diagnostics.ps1`
3. Click **"Raw"** button
4. Right-click → **"Save as..."** → Save to Desktop
5. Right-click the file → **"Run with PowerShell"**

### Tests show "Request timed out"

This is normal if there are network connectivity issues - that's what we're diagnosing! The results will still be saved and are useful for troubleshooting.

### Pathping seems stuck

Pathping takes 10-15 minutes to complete. As long as the elapsed time is increasing, it's working correctly. Please wait for it to finish.

### I closed PowerShell accidentally

No problem! Just run the command again. Each run creates new timestamped files, so nothing will be overwritten.

## Need Help?

If you encounter issues running this tool, contact your support team with:
- A screenshot of any error messages
- Your Windows version
- Description of what happened when you tried to run it

---

## Advanced: Running from a Specific Location

If you want the result files in a specific folder:

```powershell
# Navigate to your desired folder first
cd C:\Users\YourName\Desktop

# Then run the diagnostic command
powershell -ExecutionPolicy Bypass -Command "iex (irm YOUR_URL)"
```

The result files will be saved to your Desktop.

---

## macOS Linux Instructions

### Quick Start (3-4 Easy Steps)

### Step 1: Open Terminal

**macOS:**
1. Press **Command + Space** to open Spotlight
2. Type `Terminal`
3. Press **Enter**

**OR**

1. Open **Finder**
2. Go to **Applications → Utilities**
3. Double-click **Terminal**

### Step 2: Run the Diagnostic Tool

Copy and paste this command into Terminal, then press **Enter**:

```bash
bash <(curl -s https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.sh)
```

> **Note:** The command is one long line - make sure to copy it completely.

### Step 3: MTR Sudo Prompt (If MTR is Installed)

If you have MTR installed, you'll see:

```
═══════════════════════════════════════════════════════
  MTR requires sudo for optimal performance
═══════════════════════════════════════════════════════

MTR (My Traceroute) needs administrator privileges to run.
You will be prompted for your password.

Run MTR with sudo? (y/N):
```

- Press **Y** if you want MTR to run with optimal performance (recommended)
- Enter your Mac password when prompted
- Press **N** to skip MTR (tests will still run without it)

> **Note:** If you don't have MTR installed, this step is automatically skipped.

### Step 4: Enter Your Instance Name

When prompted, type your instance name and press **Enter**:

```
Enter instance name: [TYPE YOUR INSTANCE NAME HERE]
```

## What Happens Next

The tool will:
1. Display a progress dashboard showing real-time status
2. Run tests in parallel:
   - **Ping** (5 minutes)
   - **Traceroute** (1-2 minutes)
   - **MTR** (25-50 seconds, if available with sudo)
3. Save results to three text files in your current directory
4. Show you where the files are saved

**Total time:** Approximately 10-15 minutes

## Understanding the Progress Display

You'll see a live dashboard like this:

```
═══════════════════════════════════════════════════════
  Network Diagnostics - yourinstance.aswat.co
  Platform: macOS
═══════════════════════════════════════════════════════

  Ping:       [##########----------] 2:34 remaining
  Traceroute: [Completed] (0:45)
  MTR:        [Completed] (0:28)

  Total Elapsed: 3:45

═══════════════════════════════════════════════════════
```

## Finding Your Results

After completion, you'll see:

```
═══════════════════════════════════════════════════════
  Tests Completed!
═══════════════════════════════════════════════════════

  Results saved to:
    - yourinstance ping 2026-01-31_143045.txt
    - yourinstance traceroute 2026-01-31_143045.txt
    - yourinstance mtr 2026-01-31_143045.txt

  Total Duration: 05:34

═══════════════════════════════════════════════════════
  Next Steps
═══════════════════════════════════════════════════════

  Please share the results with ZIWO Support Team by
  replying to the same ticket with the files attached or
  send the files to support@ziwo.io

═══════════════════════════════════════════════════════
```

The files will be in your current Terminal directory (usually your home folder).

## Sending Results to Support

1. Locate the three `.txt` files created by the tool
2. Attach all three files to your support email or ticket
3. Send to: **support@ziwo.io**
4. Include a brief description of the issue you're experiencing

## Troubleshooting (macOS/Linux)

### MTR Shows Errors

**Issue:** `MTR test failed. You may need to run with sudo.`

**Solution:** When prompted at the beginning, press **Y** to allow sudo access.

### "Command not found" Error

**Issue:** `bash: curl: command not found` or similar

**Solution:**
- macOS: curl is pre-installed, check your internet connection
- Linux: Install curl with `sudo apt install curl` or `sudo yum install curl`

### Tests Show Connection Failures

This is normal if there are network connectivity issues - that's what we're diagnosing! The results are still useful for troubleshooting.

### MTR Not Installed

If you see: `MTR not installed (install with: brew install mtr)` - this is fine. The other two tests will still run and provide useful information.

To install MTR (optional):
```bash
# macOS
brew install mtr

# Ubuntu/Debian Linux
sudo apt install mtr

# CentOS/RHEL Linux
sudo yum install mtr
```

### I Closed Terminal Accidentally

No problem! Just run the command again. Each run creates new timestamped files, so nothing will be overwritten.

---

**That's it! The tool does the rest automatically.**
