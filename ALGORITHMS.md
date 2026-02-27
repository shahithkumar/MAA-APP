# 🧠 Algorithms & AI Architecture

This project uses a hybrid AI approach, combining **Deep Learning** for emotion recognition with a **Cognitive Architecture** for the chatbot.

---

## 1. Multi-Modal Emotion Recognition (`ml_inference_server`)
The system analyzes three modalities—**Face, Voice, and Text**—in parallel and fuses them to determine the user's emotional state.

### A. The Models
| Modality | Model / Algorithm | Implementation | Input |
| :--- | :--- | :--- | :--- |
| **Face** | **Custom CNN** (Convolutional Neural Network) | PyTorch (TorchScript) | 48x48 Grayscale Image |
| **Voice** | **Wav2Vec 2.0** (by Meta) + Classification Head | HuggingFace / PyTorch | Raw Audio Waveform (16kHz) |
| **Text** | **RoBERTa** (Robustly Optimized BERT) | HuggingFace / PyTorch | Tokenized Text Strings |

### B. The Fusion Algorithm: "The Humble Expert"
Instead of a simple average, the system uses a **Dynamic Weighted Averaging** algorithm located in `services/fusion.py`.

**Logic:**
1.  **Confidence Check**: Each model reports its highest probability (e.g., Face: 90% Happy, Voice: 60% Happy).
2.  **The "Humble" Cap**: Confidence is capped at **0.85** to prevent one model from completely dominating the decision if it's "overconfident."
3.  **Weighted Sum**: The final emotion is calculated by summing the weighted probabilities from all three sources.
    $$ FinalScore_E = \frac{\sum (Prob_{E,m} \times Weight_m)}{\sum Weight_m} $$
    *Where $m$ is the modality (Face, Voice, Text).*

---

## 2. Cognitive Chatbot Architecture (`chatbot`)
The chatbot does not simply send text to an LLM. It uses a **7-Layer Cognitive Architecture** to ensure safety, empathy, and therapeutic structure.

### The 7 Layers
1.  **Input Layer**: Sanitizes user input and protects against injection attacks.
2.  **Signal Layer**: Extracts meta-data like Emotion, Intensity, and Cognitive Distortions.
3.  **Safety Layer**: Evaluates suicide/self-harm risk (**Low / Medium / High / Critical**). Triggers immediate crisis protocols if needed.
4.  **Meaning Layer (Memory)**: Updates the **Finite State Machine (FSM)**. Tracks where the user is in the conversation flow (e.g., *Check-In* $\rightarrow$ *Validation* $\rightarrow$ *Intervention*).
5.  **Decision Layer (Policy Engine)**: Selects the best therapeutic approach:
    *   `CBT`: Cognitive Behavioral Therapy (reframing thoughts).
    *   `SUPPORTIVE`: Empathetic listening (Rogersian).
    *   `GROUNDING`: Panic attack intervention (5-4-3-2-1 technique).
    *   `CRISIS`: Emergency protocols.
6.  **RAG Layer**: **Retrieval-Augmented Generation**. Fetches verified psychoeducational content from the database if the user asks for information.
7.  **Generation Layer**: dynamic **Prompt Engineering**. Constructs a massive system prompt containing the User's State, Selected Policy, and RAG Context, and sends it to **Llama 3.1-8b** (via Groq) to generate the final response.

---

## 3. Technology Stack

*   **Deep Learning Framework**: PyTorch
*   **LLM Provider**: Groq (Llama 3.1)
*   **Orchestration**: Custom Python Logic (Django)
*   **Vector Search**: Internal logic (for RAG)
