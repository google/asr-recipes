#! /bin/bash

# Copyright 2018 Google LLC. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ ! -d "$1" ] ; then
  echo >&2 "Usage: prep.sh CORPUSDIR"
  exit 1
fi

if [ ! -d "$KALDI_ROOT" ] ; then
  echo >&2 'KALDI_ROOT must be set and point to the Kaldi directory'
  exit 1
fi

set -o errexit
set -o nounset
export LC_ALL=C

readonly CORPUSDIR="$1"

#
# Kaldi recipe directory layout
#

# Create the directories needed
mkdir -p data/local/dict data/local/tmp data/train data/test

# Symlink path setup file expected to be present in the recipe directory
ln -sf ../common/path.sh

# Symlink auxiliary Kaldi recipe subdirectories
kaldi_egs_dir="$KALDI_ROOT/egs"
ln -sf "$kaldi_egs_dir/wsj/s5/steps"
ln -sf "$kaldi_egs_dir/wsj/s5/utils"
ln -sf "$kaldi_egs_dir/rm/s5/local"
ln -sf "$kaldi_egs_dir/rm/s5/conf"

#
# Training and test data
#

full_file=utt_spk_text.tsv
train_file=utt_spk_text-train.tsv
test_file=utt_spk_text-test.tsv

# Symlink the corpus info file and perform a train/test split
ln -sf "$CORPUSDIR/utt_spk_text.tsv" "$full_file"
../tools/traintest-split.sh "$full_file"

echo "Preparing training data, this may take a while"
../tools/kaldi_converter.py -d $CORPUSDIR -f $train_file --alsent > data/train/al_sent.txt
../tools/kaldi_converter.py -d $CORPUSDIR -f $train_file --spk2utt    | sort -k1,1 > data/train/spk2utt
../tools/kaldi_converter.py -d $CORPUSDIR -f $train_file --spk2gender | sort -k1,1 > data/train/spk2gender
../tools/kaldi_converter.py -d $CORPUSDIR -f $train_file --text       | sort -k1,1 > data/train/text
../tools/kaldi_converter.py -d $CORPUSDIR -f $train_file --utt2spk    | sort -k1,1 > data/train/utt2spk
../tools/kaldi_converter.py -d $CORPUSDIR -f $train_file --wavscp     | sort -k1,1 > data/train/wav.scp
echo "Training data prepared"

echo "Preparing test data, this may take a while"
../tools/kaldi_converter.py -d $CORPUSDIR -f $test_file  --alsent > data/test/al_sent.txt
../tools/kaldi_converter.py -d $CORPUSDIR -f $test_file  --spk2utt    | sort -k1,1 > data/test/spk2utt
../tools/kaldi_converter.py -d $CORPUSDIR -f $test_file  --spk2gender | sort -k1,1 > data/test/spk2gender
../tools/kaldi_converter.py -d $CORPUSDIR -f $test_file  --text       | sort -k1,1 > data/test/text
../tools/kaldi_converter.py -d $CORPUSDIR -f $test_file  --utt2spk    | sort -k1,1 > data/test/utt2spk
../tools/kaldi_converter.py -d $CORPUSDIR -f $test_file  --wavscp     | sort -k1,1 > data/test/wav.scp
echo "Test data prepared"

# Fix sorting issues etc.
utils/fix_data_dir.sh data/train
utils/fix_data_dir.sh data/test

#
# Lexicon and phone set
#

lexicon=data/local/dict/lexicon.txt
nonsilence_phones=data/local/dict/nonsilence_phones.txt

awk '{for (i = 2; i <= NF; ++i) print $i}' data/train/text data/test/text |
  sort -u > vocabulary.txt

../tools/simpleg2g.py -i vocabulary.txt -n 2 > "$lexicon"

awk '{for (i = 2; i <= NF; ++i) print $i}' "$lexicon" |
  sort -u > "$nonsilence_phones"

# Add silence word and phone to lexicon
echo "!SIL  sil" >> "$lexicon"

# Creating empty files and silence only files
echo "sil" > data/local/dict/silence_phones.txt
echo "sil" > data/local/dict/optional_silence.txt
touch data/local/dict/extra_questions.txt

#
# Language model
#

# Corpora depentent text for language models
# Files for data/local/tmp
../tools/kaldi_converter.py -d $CORPUSDIR -f $full_file --transcriptions |
  sort -u > tmp_transcripts.txt

# Generating text for language model
echo "Processing all utterances to generate Language model"
../tools/kaldi_converter.py -d $CORPUSDIR --f $full_file --bigram tmp_transcripts.txt > tmp_bigrams.txt
local/make_rm_lm.pl tmp_bigrams.txt > data/local/tmp/G.txt
echo "All utterances processed"

rm -f tmp_transcripts.txt; rm tmp_bigrams.txt

#
# Hand off to Kaldi
#

utils/prepare_lang.sh data/local/dict '!SIL' data/local/lang data/lang

local/rm_prepare_grammar.sh      # Traditional RM grammar (bigram word-pair)
#local/rm_prepare_grammar_ug.sh   # Unigram grammar (gives worse results, but changes in WER will be more significant.)
