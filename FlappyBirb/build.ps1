# Builds a standalone Windows version of Flappy Birb that runs without LÖVE
# installed. Output goes to ../dist:
#   dist/FlappyBirb/              - FlappyBirb.exe plus the DLLs it needs
#   dist/FlappyBirb-windows.zip   - the folder above, zipped, ready to share
#
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1 [-LovePath <dir>]
param(
    [string]$LovePath = 'C:\Program Files\LOVE'
)

$ErrorActionPreference = 'Stop'

$gameDir = $PSScriptRoot
$distDir = Join-Path (Split-Path $gameDir -Parent) 'dist'
$outDir = Join-Path $distDir 'FlappyBirb'
$loveFile = Join-Path $distDir 'FlappyBirb.love'
$zipFile = Join-Path $distDir 'FlappyBirb-windows.zip'

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
    main.lua class.lua push.lua StateMachine.lua Bird.lua Pipe.lua PipePair.lua states `
    background.png ground.png bird.png pipe.png font.ttf flappy.ttf `
    jump.wav explosion.wav hurt.wav score.wav marios_way.mp3
if ($LASTEXITCODE -ne 0) { throw 'Failed to create FlappyBirb.love' }

# 2. append the .love to love.exe; LÖVE runs a game fused to its own exe
cmd /c copy /b "`"$LovePath\love.exe`"+`"$loveFile`"" "`"$outDir\FlappyBirb.exe`"" | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Failed to create FlappyBirb.exe' }

# 3. the exe still needs LÖVE's DLLs next to it; its license must ship too
Copy-Item (Join-Path $LovePath '*.dll') $outDir
Copy-Item (Join-Path $LovePath 'license.txt') $outDir

# 4. zip the folder so it can be shared as a single file
& $tar -a -cf $zipFile -C $distDir FlappyBirb
if ($LASTEXITCODE -ne 0) { throw 'Failed to create FlappyBirb-windows.zip' }

Remove-Item $loveFile

Write-Host "Done: $zipFile"
