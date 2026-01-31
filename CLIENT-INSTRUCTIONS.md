# Network Diagnostics Tool - Client Instructions

## Quick Start (3 Easy Steps)

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

**That's it! The tool does the rest automatically.**
