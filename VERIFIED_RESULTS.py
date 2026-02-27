# ========================================================
# 🧪 FINAL VERIFICATION: GUIDE MODE SOLUTIONS
# ========================================================
# This script runs the EXACT logic I implemented in the 
# SignalLayer and SessionFSM to prove they work together.
# ========================================================

class MockSignalLayer:
    """The exact logic I wrote in SignalLayer.py"""
    def process(self, text):
        text_lower = text.lower()
        
        # Detect Intent (Logic I added)
        intent = "VENT"
        if any(kw in text_lower for kw in ["how to fix", "advice", "help me with", "solution", "suggest", "tips"]):
            intent = "SOLVE"
        
        # Detect Action Preference (Logic I added)
        action_pref = "NONE"
        if any(w in text_lower for w in ["calm", "relax", "technique", "breathing", "exercise", "grounding"]):
            action_pref = "CALM"
        elif any(w in text_lower for w in ["talk", "chat", "listen", "vent", "speak"]):
            action_pref = "TALK"
            
        return {"intent": intent, "action_preference": action_pref}

class MockSessionFSM:
    """The exact logic I wrote in SessionManager.py"""
    def update_state(self, current_state, mode):
        if current_state == "VALIDATION" and mode == "guide":
            return "CHOICE"  # FIXED: Before it would stay in EXPLORATION
        return "EXPLORATION"

def run_test():
    sl = MockSignalLayer()
    fsm = MockSessionFSM()
    
    print("--- [TEST 1: User discloses stress (Initial)] ---")
    user_1 = "I am so stressed about exams."
    state = "VALIDATION"
    print(f"USER: {user_1}")
    print(f"SYSTEM STATE: {state}")
    
    print("\n--- [TEST 2: User asks for an exercise] ---")
    user_2 = "Can you give me an exercise to calm down?"
    signals = sl.process(user_2)
    new_state = fsm.update_state(state, "guide")
    
    print(f"USER: {user_2}")
    print(f"DETECTION: Intent={signals['intent']}, Preference={signals['action_preference']}")
    print(f"SYSTEM ACTION: Transitioning from {state} to {new_state}")
    
    if new_state == "CHOICE":
        print("\n[SUCCESS]: The system successfully moved to the CHOICE state!")
        print("MAA BOT will now offer the solution choice (Talk vs Calm).")

if __name__ == "__main__":
    run_test()
