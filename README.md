# Recipes for using open-source ASR corpora

Recipes for using open-source ASR corpora with [Kaldi](http://kaldi-asr.org/).

This is not an official Google product.

## Languages

| Language  | Directory | Corpus |
|-----------|-----------|--------|
| Javanese  | jv | [Open SLR 35](http://openslr.org/35/) |
| Sundanese | su | [Open SLR 36](http://openslr.org/36/) |
| Sinhala   | si | [Open SLR 52](http://openslr.org/52/) |

## How to use

The above corpora are ready for use with Kaldi, after some simple data munging.
We provide a small Kaldi recipe for training a triphone recognizer, inspired by
the start of Kaldi's Resource Management recipe. The recipe is only intended for
illustration and for validating the corpus and data preparation.

### Prerequisites

1. [Kaldi](http://kaldi-asr.org/). First [download Kaldi from GitHub](https://github.com/kaldi-asr/kaldi), compile, and install.
2. [Flac](https://xiph.org/flac/). The scripts below use the `flac` command line tool (assumed to be on the shell `PATH`) for on-the-fly decompression of the corpus.
3. Python and Bash.

### General steps

1. **IMPORTANT:** You must define and export an environment variable `KALDI_ROOT` pointing at your Kaldi directory.
2. Download and unpack the corpora you need.
3. Change to a recipe directory and execute `run.sh`.

### Example

Here is how to use the Javanese corpus:
```
sudo apt-get install flac wget
git clone https://github.com/kaldi-asr/kaldi
cd kaldi
export KALDI_ROOT="$(realpath .)"
cat INSTALL
# and follow the instructions there to build Kaldi
cd ..
git clone https://github.com/googlei18n/asr-recipes
cd asr-recipes
tools/download_data.sh jv
# this unpacks the Javanese corpus into asr_javanese
cd jv
./run.sh
```

## License

Unless otherwise noted, all original files are licensed under an
[Apache License, Version 2.0](LICENSE).
