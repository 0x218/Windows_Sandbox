###############################################################################
## This script is responsible to setup environment in the Sandbox.
## you may customize this file as you need.
## 
## You need to enable Windows Sandbox (a Windows Feature) in your Windows 11.
## Create a folder Sandbox in your C drive.
## Download Oracle JDK 22 -> rename it to C:\Sandbox\jdk22.exe
## Place your java application (built with JRE/JDK 22) as C:\Sandbox\myJavaApp.jar
## Place container.wsb as C:\Sandbox\container.wsb.
## Execute powershell -ExecutionPolicy Bypass -File .\trigger_container.ps1
################################################################################


$progressPreference = 'silentlyContinue'

# Paths to Files in the Sandbox
$javaInstaller = "C:\Sandbox\jdk22.exe"
$jarFile = "C:\Sandbox\myJavaApp.jar"

# Log paths for debugging
Write-Host "Checking paths..." -ForegroundColor Cyan
Write-Host "Java Installer Path: $javaInstaller" -ForegroundColor Yellow
Write-Host "JAR File Path: $jarFile" -ForegroundColor Yellow


# Verify Java Installer Exists
if (!(Test-Path $javaInstaller)) {
    Write-Host "Java installer not found!" -ForegroundColor Red
    exit 1
}

# Install JRE Silently
Write-Host "Installing Java..."
Start-Process 'C:\Sandbox\jdk22.exe' `
  -ArgumentList 'INSTALL_SILENT=Enable REBOOT=Disable SPONSORS=Disable' `
  -Wait -PassThru


## Refresh PATH
Write-Host "Refreshing environment variables..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")


# Disable Firewall (Optional)
Write-Host "Disabling Windows Firewall..."
netsh advfirewall set allprofiles state off

# Verify Java Installation
Write-Host "Verifying Java installation..."
java -version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Java installation verification failed!" -ForegroundColor Red
    exit 1
}

# Start Edge update manually in the Sandbox
Write-Host "Triggering Microsoft Edge update..."
Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "--force-update"


# Run the JAR File
Write-Host "Running JAR file..."
Start-Process -FilePath "java" -ArgumentList "-jar $jarFile" -NoNewWindow -Wait
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to run JAR file!" -ForegroundColor Red
    exit 1
}

# Shutdown Sandbox
Write-Host "Shutting down sandbox..."
Stop-Computer -Force

