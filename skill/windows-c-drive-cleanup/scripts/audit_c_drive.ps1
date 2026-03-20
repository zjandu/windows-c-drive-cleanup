[CmdletBinding()]
param(
    [string]$Drive = 'C',
    [string]$UserProfile = $env:USERPROFILE,
    [switch]$IncludeAppDataBreakdown,
    [switch]$AsJson
)

$ErrorActionPreference = 'SilentlyContinue'

function Get-FileBytes([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        return (Get-Item -LiteralPath $Path -Force).Length
    }
    return 0
}

function Get-DirBytes([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        return (Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    }
    return 0
}

function Get-ChildBreakdown([string]$Path, [int]$Top = 20) {
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    Get-ChildItem -LiteralPath $Path -Force | ForEach-Object {
        if ($_.PSIsContainer) {
            $size = Get-DirBytes $_.FullName
            [pscustomobject]@{ Name = $_.Name; Type = 'Dir'; SizeGB = [math]::Round($size / 1GB, 2) }
        }
        else {
            [pscustomobject]@{ Name = $_.Name; Type = 'File'; SizeGB = [math]::Round($_.Length / 1GB, 2) }
        }
    } | Sort-Object SizeGB -Descending | Select-Object -First $Top
}

$driveInfo = Get-PSDrive -PSProvider FileSystem | Where-Object Name -eq $Drive | Select-Object Name,
    @{Name='UsedGB';Expression={[math]::Round($_.Used / 1GB, 2)}},
    @{Name='FreeGB';Expression={[math]::Round($_.Free / 1GB, 2)}},
    @{Name='TotalGB';Expression={[math]::Round(($_.Used + $_.Free) / 1GB, 2)}}

$cleanupPaths = @(
    Join-Path $UserProfile 'AppData\Local\Temp'
    "${Drive}:\Windows\Temp"
    "${Drive}:\Windows\SoftwareDistribution\Download"
    "${Drive}:\Windows\MEMORY.DMP"
    Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Cache'
    Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Code Cache'
    Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\GPUCache'
    Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage'
)

$cleanupSummary = foreach ($path in $cleanupPaths) {
    if (Test-Path -LiteralPath $path) {
        $item = Get-Item -LiteralPath $path -Force
        $bytes = if ($item.PSIsContainer) { Get-DirBytes $path } else { $item.Length }
        [pscustomobject]@{
            Path = $path
            Type = if ($item.PSIsContainer) { 'Dir' } else { 'File' }
            SizeGB = [math]::Round($bytes / 1GB, 3)
        }
    }
}

$systemFiles = @(
    "${Drive}:\hiberfil.sys"
    "${Drive}:\pagefile.sys"
    "${Drive}:\swapfile.sys"
    "${Drive}:\aow_drv.log"
) | ForEach-Object {
    if (Test-Path -LiteralPath $_) {
        [pscustomobject]@{
            Path = $_
            SizeGB = [math]::Round((Get-FileBytes $_) / 1GB, 3)
        }
    }
}

$result = [pscustomobject]@{
    Drive = $driveInfo
    RootTop = Get-ChildBreakdown "${Drive}:\"
    CleanupCandidates = $cleanupSummary
    SystemFiles = $systemFiles
    AppData = if ($IncludeAppDataBreakdown) {
        [pscustomobject]@{
            LocalTop = Get-ChildBreakdown (Join-Path $UserProfile 'AppData\Local') 25
            RoamingTop = Get-ChildBreakdown (Join-Path $UserProfile 'AppData\Roaming') 25
        }
    } else { $null }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result
}
