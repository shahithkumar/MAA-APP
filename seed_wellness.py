import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from auth_api.models import (
    Category, MeditationSession, YogaSession,
    MusicCategory, MusicTrack, TherapySession, ReflectionQuestion,
    CBTTopic, AffirmationCategory, GenericAffirmation, AffirmationTemplate,
    BackgroundMusic, Disorder, Article, CopingMethod, RoadmapStep,
)
from django.utils import timezone


def seed_categories():
    """Seed wellness categories used across meditations & yoga."""
    print("📂 Seeding Categories...")
    categories = [
        {"name": "Stress Relief", "emoji": "😌"},
        {"name": "Sleep", "emoji": "🌙"},
        {"name": "Focus", "emoji": "🎯"},
        {"name": "Anxiety Relief", "emoji": "🫧"},
        {"name": "Self-Compassion", "emoji": "💛"},
        {"name": "Morning Routine", "emoji": "☀️"},
        {"name": "Emotional Healing", "emoji": "🌿"},
        {"name": "Breathwork", "emoji": "🌬️"},
    ]
    created_cats = {}
    for c in categories:
        obj, created = Category.objects.get_or_create(name=c["name"], defaults={"emoji": c["emoji"]})
        created_cats[c["name"]] = obj
        if created:
            print(f"  + Category: {c['name']}")
    return created_cats


def seed_meditations(cats):
    """Seed clinically-informed meditation sessions with guidance scripts."""
    print("\n🧘 Seeding Meditation Sessions...")
    meditations = [
        {
            "title": "5-Minute Mindful Breathing",
            "description": "A brief anchor practice based on diaphragmatic breathing. Ideal for quick stress resets between tasks.",
            "duration": 5,
            "category": cats["Breathwork"],
            "emoji": "🌬️",
            "guidance_text": (
                "Find a comfortable seated position. Let your eyes gently close.\n\n"
                "Inhale slowly through your nose for 4 counts… feel your belly expand.\n"
                "Hold gently for 2 counts…\n"
                "Exhale through your mouth for 6 counts… feel the tension leaving.\n\n"
                "With each breath, imagine drawing in calm, clear air.\n"
                "With each exhale, release anything you no longer need.\n\n"
                "If your mind wanders, that's perfectly natural — simply return to your breath.\n"
                "You are exactly where you need to be."
            ),
        },
        {
            "title": "Deep Sleep Body Scan",
            "description": "A progressive relaxation body scan designed to reduce sleep-onset latency. Based on Jacobson's Progressive Muscle Relaxation.",
            "duration": 20,
            "category": cats["Sleep"],
            "emoji": "💤",
            "guidance_text": (
                "Lie down in a comfortable position. Let the bed fully support you.\n\n"
                "Bring your awareness to your toes. Gently tense them for 3 seconds… now release.\n"
                "Feel the warmth flowing through your feet as they soften.\n\n"
                "Move to your calves — tense gently… and release.\n"
                "Your legs grow heavy, sinking deeper into the surface beneath you.\n\n"
                "Continue upward — thighs, hips, abdomen, chest…\n"
                "Each area you visit, tension melts away like snow at dawn.\n\n"
                "Your arms feel weightless. Your jaw unclenches. Your forehead smooths.\n"
                "You are safe. You are at peace. Let sleep find you."
            ),
        },
        {
            "title": "Loving-Kindness Meditation",
            "description": "A traditional Metta meditation cultivating compassion for self and others. Shown to reduce self-criticism and increase positive affect.",
            "duration": 15,
            "category": cats["Self-Compassion"],
            "emoji": "💗",
            "guidance_text": (
                "Close your eyes and place one hand on your heart.\n\n"
                "Begin by directing warmth toward yourself:\n"
                "\"May I be safe. May I be healthy. May I be happy. May I live with ease.\"\n\n"
                "Now picture someone you love. Send them the same wishes:\n"
                "\"May you be safe. May you be healthy. May you be happy.\"\n\n"
                "Expand this circle — to a neutral person, to someone difficult,\n"
                "and finally to all living beings everywhere.\n\n"
                "Feel the warmth radiating outward like ripples on a still lake.\n"
                "You are connected. You are not alone."
            ),
        },
        {
            "title": "Anxiety Release – 4-7-8 Breathing",
            "description": "Dr. Andrew Weil's 4-7-8 breathing technique. Activates the parasympathetic nervous system to counter the fight-or-flight response.",
            "duration": 10,
            "category": cats["Anxiety Relief"],
            "emoji": "🫧",
            "guidance_text": (
                "Sit comfortably with your back straight.\n"
                "Place the tip of your tongue behind your upper front teeth.\n\n"
                "Exhale completely through your mouth with a whoosh sound.\n\n"
                "Now — Inhale quietly through your nose for 4 counts.\n"
                "Hold your breath for 7 counts.\n"
                "Exhale completely through your mouth for 8 counts.\n\n"
                "This is one cycle. Repeat 3 more times.\n\n"
                "With each cycle, notice your heart rate slowing.\n"
                "Your nervous system is resetting. You are regaining control.\n"
                "Anxiety is a wave — and you are learning to surf."
            ),
        },
        {
            "title": "Morning Intention Setting",
            "description": "A brief visualization practice to set the tone for the day with clarity and purpose. Rooted in cognitive reframing techniques.",
            "duration": 7,
            "category": cats["Morning Routine"],
            "emoji": "🌅",
            "guidance_text": (
                "Take three deep breaths to arrive fully in this moment.\n\n"
                "Ask yourself gently: \"What kind of day do I want to create?\"\n\n"
                "Visualize yourself moving through your day with calm confidence.\n"
                "See yourself handling challenges with grace.\n"
                "See yourself connecting meaningfully with others.\n\n"
                "Choose one word for today — perhaps 'patience,' 'courage,' or 'joy.'\n"
                "Carry this word with you like a quiet compass.\n\n"
                "You don't need to be perfect. You just need to begin."
            ),
        },
        {
            "title": "Stress Dissolve – Guided Visualization",
            "description": "A nature-based visualization technique for chronic stress. Uses mental imagery to activate relaxation response pathways.",
            "duration": 12,
            "category": cats["Stress Relief"],
            "emoji": "🏔️",
            "guidance_text": (
                "Close your eyes and imagine standing at the edge of a quiet forest.\n"
                "The air is crisp and scented with pine.\n\n"
                "With each step along the path, you leave a burden behind.\n"
                "A worry about work — set it down by the mossy rock.\n"
                "A fear about the future — place it gently at the base of the oak.\n\n"
                "Ahead, a clearing opens. Warm sunlight filters through the canopy.\n"
                "A stream murmurs nearby. You sit on the soft ground.\n\n"
                "Feel the earth beneath you, steady and unchanging.\n"
                "You are held. You are enough. The forest asks nothing of you."
            ),
        },
        {
            "title": "Focus Enhancement – Single-Point Awareness",
            "description": "A concentration-building meditation adapted from Samatha practice. Trains sustained attention and reduces mind-wandering.",
            "duration": 10,
            "category": cats["Focus"],
            "emoji": "🔮",
            "guidance_text": (
                "Sit upright. Let your gaze rest softly on a single point.\n"
                "Or close your eyes and focus on the sensation at the tip of your nose.\n\n"
                "Each time a thought arises, acknowledge it without judgment.\n"
                "Label it gently — 'thinking' — and return to your anchor point.\n\n"
                "Your mind will wander. That is its nature.\n"
                "Each return is a repetition that builds your mental muscle.\n\n"
                "Stay here for the next few minutes.\n"
                "When the session ends, carry this clarity with you."
            ),
        },
        {
            "title": "Emotional Healing – Inner Child Work",
            "description": "A gentle guided meditation for processing past emotional wounds. Draws from Internal Family Systems (IFS) therapy principles.",
            "duration": 8,
            "category": cats["Emotional Healing"],
            "emoji": "🧸",
            "guidance_text": (
                "Find a safe, quiet space. Let your breathing deepen.\n\n"
                "Imagine walking down a warm corridor of memory.\n"
                "At the end, you see your younger self sitting quietly.\n\n"
                "Approach them gently. Sit beside them.\n"
                "What are they feeling? Let that feeling exist without trying to fix it.\n\n"
                "Now speak to them from the wisdom you have today:\n"
                "\"I see you. What happened wasn't your fault.\n"
                "You did the best you could. And you turned out brave.\"\n\n"
                "Hold their hand. Let them know they are safe now.\n"
                "You are both healing, together, in this moment."
            ),
        },
    ]

    for m in meditations:
        obj, created = MeditationSession.objects.get_or_create(
            title=m["title"],
            defaults={
                "description": m["description"],
                "duration": m["duration"],
                "category": m["category"],
                "emoji": m["emoji"],
                "guidance_text": m.get("guidance_text", ""),
            },
        )
        if created:
            print(f"  + Meditation: {m['title']}")


