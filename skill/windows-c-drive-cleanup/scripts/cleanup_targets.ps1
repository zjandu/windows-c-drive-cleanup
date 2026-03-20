[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$UserProfile = $env:USERPROFILE,
    [switch]$ClearUserTemp,
    [switch]$ClearChromeCache,
    [switch]$ClearUpdaterCaches,
    [string[]]$RemoveApprovedDirs = @(),
    [switch]$DeleteMemoryDump,
    [switch]$DeleteDriverLogs
)

$ErrorActionPreference = 'SilentlyContinue'

function Get-Bytes([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSIsContainer) {
        return (Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    }
    return $item.Length
}

function Remove-Target([string]$Path, [string]$Mode) {
    $before = Get-Bytes $Path
    if (-not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{ Path = $Path; Action = $Mode; BeforeGB = 0; AfterGB = 0; Success = $true; Note = 'missing' }
    }

    if ($PSCmdlet.ShouldProcess($Path, $Mode)) {
        try {
            switch ($Mode) {
                'remove-file' { Remove-Item -LiteralPath $Path -Force -ErrorAction Stop }
                'remove-dir' { Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop }
                'clear-dir-contents' {
                    Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
        catch {
        }
    }

    $afterExists = Test-Path -LiteralPath $Path
    $after = Get-Bytes $Path
    [pscustomobject]@{
        Path = $Path
        Action = $Mode
        BeforeGB = [math]::Round($before / 1GB, 3)
        AfterGB = [math]::Round($after / 1GB, 3)
        Success = ($after -lt $before -or -not $afterExists)
        Note = if ($afterExists) { 'exists-after' } else { 'removed' }
    }
}

$targets = @()

if ($ClearUserTemp) {
    $targets += [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\Temp'); Mode = 'clear-dir-contents' }
}

if ($ClearChromeCache) {
    $targets += @(
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Cache'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Code Cache'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\GPUCache'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage'); Mode = 'remove-dir' }
    )
}

if ($ClearUpdaterCaches) {
    $targets += @(
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\chatglm-updater'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\openscreen-updater'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\pencil-updater'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\xmind-updater'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\dt-updater'); Mode = 'remove-dir' },
        [pscustomobject]@{ Path = (Join-Path $UserProfile 'AppData\Local\notion-updater'); Mode = 'remove-dir' }
    )
}

foreach ($dir in $RemoveApprovedDirs) {
    if ($dir) {
        $targets += [pscustomobject]@{ Path = $dir; Mode = 'remove-dir' }
    }
}

if ($DeleteMemoryDump) {
    $targets += [pscustomobject]@{ Path = 'C:\Windows\MEMORY.DMP'; Mode = 'remove-file' }
}

if ($DeleteDriverLogs) {
    $targets += [pscustomobject]@{ Path = 'C:\aow_drv.log'; Mode = 'remove-file' }
}

$results = foreach ($target in $targets) {
    Remove-Target -Path $target.Path -Mode $target.Mode
}

$results | Format-Table -AutoSize
