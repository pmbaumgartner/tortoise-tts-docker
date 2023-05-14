FROM nvidia/cuda:11.3.1-base-ubuntu20.04

LABEL org.opencontainers.image.source=https://github.com/pmbaumgartner/tortoise-tts-docker
LABEL org.opencontainers.image.description="A Docker image for tortoise TTS with pinned dependencies and pre-installed models."
LABEL org.opencontainers.image.licenses=Apache-2.0

ENV PYTHON_VERSION=3.8

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    libsndfile1-dev \
    git \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    sudo \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s -f /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    ln -s -f /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
    ln -s -f /usr/bin/pip3 /usr/bin/pip

# Configure non-root user
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user
ARG USERNAME=tortoise
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /app
# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN chown -R $USER_UID:$USER_GID /app

USER $USERNAME

RUN pip install --upgrade --user pip 

RUN pip install --user --no-cache-dir torch==1.12.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113

RUN chmod 777 .

RUN git clone --depth=1 https://github.com/pmbaumgartner/tortoise-tts

WORKDIR tortoise-tts

# This is important for a specific version of code AND so that docker doesn't cache the repo
RUN git fetch && git checkout 7a7b4a7

RUN pip install --user --no-cache-dir -r requirements.txt 
RUN python setup.py install --user

RUN sudo mkdir /results && sudo chmod 777 /results && mkdir results && ln -s -f /app/tortoise-tts/results /results
RUN sudo mkdir /voices && sudo chmod 777 /voices && /app/tortoise-tts/tortoise/voices /voices

# Do this to download the models for the first time
RUN python -c 'from tortoise.api import TextToSpeech; tts = TextToSpeech()'