def seed_yoga(cats):
    """Seed yoga sessions with real YouTube video URLs from reputable channels."""
    print("\n🧘‍♀️ Seeding Yoga Sessions...")
    sessions = [
        {
            "title": "Morning Sun Salutation Flow",
            "description": "A classical Surya Namaskar sequence to awaken the body and align breath with movement. Perfect for energizing your morning.",
            "duration": 15,
            "type": cats["Morning Routine"],
            "emoji": "☀️",
            "video_url": "https://www.youtube.com/watch?v=73sjOu0g58M",
            "channel_name": "Yoga With Adriene",
        },
        {
            "title": "Yoga for Stress & Anxiety",
            "description": "A slow, grounding flow targeting the hips and shoulders where stress accumulates. Incorporates controlled breathing throughout.",
            "duration": 20,
            "type": cats["Stress Relief"],
            "emoji": "🌿",
            "video_url": "https://www.youtube.com/watch?v=hJbRpHZr_d0",
            "channel_name": "Yoga With Adriene",
        },
        {
            "title": "Bedtime Yoga for Deep Sleep",
            "description": "A restorative Yin practice with extended holds to activate the parasympathetic nervous system before bed.",
            "duration": 20,
            "type": cats["Sleep"],
            "emoji": "🌙",
            "video_url": "https://www.youtube.com/watch?v=v7SN-d4qXx0",
            "channel_name": "Yoga With Kassandra",
        },
        {
            "title": "Yoga for Focus & Productivity",
            "description": "An invigorating sequence with balancing poses and breath-of-fire to sharpen mental clarity and sustained attention.",
            "duration": 15,
            "type": cats["Focus"],
            "emoji": "🎯",
            "video_url": "https://www.youtube.com/watch?v=COp7BR_Dvps",
            "channel_name": "Yoga With Adriene",
        },
        {
            "title": "Heart-Opening Self-Love Flow",
            "description": "Gentle backbends and chest openers to release emotional tension stored in the heart space. A practice in radical self-acceptance.",
            "duration": 25,
            "type": cats["Self-Compassion"],
            "emoji": "💛",
            "video_url": "https://www.youtube.com/watch?v=rsGRdsEbgU8",
            "channel_name": "Yoga With Adriene",
        },
        {
            "title": "Breathing Exercises – Pranayama",
            "description": "A dedicated breathwork session covering Nadi Shodhana (Alternate Nostril), Ujjayi, and Box Breathing for nervous system regulation.",
            "duration": 12,
            "type": cats["Breathwork"],
            "emoji": "🌬️",
            "video_url": "https://www.youtube.com/watch?v=ec3Y2_rGHNE",
            "channel_name": "Breathe and Flow",
        },
        {
            "title": "Gentle Yoga for Emotional Release",
            "description": "A slow, supported practice focusing on hip openers and forward folds — areas where unexpressed emotions are often held.",
            "duration": 30,
            "type": cats["Emotional Healing"],
            "emoji": "🧸",
            "video_url": "https://www.youtube.com/watch?v=1it5JMy6sGo",
            "channel_name": "Yoga With Kassandra",
        },
        {
            "title": "Chair Yoga for Anxiety Relief",
            "description": "An accessible, seated yoga practice perfect for the office or limited mobility. Focuses on breath synchronization and gentle stretching.",
            "duration": 10,
            "type": cats["Anxiety Relief"],
            "emoji": "🪑",
            "video_url": "https://www.youtube.com/watch?v=KEjiXtb2hRg",
            "channel_name": "Yoga With Adriene",
        },
    ]

    for s in sessions:
        obj, created = YogaSession.objects.get_or_create(
            title=s["title"],
            defaults={
                "description": s["description"],
                "duration": s["duration"],
                "type": s["type"],
                "emoji": s["emoji"],
                "video_url": s["video_url"],
                "channel_name": s["channel_name"],
            },
        )
        if created:
            print(f"  + Yoga: {s['title']}")


