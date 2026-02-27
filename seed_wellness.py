import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from auth_api.models import Category, MeditationSession, YogaSession, MusicCategory, MusicTrack, TherapySession
from django.utils import timezone

def seed_data():
    print("🌱 Seeding Wellness Content...")

    # 1. Create General Categories
    stress_cat, _ = Category.objects.get_or_create(name="Stress Relief", defaults={'emoji': "😌"})
    sleep_cat, _ = Category.objects.get_or_create(name="Sleep", defaults={'emoji': "🌙"})
    focus_cat, _ = Category.objects.get_or_create(name="Focus", defaults={'emoji': "🎯"})

    # 2. Add Sample Meditations
    m1, created = MeditationSession.objects.get_or_create(
        title="5-Minute Mindful Breathing",
        defaults={
            'description': "A quick guided session to center yourself during a busy day.",
            'duration': 5,
            'category': stress_cat,
            'emoji': "🌬️"
        }
    )
    if created: print(f"  + Added Meditation: {m1.title}")
    
    m2, created = MeditationSession.objects.get_or_create(
        title="Deep Sleep Visualization",
        defaults={
            'description': "Guided imagery to help you drift into a restful slumber.",
            'duration': 15,
            'category': sleep_cat,
            'emoji': "💤"
        }
    )
    if created: print(f"  + Added Meditation: {m2.title}")

    # 3. Add Sample Yoga
    y1, created = YogaSession.objects.get_or_create(
        title="Quick Morning Flow",
        defaults={
            'description': "Energize your body with this 10-minute Vinyasa sequence.",
            'duration': 10,
            'type': focus_cat,
            'emoji': "☀️",
            'video_url': "https://www.youtube.com/watch?v=sTANio_2E0Q",
            'channel_name': "Yoga With Adriene"
        }
    )
    if created: print(f"  + Added Yoga: {y1.title}")

    # 4. Add Music Therapy Categories
    calm_music, created = MusicCategory.objects.get_or_create(
        name="Calm & Peace",
        defaults={
            'emoji': "🌊", 
            'color': "#2196F3", 
            'description': "Soothing sounds of water and nature."
        }
    )
    if created: print(f"  + Added Music Category: {calm_music.name}")

    # 5. Add Therapy Sessions (General)
    t1, created = TherapySession.objects.get_or_create(
        title="Piano Relaxation",
        therapy_type="Music",
        defaults={
            'duration': 300,
            'created_at': timezone.now()
        }
    )
    if created: print(f"  + Added Therapy Session: {t1.title}")

    print("\n✅ Successfully seeded wellness content! Go to /admin to upload real audio files.")

if __name__ == "__main__":
    seed_data()
