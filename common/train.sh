#!/bin/bash

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

# Simple recipe similar to kaldi/egs/rm/s5, but stop after first triphone pass.
# This is just for validating that our corpora are usable with Kaldi.

if [ ! -d "$KALDI_ROOT" ] ; then
  echo >&2 'KALDI_ROOT must be set and point to the Kaldi directory'
  exit 1
fi

set -o errexit
set -o nounset
export LC_ALL=C

nj=4
train_cmd=run.pl
decode_cmd=run.pl

# Buildng MFCC and CMVN
featdir=mfcc
steps/make_mfcc.sh --nj "$nj" --cmd "$train_cmd" data/train exp/make_feat/train "$featdir"
steps/compute_cmvn_stats.sh data/train exp/make_feat/train "$featdir"
steps/make_mfcc.sh --nj "$nj" --cmd "$train_cmd" data/test exp/make_feat/test "$featdir"
steps/compute_cmvn_stats.sh data/test exp/make_feat/test "$featdir"

# Train monophone model
steps/train_mono.sh --nj "$nj" --cmd "$train_cmd" data/train data/lang exp/mono
utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph

# Decode monophone model
steps/decode.sh --config conf/decode.config --nj "$nj" --cmd "$decode_cmd" \
  exp/mono/graph data/test exp/mono/decode

# Get monophone alignments
steps/align_si.sh --nj "$nj" --cmd "$train_cmd" \
  data/train data/lang exp/mono exp/mono_ali

# Train first triphone model
steps/train_deltas.sh --cmd "$train_cmd" \
 1800 9000 data/train data/lang exp/mono_ali exp/tri1

# Decode first triphone model
utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
steps/decode.sh --config conf/decode.config --nj "$nj" --cmd "$decode_cmd" \
  exp/tri1/graph data/test exp/tri1/decode
