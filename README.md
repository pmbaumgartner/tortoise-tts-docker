A Dockerfile and image for [tortoise-tts](https://github.com/pmbaumgartner/tortoise-tts) with pinned dependencies and pre-installed models.

## Examples

**Single Voice**

Inside the container `/results` is a symlink to the default output directory (`./results/`). If you change the `--output_path` argument for this function (not shown in example below), you'll need to bind mount to the same folder you specify in that argument.

```
docker run -it --rm --gpus all \
  -v $(pwd)/results:/results \
  ghcr.io/pmbaumgartner/tortoise-tts:latest 
  python tortoise/do_tts.py --text "I'm going to speak this" --voice tom --preset ultra_fast
```

**Custom Voice**

If you want to add a custom voice the `/voices` folder is a symlink to the `voices` folder within the tortoise package. Inside of your local `voices` folder, you should include a subfolder with the voice name (e.g. `voices/<newvoice>` for the example below) with sample audio files for your custom voice.

Because this is mounting a local folder and its contents, it will remove the contents of the folder that is in the tortoise package, which means none of the default voices are available while you're using a custom voice.

```
docker run -it --rm --gpus all \
  -v $(pwd)/results:/results \
  -v $(pwd)/voices:/voices \
  ghcr.io/pmbaumgartner/tortoise-tts:latest 
  python tortoise/do_tts.py --text "I'm going to speak this" --voice <newvoice> --preset ultra_fast
```

**Other Notes**

This image includes `ffmpeg` if you want to convert audio files. For example, the input audio format is a 22500 sample rate wav, so you may need something like:

```
ffmpeg -i input.m4a -ac 1 -ar 22500 output.wav
```
