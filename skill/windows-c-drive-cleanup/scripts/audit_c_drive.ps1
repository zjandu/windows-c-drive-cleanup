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

function Get-PathBytes([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSIsContainer) { return Get-DirBytes $Path }
    return $item.Length
}

function Get-CandidateSummary([string[]]$Paths) {
    foreach ($path in $Paths) {
        if (Test-Path -LiteralPath $path) {
            $item = Get-Item -LiteralPath $path -Force
            $bytes = Get-PathBytes $path
            [pscustomobject]@{
                Path = $path
                Type = if ($item.PSIsContainer) { 'Dir' } else { 'File' }
                SizeGB = [math]::Round($bytes / 1GB, 3)
            }
        }
    }
}

$driveInfo = Get-PSDrive -PSProvider FileSystem | Where-Object Name -eq $Drive | Select-Object Name,
    @{Name='UsedGB';Expression={[math]::Round($_.Used / 1GB, 2)}},
    @{Name='FreeGB';Expression={[math]::Round($_.Free / 1GB, 2)}},
    @{Name='TotalGB';Expression={[math]::Round(($_.Used + $_.Free) / 1GB, 2)}}

$rootCandidates = @(
    "${Drive}:\Windows",
    "${Drive}:\Users",
    "${Drive}:\Program Files",
    "${Drive}:\Program Files (x86)",
    "${Drive}:\ProgramData",
    "${Drive}:\Recovery",
    "${Drive}:\pagefile.sys",
    "${Drive}:\hiberfil.sys",
    "${Drive}:\swapfile.sys",
    "${Drive}:\Windows\MEMORY.DMP"
)

$cleanupCandidates = @(
    (Join-Path $UserProfile 'AppData\Local\Temp'),
    "${Drive}:\Windows\Temp",
    "${Drive}:\Windows\SoftwareDistribution\Download",
    "${Drive}:\Windows\MEMORY.DMP",
    (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Cache'),
    (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Code Cache'),
    (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\GPUCache'),
    (Join-Path $UserProfile 'AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage')
)

$systemFiles = @(
    "${Drive}:\hiberfil.sys",
    "${Drive}:\pagefile.sys",
    "${Drive}:\swapfile.sys",
    "${Drive}:\aow_drv.log"
)

$result = [pscustomobject]@{
    Drive = $driveInfo
    RootTop = Get-CandidateSummary $rootCandidates | Sort-Object SizeGB -Descending
    CleanupCandidates = Get-CandidateSummary $cleanupCandidates | Sort-Object SizeGB -Descending
    SystemFiles = Get-CandidateSummary $systemFiles | Sort-Object SizeGB -Descending
    AppData = if ($IncludeAppDataBreakdown) {
        [pscustomobject]@{
            LocalTop = Get-ChildItem -LiteralPath (Join-Path $UserProfile 'AppData\Local') -Force | ForEach-Object {
                $bytes = Get-PathBytes $_.FullName
                [pscustomobject]@{ Name = $_.Name; Type = if ($_.PSIsContainer) { 'Dir' } else { 'File' }; SizeGB = [math]::Round($bytes / 1GB, 3) }
            } | Sort-Object SizeGB -Descending | Select-Object -First 25
            RoamingTop = Get-ChildItem -LiteralPath (Join-Path $UserProfile 'AppData\Roaming') -Force | ForEach-Object {
                $bytes = Get-PathBytes $_.FullName
                [pscustomobject]@{ Name = $_.Name; Type = if ($_.PSIsContainer) { 'Dir' } else { 'File' }; SizeGB = [math]::Round($bytes / 1GB, 3) }
            } | Sort-Object SizeGB -Descending | Select-Object -First 25
        }
    } else { $null }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 6
}
else {
    $result
}
