# Quran memorization audio — rights and implementation gate

The UI stores a desired repeat count (1,2,3,5,7,10). Audio playback is **not active** in this build.

## Why
A public audio URL does not necessarily grant permission to redistribute, download, mirror, or embed the recording in a published child-focused app. The EveryAyah mirror project explicitly warns that rights remain with original reciters and publishers and that EveryAyah publishes no license. Quran Foundation content likewise requires compliance with its developer terms and may require backend authentication.

## Before enabling audio
1. Select a named reciter and obtain a documented license or affirmative authorization for in-app streaming and optional offline download, especially for use in a children's app.
2. Verify verse-to-file correspondence for all 6236 ayahs; reject wrong surah/ayah numbers.
3. Implement clear Play/Stop, repeat count, buffering/error behavior, and stop-on-leave/dispose lifecycle.
4. Keep audio off by default, never autoplay for children, respect Android audio focus, avoid tracking and analytics.
5. Display reciter/source credits and separate audio rights from Tanzil text rights.
6. Add device tests on slow networks and airplane mode; ensure app still functions offline without recordings.
7. Only then add a player dependency and URLs for the approved source.

## Daily learning feature currently implemented
Daily goal choices, a per-day completion set, per-surah progress, manual mastered/review flags, repeat preference. The manual self-review function cannot certify correctness of recitation.
