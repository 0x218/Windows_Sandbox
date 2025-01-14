# Windows_Sandbox

This document explains the step I am using to run my java web application in Windows Sandbox.  It’s a POC to explain the usage of Sandbox and automate application software testing in a clean Sandbox environment.


# Pre-requisites:
1.	Download and place the Oracle JDK-22 in the host machine folder (ex: C:\Sandbox\jdk22.exe)
2.	Place java executable that will run may java application in the host machine folder (ex: C:\Sandbox\myJavaApp.exe)


# Workflow Logic:
1.	Sandbox configuration is written inside a .wsb file.  You can double click this file or run it through script.
2.	As part of Sandbox configuration, as soon as the booting process of Sandbox completes, a PowerShell script (execute_job.ps1) will get executed inside the Sandbox.
3.	The PowerShell script (execute_job.ps1) installs java, disables firewall in Sandbox, Updates MS-Edge browser, Opens MS Edge, Runs the java web application (jar file) in MS-Edge browser.

# Scripts:
1.	Powershell script to trigger the Sandbox: trigger_container.ps1
   ```
##File name: trigger_container.ps1
## Command: powershell -ExecutionPolicy Bypass -File .\trigger_container.ps1

$sandboxConfig = "C:\Sandbox\container.wsb"

# How many iterations to run the test/sandbox
$iterations = 2

# Loop to create and destroy the sandbox
for ($i = 1; $i -le $iterations; $i++) {
    Write-Host "Starting sandbox instance $i..." -ForegroundColor Green
    
    # Start the sandbox
    $sandboxProcess = Start-Process -FilePath "WindowsSandbox.exe" -ArgumentList $sandboxConfig -PassThru

    # Wait for the sandbox to complete its task
    Write-Host "Waiting for sandbox instance $i to complete..."
    $sandboxProcess.WaitForExit()

    Write-Host "Sandbox instance $i finished and destroyed." -ForegroundColor Yellow
}
```

# 2.	WSB (Windows Sand Box) configuration file
```
<!--File name: container.wsb --!>
<Configuration>
    <VGpu>Disable</VGpu>
    <Networking>Enable</Networking>
    <shutdown>true</shutdown>
    <MappedFolders>
       <MappedFolder>
       <HostFolder>C:\Sandbox</HostFolder>
    <SandboxFolder>C:\Sandbox</SandboxFolder>
    <ReadOnly>false</ReadOnly>
  </MappedFolder>
</MappedFolders>
<LogonCommand>
    <Command>powershell -executionpolicy unrestricted -command "start powershell { -noexit -file C:\Sandbox\run_myJavaApp.ps1}"</Command>
</LogonCommand>
</Configuration>
```

# 3.	Powershell script that runs the tasks in Sandbox: run_myJavaApp.ps1
```
## File name: run_myJavaApp.ps1

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

Write-Host "Installing Java..."
Start-Process 'C:\Sandbox\jdk22.exe' `
  -ArgumentList 'INSTALL_SILENT=Enable REBOOT=Disable SPONSORS=Disable' `
  -Wait -PassThru

Write-Host "Refreshing environment variables..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# Disable Firewall (Optional)
Write-Host "Disabling Windows Firewall..."
netsh advfirewall set allprofiles state off

Write-Host "Verifying Java installation..."
java -version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Java installation verification failed!" -ForegroundColor Red
    exit 1
}

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
```


Happy Sandboxing!

Renjith
