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
    "age": "20",
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
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    print("✅ Successfully logged in and got JWT Token!")
    
    # 3. Test Secure Endpoints WITH Inputs (POST/GET)
    print(f"\n3. Testing Endpoints with Inputs as Authenticated User...\n")
    
    tests = [
        {"method": "POST", "url": "/api/chat/", "data": {"query": "Hello MAA", "session_id": "test_session_1"}},
        {"method": "POST", "url": "/api/sos/", "data": {"location": "12.9716, 77.5946"}}, # Bangalore coords
        {"method": "GET",  "url": "/api/meditations/", "data": None},
        {"method": "GET",  "url": "/api/yoga/", "data": None},
        {"method": "GET",  "url": "/api/affirmations/generic/", "data": None},
        {"method": "GET",  "url": "/api/background-music/", "data": None},
        {"method": "POST", "url": "/api/moods/", "data": {"moodEmoji": "😊", "moodLabel": "Happy", "note": "Testing the deployment!"}},
        {"method": "GET",  "url": "/api/moods/summary/", "data": None},
        {"method": "POST", "url": "/api/journal/2/", "data": {"transcribed_text": "I had a pretty good day today. Reached out to a friend.", "emotion_scores": {"happiness": 0.8, "sadness": 0.1}, "confidence_score": 0.9}},
        {"method": "GET",  "url": "/api/journal/2/", "data": None},
    ]
    
    for test in tests:
        url = f"{BASE_URL}{test['url']}"
        try:
            if test["method"] == "POST":
                e_resp = requests.post(url, headers=headers, json=test["data"], timeout=120)
            else:
                e_resp = requests.get(url, headers=headers, timeout=120)
            
            # Status 200 or 201 means absolute success!
            if e_resp.status_code in [200, 201]:
                print(f"✅ [WORKING] {test['url']:<30} -> Status: {e_resp.status_code}")
                # Print a tiny snippet of the response so you can see it actually worked
                print(f"   Response: {str(e_resp.json())[:80]}...")
            else:
                print(f"❌ [ISSUE]   {test['url']:<30} -> Status: {e_resp.status_code} - {e_resp.text[:50]}")
                
        except Exception as e:
            print(f"❌ [FAILED]  {test['url']:<30} -> Error: {e}")
else:
    print(f"❌ Failed to login: {resp.text}")
