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

# Script which takes an utt_spk_text.tsv file and generates two files, one for
# training and the other for testing.
#
# Usage:
#  ./traintest-split.sh file_to_split (default utt_spk_text.tsv)

set -o errexit
set -o nounset
export LC_ALL=C

if [ $# -eq 0 ]; then
   INPUT_FILE=utt_spk_text.tsv
else
   INPUT_FILE=$1
fi

ALLSIZE="$(cat "$INPUT_FILE" | wc -l)"
TESTSIZE=2000
let TRAINSIZE=$ALLSIZE-$TESTSIZE

sort -k2 "$INPUT_FILE" | head -n "$TESTSIZE"  | sort > utt_spk_text-test.tsv
sort -k2 "$INPUT_FILE" | tail -n "$TRAINSIZE" | sort > utt_spk_text-train.tsv
