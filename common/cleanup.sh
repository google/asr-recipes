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

# Removes all the directories added when the model is run.
# WARINIG: Removes all data created
if [ -d "exp" ]; then
  rm -r exp
fi
if [ -d "mfcc" ]; then
  rm -r mfcc
fi
if [ -d "data" ]; then
  rm -r data
fi
if [ -d "data-fbank" ]; then
  rm -r data-fbank
fi
echo "All generated files and directories removed."
