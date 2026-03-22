from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from .models import (
    UserProfile, Guardian, Category, MeditationSession, YogaSession,
    UserPreferences, BackgroundMusic, CalmingSession, GroundingSession,
    PanicSession, StressBusterSession, MoodLog, AffirmationCategory,
    GenericAffirmation, CustomAffirmation, AffirmationTemplate, MusicCategory, MusicTrack, MusicSession, CBTTopic, CBTSession,
    Disorder, Article, CopingMethod, RoadmapStep,  # ✅ ADDED Resources Hub models
    TherapySession, ReflectionQuestion, TherapyRecord, TherapyRecordAnswer,
    MusicTherapySession, DrawingTherapySession # ✅ PROXY MODELS
)
# ✅ UNREGISTER DEFAULT USER ADMIN
try:
    admin.site.unregister(User)
except admin.sites.NotRegistered:
    pass

from import_export.admin import ImportExportModelAdmin

# ---------------------------
# USER INLINES
# ---------------------------
# ... (UserProfileInline and GuardianInline remain)

# ... (CustomUserAdmin remains)

@admin.register(UserProfile)
class UserProfileAdmin(ImportExportModelAdmin):
    list_display = ['name', 'user', 'age', 'phone_number', 'email', 'gender']
    search_fields = ['name', 'email', 'phone_number']

@admin.register(Guardian)
class GuardianAdmin(ImportExportModelAdmin):
    list_display = ['name', 'user', 'relationship', 'phone_number']
    search_fields = ['name', 'phone_number', 'email']

@admin.register(Category)
class CategoryAdmin(ImportExportModelAdmin):
    list_display = ['name', 'emoji']
    search_fields = ['name']

@admin.register(MeditationSession)
class MeditationSessionAdmin(ImportExportModelAdmin):
    list_display = ['title', 'duration', 'category', 'emoji']
    fields = ['title', 'description', 'duration', 'audio_file', 'category', 'emoji', 'guidance_text', 'image']
    search_fields = ['title', 'description']
    list_filter = ['category']

@admin.register(YogaSession)
class YogaSessionAdmin(ImportExportModelAdmin):
    list_display = ['title', 'duration', 'type', 'emoji', 'channel_name']
    fields = ['title', 'description', 'duration', 'audio_file', 'type', 'emoji', 'video_url', 'channel_name', 'image']
    search_fields = ['title', 'description']
    list_filter = ['type']

@admin.register(UserPreferences)
class UserPreferencesAdmin(ImportExportModelAdmin):
    list_display = ['user', 'meditation_music_on']
    search_fields = ['user__username']

@admin.register(BackgroundMusic)
class BackgroundMusicAdmin(ImportExportModelAdmin):
    list_display = ['title', 'emoji']
    search_fields = ['title']

@admin.register(CalmingSession)
class CalmingSessionAdmin(ImportExportModelAdmin):
    list_display = ['user', 'actions', 'end_time']
    search_fields = ['user__username', 'actions']

@admin.register(GroundingSession)
class GroundingSessionAdmin(ImportExportModelAdmin):
    list_display = ['user', 'end_time']
    search_fields = ['user__username']

@admin.register(PanicSession)
class PanicSessionAdmin(ImportExportModelAdmin):
    list_display = ['user', 'end_time']
    search_fields = ['user__username']

@admin.register(StressBusterSession)
class StressBusterSessionAdmin(ImportExportModelAdmin):
    list_display = ['user', 'session_type', 'duration', 'end_time']
    search_fields = ['user__username', 'session_type']

@admin.register(MoodLog)
class MoodLogAdmin(ImportExportModelAdmin):
    list_display = ['user', 'mood_emoji', 'mood_label', 'tag', 'date_time']
    search_fields = ['user__username', 'mood_label']
    list_filter = ['mood_label', 'tag']

# ---------------------------
# AFFIRMATIONS
# ---------------------------
@admin.register(AffirmationCategory)
class AffirmationCategoryAdmin(ImportExportModelAdmin):
    list_display = ['name', 'icon']
    search_fields = ['name', 'description']

@admin.register(GenericAffirmation)
class GenericAffirmationAdmin(ImportExportModelAdmin):
    list_display = ['text_preview', 'category', 'is_active']
    list_filter = ['category', 'is_active']
    search_fields = ['text']
    
    def text_preview(self, obj):
        return obj.text[:50] + "..." if len(obj.text) > 50 else obj.text