def seed_music():
    """Seed music therapy categories and track metadata (no audio files — upload via admin)."""
    print("\n🎵 Seeding Music Therapy...")
    music_data = [
        {
            "name": "Calm & Peace",
            "emoji": "🌊",
            "color": "#4FC3F7",
            "description": "Gentle ambient soundscapes and slow-tempo instrumentals to induce deep relaxation.",
            "tracks": [
                {"title": "Ocean Waves at Sunset", "duration": 300, "emoji": "🌅"},
                {"title": "Weightless – Ambient Piano", "duration": 480, "emoji": "🎹"},
                {"title": "Rain on a Quiet Lake", "duration": 360, "emoji": "🌧️"},
                {"title": "Tibetan Singing Bowls", "duration": 420, "emoji": "🔔"},
            ],
        },
        {
            "name": "Deep Focus",
            "emoji": "🎧",
            "color": "#7E57C2",
            "description": "Binaural beats and lo-fi instrumentals scientifically shown to improve concentration.",
            "tracks": [
                {"title": "Alpha Wave Focus – 10Hz Binaural", "duration": 600, "emoji": "🧠"},
                {"title": "Lo-Fi Study Session", "duration": 540, "emoji": "📚"},
                {"title": "Café Ambience with Soft Piano", "duration": 480, "emoji": "☕"},
                {"title": "Forest Stream White Noise", "duration": 360, "emoji": "🌲"},
            ],
        },
        {
            "name": "Sleep & Rest",
            "emoji": "🌙",
            "color": "#5C6BC0",
            "description": "Delta-wave inducing tracks and sleep stories to support healthy sleep architecture.",
            "tracks": [
                {"title": "Delta Sleep Induction", "duration": 900, "emoji": "💤"},
                {"title": "Starlit Lullaby – Harp & Strings", "duration": 600, "emoji": "✨"},
                {"title": "Midnight Rainforest", "duration": 720, "emoji": "🌴"},
                {"title": "Gentle Night Wind", "duration": 540, "emoji": "🍃"},
            ],
        },
        {
            "name": "Emotional Release",
            "emoji": "💧",
            "color": "#26A69A",
            "description": "Evocative melodies and nature sounds that create safe space for processing emotions.",
            "tracks": [
                {"title": "Letting Go – Solo Cello", "duration": 360, "emoji": "🎻"},
                {"title": "Gentle Grief – Piano & Rain", "duration": 420, "emoji": "🌧️"},
                {"title": "Healing Springs", "duration": 300, "emoji": "💧"},
                {"title": "Warm Embrace – Acoustic Guitar", "duration": 380, "emoji": "🎸"},
            ],
        },
        {
            "name": "Energy & Uplift",
            "emoji": "⚡",
            "color": "#FFA726",
            "description": "Upbeat instrumental tracks to boost mood and motivation through tempo entrainment.",
            "tracks": [
                {"title": "Morning Sunbeam – Uplifting Piano", "duration": 240, "emoji": "☀️"},
                {"title": "Joyful Stride – Acoustic Pop", "duration": 210, "emoji": "🎶"},
                {"title": "Birdsong Dawn Chorus", "duration": 300, "emoji": "🐦"},
                {"title": "Tropical Breeze – Ukulele", "duration": 250, "emoji": "🌺"},
            ],
        },
        {
            "name": "Mindfulness & Meditation",
            "emoji": "🧘",
            "color": "#AB47BC",
            "description": "Sparse, spacious soundscapes designed to support breath awareness and present-moment attention.",
            "tracks": [
                {"title": "Zen Garden – Koto & Water", "duration": 480, "emoji": "🏯"},
                {"title": "Sacred Silence – Drone & Bells", "duration": 600, "emoji": "🔔"},
                {"title": "Breath of the Earth", "duration": 360, "emoji": "🌍"},
                {"title": "Crystal Bowl Resonance", "duration": 420, "emoji": "🔮"},
            ],
        },
    ]

    for cat_data in music_data:
        cat, created = MusicCategory.objects.get_or_create(
            name=cat_data["name"],
            defaults={
                "emoji": cat_data["emoji"],
                "color": cat_data["color"],
                "description": cat_data["description"],
            },
        )
        if created:
            print(f"  + Music Category: {cat_data['name']}")

        for track in cat_data["tracks"]:
            t, t_created = MusicTrack.objects.get_or_create(
                title=track["title"],
                category=cat,
                defaults={
                    "duration": track["duration"],
                    "emoji": track["emoji"],
                },
            )
            if t_created:
                print(f"      + Track: {track['title']}")


