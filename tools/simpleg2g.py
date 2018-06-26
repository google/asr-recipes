#! /usr/bin/env python

# Copyright 2018 Google LLC. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Script to simply convert grapheme to phoneme (grapheme)."""

from __future__ import unicode_literals

import io
import optparse

stdin = io.open(0, mode='rt', encoding='utf-8', closefd=False)
stdout = io.open(1, mode='wt', encoding='utf-8', closefd=False)
stderr = io.open(2, mode='wt', encoding='utf-8', closefd=False)


def SimpleG2P(word, length=1):
  """Simple G2P (G2NG) convertion function."""
  simple_phoneme = ''
  if len(word) > length:
    for i in range(len(word) - length + 1):
      simple_phoneme = simple_phoneme + ' ' + word[i:i+length]
    return simple_phoneme.strip().lower()
  else:
    return word.strip().lower()


def GenerateDictionary(input_file, ngraph_size):
  """Generates the G2P (G2NG) dictionary."""
  words = set()
  with io.open(input_file, mode='rt', encoding='utf-8') as text:
    for line in text:
      for word in line.split():
        words.add(word)
  words = list(words)
  words.sort()
  if 'SENTNCE-END' in words:
    words.remove('SENTENCE-END')

  for word in words:
    word.replace('_', '')
    phoneme = SimpleG2P('_%s_' % word, ngraph_size)
    stdout.write('%s\t%s\n' % (word.lower(), phoneme.lower()))


def main():
  parser = optparse.OptionParser()
  parser.add_option('-i',
                    '--input',
                    dest='inputFile',
                    help='Input transcription file')
  parser.add_option('-n',
                    '--ngram',
                    dest='ngramSize',
                    help='Ngram size, default 2',
                    default='2')

  options, _ = parser.parse_args()

  if options.inputFile is None:
    parser.print_help()
    parser.error('Input file is required')

  GenerateDictionary(options.inputFile, int(options.ngramSize))


if __name__ == '__main__':
  main()
