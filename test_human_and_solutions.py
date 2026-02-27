import os
import django
import sys

# Setting up environment
sys.path.append(r"c:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')

# Mocking database for testing if needed
try:
    django.setup()
except:
    pass

from chatbot.orchestrator import process_message

def test_interaction():
    # TEST 1: FRIEND MODE (Talk like a real person)
    print("--- [TEST 1: FRIEND MODE (Human Persona)] ---")
    session_id_f = "human_test_session"
    res_f = process_message(session_id_f, "Hi, I'm just having a really bad day. Work is killing me.", mode='friend')
    print(f"USER: Hi, I'm just having a really bad day. Work is killing me.")
    print(f"MAA (Friend): {res_f}\n")

    # TEST 2: GUIDE MODE (Solution Timing Check - 4 Turns)
    print("--- [TEST 2: GUIDE MODE (Solution after 3-4 turns)] ---")
    session_id_g = "solution_timing_test_session"
    mode = 'guide'
    
    turns = [
        "I'm feeling very anxious today.",
        "I've been feeling this for a week now.",
        "I just can't stop thinking about failure." # Turn 3: Should trigger solution logic
    ]
    
    for i, msg in enumerate(turns, 1):
        response = process_message(session_id_g, msg, mode=mode)
        print(f"TURN {i}")
        print(f"USER: {msg}")
        print(f"MAA: {response}\n")

if __name__ == "__main__":
    test_interaction()
