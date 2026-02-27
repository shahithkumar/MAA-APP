
import os
import django
import sys

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from django.contrib.auth.models import User
from chatbot.models import ChatSession, ChatMessage
from auth_api.models import GenericAffirmation, AffirmationCategory
import random

def test_ai_affirmation():
    # 1. Get or create a test user
    username = "testuser_ai_aff"
    user, _ = User.objects.get_or_create(username=username, email=f"{username}@example.com")
    
    # 2. Create a dummy chat history
    session, _ = ChatSession.objects.get_or_create(session_id="test_aff_session", user=user)
    ChatMessage.objects.filter(session=session).delete()
    
    messages = [
        ("user", "I've been feeling really overwhelmed with my final exams lately."),
        ("ai", "I hear you. Exams can be incredibly stressful. How are you coping?"),
        ("user", "I'm barely sleeping. I feel like I'm going to fail everything no matter how much I study.")
    ]
    
    for sender, content in messages:
        ChatMessage.objects.create(session=session, sender=sender, content=content)
    
    print(f"[SUCCESS] Created dummy chat history for {username}")
    
    # 3. Simulate calling the view logic (Manual check)
    from auth_api.views import RandomAffirmationView
    from rest_framework.test import APIRequestFactory, force_authenticate
    
    factory = APIRequestFactory()
    view = RandomAffirmationView.as_view()
    
    request = factory.get('/api/affirmations/random/')
    force_authenticate(request, user=user)
    response = view(request)
    
    print("\n--- API RESPONSE ---")
    print(f"Status Code: {response.status_code}")
    print(f"Response Data: {response.data}")
    
    if response.data.get('type') == 'ai_personalized':
        print("\n[SUCCESS] AI successfully generated a personalized affirmation!")
        print(f"Affirmation: {response.data['affirmation']['text']}")
    else:
        print("\n[FALLBACK] AI generation skipped or failed, used random/generic.")

if __name__ == "__main__":
    test_ai_affirmation()
