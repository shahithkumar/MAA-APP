import os
import django
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone
from auth_api.models import (
    Category, MeditationSession, YogaSession, 
    AffirmationCategory, GenericAffirmation,
    MusicCategory, MusicTrack, 
    CBTTopic, Disorder, Article, CopingMethod, RoadmapStep,
    TherapySession, ReflectionQuestion
)

class Command(BaseCommand):
    help = 'Seed the entire app with premium content for all modules'

    def handle(self, *args, **options):
        self.stdout.write('🛠️  Preparing Master Database Seed...')
        
        try:
            with transaction.atomic():
                # --- 1. CORE CATEGORIES ---
                self.stdout.write('🧘 Seeding Categories...')
                med_cat, _ = Category.objects.get_or_create(name='Mindfulness', defaults={'emoji': '🧘'})
                sleep_cat, _ = Category.objects.get_or_create(name='Sleep', defaults={'emoji': '🛌'})
                stress_cat, _ = Category.objects.get_or_create(name='Stress Relief', defaults={'emoji': '🍃'})
                focus_cat, _ = Category.objects.get_or_create(name='Focus', defaults={'emoji': '🎯'})
                yoga_cat, _ = Category.objects.get_or_create(name='Vinyasa Flow', defaults={'emoji': '🤸'})
                rest_cat, _ = Category.objects.get_or_create(name='Restorative', defaults={'emoji': '☁️'})

                # --- 2. MEDITATION SESSIONS ---
                self.stdout.write('📻 Seeding Meditations...')
                meditations = [
                    ('Morning Zen', 'Start your day with clarity and intention.', 600, med_cat, '🌅'),
                    ('Deep Delta Sleep', 'Ease into a restful slumber with Delta frequencies.', 1200, sleep_cat, '🌙'),
                    ('Panic Button Breath', 'Rapid grounding for moments of high anxiety.', 300, stress_cat, '🆘'),
                    ('Flow State Focus', 'Optimize your mind for deep work.', 900, focus_cat, '🧠'),
                    ('Nature Emersion', 'Mental walk through a rainforest.', 1500, med_cat, '🌳'),
                ]
                for title, desc, dur, cat, emoji in meditations:
                    MeditationSession.objects.get_or_create(
                        title=title, 
                        defaults={
                            'description': desc, 'duration': dur, 'category': cat, 'emoji': emoji,
                            'audio_file': 'temp/dummy.mp3'
                        }
                    )

                # --- 3. YOGA SESSIONS ---
                self.stdout.write('🤸 Seeding Yoga...')
                yoga_sessions = [
                    ('Sun Salutation A', 'Classic energy-boosting flow.', 900, yoga_cat, '☀️'),
                    ('Bedtime Yin Yoga', 'Slow stretches to release the day.', 1800, rest_cat, '🛌'),
                    ('Back Strength Flow', 'Relieve desk stress and posture.', 1200, yoga_cat, '⛰️'),
                ]
                for title, desc, dur, cat, emoji in yoga_sessions:
                    YogaSession.objects.get_or_create(
                        title=title, 
                        defaults={
                            'description': desc, 'duration': dur, 'type': cat, 'emoji': emoji,
                            'audio_file': 'temp/dummy.mp3'
                        }
                    )

                # --- 4. AFFIRMATIONS ---
                self.stdout.write('🦁 Seeding Affirmations...')
                aff_data = {
                    'Confidence': ('🦁', ["I am worthy of great things.", "I trust my journey.", "I am enough as I am."]),
                    'Calmness': ('🌊', ["Peace begins with my breath.", "I am safe in this moment.", "I let go of what I cannot control."]),
                    'Gratitude': ('🙏', ["I am blessed with abundance.", "Every day is a gift.", "I appreciate the small wins."]),
                    'Strength': ('💎', ["I am stronger than my challenges.", "My resilience is my superpower.", "I rise after every fall."]),
                }
                for cat_name, info in aff_data.items():
                    emoji, texts = info
                    cat, _ = AffirmationCategory.objects.get_or_create(name=cat_name, defaults={'icon': emoji})
                    for t in texts:
                        GenericAffirmation.objects.get_or_create(text=t, category=cat)

                # --- 5. MUSIC THERAPY ---
                self.stdout.write('🎶 Seeding Music...')
                music_cats = [
                    ('Lofi Study', '📚', '#9C27B0', 'Low fidelity beats for focus.'),
                    ('Ocean Waves', '🌊', '#03A9F4', 'Calming nature soundscapes.'),
                    ('Zen Piano', '🎹', '#4CAF50', 'Soft melodies for relaxation.'),
                ]
                for name, emoji, color, desc in music_cats:
                    m_cat, _ = MusicCategory.objects.get_or_create(name=name, defaults={'emoji': emoji, 'color': color, 'description': desc})
                    MusicTrack.objects.get_or_create(
                        title=f'{name} Serenity', 
                        category=m_cat, 
                        defaults={'audio_file': 'temp/dummy.mp3', 'duration': 300, 'emoji': '🎵'}
                    )

                # --- 6. CBT TOPICS ---
                self.stdout.write('🧠 Seeding CBT...')
                cbt_topics = [
                    ('Cognitive Distortions', '🕸️', '#E91E63', 'Learn to identify cognitive distortions like catastrophizing.'),
                    ('Evidence Checking', '⚖️', '#2196F3', 'Judge your thoughts like a lawyer to find the truth.'),
                    ('Core Beliefs', '💎', '#FF9800', 'Rewire the deep-seated beliefs that hold you back.'),
                ]
                for title, emoji, color, desc in cbt_topics:
                    CBTTopic.objects.get_or_create(title=title, defaults={'emoji': emoji, 'color': color, 'description': desc})

                # --- 7. RESOURCES HUB ---
                self.stdout.write('🏥 Seeding Resources...')
                disorders = [
                    ('Anxiety', '🌪️', 'Finding calm within the internal storm.'),
                    ('Depression', '☁️', 'Small, manageable steps towards the light.'),
                    ('ADHD', '🎡', 'Harnessing the power of the creative whirlwind.'),
                ]
                for name, emoji, summary in disorders:
                    dis, _ = Disorder.objects.get_or_create(name=name, defaults={'emoji': emoji, 'summary': summary})
                    Article.objects.get_or_create(disorder=dis, title=f'Understanding {name}', defaults={'content': f'Comprehensive guide to understanding the roots and management of {name}.', 'url': 'https://www.who.int'})
                    CopingMethod.objects.get_or_create(disorder=dis, title=f'{name} Rescue Tool', defaults={'instructions': '1. Pause 2. Name three things you see 3. Take a deep breath.'})
                    RoadmapStep.objects.get_or_create(disorder=dis, title='Phase 1: Awareness', order=1, defaults={'description': 'Build the foundation by noticing patterns without judgment.'})
                    RoadmapStep.objects.get_or_create(disorder=dis, title='Phase 2: Action', order=2, defaults={'description': 'Implement daily habits that support your growth.'})

                # --- 8. GUIDED THERAPY SESSIONS ---
                self.stdout.write('🎨 Seeding Therapy...')
                TherapySession.objects.get_or_create(
                    title='Zen Mandala Flow', 
                    therapy_type='Drawing', 
                    defaults={'prompt_text': 'Draw a central circle and fill it with patterns that represent your current peace.'}
                )
                TherapySession.objects.get_or_create(
                    title='Rainforest Sound Bath', 
                    therapy_type='Music', 
                    defaults={'audio_file': 'temp/dummy.mp3', 'duration': 600}
                )

            self.stdout.write(self.style.SUCCESS('🎉 SUCCESS! Your Database is now fully seeded with Premium Data.'))
            self.stdout.write(self.style.SUCCESS('👉 You can now see everything in your Dashboard / Admin.'))

        except Exception as e:
            self.stdout.write(self.style.ERROR(f'💥 SEEDING FAILED: {str(e)}'))
