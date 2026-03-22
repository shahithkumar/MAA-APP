# 2.3 THEORETICAL BACKGROUND

### 2.3.1 Machine Learning & Deep Learning
Machine learning (ML) is the study of computer algorithms that improve automatically through experience and by the use of data. It is a subset of artificial intelligence (AI). Machine learning algorithms build models based on sample data, known as "training data," to make predictions or decisions without being explicitly programmed to do so. In the context of this Mental Health App, advanced ML—specifically **Deep Learning**—is heavily utilized for complex tasks such as natural language understanding, speech emotion recognition, and computer vision, where traditional rule-based algorithms fall short.

### 2.3.2 Approaches
Machine learning approaches are traditionally divided into several broad categories depending on the nature of the "signal" or "feedback" available to the learning system:

*   **Supervised learning**: The computer is presented with example inputs and their desired outputs (labels), and the goal is to learn a general rule that maps inputs to outputs. In this app, models are trained on datasets of faces, voices, and text labeled with specific emotions (e.g., Happy, Sad, Stressed).
*   **Unsupervised learning**: No labels are given to the algorithm, leaving it on its own to find underlying structures in its input. This can be used to cluster users with similar stress patterns to recommend customized therapies.
*   **Generative AI (Large Language Models)**: A highly advanced branch of deep learning where models (like **Llama 3.1**) learn the statistical probabilities of human language from vast datasets. Instead of just classifying data, they generate novel, context-aware text, enabling the app's empathetic chatbot (**MAA**).

---

# 2.4 PROCESS FLOW STEPS
The core AI engine of the Mental Health App follows a systematic pipeline when processing "Stress Buster" journal entries:

1.  **Data Collection**
2.  **Data Pre-processing**
3.  **Data Visualization**
4.  **Multi-Modal Emotion Tracking**
5.  **Data Modelling**
6.  **Performance Evaluation**

### 2.4.1 Data Collection
Data collection in this project occurs in real-time through user interactions on the **Flutter-based mobile UI**. When a user submits a "Stress Buster" journal entry, the system captures tri-modal data:
*   **Visual Data**: An image/selfie captured via the device camera.
*   **Audio Data**: A voice recording captured via the device microphone.
*   **Text Data**: A written note or journal entry typed by the user.

Additionally, the underlying ML models were pre-trained on large, publicly transparent databases of human emotions such as the **RAVDESS** audio dataset and **FER-2013** facial expression dataset.

### 2.4.2 Data Pre-processing
Before the raw multi-modal data is fed into the machine learning models, it must be cleaned and transformed into a format the models can process effectively:
*   **Text Pre-processing**: User text is cleansed by removing special characters, converting to lowercase, and tokenization (splitting text into processable integer sequences) using the **RoBERTa tokenizer** so the NLP model can understand the context.
*   **Audio Pre-processing**: Raw audio waves are trimmed to remove dead silence. The audio is then converted into numerical arrays (measuring pitch, tone, and prosody) using libraries like **LibROSA**.
*   **Image Pre-processing**: The system isolates the user's face from the captured image (**Face Detection** using OpenCV/Mediapipe). The cropped face is then resized to a standard resolution (e.g., 48x48 pixels) and normalized so the visual model isn't distracted by background noise or lighting differences.

### 2.4.3 Data Visualization
Data visualization is crucial for helping the end-user interpret their mental health journey. The application uses the **FL Chart** library in Flutter to provide users with visual feedback:
*   **Chronological Mood Graphs**: Line charts visualizing the user's logged emotional state over days, weeks, or months, helping identify triggers.
*   **Emotion Distribution**: Pie charts breaking down the percentage of positive, neutral, and negative days. Visualizing this data helps the system in recommending the right resources (e.g., pushing meditation exercises during a visually tracked high-stress week).

### 2.4.4 Multi-Modal Emotion Tracking (System Persona)
A single modality (like only judging text) can be inaccurate—a user might type "I'm fine" but have a highly stressed vocal tone. The system calculates a fused emotional score by combining:
*   **T_Value (Text Sentiment)**: What the user is explicitly saying (Analyzed by **RoBERTa**).
*   **A_Value (Audio Prosody)**: How the user sounds while speaking (Analyzed by **Wav2Vec 2.0**).
*   **V_Value (Visual Expression)**: What the user's micro-expressions reveal (Analyzed by **CNN**).

The AI logic in the **FastAPI ML Server** weights these three inputs to generate a final, highly accurate emotional diagnosis (e.g., "70% Stressed, 30% Neutral"). Based on this fusion, the app triggers personalized interventions, routing the user to specific Yoga videos or emergency SOS lines if severe distress is detected.

### 2.4.5 Data Modelling
To accurately assess the user's mental state, specialized deep learning architectures are utilized for each distinct data modality.

1.  **Convolutional Neural Networks (CNN) for Facial Analysis**: CNNs are used for image classification. The network uses mathematical "filters" to scan the user's face, detecting edges, curves, and eventually complex features like furrowed brows or frowning lips.
2.  **Wav2Vec 2.0 for Audio Emotion**: A highly advanced acoustic model that processes raw waveforms. Instead of just looking at the volume, it learns the nuanced rhythms, pauses, and pitch variations indicative of human emotion, classifying the voice note as stressed, calm, etc.
3.  **Transformers (RoBERTa) for Text Sentiment**: Transformer models excel at understanding context in natural language. RoBERTa understands contextual negation and classifies the journal entry with high accuracy.
4.  **Generative LLMs (Llama 3.1) for Chatbot**: Utilizing the **Groq API**, the **Llama 3.1-8B** model acts as an empathetic conversationalist (**MAA**). It generates dynamic, supportive dialogue based on the user's chat history, providing a safe, non-judgmental space.

### 2.4.6 Evaluation Metrics for Classification
To ensure the AI is not falsely diagnosing user emotions, the models are rigorously tested using specific evaluation metrics:
*   **Confusion Matrix**: A table used to evaluate the performance of the emotion classification models.
    *   **True Positives (TP)**: The user was actually Stressed, and the AI correctly predicted Stressed.
    *   **True Negatives (TN)**: The user was actually Calm, and the AI correctly predicted Calm.
    *   **False Positives (FP)**: The user was Calm, but the AI incorrectly flagged them as Stressed.
    *   **False Negatives (FN)**: The user was Stressed, but the AI incorrectly missed it and predicted Calm (Highly undesirable in a mental health app).
*   **Accuracy**: `(TP + TN) / Total Samples`
*   **Precision**: `TP / (TP + FP)` (Measures how accurate the AI is when it does predict a specific emotion).
*   **Recall**: `TP / (TP + FN)` (Measures the system's ability to safely catch all instances of a specific emotion).
*   **F1-Score**: The harmonic mean of Precision and Recall, providing a balanced metric to judge the model.
