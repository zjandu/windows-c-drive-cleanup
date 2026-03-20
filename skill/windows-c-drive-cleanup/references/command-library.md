# Command Library

## Drive Totals

```powershell
Get-PSDrive -PSProvider FileSystem | Where-Object Name -eq 'C'
```

## Root Breakdown

Use the bundled script for a faster fixed-candidate audit:

```powershell
.\scripts\audit_c_drive.ps1 -Drive C
```

## Common Reclaimable Paths

Typical examples:

- `%LOCALAPPDATA%\Temp`
- `C:\Windows\Temp`
- `C:\Windows\SoftwareDistribution\Download`
- `C:\Windows\MEMORY.DMP`
- browser caches
- updater installer caches

## Hibernation

Requires real admin elevation:

```powershell
powercfg /hibernate off
```

## Page File Inspection

```powershell
Get-CimInstance Win32_PageFileUsage
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
```

## Crash Dump Policy

```powershell
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
```

## Suggested Script Usage

Audit:

```powershell
.\scripts\audit_c_drive.ps1 -Drive C -IncludeAppDataBreakdown
```

Safe cleanup batch:

```powershell
.\scripts\cleanup_targets.ps1 -ClearUserTemp -ClearChromeCache -ClearUpdaterCaches
```

Approved app-local data removal:

```powershell
.\scripts\cleanup_targets.ps1 -RemoveApprovedDirs @('C:\Path\ApprovedAppLocalData')
```

Conditional cleanup:

```powershell
.\scripts\cleanup_targets.ps1 -DeleteMemoryDump -DeleteDriverLogs
```

## Verification

```powershell
Get-PSDrive -PSProvider FileSystem | Where-Object Name -eq 'C'
```

## Important Interpretation Rules

- If a file still exists after deletion, check whether it was recreated or never removed.
- If admin-only commands fail, report the exact failure.
- If a browser cache reappears, it may be because the browser is still running.
- If a registered uninstall path is stale, treat it as a leftover uninstall entry rather than proof that the app is still installed.
