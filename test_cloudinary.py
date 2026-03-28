import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from cloudinary_storage.storage import MediaCloudinaryStorage, VideoMediaCloudinaryStorage, RawMediaCloudinaryStorage
from auth_api.models import MeditationSession

try:
    m = MeditationSession.objects.last()
    print("URL string:", m.audio_file.url if m and m.audio_file else "None")
    print("Type of audio_file storage:", type(m.audio_file.storage))
except Exception as e:
    print("Error:", e)
