import sys
sys.path.append(r"c:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend")

from chatbot.core.signal_layer import SignalLayer

def test_signals():
    sl = SignalLayer()
    
    # Test 1: Calming request
    text1 = "I need some exercises to calm down."
    res1 = sl.process(text1)
    print(f"TEXT: {text1}")
    print(f"SIGNALS: {res1}\n")
    
    # Test 2: Talking request
    text2 = "I just want to talk to someone."
    res2 = sl.process(text2)
    print(f"TEXT: {text2}")
    print(f"SIGNALS: {res2}\n")
    
    # Test 3: Standard disclosure
    text3 = "I feel really sad today."
    res3 = sl.process(text3)
    print(f"TEXT: {text3}")
    print(f"SIGNALS: {res3}\n")

if __name__ == "__main__":
    test_signals()
