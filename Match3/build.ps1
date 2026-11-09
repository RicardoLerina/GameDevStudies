# Builds a standalone Windows version of Match3 that runs without LÖVE
# installed. Output goes to ../dist:
#   dist/Match3/              - Match3.exe plus the DLLs it needs
#   dist/Match3-windows.zip   - the folder above, zipped, ready to share
#
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1 [-LovePath <dir>]
param(
    [string]$LovePath = 'C:\Program Files\LOVE'
)

$ErrorActionPreference = 'Stop'

$gameDir = Join-Path $PSScriptRoot 'match-3'
$distDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'dist'
$outDir = Join-Path $distDir 'Match3'
$loveFile = Join-Path $distDir 'Match3.love'
$zipFile = Join-Path $distDir 'Match3-windows.zip'

# Windows' own tar (bsdtar) can write zip files, unlike Git Bash's tar
$tar = Join-Path $env:SystemRoot 'System32\tar.exe'

if (-not (Test-Path (Join-Path $LovePath 'love.exe'))) {
    throw "love.exe not found in '$LovePath'. Pass -LovePath with your LÖVE folder."
}

# start from a clean output, removing only this game's files since dist is
# shared with the other games' builds
foreach ($old in $outDir, $loveFile, $zipFile) {
    if (Test-Path $old) {
        Remove-Item -Recurse -Force $old
    }
}
New-Item -ItemType Directory -Force $outDir | Out-Null

# 1. package the game files into a .love file (a zip with main.lua at its root)
& $tar --format zip -cf $loveFile -C $gameDir `
    main.lua lib src fonts graphics sounds
if ($LASTEXITCODE -ne 0) { throw 'Failed to create Match3.love' }

# 2. append the .love to love.exe; LÖVE runs a game fused to its own exe
cmd /c copy /b "`"$LovePath\love.exe`"+`"$loveFile`"" "`"$outDir\Match3.exe`"" | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Failed to create Match3.exe' }

# 3. the exe still needs LÖVE's DLLs next to it; its license must ship too
Copy-Item (Join-Path $LovePath '*.dll') $outDir
Copy-Item (Join-Path $LovePath 'license.txt') $outDir

# 4. zip the folder so it can be shared as a single file
& $tar -a -cf $zipFile -C $distDir Match3
if ($LASTEXITCODE -ne 0) { throw 'Failed to create Match3-windows.zip' }

Remove-Item $loveFile

Write-Host "Done: $zipFile"
