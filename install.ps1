#Requires -Version 5.1
<#
  Voided Items - J510 black screen patch (unofficial)
  Usage:
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -ModPath "D:\Steam\...\mods\voided items_3312038195"
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

$rendering = Join-Path $ModPath 'rendering.lua'
$shader = Join-Path $ModPath 'content\shaders.xml'
$shaderDisabled = Join-Path $ModPath 'content\shaders.xml.disabled'
if (-not (Test-Path -LiteralPath $rendering)) {
  throw "rendering.lua not found in $ModPath. Is this the Voided Items mod folder?"
}

$backup = Join-Path $ModPath ('.j510-patch-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item -LiteralPath $rendering -Destination $backup -Force
if (Test-Path -LiteralPath $shader) { Copy-Item -LiteralPath $shader -Destination $backup -Force }

Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'patch\rendering.lua') -Destination $rendering -Force
if (Test-Path -LiteralPath $shader) {
  Move-Item -LiteralPath $shader -Destination $shaderDisabled -Force
}

Write-Output "Patched: $ModPath"
Write-Output "Backup:  $backup"
Write-Output 'Restart The Binding of Isaac. To roll back, run uninstall.ps1.'
