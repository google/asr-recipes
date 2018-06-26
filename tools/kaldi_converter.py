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

"""Utility to convert open-source speech corpora to Kaldi RM recipe format."""

from __future__ import unicode_literals

import io
from operator import itemgetter
import optparse
import os.path
import corpus_util as kaldi_util

stdin = io.open(0, mode='rt', encoding='utf-8', closefd=False)
stdout = io.open(1, mode='wt', encoding='utf-8', closefd=False)
stderr = io.open(2, mode='wt', encoding='utf-8', closefd=False)


class CorpusConverter(object):
  """Container for cretion from open-soruce corpus to RM recipe."""

  def __init__(self, corpus):
    self.corpus = corpus
    self.corpus_info = corpus.corpus_info.items()

  def AlSent(self):
    """Prints out the text used in al_sent.txt file in the RM recipe."""
    for _, rec in self.corpus_info:
      stdout.write('%s (%s)\n' % (rec.text, rec.utterance_id))

  def Spk2gender(self):
    """Prints out the text used in spk2gender file in the RM recipe."""
    spk_gender = {}
    for _, rec in self.corpus_info:
      if rec.session_id not in spk_gender:
        spk_gender[rec.session_id] = rec.gender
    for spk_id in spk_gender:
      stdout.write('%s %s\n' % (spk_id, spk_gender[spk_id][0]))

  def Text(self):
    """Prints out the text used in text file in the RM recipe."""
    for _, rec in self.corpus_info:
      stdout.write('%s %s\n' % (rec.utterance_id, rec.text.lower()))

  def Spk2utt(self):
    """Prints out the text used in spk2utt file in RM recipe."""
    spk_utt = {}
    for _, rec in self.corpus_info:
      if rec.session_id not in spk_utt:
        spk_utt[rec.session_id] = []
      spk_utt[rec.session_id].append(rec.utterance_id)

    for session_id in spk_utt:
      stdout.write('%s' % session_id)
      for utt_id in spk_utt[session_id]:
        stdout.write(' %s' % utt_id)
      stdout.write('\n')

  def Utt2spk(self):
    """Prints out the text used in utt2spk file in RM recipe."""
    spk_utt = {}
    for _, rec in self.corpus_info:
      if rec.session_id not in spk_utt:
        spk_utt[rec.session_id] = []
      spk_utt[rec.session_id].append(rec.utterance_id)

    for session_id in spk_utt:
      for utt_id in spk_utt[session_id]:
        stdout.write('%s %s\n' % (utt_id, session_id))

  def Wavscp(self):
    """Prints out the text used in wav.scp file in RM recipe."""
    spk_utt = {}
    for _, rec in self.corpus_info:
      if rec.session_id not in spk_utt:
        spk_utt[rec.session_id] = []
      spk_utt[rec.session_id].append(rec.utterance_id)

    # Adding [-10:] in order to make sure that the order is preserved correctly
    # in the spk2utt.pl and utt2spk.pl sorting in the utils
    for session_id in spk_utt:
      for utt_id in spk_utt[session_id]:
        _, basename = utt_id.split('-')
        path = os.path.join(self.corpus.corpus_dir, 'data', basename[:2],
                            '%s.flac' % basename)
        stdout.write('%s flac -cds %s |\n' % (utt_id, path))

  def Transcriptions(self):
    """Prints out the transcriptions, used to generate grammar file."""
    for _, rec in self.corpus_info:
      if rec.text:
        stdout.write('%s SENTENCE-END\n' % rec.text.lower())


def Bigrams(inputfile):
  with io.open(inputfile, mode='rt', encoding='utf-8') as text:
    data = ' '.join(line.strip() for line in text)
    data = data.split(' ')

    grams = []
    for i in range(len(data) - 1):
      grams.append((data[i], data[i+1]))

    grams = list(set(grams))
    bigram_dict = {}

    for gram in sorted(grams, key=itemgetter(0)):
      if gram[0] not in bigram_dict:
        bigram_dict[gram[0]] = []
      bigram_dict[gram[0]].append(gram[1])

    for start_gram in sorted(bigram_dict):
      stdout.write('>%s\n' % start_gram)
      for end_gram in sorted(bigram_dict[start_gram]):
        stdout.write(' %s\n' % end_gram)


def main():
  parser = optparse.OptionParser()
  parser.add_option('-d',
                    '--dir',
                    dest='corpusdir',
                    help='Input corpus directory')
  parser.add_option('--alsent',
                    dest='alsent',
                    action='store_false',
                    help='Output for al_sent.txt file')
  parser.add_option('--spk2utt',
                    dest='spk2utt',
                    action='store_false',
                    help='Output for spk2utt file')
  parser.add_option('--spk2gender',
                    dest='spk2gender',
                    action='store_false',
                    help='Output for spk2gender file')
  parser.add_option('--text',
                    dest='text',
                    action='store_false',
                    help='Output for text file')
  parser.add_option('--utt2spk',
                    dest='utt2spk',
                    action='store_false',
                    help='Output for utt2spk file')
  parser.add_option('--wavscp',
                    dest='wavscp',
                    action='store_false',
                    help='Output for wac.scp file')
  parser.add_option('--transcriptions',
                    dest='transcriptions',
                    action='store_false',
                    help='Output only transcriptions')
  parser.add_option('--bigram',
                    dest='bigram',
                    help='Outputs bigrams based on the sentece file')
  parser.add_option('-f',
                    '--file',
                    dest='corpusfile',
                    help='Output training data')
  parser.add_option('--testfile',
                    dest='corpus_test_file',
                    help='Output testfile data')

  options, _ = parser.parse_args()

  corpus = kaldi_util.Corpus(options.corpusdir, options.corpusfile)
  corpus.LoadItems()
  kaldi_converter = CorpusConverter(corpus)

  if options.alsent is not None:
    kaldi_converter.AlSent()

  if options.spk2gender is not None:
    kaldi_converter.Spk2gender()

  if options.spk2utt is not None:
    kaldi_converter.Spk2utt()

  if options.text is not None:
    kaldi_converter.Text()

  if options.utt2spk is not None:
    kaldi_converter.Utt2spk()

  if options.wavscp is not None:
    kaldi_converter.Wavscp()

  if options.transcriptions is not None:
    kaldi_converter.Transcriptions()

  if options.bigram is not None:
    Bigrams(options.bigram)


if __name__ == '__main__':
  main()
