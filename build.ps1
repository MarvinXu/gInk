$ExeName = "gInk.exe"
$MsbuildPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

Write-Host "Checking if $ExeName is running..."
Get-Process $ExeName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Write-Host "Building gInk..."
& $MsbuildPath gInk.sln /p:Configuration=Release /p:Platform=x86 /verbosity:minimal

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
