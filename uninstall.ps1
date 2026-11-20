#Requires -Version 5.1
<#
  Voided Items - J510 black screen patch (unofficial)
  Restores the files saved by install.ps1.
  Usage:
    powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
    powershell -ExecutionPolicy Bypass -File .\uninstall.ps1 -ModPath "D:\Steam\...\mods\voided items_3312038195"
#>
[CmdletBinding()]
param([string]$ModPath)
$ErrorActionPreference = 'Stop'

function Find-VoidedItemsMod {
  $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
  $candidates = @()
  if ($steam) { $candidates += (Join-Path $steam 'steamapps\common\The Binding of Isaac Rebirth\mods\voided items_3312038195') }
  $candidates += 'C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\mods\voided items_3312038195'
  $candidates += 'D:\Steam\steamapps\common\The Binding of Isaac Rebirth\mods\voided items_3312038195'
  foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { return $c } }
  return $null
}

if (-not $ModPath) { $ModPath = Find-VoidedItemsMod }
if (-not $ModPath -or -not (Test-Path -LiteralPath $ModPath)) {
  throw 'Could not find the Voided Items mod folder. Pass it with -ModPath "X:\...\mods\voided items_3312038195".'
}

$backup = Get-ChildItem -LiteralPath $ModPath -Directory -Filter '.j510-patch-backup-*' |
  Sort-Object Name -Descending | Select-Object -First 1
if (-not $backup) { throw "No patch backup found in $ModPath." }

Copy-Item -LiteralPath (Join-Path $backup.FullName 'rendering.lua') -Destination (Join-Path $ModPath 'rendering.lua') -Force
$shaderBackup = Join-Path $backup.FullName 'shaders.xml'
if (Test-Path -LiteralPath $shaderBackup) {
  Copy-Item -LiteralPath $shaderBackup -Destination (Join-Path $ModPath 'content\shaders.xml') -Force
  $disabled = Join-Path $ModPath 'content\shaders.xml.disabled'
  if (Test-Path -LiteralPath $disabled) { Remove-Item -LiteralPath $disabled -Force }
}

Write-Output "Restored original files from: $($backup.FullName)"
Write-Output 'Restart The Binding of Isaac. The backup folder is kept; delete it manually if you no longer need it.'
