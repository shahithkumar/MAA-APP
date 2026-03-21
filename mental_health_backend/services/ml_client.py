
import requests
import json
from django.conf import settings

# Configuration for ML Server URL
# Ideally this should be in settings.py, but for now we default to localhost
ML_SERVER_URL = getattr(settings, 'ML_SERVER_URL', 'http://127.0.0.1:8001')

class MLClient:
    
    @staticmethod
    def _handle_response(response):
        try:
            return response.json()
        except json.JSONDecodeError:
            return {"error": "Invalid JSON response from ML Server", "status_code": response.status_code}
        except Exception as e:
            return {"error": str(e)}

    @staticmethod
    def predict_face(image_file):
        """
        Sends image file to /predict/face
        image_file: file-like object (opened in binary mode)
        """
        try:
            files = {'file': ('face.jpg', image_file, 'image/jpeg')}
            response = requests.post(f"{ML_SERVER_URL}/predict/face", files=files, timeout=30)
            if response.status_code == 200:
                result = response.json()
                return result.get('dominant_emotion', 'neutral'), result.get('confidence', 0.0), result.get('normalized_probs', {})
            return "neutral", 0.0, {}
        except Exception as e:
            print(f"ML Client Error (Face): {e}")
            return "neutral", 0.0, {}

    @staticmethod
    def predict_audio(audio_file):
        """
        Sends audio file to /predict/audio
        audio_file: file-like object
        """
        try:
            files = {'file': ('audio.wav', audio_file, 'audio/wav')}
            print(f"🎵 [ML_CLIENT] Sending AUDIO to {ML_SERVER_URL}/predict/audio ...")
            # Increased timeout to 180s to handle slow CPU inference (esp. on first run)
            response = requests.post(f"{ML_SERVER_URL}/predict/audio", files=files, timeout=180)
            print(f"🎵 [ML_CLIENT] Received response from ML Server! Status: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print(f"🎵 [ML_CLIENT] Audio Prediction: {result}")
                return result.get('dominant_emotion', 'neutral'), result.get('confidence', 0.0), result.get('normalized_probs', {})
            else:
                print(f"❌ [ML_CLIENT] Audio Prediction Failed! Server Said: {response.text}")
            return "neutral", 0.0, {}
        except Exception as e:
            print(f"❌ [ML_CLIENT] CRITICAL Error (Audio): Could not connect to {ML_SERVER_URL}. Exception: {e}")
            return "neutral", 0.0, {}

    @staticmethod
    def predict_text(text):
        """
        Sends text to /predict/text
        """
        try:
            data = {'text': text}
            print(f"🤖 [ML_CLIENT] Sending TEXT to {ML_SERVER_URL}/predict/text ...")
            response = requests.post(f"{ML_SERVER_URL}/predict/text", data=data, timeout=20)
            print(f"🤖 [ML_CLIENT] Received response from ML Server! Status: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print(f"🤖 [ML_CLIENT] Text Prediction: {result}")
                return result.get('dominant_emotion', 'neutral'), result.get('confidence', 0.0), result.get('normalized_probs', {})
            else:
                print(f"❌ [ML_CLIENT] Text Prediction Failed! Server Said: {response.text}")
            return "neutral", 0.0, {}
        except Exception as e:
            print(f"❌ [ML_CLIENT] CRITICAL Error (Text): Could not connect to {ML_SERVER_URL}. Exception: {e}")
            return "neutral", 0.0, {}

    @staticmethod
    def predict_multimodal(text=None, voice_file=None, face_file=None):
        """
        Sends all available modalities to /predict/multimodal
        """
        try:
            data = {}
            files = []
            
            if text:
                data['text_input'] = text
                
            if voice_file:
                # We need to rewind file if it was read before, but usually in Django view it's fresh
                voice_file.seek(0) 
                files.append(('audio_file', ('audio.wav', voice_file, 'audio/wav')))
                
            if face_file:
                face_file.seek(0)
                files.append(('face_file', ('face.jpg', face_file, 'image/jpeg')))
            
            if not data and not files:
                return "neutral", 0.0, {}

            # Extra long timeout for multimodal (up to 300s) to handle sequential cold-starts on slow CPUs
            response = requests.post(f"{ML_SERVER_URL}/predict/multimodal", data=data, files=files, timeout=300)
            
            if response.status_code == 200:
                full_result = response.json()
                # Extract fusion
                fusion = full_result.get('fusion', {})
                dominant = fusion.get('dominant_emotion', 'neutral')
                confidence = fusion.get('confidence', 0.0)
                
                # Extract individual components for logging if needed
                components = full_result.get('components', {})
                return dominant, confidence, components
                
            return "neutral", 0.0, {}
            
        except Exception as e:
            print(f"ML Client Error (Multimodal): {e}")
            return "neutral", 0.0, {}

ml_client = MLClient()
