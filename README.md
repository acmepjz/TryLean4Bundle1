# TryLean4Bundle

TryLean4 Windows bundle inspired by https://github.com/MohanadAhmed/TryLean4Bundle.
It is a standalone Git+Bash+VSCode+Lean4+Mathlib distribution without requiring Internet access at install or use.
All you need is 7-Zip or some other software which can unpack 7z files.

It will not write files to directories other than TryLean4Bundle directory.
It will not modify user's environment variable.
It will not write registry.

## Download link

https://github.com/acmepjz/TryLean4Bundle1/releases/tag/nightly

- `TryLean4Bundle.7z`: the complete bundle with launcher+standalone Git+Bash+VSCode+Lean4+Mathlib+offline Mathlib help
- `OfflineMathlibHelpWindows.zip`: only contains Windows PowerShell version of offline Mathlib help launcher
- `OfflineMathlibHelpPython.zip`: only contains cross platform Python version of offline Mathlib help launcher
- `doc.zip`: Data file for offline Mathlib help. *NOTE: The launcher expects zip file, not extracted contents!*
  **Don't extract this zip file!! Just put this file in the working directory (for example, next to `TryLean4Launcher.cmd` file or `OfflineMathlibHelp.cmd` file or `TryLean4Launcher.py` file) and that's OK!!**
- `doc_version.txt`: used for offline Mathlib help launcher to check updates

Usage:

1. Extract all contents of the archive to a folder.
2. Double click `TryLean4Launcher.cmd` or `OfflineMathlibHelp.cmd`. Trust the script in your antivirus.
3. Click the big button with Lean icon. Follow the instruction to unpack Mathlib cache for the first time run.
4. The second tab is for offline Mathlib help.
5. The third tab is for advanced settings.

Python version usage:

1. Put `doc.zip` next to the script file, or use built-in update feature in script file.
2. `chmod a+x TryLean4Launcher.py`
3. `./TryLean4Launcher.py` or `python3 TryLean4Launcher.py`

## Directory structure of this repository

- `Resources`: resources and scripts used in build and run process
- `TryLean4Launcher`: a Windows only TryLean4 bundle + offline Mathlib help launcher written in PowerShell.
- `OfflineMathlibHelpPython`: a cross platform offline Mathlib help launcher written in Python.

Other directories will be created at build time:

- `Downloads`: components downloaded at build time
- `TryLean4Bundle`: the directory containing the bundle

## Build TryLean4Bundle on your own Windows computer

This requires Internet connection.
The build process will not write files to directories other than repository directory.
The build process will not modify user's environment variable.
The build process will not write registry.

### Step 1: Create TryLean4Bundle package

Double click `001_create_windows_bundle.cmd`. This will download Git+Bash+VSCode+Lean4+Mathlib+Mathlib cache (without unpacking),
configure them and pack them into `TryLean4Bundle.7z`.
This will take 20-30 minutes.

### Step 2 (optional): Create offline Mathlib help

Note: this step will modify files in `TryLean4Launcher` directory. Don't run Step 1 again after running this step!

- If you have github command line `gh` installed and with your github token in environment variable, double click `003_download_mathlib4_docs.cmd`.
  This will download latest Mathlib help from <https://github.com/leanprover-community/mathlib4_docs/actions>.
  It will process the downloaded help, add them into `TryLean4Bundle.7z` and `OfflineMathlibHelp.7z`.
  It will take 20-30 minutes.
- Otherwise, double click `002_compile_mathlib4_docs.cmd`.
  This will download and run doc-gen4 to build Mathlib help locally.
  It will process the generated help, add them into `TryLean4Bundle.7z` and `OfflineMathlibHelp.7z`.
  It will take a few hours.

TODO: Add a way to create offline Mathlib help without creating TryLean4Bundle package
