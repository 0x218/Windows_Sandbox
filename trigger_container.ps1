####Run command: powershell -ExecutionPolicy Bypass -File .\trigger_container.ps1

$sandboxConfig = "C:\Sandbox\container.wsb"

# Number of iterations
$iterations = 2

# Loop to create and destroy the sandbox
for ($i = 1; $i -le $iterations; $i++) {
    Write-Host "Starting sandbox instance $i..." -ForegroundColor Green
    
    # Start the sandbox
    $sandboxProcess = Start-Process -FilePath "WindowsSandbox.exe" -ArgumentList $sandboxConfig -PassThru

    # Monitor the sandbox process
    Write-Host "Waiting for sandbox instance $i to complete..."
    $sandboxProcess.WaitForExit()

    Write-Host "Sandbox instance $i finished and destroyed." -ForegroundColor Yellow
}

