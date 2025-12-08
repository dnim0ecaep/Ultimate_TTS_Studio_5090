# CUDA 12.8 + Ubuntu 22.04 LTS
FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# ---- System packages ----
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip python3-dev \
    git build-essential cmake ninja-build \
    libopenblas-dev libblas-dev liblapack-dev \
    libsndfile1 \
    ffmpeg \
    espeak-ng libespeak-ng-dev \
    sox libsox-dev libsox-fmt-all \
    portaudio19-dev \
    wget curl \
 && rm -rf /var/lib/apt/lists/*

# Ensure "python" -> python3 (3.10 on Ubuntu 22.04)
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# ---- Python tooling (pip + uv) ----
RUN python -m pip install --upgrade pip setuptools wheel uv

# ---- Workspace ----
WORKDIR /workspace

# Clone Ultimate-TTS-Studio
RUN git clone https://github.com/SUP3RMASS1VE/Ultimate-TTS-Studio-SUP3R-Edition.git

WORKDIR /workspace/Ultimate-TTS-Studio-SUP3R-Edition

# ---- Install dependencies with uv (based on README Option 3) ----
# Step 1: core requirements (install into system env)
RUN uv pip install --system -r requirements.txt

# Step 2: specific packages (Linux-safe subset, also into system env)
RUN uv pip install --system voxcpm openai-whisper --no-deps \
 && uv pip install --system WeTextProcessing --no-deps \
 && uv pip install --system \
        torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 \
        --index-url https://download.pytorch.org/whl/cu128

# ---- Runtime debug env (for CUDA errors) ----
ENV TORCH_USE_CUDA_DSA=1 \
    CUDA_LAUNCH_BLOCKING=1

# Expose Gradio default port
EXPOSE 7860

# Default: launch the app
CMD ["python", "launch.py"]