@admin.register(CustomAffirmation)
class CustomAffirmationAdmin(ImportExportModelAdmin):
    list_display = ['user', 'focus_area', 'created_at']
    list_filter = ['focus_area', 'user']
    search_fields = ['affirmation_text', 'user__username']

@admin.register(AffirmationTemplate)
class AffirmationTemplateAdmin(ImportExportModelAdmin):
    list_display = ['template_preview', 'focus_areas']
    search_fields = ['template']
    
    def template_preview(self, obj):
        return obj.template[:50] + "..."

# MUSIC ADMIN
@admin.register(MusicCategory)
class MusicCategoryAdmin(ImportExportModelAdmin):
    list_display = ['name', 'emoji', 'color', 'created_at']
    search_fields = ['name']
    list_filter = ['created_at']

@admin.register(MusicTrack)
class MusicTrackAdmin(ImportExportModelAdmin):
    list_display = ['title', 'category', 'duration', 'audio_file']
    list_filter = ['category']
    search_fields = ['title', 'audio_file']

@admin.register(MusicSession)
class MusicSessionAdmin(ImportExportModelAdmin):
    list_display = ['user', 'category', 'mood_change', 'current_emotion', 'session_duration', 'created_at']
    list_filter = ['mood_change', 'current_emotion', 'category']
    search_fields = ['user__username']

# CBT ADMIN
@admin.register(CBTTopic)
class CBTTopicAdmin(ImportExportModelAdmin):
    list_display = ['title', 'emoji', 'color', 'created_at']
    search_fields = ['title']

@admin.register(CBTSession)
class CBTSessionAdmin(ImportExportModelAdmin):
    list_display = ['user', 'topic', 'created_at']
    list_filter = ['topic']
    search_fields = ['user__username', 'balanced_thought']

# Resources Hub
@admin.register(Disorder)
class DisorderAdmin(ImportExportModelAdmin):
    list_display = ['name', 'emoji', 'created_at']
    search_fields = ['name', 'summary']

@admin.register(Article)
class ArticleAdmin(ImportExportModelAdmin):
    list_display = ['title', 'disorder', 'created_at']
    list_filter = ['disorder']
    search_fields = ['title', 'content']

@admin.register(CopingMethod)
class CopingMethodAdmin(ImportExportModelAdmin):
    list_display = ['title', 'disorder', 'created_at']
    list_filter = ['disorder']
    search_fields = ['title', 'instructions']

@admin.register(RoadmapStep)
class RoadmapStepAdmin(ImportExportModelAdmin):
    list_display = ['title', 'disorder', 'order', 'created_at']
    list_filter = ['disorder']
    search_fields = ['title', 'description']

# THERAPY ADMIN
@admin.register(MusicTherapySession)
class MusicTherapySessionAdmin(ImportExportModelAdmin):
    list_display = ['title', 'duration', 'created_at']
    search_fields = ['title']
    fields = ['title', 'audio_file', 'duration', 'image', 'created_at']
    readonly_fields = ['created_at']
    
    def save_model(self, request, obj, form, change):
        obj.therapy_type = 'Music'
        super().save_model(request, obj, form, change)
        
    def get_queryset(self, request):
        return super().get_queryset(request).filter(therapy_type='Music')

@admin.register(DrawingTherapySession)
class DrawingTherapySessionAdmin(ImportExportModelAdmin):
    list_display = ['title', 'created_at']
    search_fields = ['title']
    fields = ['title', 'prompt_text', 'image', 'created_at']
    readonly_fields = ['created_at']

    def save_model(self, request, obj, form, change):
        obj.therapy_type = 'Drawing'
        super().save_model(request, obj, form, change)

    def get_queryset(self, request):
        return super().get_queryset(request).filter(therapy_type='Drawing')


@admin.register(TherapyRecord)
class TherapyRecordAdmin(ImportExportModelAdmin):
    list_display = ['user', 'session', 'mood_before', 'mood_after', 'created_at']
    list_filter = ['session__therapy_type', 'created_at']
    search_fields = ['user__username', 'session__title']
    readonly_fields = ['user', 'session', 'mood_before', 'mood_after', 'drawing_file', 'reflection_notes', 'created_at']

@admin.register(TherapyRecordAnswer)
class TherapyRecordAnswerAdmin(ImportExportModelAdmin):
    list_display = ['record', 'question', 'answer_text']