def seed_cbt():
    """Seed CBT topics based on standard Cognitive Behavioral Therapy frameworks."""
    print("\n🧠 Seeding CBT Topics...")
    topics = [
        {
            "title": "Catastrophizing",
            "emoji": "🌪️",
            "color": "#EF5350",
            "description": "The tendency to jump to the worst-case scenario. This cognitive distortion amplifies fear and prevents rational problem-solving. CBT helps you evaluate the actual probability and impact of feared outcomes.",
        },
        {
            "title": "All-or-Nothing Thinking",
            "emoji": "⚫",
            "color": "#78909C",
            "description": "Seeing things in absolute, black-or-white terms with no middle ground. If a performance falls short of perfect, it's seen as total failure. CBT introduces the gray zone — where most of life actually lives.",
        },
        {
            "title": "Mind Reading",
            "emoji": "🔮",
            "color": "#AB47BC",
            "description": "Assuming you know what others are thinking — usually that they're judging you negatively. CBT challenges you to separate assumptions from evidence and consider alternative explanations.",
        },
        {
            "title": "Negative Self-Talk",
            "emoji": "🗣️",
            "color": "#FF7043",
            "description": "The inner critic that constantly undermines your worth. This pattern often originates in childhood and becomes automatic. CBT helps you catch, challenge, and replace these thoughts with balanced ones.",
        },
        {
            "title": "Emotional Reasoning",
            "emoji": "💭",
            "color": "#42A5F5",
            "description": "Believing something is true because it 'feels' true. 'I feel stupid, therefore I am stupid.' CBT teaches you that emotions are information, not facts — and to evaluate evidence independently.",
        },
        {
            "title": "Should Statements",
            "emoji": "📜",
            "color": "#66BB6A",
            "description": "Rigid rules about how you or others 'should' behave. These create guilt, frustration, and disappointment. CBT helps replace 'shoulds' with flexible preferences and realistic expectations.",
        },
        {
            "title": "Overgeneralization",
            "emoji": "🔄",
            "color": "#FFA726",
            "description": "Drawing broad negative conclusions from a single event. One rejection becomes 'nobody will ever love me.' CBT teaches you to see each experience as unique rather than a pattern of doom.",
        },
        {
            "title": "Personalization",
            "emoji": "👤",
            "color": "#EC407A",
            "description": "Taking excessive responsibility for events outside your control, or believing that things are always about you. CBT helps you distinguish between what you can and cannot influence.",
        },
    ]

    for topic in topics:
        obj, created = CBTTopic.objects.get_or_create(
            title=topic["title"],
            defaults={
                "emoji": topic["emoji"],
                "color": topic["color"],
                "description": topic["description"],
            },
        )
        if created:
            print(f"  + CBT Topic: {topic['title']}")


def seed_affirmations():
    """Seed affirmation categories, individual affirmations, and templates."""
    print("\n✨ Seeding Affirmations...")
    affirmation_data = [
        {
            "name": "Self-Worth",
            "icon": "💎",
            "description": "Affirmations to internalize your inherent value, independent of achievements or approval.",
            "affirmations": [
                "I am worthy of love and belonging, exactly as I am.",
                "My value does not decrease based on someone's inability to see my worth.",
                "I deserve to take up space in this world.",
                "I am enough — not because of what I do, but because of who I am.",
                "I release the need to prove myself to anyone.",
            ],
        },
        {
            "name": "Anxiety & Calm",
            "icon": "🌊",
            "description": "Grounding affirmations to soothe the nervous system and redirect anxious thought spirals.",
            "affirmations": [
                "This feeling is temporary. It will pass, like every feeling before it.",
                "I am safe in this moment. Right here, right now, I am okay.",
                "I breathe in calm. I breathe out fear.",
                "I do not need to solve everything today. One step at a time is enough.",
                "My anxious thoughts are not facts. I can observe them without believing them.",
            ],
        },
        {
            "name": "Resilience",
            "icon": "🏔️",
            "description": "Strength-building affirmations for navigating difficult seasons of life.",
            "affirmations": [
                "I have survived every difficult day so far, and I will survive this one too.",
                "Setbacks are setups for comebacks. I am growing through this.",
                "I am stronger than my circumstances. My story is still being written.",
                "I give myself permission to rest without guilt. Rest is not weakness.",
                "Every challenge I face is shaping me into someone I haven't met yet.",
            ],
        },
        {
            "name": "Confidence",
            "icon": "🦁",
            "description": "Empowering affirmations to build self-trust and courage in daily life.",
            "affirmations": [
                "I trust myself to handle whatever comes my way.",
                "My voice matters and my ideas have value.",
                "I am capable of achieving things I haven't even imagined yet.",
                "I choose to believe in my ability to figure things out.",
                "Courage does not mean being unafraid — it means moving forward anyway.",
            ],
        },
        {
            "name": "Gratitude",
            "icon": "🙏",
            "description": "Appreciation-centered affirmations to shift perspective and increase positive affect.",
            "affirmations": [
                "I am grateful for the small blessings I often overlook.",
                "Today holds something good for me, even if I can't see it yet.",
                "I appreciate my body for carrying me through each day.",
                "I choose to focus on what I have, not what I lack.",
                "Gratitude rewires my brain for joy. I practice it daily.",
            ],
        },
        {
            "name": "Healing",
            "icon": "🌱",
            "description": "Gentle affirmations for those working through grief, trauma, or emotional pain.",
            "affirmations": [
                "Healing is not linear. Every step forward counts, even the small ones.",
                "I give myself permission to feel my emotions fully without judgment.",
                "My past does not define my future. I am writing a new chapter.",
                "It is okay to not be okay. I honor where I am in my journey.",
                "I am gently becoming the person I needed when I was younger.",
            ],
        },
    ]

    for cat_data in affirmation_data:
        cat, created = AffirmationCategory.objects.get_or_create(
            name=cat_data["name"],
            defaults={
                "icon": cat_data["icon"],
                "description": cat_data["description"],
            },
        )
        if created:
            print(f"  + Affirmation Category: {cat_data['name']}")

        for text in cat_data["affirmations"]:
            a, a_created = GenericAffirmation.objects.get_or_create(
                category=cat,
                text=text,
            )
            if a_created:
                print(f"      + \"{text[:50]}...\"")

    # Seed affirmation templates
    templates = [
        {
            "template": "I am learning to {positive_direction}, even when {challenge}.",
            "focus_areas": ["Calm", "Confidence", "Resilience"],
        },
        {
            "template": "Every day, I grow stronger in my ability to {positive_direction}.",
            "focus_areas": ["Confidence", "Resilience", "Self-Worth"],
        },
        {
            "template": "I choose {positive_direction} over fear, one breath at a time.",
            "focus_areas": ["Calm", "Anxiety", "Healing"],
        },
        {
            "template": "Even though {challenge}, I deeply and completely accept myself.",
            "focus_areas": ["Self-Worth", "Healing", "Anxiety"],
        },
        {
            "template": "I release the need to {challenge}. Instead, I embrace {positive_direction}.",
            "focus_areas": ["Calm", "Healing", "Gratitude"],
        },
    ]

    for t in templates:
        obj, created = AffirmationTemplate.objects.get_or_create(
            template=t["template"],
            defaults={"focus_areas": t["focus_areas"]},
        )
        if created:
            print(f"  + Template: \"{t['template'][:60]}...\"")


