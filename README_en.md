# NekoClean - C Drive Space Cleaner

<div align="center">

![Windows](https://img.shields.io/badge/Windows-0078D4?style=flat-square&logo=windows&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/NekoAiDev/nekoclean)

**A safe, simple and efficient Windows C: drive cleaner. No installation required, just download and run.**

English | [简体中文](./README.md)

</div>

---

## Features

NekoClean provides four cleaning modes for different scenarios:

| Mode | Description | Best For |
|------|-------------|----------|
| **Quick Scan** | Preview total cleanable space without deleting | Before cleaning, estimate results |
| **Smart Clean** | Auto-clean safe junk files (temp files, recycle bin, etc.) | Regular maintenance |
| **Deep Clean** | Smart Clean + Prefetch files, DNS cache, etc. | System optimization |
| **Full Clean** | Deep Clean + Windows logs, error reports, etc. | Emergency space release |

### Supported Items

- ✅ User temporary folder (`%TEMP%`)
- ✅ Windows system temporary files
- ✅ Prefetch files
- ✅ Thumbnail cache
- ✅ Recycle Bin
- ✅ Windows Update cache
- ✅ DirectX shader cache
- ✅ npm cache
- ✅ DNS cache (Deep+)
- ✅ Windows logs (Full)
- ✅ Error report files (Full)

## Quick Start

### Method 1: Direct Run

1. Download `NekoClean.ps1`
2. Right-click → **"Run with PowerShell"** (or right-click → "Run as administrator")
3. Choose a cleaning mode

> 💡 If double-clicking doesn't open in PowerShell, right-click → "Open with" → Windows PowerShell, or open PowerShell first and run `.\NekoClean.ps1`

### Method 2: Command Line

```powershell
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode scan   # Quick scan
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode smart  # Smart clean
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode deep   # Deep clean
powershell -ExecutionPolicy Bypass -File .\NekoClean.ps1 -Mode full    # Full clean
```

### Method 3: Clone Repository

```bash
git clone https://github.com/NekoAiDev/nekoclean.git
cd nekoclean
.\NekoClean.ps1
```

## Usage

1. Launch the tool (run as administrator)
2. Choose `1` for Quick Scan to see how much space can be freed
3. Choose your preferred cleaning mode (`2`/`3`/`4`)
4. Press Enter to start cleaning
5. Restart your computer after cleaning (recommended)

## Cleaning Modes

### Quick Scan
Scans and displays total size of cleanable junk files without deleting anything.

### Smart Clean (Recommended)
Safely cleans these items without affecting system operation:
- User temporary files
- Windows temporary files
- Thumbnail cache (auto-rebuilds)
- Recycle Bin
- Windows Update cache
- DirectX shader cache

### Deep Clean
In addition to Smart Clean:
- Prefetch files (may improve boot speed)
- DNS cache (fixes DNS resolution issues)

### Full Clean
In addition to Deep Clean:
- Windows log files
- Error report files
- Disk defragmentation (runs in background)

## Project Structure

```
nekoclean/
├── Nekoclean.ps1     # Main program (PowerShell)
├── README.md          # Chinese documentation
├── README_en.md       # English documentation
└── LICENSE            # MIT License
```

## Changelog

### v1.0.0 (2026-05-01)
- 🎉 Initial release
- Four cleaning modes
- Interactive menu interface
- Cleaning log records
- Auto-rebuild thumbnail cache
- Background defragmentation

## License

This project is [MIT Licensed](./LICENSE).

---

<div align="center">

**Made with ❤️ by <a href="https://github.com/NekoAiDev">Neko Ai</a>**

</div>
