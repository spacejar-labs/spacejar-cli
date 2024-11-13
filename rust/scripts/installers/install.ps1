# Enable strict mode for better error handling
Set-StrictMode -Version Latest

Write-Host "Installing SpaceJar CLI..." -ForegroundColor Blue

# Detect OS architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "x86" }

# Get the latest version from GitHub
Write-Host "Getting latest version..." -ForegroundColor Blue
try {
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/spacejar-labs/spacejar-cli/releases/latest"
    $version = $latestRelease.tag_name
} catch {
    Write-Host "Failed to get the latest version from GitHub." -ForegroundColor Red
    Exit 1
}

# Set up install directory
$installDir = "$env:LOCALAPPDATA\spacejar\bin"
if (-Not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}
Write-Host "Install directory set to $installDir" -ForegroundColor Blue

# Download and extract the binary
$filename = "spacejar-${version}-windows-${arch}.zip"
$url = "https://github.com/spacejar-labs/spacejar-cli/releases/download/${version}/${filename}"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir | Out-Null

Write-Host "Downloading SpaceJar $version for Windows $arch..." -ForegroundColor Blue
try {
    $zipFile = "$tempDir\$filename"
    Invoke-WebRequest -Uri $url -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath $tempDir
    Move-Item -Path "$tempDir\spacejar.exe" -Destination "$installDir\spacejar.exe" -Force
} catch {
    Write-Host "Failed to download or extract $filename." -ForegroundColor Red
    Remove-Item -Path $tempDir -Recurse -Force
    Exit 1
} finally {
    Remove-Item -Path $tempDir -Recurse -Force
}

# Update PATH if necessary
$pathAddition = $installDir
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if (-Not ($currentPath -split ';' | Where-Object { $_ -eq $pathAddition })) {
    $newPath = "$currentPath;$pathAddition"
    # Update both persistent and current session
    [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::User)
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
    Write-Host "Added $installDir to PATH." -ForegroundColor Green
}

Write-Host "SpaceJar CLI installed successfully." -ForegroundColor Green
Write-Host "Verifying installation..." -ForegroundColor Blue

# Verify installation
try {
    & "$installDir\spacejar.exe" --version
} catch {
    Write-Host "Failed to verify installation." -ForegroundColor Red
}
