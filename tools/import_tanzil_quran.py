#!/usr/bin/env python3
"""Import Tanzil Uthmani v1.1 without changing verse text."""
import datetime
import hashlib
import json
import pathlib
import urllib.parse
import urllib.request
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/content/quran/quran.json"
RAW = ROOT / "assets/content/quran/quran-uthmani.txt"
URL = "https://tanzil.net/pub/download/index.php"
EXPECTED = [7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6]
NOTICE = """Tanzil Quran Text
Copyright (C) 2007-2021 Tanzil Project
License: Creative Commons Attribution 3.0

This copy of the Quran text is carefully produced, highly verified and continuously monitored by a group of specialists in Tanzil Project.

TERMS OF USE:
- Permission is granted to copy and distribute verbatim copies of this text, but CHANGING IT IS NOT ALLOWED.
- This Quran text can be used in any website or application, provided that its source (Tanzil Project) is clearly indicated, and a link is made to tanzil.net to enable users to keep track of changes.
- This copyright notice shall be included in all verbatim copies of the text, and shall be reproduced appropriately in all files derived from or containing substantial portion of this text.
"""
def main():
    payload = urllib.parse.urlencode({
        "quranType":"uthmani", "outType":"txt-2", "agree":"true",
        "marks":"true", "sajdah":"true", "tatweel":"true"
    }).encode()
    request = urllib.request.Request(URL, data=payload, headers={
        "User-Agent":"NoorQuran/0.2 (Quran data importer)",
        "Content-Type":"application/x-www-form-urlencoded"
    }, method="POST")
    with urllib.request.urlopen(request, timeout=90) as response:
        raw = response.read()
    if len(raw) < 100000 or len(raw) > 10000000:
        raise SystemExit("Unexpected source response size; aborting")
    text = raw.decode("utf-8-sig")
    verses = []
    for line in text.splitlines():
        if not line or line.startswith("#"):
            continue
        fields = line.split("|", 2)
        if len(fields) != 3 or not fields[0].isdigit() or not fields[1].isdigit():
            raise SystemExit("Unexpected source line format; aborting")
        s, a, t = int(fields[0]), int(fields[1]), fields[2]
        if not t.strip():
            raise SystemExit("Blank verse; aborting")
        verses.append({"surahId":s, "ayahNumber":a, "textUthmani":t})
    if len(verses) != 6236:
        raise SystemExit("Expected 6236 verses, received "+str(len(verses)))
    counts = Counter(v["surahId"] for v in verses)
    if len(counts) != 114:
        raise SystemExit("Expected 114 surahs")
    for s in range(1,115):
        if counts[s] != EXPECTED[s-1]:
            raise SystemExit("Surah count mismatch: "+str(s))
        numbers = [v["ayahNumber"] for v in verses if v["surahId"] == s]
        if numbers != list(range(1,EXPECTED[s-1]+1)):
            raise SystemExit("Surah numbering mismatch: "+str(s))
    sha = hashlib.sha256(raw).hexdigest()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    RAW.write_bytes(raw)
    OUT.write_text(json.dumps({
        "source":"Tanzil Project", "source_url":"https://tanzil.net/",
        "license":"Creative Commons Attribution 3.0",
        "version":"Uthmani v1.1", "sha256_raw":sha,
        "verified_at":datetime.datetime.now(datetime.timezone.utc).date().isoformat(),
        "surah_count":114, "verse_count":6236,
        "text_notice":NOTICE, "verses":verses
    }, ensure_ascii=False, separators=(",",":")),encoding="utf-8")
    print("Imported 6236 verses; source SHA256:",sha)
if __name__=="__main__":
    main()
