from django.urls import path
from .views import (
    # Authentication
    LoginView, RegisterView, ResetPasswordView, ResetPasswordConfirmView,
    
    # User Profile & Guardian
    UserProfileView, GuardianView, CategoryView,
    
    # Meditation & Yoga
    MeditationListView, MeditationDetailView, YogaListView, YogaDetailView,
    
    # Audio & Preferences
    UploadAudioView, UserPreferencesView, BackgroundMusicView,
    
    # Sessions
    CalmingSessionView, GroundingSessionView, PanicSessionView, StressBusterSessionView,
    
    # SOS
    SOSView,
    
    # Mood Tracking
    MoodLogView, MoodSummaryView,
    
    # Affirmations
    AffirmationCategoryView, GenericAffirmationsView, CustomAffirmationView, GenerateAIAffirmationsView,
    RandomCustomAffirmationView, RandomAffirmationView, AffirmationTemplatesView,
    
    # Music Therapy
    MusicCategoryView, MusicTracksView, MusicSessionView,
    
    # CBT Therapy
    CBTTopicView, CBTSessionView,
    
    # Resources Hub (NEW)
    DisorderListView, DisorderDetailView, ArticleListView, CopingMethodListView, RoadmapView,VoiceEmotionView, TextEmotionView, FaceEmotionView, TriModalJournalView,
    TherapySessionListView, TherapySessionDetailView, TherapyRecordCreateView, Journal2View, Journal2FaceTrackView, Journal2LatestPlanView, ArtTherapyAnalysisView
)

urlpatterns = [
    # ===========================
    # AUTHENTICATION ENDPOINTS
    # ===========================
    path('auth/login/', LoginView.as_view(), name='login'),
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/reset/', ResetPasswordView.as_view(), name='reset-password'),
    path('auth/reset-confirm/<str:uidb64>/<str:token>/', 
         ResetPasswordConfirmView.as_view(), name='reset-confirm'),

    # ===========================
    # USER PROFILE ENDPOINTS
    # ===========================
    path('auth/profile/', UserProfileView.as_view(), name='user_profile'),
    path('auth/guardian/', GuardianView.as_view(), name='guardian'),
    path('auth/categories/', CategoryView.as_view(), name='categories'),

    # ===========================
    # MEDITATION & YOGA
    # ===========================
    path('meditations/', MeditationListView.as_view(), name='meditation_list'),
    path('meditations/<int:pk>/', MeditationDetailView.as_view(), name='meditation_detail'),
    path('yoga/', YogaListView.as_view(), name='yoga_list'),
    path('yoga/<int:pk>/', YogaDetailView.as_view(), name='yoga_detail'),

    # ===========================
    # AUDIO UPLOAD & PREFERENCES
    # ===========================
    path('upload/audio/', UploadAudioView.as_view(), name='upload_audio'),
    path('user/preferences/', UserPreferencesView.as_view(), name='user_preferences'),
    path('background-music/', BackgroundMusicView.as_view(), name='background_music'),

    # ===========================
    # SESSION LOGGING
    # ===========================
    path('sessions/calming/', CalmingSessionView.as_view(), name='calming_session'),
    path('sessions/grounding/', GroundingSessionView.as_view(), name='grounding_session'),
    path('sessions/panic/', PanicSessionView.as_view(), name='panic_session'),
    path('sessions/stress-buster/', StressBusterSessionView.as_view(), name='stress_buster_session'),

    # ===========================
    # SOS EMERGENCY
    # ===========================
    path('sos/', SOSView.as_view(), name='sos'),

    # ===========================
    # MOOD TRACKING
    # ===========================
    path('moods/', MoodLogView.as_view(), name='mood_logs'),
    path('moods/summary/', MoodSummaryView.as_view(), name='mood_summary'),

    # ===========================
    # AFFIRMATIONS
    # ===========================
    path('affirmations/categories/', AffirmationCategoryView.as_view(), name='affirmation_categories'),
    path('affirmations/generic/<int:category_id>/', GenericAffirmationsView.as_view(), 
         name='generic_affirmations_category'),
    path('affirmations/generic/', GenericAffirmationsView.as_view(), 
         name='all_generic_affirmations'),
    path('affirmations/custom/', CustomAffirmationView.as_view(), name='custom_affirmations'),
    path('affirmations/custom/<int:pk>/', CustomAffirmationView.as_view(), 
         name='delete_custom_affirmation'),
    path('affirmations/random-custom/', RandomCustomAffirmationView.as_view(), 
         name='random_custom_affirmation'),
    path('affirmations/random/', RandomAffirmationView.as_view(), 
         name='random_affirmation'),
    path('affirmations/templates/', AffirmationTemplatesView.as_view(), 
         name='affirmation_templates'),

    # ===========================
    # MUSIC THERAPY
    # ===========================
    path('music/categories/', MusicCategoryView.as_view(), name='music_categories'),
    path('music/tracks/<int:category_id>/', MusicTracksView.as_view(), name='music_tracks'),
    path('music/sessions/', MusicSessionView.as_view(), name='music_sessions'),

    # ===========================
    # CBT THERAPY
    # ===========================
    path('cbt/topics/', CBTTopicView.as_view(), name='cbt_topics'),
    path('cbt/sessions/', CBTSessionView.as_view(), name='cbt_sessions'),

    # ===========================
    # RESOURCES HUB (NEW)
    # ===========================
    path('resources/disorders/', DisorderListView.as_view(), name='disorder-list'),
    path('resources/disorders/<int:pk>/', DisorderDetailView.as_view(), name='disorder-detail'),
    path('resources/articles/<int:disorder_id>/', ArticleListView.as_view(), name='article-list'),
    path('resources/coping-methods/<int:disorder_id>/', CopingMethodListView.as_view(), name='coping-method-list'),
    path('resources/roadmap/<int:disorder_id>/', RoadmapView.as_view(), name='roadmap'),


    path('voice/', VoiceEmotionView.as_view()),
    path('text/', TextEmotionView.as_view()),
    path('face/', FaceEmotionView.as_view()),
    path("journal/tri-modal/", TriModalJournalView.as_view()),  # correct one

    # ===========================
    # THERAPY MODULE (Music & Drawing)
    # ===========================
    path('therapy/sessions/', TherapySessionListView.as_view(), name='therapy-sessions'),
    path('therapy/sessions/<int:pk>/', TherapySessionDetailView.as_view(), name='therapy-session-detail'),
    path('therapy/records/', TherapyRecordCreateView.as_view(), name='therapy-record-create'),
    
    # ===========================
    # AI AFFIRMATIONS
    # ===========================
    path('affirmations/generate-ai/', GenerateAIAffirmationsView.as_view(), name='generate_ai_affirmations'),
    path('journal/2/', Journal2View.as_view(), name='journal2'),
    path('journal/2/plan/', Journal2LatestPlanView.as_view(), name='journal2_plan'),
    path('art-therapy/analyze/', ArtTherapyAnalysisView.as_view(), name='art_therapy_analyze'),
    path('journal/2/face-track/', Journal2FaceTrackView.as_view(), name='journal2_face_track'),
]