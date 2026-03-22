import requests
import json
import time

BASE_URL = "https://maa-backend-u6e5.onrender.com"

# 1. Register a test user
print("1. Creating a test user...")
register_data = {
    "name": "Test User",
    "email": f"test_{int(time.time())}@example.com",
    "password": "SecurePassword123!",
    "confirm_password": "SecurePassword123!",
    "age": 20,
    "phone_number": "1234567890",
    "guardian_name": "Guardian",
    "guardian_relationship": "Parent",
    "guardian_phone_number": "0987654321",
    "guardian_email": "guardian@example.com"
}

resp = requests.post(f"{BASE_URL}/api/auth/register/", data=register_data)
print(f"Registration status: {resp.status_code}")

# 2. Login
print("\n2. Logging in...")
login_data = {
    "email": register_data["email"],
    "password": register_data["password"]
}

resp = requests.post(f"{BASE_URL}/api/auth/login/", json=login_data)
print(f"Login status: {resp.status_code}")

if resp.status_code == 200:
    token = resp.json().get('access_token')
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Successfully logged in and got JWT Token!")
    
    # 3. Test Secure Endpoints
    ENDPOINTS = [
        "/api/chat/",
        "/api/sos/",
        "/api/meditations/",
        "/api/yoga/",
        "/api/affirmations/generic/",
        "/api/background-music/",
        "/api/moods/summary/",
        "/api/journal/tri-modal/",
        "/api/journal/2/"
    ]
    
    print(f"\n3. Testing Endpoints as Authenticated User...\n")
    for endpoint in ENDPOINTS:
        url = f"{BASE_URL}{endpoint}"
        try:
            # We'll stick to GET requests just to check if they are up and running
            e_resp = requests.get(url, headers=headers, timeout=10)
            
            # Status 200 (OK) or Status 405 (Method Not Allowed - usually means it wants POST instead of GET)
            if e_resp.status_code in [200, 405]:
                print(f"✅ [WORKING] {endpoint:<30} -> Status: {e_resp.status_code}")
            else:
                print(f"❌ [ISSUE]   {endpoint:<30} -> Status: {e_resp.status_code} - {e_resp.text[:50]}")
                
        except Exception as e:
            print(f"❌ [FAILED]  {endpoint:<30} -> Error: {e}")
else:
    print(f"❌ Failed to login: {resp.text}")
