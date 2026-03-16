FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set up a non-root user (ID 1000) for Hugging Face Spaces compatibility
RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the server code and models
COPY --chown=user . .

# Start the FastAPI server
ENV PORT=7860
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