def seed_disorders():
    """Seed clinically-accurate disorder information with articles, coping methods, and recovery roadmaps."""
    print("\n📖 Seeding Disorder Resource Hub...")
    disorders_data = [
        {
            "name": "Generalized Anxiety Disorder (GAD)",
            "emoji": "😰",
            "summary": "GAD involves persistent, excessive worry about various aspects of daily life — work, health, family, finances — that is difficult to control. It affects approximately 6.8 million adults and is highly treatable with therapy and lifestyle changes.",
            "articles": [
                {
                    "title": "Understanding GAD: Beyond Normal Worry",
                    "content": "Everyone worries sometimes, but GAD is different. People with GAD find it nearly impossible to stop worrying, even when they recognize their fears are disproportionate. The worry persists for months or years and often manifests physically through insomnia, muscle tension, digestive issues, and fatigue. GAD responds well to Cognitive Behavioral Therapy (CBT), which helps identify and restructure worry patterns.",
                },
                {
                    "title": "The Neuroscience of Anxiety",
                    "content": "Anxiety activates the amygdala — the brain's threat detection center — even when there is no real danger. In GAD, this system is chronically overactive. Research shows that mindfulness meditation can reduce amygdala reactivity by up to 50% over 8 weeks, while regular aerobic exercise increases GABA — the brain's natural calming neurotransmitter.",
                },
            ],
            "coping_methods": [
                {
                    "title": "The Worry Period Technique",
                    "instructions": "Designate a specific 20-minute 'worry window' each day. When anxious thoughts arise outside this time, write them down and postpone them. During your worry period, review the list — you'll find most worries have resolved themselves or feel less urgent.",
                },
                {
                    "title": "Progressive Muscle Relaxation",
                    "instructions": "Starting from your feet and moving upward, tense each muscle group for 5 seconds, then release for 15 seconds. This practice trains your body to recognize and release the physical tension that accompanies anxiety.",
                },
                {
                    "title": "Structured Problem-Solving",
                    "instructions": "For productive worries (things you can act on), use this framework: 1) Define the problem clearly, 2) Brainstorm 5+ solutions without judging, 3) Evaluate pros/cons, 4) Choose one and create an action plan, 5) Review after implementation.",
                },
            ],
            "roadmap": [
                {"title": "Recognize the Pattern", "description": "Learn to distinguish between productive concern and GAD-driven worry spirals. Start a worry journal to track triggers, frequency, and intensity.", "order": 1},
                {"title": "Build Your Toolkit", "description": "Begin practicing daily relaxation techniques: diaphragmatic breathing, progressive muscle relaxation, and grounding exercises.", "order": 2},
                {"title": "Challenge Anxious Thoughts", "description": "Use CBT thought records to identify cognitive distortions. Ask: 'What evidence supports this worry? What evidence contradicts it?'", "order": 3},
                {"title": "Gradual Exposure", "description": "Create a hierarchy of avoided situations and gradually face them, starting with the least anxiety-provoking.", "order": 4},
                {"title": "Lifestyle Foundation", "description": "Establish sleep hygiene, regular exercise (150 min/week), reduce caffeine, and build a consistent daily routine.", "order": 5},
                {"title": "Maintain & Prevent Relapse", "description": "Continue practicing skills even when feeling well. Develop a personal relapse prevention plan identifying early warning signs.", "order": 6},
            ],
        },
        {
            "name": "Major Depressive Disorder",
            "emoji": "🌧️",
            "summary": "Depression is more than sadness — it's a persistent state of low mood, loss of interest, and diminished energy lasting at least two weeks. It affects how you think, feel, and handle daily activities. With proper support, most people experience significant improvement.",
            "articles": [
                {
                    "title": "Depression: The Invisible Weight",
                    "content": "Depression often doesn't look like crying. It can manifest as numbness, irritability, difficulty concentrating, or losing interest in things you once loved. The condition involves neurochemical imbalances (serotonin, norepinephrine, dopamine) and structural brain changes that are reversible with treatment. Behavioral activation — gradually re-engaging with rewarding activities — is one of the most effective interventions.",
                },
                {
                    "title": "The Connection Between Sleep and Depression",
                    "content": "Depression and sleep have a bidirectional relationship. Poor sleep worsens depressive symptoms, while depression disrupts sleep architecture. Maintaining consistent sleep/wake times, avoiding screens before bed, and using the bed only for sleep can significantly improve both conditions.",
                },
            ],
            "coping_methods": [
                {
                    "title": "Behavioral Activation Planning",
                    "instructions": "When motivation is low, schedule small pleasurable or meaningful activities: a 5-minute walk, calling a friend, cooking a simple meal. Rate your mood before and after — you'll often find that action precedes motivation, not the other way around.",
                },
                {
                    "title": "The 5-Minute Rule",
                    "instructions": "Commit to doing any task for just 5 minutes. If after 5 minutes you want to stop, that's okay. Most often, starting is the hardest part — momentum tends to carry you forward.",
                },
                {
                    "title": "Social Connection Micro-Doses",
                    "instructions": "Depression whispers 'isolate.' Counter this by scheduling brief, low-pressure social interactions: a text to a friend, a kind word to a stranger, sitting in a café. Connection is medicine.",
                },
            ],
            "roadmap": [
                {"title": "Acknowledge Without Judgment", "description": "Recognizing depression is not weakness — it's awareness. Name what you're experiencing without self-criticism.", "order": 1},
                {"title": "Establish a Baseline Routine", "description": "Focus on three basics: sleep at the same time, eat at least one nourishing meal, and take a brief walk daily.", "order": 2},
                {"title": "Behavioral Activation", "description": "Schedule one small, values-aligned activity per day. Track your mood before and after to see the impact.", "order": 3},
                {"title": "Address Cognitive Patterns", "description": "Identify negative automatic thoughts. Use the triple-column technique: thought → distortion type → balanced alternative.", "order": 4},
                {"title": "Expand Your World", "description": "Gradually increase social engagement and physical activity. Join a class, volunteer, or reconnect with a hobby.", "order": 5},
                {"title": "Build Resilience for the Future", "description": "Create a wellness maintenance plan with early warning signs and action steps. Share it with a trusted person.", "order": 6},
            ],
        },
        {
            "name": "Social Anxiety Disorder",
            "emoji": "😶",
            "summary": "Social anxiety goes beyond shyness. It involves intense fear of being judged, embarrassed, or humiliated in social situations, leading to avoidance and significant life impairment. It is the third most common mental health condition and responds excellently to gradual exposure therapy.",
            "articles": [
                {
                    "title": "The Spotlight Effect: Why Others Notice Less Than You Think",
                    "content": "Research shows that people vastly overestimate how much others notice their mistakes or appearance — a phenomenon called the 'spotlight effect.' In studies, participants wearing embarrassing t-shirts estimated 50% of people noticed, but only 23% actually did. Social anxiety amplifies this bias, making you feel like you're under a microscope when you're not.",
                },
            ],
            "coping_methods": [
                {
                    "title": "Attention Refocusing",
                    "instructions": "Social anxiety causes excessive self-focused attention. Practice shifting focus outward: notice what the other person is wearing, the color of their eyes, what they're saying. External focus reduces self-consciousness dramatically.",
                },
                {
                    "title": "Post-Event Processing Interruption",
                    "instructions": "After social events, anxiety makes you ruminate on 'mistakes.' Set a rule: you get 2 minutes to review, then redirect to another activity. What feels like a disaster to you was likely unnoticed or quickly forgotten by others.",
                },
            ],
            "roadmap": [
                {"title": "Understand Your Safety Behaviors", "description": "Identify what you do to 'manage' anxiety in social situations: avoiding eye contact, rehearsing lines, staying quiet. These maintain anxiety long-term.", "order": 1},
                {"title": "Create Your Fear Hierarchy", "description": "List social situations from least to most anxiety-provoking (e.g., texting a friend → making a phone call → speaking in a meeting).", "order": 2},
                {"title": "Begin Gradual Exposure", "description": "Start with the lowest item on your hierarchy. Repeat until anxiety naturally decreases. Then move to the next level.", "order": 3},
                {"title": "Drop Safety Behaviors", "description": "Intentionally reduce avoidance strategies during exposures. Make eye contact. Let pauses happen. Discover that discomfort is survivable.", "order": 4},
                {"title": "Celebrate Social Wins", "description": "Keep a 'social courage journal.' Each interaction you don't avoid is a victory, regardless of how it felt.", "order": 5},
            ],
        },
        {
            "name": "Panic Disorder",
            "emoji": "💓",
            "summary": "Panic disorder involves recurrent, unexpected panic attacks — sudden surges of intense fear accompanied by physical symptoms like racing heart, chest pain, dizziness, and shortness of breath. The fear of future attacks often becomes as debilitating as the attacks themselves.",
            "articles": [
                {
                    "title": "What's Really Happening During a Panic Attack",
                    "content": "A panic attack is your fight-or-flight system misfiring. Adrenaline surges, heart rate spikes, breathing quickens. These symptoms are frightening but medically harmless. The attack typically peaks within 10 minutes and subsides within 20-30 minutes. Understanding this biology is the first step to reducing fear of the attacks themselves.",
                },
            ],
            "coping_methods": [
                {
                    "title": "The DARE Response",
                    "instructions": "D: Defuse the 'what if' thought ('So what?'). A: Allow and Accept the sensations without fighting. R: Run toward the feeling — ask for more (paradoxically reduces intensity). E: Engage with an activity to redirect attention.",
                },
                {
                    "title": "Physiological Sigh",
                    "instructions": "Take two quick inhales through your nose (filling lungs fully), then one long, slow exhale through your mouth. This is the fastest known method to calm the nervous system — it works within 1-2 breaths. Discovered by Stanford neuroscientist Dr. Andrew Huberman.",
                },
            ],
            "roadmap": [
                {"title": "Education is Power", "description": "Learn the biology of panic attacks. They cannot hurt you. They are adrenaline surges with an expiration date.", "order": 1},
                {"title": "Change Your Relationship to Symptoms", "description": "Practice interoceptive exposure: intentionally trigger mild symptoms (spin in a chair for dizziness, breathe through a straw for breathlessness) to desensitize the fear response.", "order": 2},
                {"title": "Master the Physiological Sigh", "description": "Practice the double-inhale, long-exhale technique daily so it becomes automatic during acute episodes.", "order": 3},
                {"title": "Eliminate Avoidance", "description": "Gradually return to places and situations you've been avoiding due to fear of panic.", "order": 4},
                {"title": "Build Confidence", "description": "Track successful panic management episodes. Each one proves your resilience.", "order": 5},
            ],
        },
        {
            "name": "Post-Traumatic Stress Disorder (PTSD)",
            "emoji": "🛡️",
            "summary": "PTSD develops after experiencing or witnessing a traumatic event. It involves intrusive memories, emotional numbness, hypervigilance, and avoidance of trauma reminders. Recovery is possible — the brain's neuroplasticity allows traumatic memories to be reprocessed and integrated.",
            "articles": [
                {
                    "title": "Understanding Trauma Responses",
                    "content": "Trauma responses (fight, flight, freeze, fawn) are survival mechanisms, not character flaws. PTSD occurs when the brain fails to properly file a traumatic memory — it remains 'active,' as if the event is still happening. Evidence-based treatments like EMDR and Prolonged Exposure help the brain complete this filing process.",
                },
            ],
            "coping_methods": [
                {
                    "title": "5-4-3-2-1 Grounding",
                    "instructions": "During flashbacks or dissociation, anchor to the present: Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste. This reactivates the prefrontal cortex.",
                },
                {
                    "title": "Safe Place Visualization",
                    "instructions": "Create a detailed mental image of a place where you feel completely safe. Include all senses: what you see, hear, smell, feel, and taste. Practice visiting this place daily so it becomes easily accessible during distress.",
                },
            ],
            "roadmap": [
                {"title": "Safety & Stabilization", "description": "Priority one is establishing physical and emotional safety. Build daily routines, grounding skills, and a support network before processing trauma.", "order": 1},
                {"title": "Psychoeducation", "description": "Learn how trauma affects the brain and body. Understanding your symptoms removes shame and self-blame.", "order": 2},
                {"title": "Professional Support", "description": "Seek a trauma-specialized therapist trained in EMDR, CPT, or Prolonged Exposure. Trauma processing should be guided, not done alone.", "order": 3},
                {"title": "Gradual Trauma Processing", "description": "With professional support, begin processing traumatic memories in a structured, titrated manner.", "order": 4},
                {"title": "Post-Traumatic Growth", "description": "Many trauma survivors develop deeper empathy, clearer priorities, and greater appreciation for life. Your pain can become your purpose.", "order": 5},
            ],
        },
        {
            "name": "Obsessive-Compulsive Disorder (OCD)",
            "emoji": "🔁",
            "summary": "OCD involves unwanted, intrusive thoughts (obsessions) and repetitive behaviors or mental acts (compulsions) performed to reduce the anxiety caused by obsessions. It is not about being 'neat' — it's a neurological condition that hijacks the brain's doubt system.",
            "articles": [
                {
                    "title": "OCD: It's Not What You Think",
                    "content": "OCD is widely misunderstood. It's not about preferring clean desks or organized closets. People with OCD experience intrusive, ego-dystonic thoughts — thoughts that directly contradict their values. A loving parent might have unwanted thoughts about harming their child. A devout person might have blasphemous intrusions. The distress comes from how seriously these thoughts are taken, and compulsions are desperate attempts to neutralize them.",
                },
            ],
            "coping_methods": [
                {
                    "title": "ERP (Exposure & Response Prevention)",
                    "instructions": "The gold standard for OCD. Gradually expose yourself to triggers while resisting the compulsion. Example: touch a doorknob (exposure) without washing hands (response prevention). Anxiety peaks then naturally decreases — this is habituation.",
                },
                {
                    "title": "Thought Defusion",
                    "instructions": "Instead of engaging with an intrusive thought, label it: 'I'm having the thought that...' This creates distance. You are not your thoughts. Thoughts are mental events, not commands or predictions.",
                },
            ],
            "roadmap": [
                {"title": "Accept the Diagnosis", "description": "OCD is a neurological condition, not a moral failing. Your intrusive thoughts say nothing about your character.", "order": 1},
                {"title": "Map Your OCD Cycle", "description": "Identify your specific obsession-compulsion loops. What triggers arise? What compulsions follow? What do you avoid?", "order": 2},
                {"title": "Find an OCD Specialist", "description": "Seek a therapist trained in ERP (Exposure and Response Prevention). General talk therapy often worsens OCD.", "order": 3},
                {"title": "Begin ERP Practice", "description": "Start with lower-difficulty exposures. Sit with discomfort without performing compulsions. Track anxiety levels.", "order": 4},
                {"title": "Maintain Gains", "description": "OCD is manageable but requires ongoing practice. Regular ERP maintenance prevents relapse.", "order": 5},
            ],
        },
    ]

    for d_data in disorders_data:
        disorder, created = Disorder.objects.get_or_create(
            name=d_data["name"],
            defaults={
                "emoji": d_data["emoji"],
                "summary": d_data["summary"],
            },
        )
        if created:
            print(f"  + Disorder: {d_data['name']}")

        for article in d_data.get("articles", []):
            a, a_created = Article.objects.get_or_create(
                disorder=disorder,
                title=article["title"],
                defaults={"content": article["content"]},
            )
            if a_created:
                print(f"      + Article: {article['title']}")

        for coping in d_data.get("coping_methods", []):
            c, c_created = CopingMethod.objects.get_or_create(
                disorder=disorder,
                title=coping["title"],
                defaults={"instructions": coping["instructions"]},
            )
            if c_created:
                print(f"      + Coping: {coping['title']}")

        for step in d_data.get("roadmap", []):
            r, r_created = RoadmapStep.objects.get_or_create(
                disorder=disorder,
                title=step["title"],
                defaults={
                    "description": step["description"],
                    "order": step["order"],
                },
            )
            if r_created:
                print(f"      + Roadmap Step {step['order']}: {step['title']}")


