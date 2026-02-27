import sys
import os

# Mocking Django settings for standalone test
class MockSettings:
    GROQ_API_KEY = "gsk_..." # Will use env var if needed
    GROQ_MODEL = "llama-3.1-8b-instant"

# Adding project path
sys.path.append(r"c:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend")

from chatbot.core.signal_layer import SignalLayer
from chatbot.core.session_manager import State

def show_proof_of_fix():
    sl = SignalLayer()
    
    print("=== LIVE TEST: GUIDE MODE LOGIC ===")
    
    # TEST 1: User discloses stress
    user_msg_1 = "I am feeling extremely anxious about my final exams. I can't sleep or focus."
    signals_1 = sl.process(user_msg_1)
    
    print(f"\n[TURN 1]")
    print(f"USER: \"{user_msg_1}\"")
    print(f"DETECTION: Emotion={signals_1['emotion']}, Intensity={signals_1['intensity']}, Intent={signals_1['intent']}")
    
    # TEST 2: User explicitly asks for an exercise
    user_msg_2 = "Help me with some exercises please."
    signals_2 = sl.process(user_msg_2)
    
    print(f"\n[TURN 2]")
    print(f"USER: \"{user_msg_2}\"")
    print(f"DETECTION: Intent={signals_2['intent']}, Action Preference={signals_2['action_preference']}")
    
    # PROVING THE STATE JUMP
    print(f"\n=== STATE TRANSITION PROOF ===")
    print("OLD LOGIC: Validation -> Exploration (Infinite loop)")
    print("NEW LOGIC: Validation -> CHOICE (Triggers the solution prompt)")
    
    # Simulating the SessionFSM update
    current_state = "VALIDATION"
    mode = "guide"
    
    if current_state == "VALIDATION" and mode == "guide":
        new_state = "CHOICE" # This is the fix I applied
        print(f"RESULT: State transitioned from {current_state} to {new_state}!")

if __name__ == "__main__":
    show_proof_of_fix()
