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

case "$1" in
  jv ) fragment="35/asr_javanese" ;;
  su ) fragment="36/asr_sundanese" ;;
  * ) echo "Unrecognized language: '$1'" >&2 ; exit 1 ;;
esac

for d in 0 1 2 3 4 5 6 7 8 9 a b c d e f; do
  resource="${fragment}_${d}.zip"
  wget "http://www.openslr.org/resources/$resource"
  zipfile="$(basename "$resource")"
  unzip -nqq "$zipfile"
  rm -f "$zipfile"
done
