FROM nvidia/cuda:11.3.1-base-ubuntu20.04

ENV PYTHON_VERSION=3.8

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    libsndfile1-dev \
    git \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s -f /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    ln -s -f /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
    ln -s -f /usr/bin/pip3 /usr/bin/pip

RUN pip install --upgrade pip

RUN pip install --no-cache-dir torch==1.12.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113

WORKDIR app/

RUN git clone --depth=1 https://github.com/pmbaumgartner/tortoise-tts

WORKDIR tortoise-tts

# This is important for a specific version of code AND so that docker doesn't cache the repo
RUN git fetch && git checkout 7a7b4a7

RUN pip install --no-cache-dir -r requirements.txt 
RUN python setup.py install

# Do this to download the models for the first time
RUN python -c 'from tortoise.api import TextToSpeech; tts = TextToSpeech()'
