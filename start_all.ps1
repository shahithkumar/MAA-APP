Write-Host "Starting all components..."

$root = (Get-Location).Path

# Start Django Backend
Write-Host "Launching Django Backend..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "& {cd '$root'; if (Test-Path 'venv') { .\venv\Scripts\Activate.ps1 } else { Write-Warning 'Result: No venv found in root.' }; python manage.py runserver 0.0.0.0:8000}"

# Start ML Inference Server
Write-Host "Launching ML Inference Server..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "& {cd '$root\ml_inference_server'; if (Test-Path '..\venv') { ..\venv\Scripts\Activate.ps1 } else { Write-Warning 'Result: No root venv found.' }; uvicorn main:app --reload --host 0.0.0.0 --port 8001}"

# Start Flutter Frontend
Write-Host "Launching Flutter Frontend..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "& {cd '$root\mental_health_app_frontend'; flutter run}"

Write-Host "All components launched. Please check the 3 new PowerShell windows."
