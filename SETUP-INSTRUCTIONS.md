# GitHub Repository Setup Instructions

Follow these steps to set up your GitHub repository and deploy the Network Diagnostics tool.

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the **"+"** icon in the top right, then **"New repository"**
3. Configure your repository:
   - **Repository name:** `tbs-network-tools` (or your preferred name)
   - **Description:** "Network diagnostics tool for troubleshooting connectivity issues"
   - **Visibility:** Public (as discussed)
   - **Initialize:** ✅ Check "Add a README file"
4. Click **"Create repository"**

## Step 2: Upload Files

### Option A: Via GitHub Web Interface (Easiest)

1. In your new repository, click **"Add file"** → **"Upload files"**
2. Upload these files:
   - `Network-Diagnostics.ps1`
   - `README.md` (replace the default one)
3. Add a commit message: "Initial commit - Network Diagnostics Tool"
4. Click **"Commit changes"**

### Option B: Via Git Command Line

```bash
# Navigate to the TBS CLI Tool folder
cd "/Users/ZiwoUser/Desktop/Scripts/TBS CLI Tool"

# Initialize git (if not already done)
git init

# Add files
git add Network-Diagnostics.ps1 README.md

# Commit
git commit -m "Initial commit - Network Diagnostics Tool"

# Connect to GitHub (replace with your details)
git remote add origin https://github.com/YOUR_USERNAME/tbs-network-tools.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Get the Raw URL

After uploading, you need the direct link to the script:

1. In GitHub, navigate to `Network-Diagnostics.ps1`
2. Click the **"Raw"** button
3. Copy the URL - it will look like:
   ```
   https://raw.githubusercontent.com/YOUR_USERNAME/tbs-network-tools/main/Network-Diagnostics.ps1
   ```

## Step 4: Create Client Command

Now create the one-liner command for your clients:

```powershell
powershell -ExecutionPolicy Bypass -Command "iex (irm https://raw.githubusercontent.com/YOUR_USERNAME/tbs-network-tools/main/Network-Diagnostics.ps1)"
```

### Optional: Shorten the URL

For easier sharing, you can use a URL shortener:

1. Go to [bit.ly](https://bitly.com) or [tinyurl.com](https://tinyurl.com)
2. Paste your raw GitHub URL
3. Create a custom short link like: `bit.ly/tbs-network-diag`
4. Your command becomes:
   ```powershell
   powershell -ExecutionPolicy Bypass -Command "iex (irm bit.ly/tbs-network-diag)"
   ```

## Step 5: Test It

Before giving it to clients, test the command:

1. Open PowerShell on a Windows machine
2. Run your one-liner command
3. Verify the script downloads and runs correctly
4. Check that output files are created

## Step 6: Share with Clients

### Method 1: Email Template

```
Subject: Network Diagnostics Tool - Quick Start

Hi [Client],

To help troubleshoot your network connectivity, please run this diagnostic tool:

1. Right-click on Windows Start menu and select "Windows PowerShell (Admin)"
2. Copy and paste this command:

powershell -ExecutionPolicy Bypass -Command "iex (irm YOUR_SHORT_URL)"

3. Press Enter
4. When prompted, enter your instance name
5. Wait for all tests to complete (approximately 10-15 minutes)
6. Send us the generated text files

The tool will create three files with test results in the same directory.

Documentation: https://github.com/YOUR_USERNAME/tbs-network-tools

Thanks,
TBS Support Team
```

### Method 2: Documentation Page

Update the README.md in your GitHub repo with the actual command (replace YOUR_USERNAME/YOUR_REPO placeholders with real values).

## Step 7: Updating the Script

When you need to update the script:

1. Edit `Network-Diagnostics.ps1` in GitHub or locally
2. Commit and push the changes
3. Clients automatically get the latest version when they run the command
4. No need to redistribute - they use the same URL

## Step 8: Version Control (Optional but Recommended)

Track versions in the script header:

```powershell
# Version: 1.0.0
# Last Updated: 2026-01-31
# Changes: Initial release
```

Update the version number and changelog with each update.

## Security Considerations

### For Public Repository:

✅ **Pros:**
- No authentication needed
- Easy client access
- Simple command

⚠️ **Cons:**
- Anyone can see the code (but it's just diagnostics, no secrets)
- Need to ensure no sensitive info in the script

### Recommendations:

1. Never hardcode credentials or API keys
2. Keep the script focused on diagnostics only
3. Review code before each commit
4. Use GitHub's built-in security scanning

## Troubleshooting Setup

### "Repository not found" error
- Check repository visibility is set to Public
- Verify the URL is correct
- Ensure you've pushed the files

### Raw URL not working
- Make sure you clicked "Raw" button for the script file
- URL should start with `raw.githubusercontent.com`
- Check file is on the `main` branch

### Script downloads but won't run
- Verify the raw URL points to `.ps1` file, not the GitHub page
- Check PowerShell execution policy
- Try running with `-ExecutionPolicy Bypass`

---

## Quick Reference

**Your Repository URL:**
```
https://github.com/YOUR_USERNAME/tbs-network-tools
```

**Raw Script URL:**
```
https://raw.githubusercontent.com/YOUR_USERNAME/tbs-network-tools/main/Network-Diagnostics.ps1
```

**Client Command:**
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (irm YOUR_RAW_URL)"
```

---

Once you complete these steps, you'll have a professional, easy-to-maintain distribution method for your network diagnostics tool!
