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

"""Utilities for working with open-source ASR speech corpora."""

import collections
import io
import re

FILENAME_RE = re.compile(r'^[a-f0-9]{10}.(flac)$')
UTTERANCE_ID_RE = re.compile(r'^[a-f0-9]{10}$')
SESSION_ID_RE = re.compile(r'^[a-f0-9]{5}$')

stdin = io.open(0, mode='rt', encoding='utf-8', closefd=False)
stdout = io.open(1, mode='wt', encoding='utf-8', closefd=False)
stderr = io.open(2, mode='wt', encoding='utf-8', closefd=False)


def SessionIdFromFilename(filename):
  match = FILENAME_RE.match(filename)
  assert match is not None
  return match.group(1)


Recording = collections.namedtuple(
    'Recording', [
        'utterance_id',
        'session_id',
        'text',
        'gender',
        ])


def ReadInfo(reader):
  """Parses a Google corpus info file (11-column TSV)."""
  for line in reader:
    line = line.rstrip('\n')
    fields = line.split('\t')
    assert len(fields) == 3
    assert UTTERANCE_ID_RE.match(fields[0]) is not None
    assert SESSION_ID_RE.match(fields[1]) is not None
    fields.append('female')
    fields[0] = '%s-%s' % (fields[1], fields[0])
    yield Recording._make(fields)


def ParseInfoFile(path):
  with io.open(path, mode='rt', encoding='utf-8') as reader:
    return dict((rec.utterance_id, rec) for rec in ReadInfo(reader))


class Corpus(object):
  """Information about an ASR corpus."""

  def __init__(self, corpus_dir, corpus_file):
    self.corpus_dir = corpus_dir
    self.corpus_file = corpus_file
    self.corpus_info = {}

  def LoadItems(self):
    self.corpus_info = ParseInfoFile(self.corpus_file)

  def AddItem(self, utterance_id, record):
    if utterance_id not in self.corpus_info:
      self.corpus_info[utterance_id] = record

  def RemoveItem(self, utterance_id):
    if utterance_id in self.corpus_info:
      del self.corpus_info[utterance_id]

  def CleanUp(self):
    self.corpus_info = {}
