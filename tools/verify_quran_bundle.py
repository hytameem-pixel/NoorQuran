#!/usr/bin/env python3
import json
from pathlib import Path
p = Path('assets/content/quran/quran.json')
if not p.exists():
    raise SystemExit('Missing verified Quran bundle: release blocked')
d = json.loads(p.read_text(encoding='utf-8'))
verses = d.get('verses', [])
if d.get('surah_count') != 114 or len(verses) != 6236:
    raise SystemExit('Quran integrity failure: release blocked')
keys = set()
for v in verses:
    s, a = v.get('surahId'), v.get('ayahNumber')
    if not isinstance(s,int) or not 1 <= s <= 114 or not isinstance(a,int) or a < 1 or not str(v.get('textUthmani','')).strip() or (s,a) in keys:
        raise SystemExit('Invalid Quran verse: release blocked')
    keys.add((s,a))
print('Basic Quran content validation passed; source/license validation must also be completed before publication.')
