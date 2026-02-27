from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    age = models.IntegerField()
    phone_number = models.CharField(max_length=15)
    email = models.EmailField()
    gender = models.CharField(max_length=10, null=True, blank=True)
    medical_history = models.FileField(upload_to='medical_history/', null=True, blank=True)
    is_pro = models.BooleanField(default=False)
    streak_count = models.IntegerField(default=0)
    last_activity_date = models.DateField(blank=True, null=True)

    def __str__(self):
        return self.name

class Guardian(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    relationship = models.CharField(max_length=50)
    phone_number = models.CharField(max_length=15)
    email = models.EmailField()

    def __str__(self):
        return f"{self.name} ({self.relationship})"

class Category(models.Model):
    name = models.CharField(max_length=100)
    emoji = models.CharField(max_length=10, blank=True, null=True)

    def __str__(self):
        return self.name

class MeditationSession(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    duration = models.IntegerField()
    audio_file = models.FileField(upload_to='meditations/')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    emoji = models.CharField(max_length=10, blank=True, null=True)
    guidance_text = models.TextField(blank=True, null=True, help_text="Text to display on screen during meditation")
    image = models.ImageField(upload_to='meditation_bg/', blank=True, null=True, help_text="Background Image for the session")

    def __str__(self):
        return self.title

class YogaSession(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    duration = models.IntegerField()
    audio_file = models.FileField(upload_to='yoga/')
    type = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    emoji = models.CharField(max_length=10, blank=True, null=True)
    video_url = models.URLField(blank=True, null=True, help_text="YouTube Video URL")
    channel_name = models.CharField(max_length=100, blank=True, null=True, help_text="YouTube Channel Name")
    image = models.ImageField(upload_to='yoga_thumbnails/', blank=True, null=True, help_text="Custom Thumbnail Image")

    def __str__(self):
        return self.title

class UserPreferences(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    meditation_music_on = models.BooleanField(default=True)

    def __str__(self):
        return f"Preferences for {self.user.username}"

class BackgroundMusic(models.Model):
    title = models.CharField(max_length=200)
    audio_file = models.FileField(upload_to='background_music/')
    emoji = models.CharField(max_length=10, blank=True, null=True)

    def __str__(self):
        return self.title

class CalmingSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    actions = models.CharField(max_length=200, default="unknown")
    end_time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Calming session for {self.user.username}"

class GroundingSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    five_see = models.TextField()
    four_touch = models.TextField()
    three_hear = models.TextField()
    two_smell = models.TextField()
    one_taste = models.TextField()
    feedback = models.TextField(blank=True, null=True)
    end_time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Grounding session for {self.user.username}"

class PanicSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    actions = models.JSONField(default=dict)
    end_time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Panic session for {self.user.username}"

class StressBusterSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    session_type = models.CharField(max_length=100, default="unknown")
    duration = models.IntegerField(default=0)
    note_text = models.TextField(blank=True, null=True)
    voice_file = models.FileField(upload_to='stress_buster/', null=True, blank=True)
    feedback = models.TextField(blank=True, null=True)
    end_time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Stress buster session for {self.user.username}"

class MoodLog(models.Model):
    MOOD_CHOICES = [
        # Positive High
        ('Joyful', 'Joyful'),
        ('Excited', 'Excited'),
        ('Energetic', 'Energetic'),
        ('Proud', 'Proud'),
        
        # Positive Warm
        ('Happy', 'Happy'),
        ('Grateful', 'Grateful'),
        ('Loved', 'Loved'),
        ('Calm', 'Calm'),
        ('Relaxed', 'Relaxed'),
        
        # Neutral/Focus
        ('Neutral', 'Neutral'),
        ('Focused', 'Focused'),
        
        # Negative Sad
        ('Sad', 'Sad'),
        ('Lonely', 'Lonely'),
        ('Grief', 'Grief'),
        
        # Negative Stress/Anger
        ('Angry', 'Angry'),
        ('Frustrated', 'Frustrated'),
        ('Anxious', 'Anxious'),
        ('Stressed', 'Stressed'),
        ('Overwhelmed', 'Overwhelmed'),
        
        # Physical/Low
        ('Tired', 'Tired'),
    ]
    TAG_CHOICES = [
        ('Work', 'Work'),
        ('Friends', 'Friends'),
        ('Family', 'Family'),
        ('Sleep', 'Sleep'),
        ('Other', 'Other'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date_time = models.DateTimeField(default=timezone.now)
    mood_emoji = models.CharField(max_length=10)
    mood_label = models.CharField(max_length=20, choices=MOOD_CHOICES)
    note = models.TextField(blank=True, null=True)
    tag = models.CharField(max_length=20, choices=TAG_CHOICES, blank=True, null=True)

    def __str__(self):
        return f"{self.mood_label} log by {self.user.username} on {self.date_time}"

class AffirmationCategory(models.Model):
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=10)  # Emoji
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.name

class GenericAffirmation(models.Model):
    category = models.ForeignKey(AffirmationCategory, on_delete=models.CASCADE, related_name='affirmations')
    text = models.TextField()
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return self.text[:50]

class CustomAffirmation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    affirmation_text = models.TextField()
    focus_area = models.CharField(max_length=100)  # Calm, Confidence, etc.
    challenge = models.TextField()  # User's challenge
    positive_direction = models.TextField()  # User's positive reminder
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return self.affirmation_text[:50]

class AffirmationTemplate(models.Model):
    template = models.TextField()  # e.g., "I am learning to {positive_direction} even when {challenge}."
    focus_areas = models.JSONField(default=list)  # ['Calm', 'Confidence']

# MUSIC THERAPY MODELS (NEW - ADDED ONLY, NO CHANGES TO OLD)
class MusicCategory(models.Model):
    name = models.CharField(max_length=100)
    emoji = models.CharField(max_length=10)
    color = models.CharField(max_length=20)  # hex color e.g., '#2196F3'
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return self.name

    @property
    def track_count(self):
        return self.tracks.count()

class MusicTrack(models.Model):
    title = models.CharField(max_length=200)
    category = models.ForeignKey(MusicCategory, on_delete=models.CASCADE, related_name='tracks')
    audio_file = models.FileField(upload_to='music_tracks/')  # Changed to FileField for uploads
    duration = models.IntegerField(default=0)  # seconds
    emoji = models.CharField(max_length=10, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"{self.title} ({self.category.name})"
class MusicSession(models.Model):
    MOOD_CHANGE_CHOICES = [
        ('much_better', 'Much Better'),
        ('a_bit_better', 'A Bit Better'),
        ('same', 'Same'),
        ('worse', 'Worse')
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(MusicCategory, on_delete=models.CASCADE)
    tracks_played = models.JSONField(default=list)  # List of track IDs played
    mood_change = models.CharField(max_length=20, choices=MOOD_CHANGE_CHOICES)
    current_emotion = models.CharField(max_length=50)
    session_duration = models.IntegerField(default=0)  # total seconds
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"Music session by {self.user.username} - {self.category.name}"

# CBT THERAPY MODELS (NEW - ADDED ONLY, NO CHANGES TO OLD)
class CBTTopic(models.Model):
    title = models.CharField(max_length=200)
    emoji = models.CharField(max_length=10)
    color = models.CharField(max_length=20)  # hex color
    description = models.TextField()
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return self.title

class CBTSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    topic = models.ForeignKey(CBTTopic, on_delete=models.CASCADE)
    situation = models.TextField()
    automatic_thought = models.TextField()
    emotions = models.TextField()
    evidence_for = models.TextField()
    evidence_against = models.TextField()
    balanced_thought = models.TextField()
    ai_analysis = models.TextField(blank=True, null=True)
    session_duration = models.IntegerField(default=0)  # total seconds
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"CBT session by {self.user.username} - {self.topic.title}"
class Disorder(models.Model):
    name = models.CharField(max_length=100)
    emoji = models.CharField(max_length=10, blank=True)
    summary = models.TextField()
    roadmap_image = models.ImageField(upload_to='disorder_roadmaps/', blank=True, null=True)
    article_url = models.URLField(blank=True, null=True)
    youtube_url = models.URLField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Article(models.Model):
    disorder = models.ForeignKey(Disorder, on_delete=models.CASCADE, related_name='articles')
    title = models.CharField(max_length=200)
    content = models.TextField()
    url = models.URLField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

class CopingMethod(models.Model):
    disorder = models.ForeignKey(Disorder, on_delete=models.CASCADE, related_name='coping_methods')
    title = models.CharField(max_length=200)
    instructions = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

class RoadmapStep(models.Model):
    disorder = models.ForeignKey(Disorder, on_delete=models.CASCADE, related_name='roadmap_steps')
    title = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(upload_to='roadmap_steps/', blank=True, null=True)
    order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} (Order: {self.order})"

    class Meta:
        ordering = ['order']
class EmotionLog(models.Model):
    user_id = models.CharField(max_length=100, default="user123")
    modality = models.CharField(max_length=10)  # voice/text/face
    emotion = models.CharField(max_length=30)
    confidence = models.FloatField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.modality.upper()}: {self.emotion} ({self.confidence:.2f})"
class EmotionJournal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    text = models.TextField(blank=True)
    voice = models.FileField(upload_to='journal/voice/', null=True, blank=True)
    face_image = models.ImageField(upload_to='journal/face/', null=True, blank=True)
    voice_emotion = models.CharField(max_length=20, blank=True, null=True)
    text_emotion = models.CharField(max_length=20, blank=True, null=True)
    face_emotion = models.CharField(max_length=20, blank=True, null=True)
    final_emotion = models.CharField(max_length=20, blank=True, null=True)
    confidence = models.FloatField(default=0.0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Journal {self.id} - {self.final_emotion}"

class Journal2Entry(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    text_content = models.TextField(blank=True)
    voice_file = models.FileField(upload_to='journal2/voice/', null=True, blank=True)
    face_capture = models.ImageField(upload_to='journal2/face/', null=True, blank=True)
    
    face_emotion = models.CharField(max_length=50, blank=True)
    text_emotion = models.CharField(max_length=50, blank=True)
    voice_emotion = models.CharField(max_length=50, blank=True)
    final_emotion = models.CharField(max_length=50, blank=True)
    
    analysis_data = models.JSONField(null=True, blank=True) # Full AI/ML breakdown
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Journal2 - {self.user.username} - {self.final_emotion} ({self.created_at.date()})"

# THERAPY MODELS (MUSIC & DRAWING)
class TherapySession(models.Model):
    THERAPY_TYPES = [
        ('Music', 'Music Therapy'),
        ('Drawing', 'Drawing Therapy'),
    ]
    
    title = models.CharField(max_length=200)
    therapy_type = models.CharField(max_length=20, choices=THERAPY_TYPES)
    
    # For Music
    audio_file = models.FileField(upload_to='therapy_music/', blank=True, null=True)
    duration = models.IntegerField(default=0, help_text="Duration in seconds (for music)")
    
    # For Drawing
    prompt_text = models.TextField(blank=True, null=True, help_text="Prompt for guided drawing")
    
    image = models.ImageField(upload_to='therapy_thumbnails/', blank=True, null=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.therapy_type})"

class ReflectionQuestion(models.Model):
    QUESTION_TYPES = [
        ('text', 'Text Input'),
        ('choice', 'Multiple Choice'),
    ]
    
    session = models.ForeignKey(TherapySession, on_delete=models.CASCADE, related_name='questions')
    question_text = models.TextField()
    question_type = models.CharField(max_length=20, choices=QUESTION_TYPES, default='text')
    options = models.JSONField(default=list, blank=True, help_text="List of options for Multiple Choice e.g. ['Yes', 'No']")
    order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return self.question_text[:50]

class TherapyRecord(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='therapy_records')
    session = models.ForeignKey(TherapySession, on_delete=models.CASCADE)
    
    mood_before = models.CharField(max_length=50, blank=True, null=True)
    mood_after = models.CharField(max_length=50, blank=True, null=True)
    
    # Specifically for Drawing Therapy
    drawing_file = models.ImageField(upload_to='user_drawings/', blank=True, null=True)
    
    # General notes if needed (optional, since we have answers now)
    reflection_notes = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.user.username} - {self.session.title} - {self.created_at.date()}"

class TherapyRecordAnswer(models.Model):
    record = models.ForeignKey(TherapyRecord, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(ReflectionQuestion, on_delete=models.CASCADE)
    answer_text = models.TextField() # Stores the selected option or typed text

    def __str__(self):
        return f"Answer to {self.question.id} by {self.record.user.username}"

# PROXY MODELS FOR CLEANER ADMIN
class MusicTherapySession(TherapySession):
    class Meta:
        proxy = True
        verbose_name = "Music Therapy Session"
        verbose_name_plural = "Music Therapy Sessions"

class DrawingTherapySession(TherapySession):
    class Meta:
        proxy = True
        verbose_name = "Drawing Therapy Session"
        verbose_name_plural = "Drawing Therapy Sessions"