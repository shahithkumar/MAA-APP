
import requests
import json

BASE_URL = "http://127.0.0.1:8002"

def test_grounding_session_ai():
    print("--- Testing Grounding Session AI Solution ---")
    
    # Login
    login_data = {
        "email": "testuser@example.com",
        "password": "Password123!"
    }
    
    response = requests.post(f"{BASE_URL}/api/auth/login/", json=login_data)
    if response.status_code != 200:
        print("Login failed. Make sure server is running and user exists.")
        return
        
    token = response.json().get("access_token")
    headers = {"Authorization": f"Bearer {token}"}
    
    # Grounding session data
    grounding_data = {
        "five_see": "A blue vase, a green plant, a window with sunlight, a white coffee mug, and my laptop keyboard.",
        "four_touch": "The cold metal of my desk, the soft fabric of my chair, my own hands rubbing together, and the smooth phone screen.",
        "three_hear": "A distant siren, the hum of the refrigerator, and the sound of my own rhythmic breathing.",
        "two_smell": "The faint scent of coffee and the smell of fresh rain from the open window.",
        "one_taste": "The lingering bitterness of the coffee I just finished."
    }
    
    print("\nSubmitting Grounding Session...")
    res = requests.post(f"{BASE_URL}/api/sessions/grounding/", json=grounding_data, headers=headers)
    
    if res.status_code == 201:
        result = res.json()
        feedback = result.get("feedback", "No feedback received")
        print("\n--- GROUNDING AI SOLUTION RECEIVED ---")
        print(feedback)
        print("---------------------------------------")
        
        if "Analysis" in feedback and "Proposed Solution" in feedback:
            print("\n✅ Success: Grounding response contains structured analysis and solution.")
        else:
            print("\n⚠️ Warning: Feedback might be missing structured sections.")
    else:
        print(f"❌ Failed: {res.status_code} - {res.text}")

if __name__ == "__main__":
    test_grounding_session_ai()
