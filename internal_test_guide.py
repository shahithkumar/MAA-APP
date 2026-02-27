import os
import django
import sys

# Add the project path to sys.path
sys.path.append(r"c:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend")

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from chatbot.orchestrator import process_message

def test_guide_mode():
    session_id = "test_proof_session_99"
    mode = "guide"
    
    print("--- STEP 1: INITIAL DISCLOSURE ---")
    q1 = "I am feeling extremely anxious about my final exams. I can't sleep or focus."
    res1 = process_message(session_id, q1, mode=mode)
    print(f"USER: {q1}")
    print(f"MAA: {res1}\n")
    
    print("--- STEP 2: ASKING FOR HELP (TRIGGERS CHOICE/INTERVENTION) ---")
    q2 = "Yes, please help me. I need some exercises to calm down."
    res2 = process_message(session_id, q2, mode=mode)
    print(f"USER: {q2}")
    print(f"MAA: {res2}\n")

if __name__ == "__main__":
    test_guide_mode()
