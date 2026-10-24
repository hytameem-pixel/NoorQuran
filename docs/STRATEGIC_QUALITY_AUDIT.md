# NoorQuran — strategic quality audit and 10/10 acceptance gates

Status: work in progress. A successful CI build is not a 10/10 quality certification.

## User requests consolidated
1. Independent original dark brown/gold Quran-inspired icon and identity (do not copy third-party artwork).
2. Authentic Uthmani mushaf with 604 page layout, decorative verse markers, surah/juz/hizb/quarter indices, accurate metadata, Makki/Madani and page references.
3. Bookmark current position, jump to saved bookmark, multiple bookmarks, last-read, powerful Arabic search, sharing with verse citation, light/dark reading, readable fonts and accessibility.
4. Adult and child memorization, per-child local profiles, daily plans, revision, repetition audio and optional licensed offline audio.
5. Al-Tafsir Al-Muyassar, Quranic word meanings, authenticated adhkar/duas, Sahih al-Bukhari, Sahih Muslim, Riyad as-Salihin.
6. Free charitable project dedication, offline core reading, privacy and secure Android updates.

## Critical risk register
| Risk | Severity | Mitigation / acceptance |
|---|---|---|
| Incorrect Quran verse or corrupted bundle | Critical | Source provenance, counts, sequence integrity, checksum, specialist proofing |
| Invented/incorrect tafsir or hadith | Critical | Only reviewed editions with explicit attribution, verse/hadith IDs and license |
| Incorrect page/juz mapping | Critical | Verified 604-page edition metadata, regression tests on boundaries |
| Audio without distribution rights | Critical | Written rights/permission for in-app stream/offline, source and reciter credits |
| Children data and profiling | High | No personal identifiers, guardian oversight, local-only storage, no tracking |
| Loss of progress after reinstall | High | Backup/restore, documented schema migration, verified integrity |
| Android signing/upgrade failures | High | Stable application ID, managed release keystore, test in-place upgrades |
| Reader performance on low-memory phones | High | Virtualized list, caching, memory/performance benchmarks |
| Accessibility deficiencies | High | TalkBack, large text, contrast, touch targets, RTL correctness |
| Third-party image/icon copying | High | Original icon/ornament, documented asset rights |

## Implemented in this hardening branch
- Offline copy/paste backup and restore with strict schema, allowlist, type and range checks, user confirmation. No cloud service or personal data.
- Runtime verification of surah/ayah sequence to reject missing or duplicate verses before rendering.
- Visible entry to backup on home screen.
- CI Android build for this branch.

## Not implemented yet (must not be claimed)
- Pixel-perfect page layout, authentic page/quarter/hizb mapping, or original icon asset.
- Licensed per-ayah audio playback/repeat; settings alone do not play audio.
- Verified full texts of tafsir, word meanings, adhkar, Bukhari, Muslim or Riyad as-Salihin.
- Multi-child profiles, structured spaced repetition, automated tajweed grading.
- Production signing and device-based installation/upgrade validation.
- Privacy review of Android backup, long-term storage encryption, and user research.

## Definition of 10/10
All critical/high items have independent review; every feature works on supported Android devices offline where promised; no content-rights gaps; test suite and build green; at least one expert Quran proofreader signs off; app usability/accessibility testing passes; upgrade retains bookmarks and memorization; a guardian validates child flow. Rating is withheld until verified.

## Backup caveats
Clipboard export is a manual local workaround, not encrypted backup. Users must store it privately. Restoring requires app restart; saved daily completion records are included. Restore validates syntax and ranges but does not replace professional backup security, encryption or multi-profile migration.
