@echo off
echo Starting ML Inference Server...
echo Ensure you have the model .pt files in ml_inference_server/models/
cd ml_inference_server
uvicorn main:app --reload --port 8001 --host 0.0.0.0
pause
