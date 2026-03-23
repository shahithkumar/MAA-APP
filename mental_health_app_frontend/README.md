1. 📂 MODEL PATH (Where the files LIVE)
C:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\models (Do not move them. The server reads from here.)

2. 🚀 ML SERVER COMMAND (Run this FIRST)
Path: C:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\start_ml_server.bat

Command to run in Terminal:

powershell
cd ml_inference_server
venv\Scripts\activate
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
3. 🌐 BACKEND COMMAND (Run this SECOND)
Path: C:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\manage.py

Command to run in Terminal:

powershell
python manage.py runserver 0.0.0.0:8000

---
### 📱 CONNECTING YOUR MOBILE APP
 Your computer's IP is: **10.123.238.189**
 
 1. Make sure your phone and laptop are on the SAME Wi-Fi.
 2. In the App Login Screen > Settings Icon ⚙️ > Enter: `http://10.123.238.189:8000`
 3. Click Save.

---
### 📦 BUILD & INSTALL COMMANDS

1. **Build APK:**
   Open a new terminal in VS Code and run:
   ```powershell
   cd mental_health_app_frontend
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

   **Option A: PowerShell (Default in VS Code)**
   ```powershell
   cd mental_health_app_frontend
   & "C:\Users\shahi\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-release.apk"
   ```

   **Option B: Command Prompt (cmd)**
   ```cmd
   cd mental_health_app_frontend
   "C:\Users\shahi\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-release.apk"
   ```

TO INSTALL IN PHONE:

"C:\Users\shahi\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-release.apk"


