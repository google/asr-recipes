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

# Set up Kaldi-related paths.
# This file should only be sourced by other scripts.
# It is probably not a good idea to run it directly from the command line.

if [ ! -d "$KALDI_ROOT" ] ; then
  echo >&2 'KALDI_ROOT must be set and point to the Kaldi directory'
  sleep 5
  exit 1
fi
export PATH="$PWD/utils:$KALDI_ROOT/src/bin:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH"
if [ ! -f $KALDI_ROOT/tools/config/common_path.sh ] ; then
  echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!"
  sleep 5
  exit 1
fi
. "$KALDI_ROOT/tools/config/common_path.sh"
export LC_ALL=C
