#!/usr/bin/env python3
import json, pathlib, hashlib
from collections import Counter
root=pathlib.Path(__file__).resolve().parents[1]
p=root/"assets/content/quran/quran.json"
raw=root/"assets/content/quran/quran-uthmani.txt"
if not p.exists() or not raw.exists():
    raise SystemExit("Missing source Quran bundle; build blocked")
d=json.loads(p.read_text(encoding="utf-8"))
verses=d.get("verses",[])
expected=[7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6]
if d.get("source")!="Tanzil Project" or d.get("surah_count")!=114 or d.get("verse_count")!=6236 or len(verses)!=6236:
    raise SystemExit("Invalid Quran metadata")
if hashlib.sha256(raw.read_bytes()).hexdigest()!=d.get("sha256_raw"):
    raise SystemExit("Raw source checksum mismatch")
rows=[]
for line in raw.read_text(encoding="utf-8-sig").splitlines():
    if not line or line.startswith("#"):continue
    parts=line.split("|",2)
    if len(parts)!=3:raise SystemExit("Invalid source line")
    rows.append((int(parts[0]),int(parts[1]),parts[2]))
if len(rows)!=6236:raise SystemExit("Invalid raw source length")
for i,(s,a,t) in enumerate(rows):
    v=verses[i]
    if (v.get("surahId"),v.get("ayahNumber"),v.get("textUthmani"))!=(s,a,t):
        raise SystemExit("Text differs from downloaded raw source")
for s in range(1,115):
    if [a for x,a,t in rows if x==s]!=list(range(1,expected[s-1]+1)):
        raise SystemExit("Surah numbering/count mismatch")
if "Tanzil" not in d.get("text_notice",""):
    raise SystemExit("Missing attribution")
print("Verified: 114 surahs, 6236 verses, raw text preserved, source checksum matches.")