def seed_therapy_sessions():
    """Seed Music & Drawing therapy sessions with professional reflection questions."""
    print("\n🎨 Seeding Therapy Sessions...")
    sessions = [
        {
            "title": "Piano Relaxation Journey",
            "therapy_type": "Music",
            "duration": 3,
            "questions": [
                {"text": "How does your body feel right now compared to before the session?", "type": "text", "order": 1},
                {"text": "Did any specific memories or images come to mind while listening?", "type": "text", "order": 2},
                {"text": "How would you describe your current emotional state?", "type": "choice", "options": ["Calm & Peaceful", "Reflective", "Slightly Better", "Unchanged", "Emotional"], "order": 3},
            ],
        },
        {
            "title": "Nature Sounds Healing",
            "therapy_type": "Music",
            "duration": 4,
            "questions": [
                {"text": "Which sounds resonated with you the most?", "type": "text", "order": 1},
                {"text": "Were you able to let go of any thoughts during the session?", "type": "choice", "options": ["Yes, completely", "Somewhat", "Not really", "My mind was racing"], "order": 2},
                {"text": "What is one word to describe how you feel now?", "type": "text", "order": 3},
            ],
        },
        {
            "title": "Ambient Meditation Soundscape",
            "therapy_type": "Music",
            "duration": 6,
            "questions": [
                {"text": "On a scale of your own choosing, how deep was your relaxation?", "type": "text", "order": 1},
                {"text": "Did you notice any physical tension release during the session?", "type": "choice", "options": ["Yes, significant release", "Some tension released", "Slightly relaxed", "No change noticed"], "order": 2},
            ],
        },
        {
            "title": "Free Expression Drawing",
            "therapy_type": "Drawing",
            "prompt_text": "Draw whatever comes to mind without overthinking. There are no rules — let your hand move freely. Colors, shapes, or scribbles are all welcome. Focus on the process, not the result.",
            "questions": [
                {"text": "What emotions came up while you were drawing?", "type": "text", "order": 1},
                {"text": "If your drawing could speak, what would it say?", "type": "text", "order": 2},
                {"text": "How do you feel having expressed yourself visually?", "type": "choice", "options": ["Lighter", "Reflective", "Surprised", "Indifferent", "Emotional"], "order": 3},
            ],
        },
        {
            "title": "Draw Your Safe Place",
            "therapy_type": "Drawing",
            "prompt_text": "Close your eyes for a moment and picture a place where you feel completely safe, calm, and at peace. It can be real or imagined. Now draw it with as much detail as you can — include colors, textures, and any people or creatures who belong there.",
            "questions": [
                {"text": "Describe the place you drew. Why does it feel safe?", "type": "text", "order": 1},
                {"text": "Is there anyone (or anything) in your safe place? Who and why?", "type": "text", "order": 2},
                {"text": "Could you visit this safe place mentally during stressful moments?", "type": "choice", "options": ["Yes, definitely", "I think so", "I'd need more practice", "I'm not sure"], "order": 3},
            ],
        },
        {
            "title": "Emotion Color Mapping",
            "therapy_type": "Drawing",
            "prompt_text": "Assign a color to each emotion you've felt today. Then fill the canvas with those colors in proportion to how strongly you felt each one. There's no right or wrong — let instinct guide you.",
            "questions": [
                {"text": "Which color dominated your canvas, and what emotion does it represent?", "type": "text", "order": 1},
                {"text": "Were there any emotions you were surprised to see represented?", "type": "text", "order": 2},
                {"text": "How did it feel to see your emotional landscape visualized?", "type": "choice", "options": ["Eye-opening", "Comforting", "Overwhelming", "Neutral"], "order": 3},
            ],
        },
    ]

    for s in sessions:
        session, created = TherapySession.objects.get_or_create(
            title=s["title"],
            therapy_type=s["therapy_type"],
            defaults={
                "duration": s.get("duration", 0),
                "prompt_text": s.get("prompt_text"),
                "created_at": timezone.now(),
            },
        )
        if created:
            print(f"  + Therapy Session: {s['title']} ({s['therapy_type']})")

        for q in s.get("questions", []):
            rq, q_created = ReflectionQuestion.objects.get_or_create(
                session=session,
                question_text=q["text"],
                defaults={
                    "question_type": q["type"],
                    "options": q.get("options", []),
                    "order": q["order"],
                },
            )
            if q_created:
                print(f"      + Question: \"{q['text'][:50]}...\"")


