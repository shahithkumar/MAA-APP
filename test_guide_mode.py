import requests
import json

def test_chat(query, mode='guide', session_id='test_session_1'):
    url = "http://10.123.238.189:8000/api/chat/"
    # Try localhost first in case I'm on the same machine
    try:
        requests.get("http://localhost:8000/api/chat/")
        url = "http://localhost:8000/api/chat/"
    except:
        pass
        
    payload = {
        "session_id": session_id,
        "query": query,
        "mode": mode
    }
    headers = {'Content-Type': 'application/json'}
    
    print(f"Testing {mode} mode with query: {query}")
    try:
        response = requests.post(url, data=json.dumps(payload), headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_chat("I am feeling very anxious right now.")
    test_chat("Yes, please help me with some exercises.", session_id='test_session_1')
