# Ultimate_TTS_Studio_5090


docker build -t ultimate-tts-cu128 .

docker run --gpus all \
  --network host \
  --name ultimate-tts \
  ultimate-tts-cu128
