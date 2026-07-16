# Windows Auto Setup

> A PowerShell-based Windows environment auto-installer that silently sets up **developer SDKs**, **common programs**, and **personal environment settings** in one run.

[한국어](README.ko.md)

---

## Features

- **One-click setup** — run `install.bat` once, everything else is fully automated
- **SDK Installer** — installs developer SDKs (JDK, Node.js, Python, Git, Flutter) to fixed paths and registers environment variables automatically
- **Program Installer** — installs local installer files plus a curated list of apps via `winget`
- **Personal Environment Setup** — copies license keys, restores personal images, and applies custom icons/wallpaper
- **Fully Silent** — every install step runs unattended, with no dialogs or prompts
- **Logging** — every action is timestamped and written to `install_log.txt`

## Tech Stack

| Layer | Technology |
|---|---|
| Script | PowerShell 5.1+ |
| Entry Point | Windows Batch (`.bat`) |
| Package Manager | [winget](https://learn.microsoft.com/windows/package-manager/winget/) |
| Privilege Handling | UAC self-elevation via `Start-Process -Verb RunAs` |
| Archive Handling | `tar` (built into Windows 10/11) |

## Project Structure

```
.
├── scripts/
│   ├── install.bat          # Entry point (run this)
│   ├── common.ps1           # Shared functions (logging, folder processing, env vars, winget install)
│   ├── install_all.ps1      # Orchestrator - runs SDK → program → addition scripts in order
│   ├── install_sdk.ps1      # Installs developer SDKs (JDK, Node.js, Python, Flutter, Git...)
│   ├── install_program.ps1  # Installs local installer files + winget packages
│   └── install_addition.ps1 # Personal settings: registry tweaks, keys/images copy, icons, wallpaper
├── installer/
│   ├── SDK/                 # Place SDK installer files here (jdk, node, python, git, flutter zip...)
│   └── program/             # Place regular program installer files here (Chrome, Office, VMware...)
├── keys/                    # Personal license keys / config files → copied to Documents
└── images/                  # Personal images, one subfolder per category → each subfolder copied to Pictures
```

`installer/`, `keys/`, `images/` all live at the same level as `scripts/`, one directory above it (`$Root`).

## How to Run

1. Place your SDK installers in `installer/SDK/` and your regular program installers in `installer/program/`.
2. Place personal files in `keys/` and image subfolders in `images/` (optional).
3. Run `install.bat`.

```
install.bat
```

`install.bat` simply launches `scripts\install_all.ps1` with `-ExecutionPolicy Bypass`. If not already running as Administrator, the script re-launches itself with elevated privileges.

## Usage

### Install Flow

| Step | Script | Description |
|---|---|---|
| 1 | `install_sdk.ps1` | Scans `installer/SDK/`, silently installs matching SDKs to `C:\SDK\...`, registers `JAVA_HOME` and PATH entries |
| 2 | `install_program.ps1` | Scans `installer/program/`, silently installs matching apps, then installs a fixed app list via `winget` |
| 3 | `install_addition.ps1` | Applies registry tweaks, copies `keys/` → Documents and `images/*` subfolders → Pictures, sets icons/wallpaper |

### Adding or Removing Programs

| Target | How |
|---|---|
| File-based installer (SDK/program) | Add or remove an entry in the `$config` array (`Pattern`, `TargetDir`, `Action`) inside `install_sdk.ps1` / `install_program.ps1` |
| winget-based installer | Add or remove a line: `Install-Program '<winget-package-id>' '<optional silent args>'` at the bottom of `install_program.ps1` |
| New setup step | Add a new `.ps1` under `scripts/` and dot-source it from `install_all.ps1` |

### `keys/` and `images/` Behavior

| Folder | Behavior |
|---|---|
| `keys/` | Copied as a whole folder into **Documents** (`Documents\keys\...`) |
| `images/` | Only the **immediate subfolders** of `images/` are copied individually into **Pictures** (e.g. `images/wallpaper/` → `Pictures/wallpaper/`). Loose files directly in `images/` are ignored. |

Icons and wallpaper are applied from fixed paths such as `Documents\keys\icon\icon_file1.ico` and `Pictures\wallpaper\1.png` — keep those relative paths/filenames, or edit them in `install_addition.ps1` to match your own files.

### SDK & Environment Variables

If you add, remove, or change the version/path of an SDK in `install_sdk.ps1`, also update:

| Variable | Purpose |
|---|---|
| `$envVars` | Machine-level environment variables (e.g. `JAVA_HOME`) |
| `$pathsToAdd` | Folders prepended to the system `PATH` |

Both are applied through `Set-SystemEnvironment` in `common.ps1`, which registers them in the registry, updates the current session, and removes duplicate PATH entries.

## Note
- **Every install step is designed to run silently (unattended).** When adding a new program, find its actual silent-install flag (`/S`, `/silent`, `/quiet`, `--silent`, winget's `--accept-source-agreements --accept-package-agreements`, etc.) rather than launching it interactively.
- Running the setup twice will simply re-run each silent installer; PATH entries are de-duplicated but installed programs are not.
- This tool is intended for **personal environment automation on a single trusted machine**.