def seed_background_music():
    """Seed background music options for meditation sessions."""
    print("\n🎶 Seeding Background Music...")
    tracks = [
        {"title": "Gentle Rain", "emoji": "🌧️"},
        {"title": "Ocean Waves", "emoji": "🌊"},
        {"title": "Forest Ambience", "emoji": "🌲"},
        {"title": "Soft Piano", "emoji": "🎹"},
        {"title": "Singing Bowls", "emoji": "🔔"},
        {"title": "Wind Chimes", "emoji": "🎐"},
        {"title": "Campfire Crackling", "emoji": "🔥"},
        {"title": "Night Crickets", "emoji": "🦗"},
    ]

    for t in tracks:
        obj, created = BackgroundMusic.objects.get_or_create(
            title=t["title"],
            defaults={"emoji": t["emoji"]},
        )
        if created:
            print(f"  + Background Music: {t['title']}")


def seed_data():
    """Master seed function — runs all seeders."""
    print("=" * 60)
    print("🌱 MENTAL HEALTH APP — PROFESSIONAL DATA SEEDING")
    print("=" * 60)

    cats = seed_categories()
    seed_meditations(cats)
    seed_yoga(cats)
    seed_music()
    seed_cbt()
    seed_affirmations()
    seed_disorders()
    seed_therapy_sessions()
    seed_background_music()

    print("\n" + "=" * 60)
    print("✅ ALL SEED DATA LOADED SUCCESSFULLY!")
    print("=" * 60)
    print("\nSummary:")
    print(f"  📂 Categories:          {Category.objects.count()}")
    print(f"  🧘 Meditations:         {MeditationSession.objects.count()}")
    print(f"  🧘‍♀️ Yoga Sessions:       {YogaSession.objects.count()}")
    print(f"  🎵 Music Categories:    {MusicCategory.objects.count()}")
    print(f"  🎶 Music Tracks:        {MusicTrack.objects.count()}")
    print(f"  🧠 CBT Topics:          {CBTTopic.objects.count()}")
    print(f"  ✨ Affirmation Cats:     {AffirmationCategory.objects.count()}")
    print(f"  💬 Affirmations:        {GenericAffirmation.objects.count()}")
    print(f"  📖 Disorders:           {Disorder.objects.count()}")
    print(f"  📝 Articles:            {Article.objects.count()}")
    print(f"  🛠️ Coping Methods:      {CopingMethod.objects.count()}")
    print(f"  🗺️ Roadmap Steps:       {RoadmapStep.objects.count()}")
    print(f"  🎨 Therapy Sessions:    {TherapySession.objects.count()}")
    print(f"  ❓ Reflection Q's:      {ReflectionQuestion.objects.count()}")
    print(f"  🎶 Background Music:    {BackgroundMusic.objects.count()}")
    print(f"  📋 Aff. Templates:      {AffirmationTemplate.objects.count()}")
    print("\n📌 Upload audio files & images via Django Admin: /admin/")


if __name__ == "__main__":
    seed_data()
