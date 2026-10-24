# Verification and release checklist — 2026-10-24

## Delivered on this branch
- More traditional ivory/gold Quran reading frame, ornamental surah header, ayah bookmark and last-read controls, night theme, 604 verse-start page references and juz/quarter labels.
- Local MP3/M4A user-selected playback in both memorization modes with finite 1–10 repeat playlist; no audio files are redistributed.
- Corrected daily progress when a verse is moved from memorized back to review.
- Flutter CI APK workflow on this branch.

## Important limits
- This is NOT a photographed/facsimile or typographically identical 15-line Madinah Mushaf. Full verses are grouped by their starting page and can overflow the printed page; a licensed line/word layout is still required.
- Local audio is NOT a licensed built-in reciter library and does not sync to individual verses. Users supply their own recordings. No ownership or streaming rights are asserted.
- Tafsir Al-Muyassar, Quran word meanings, adhkar/duas, Sahih al-Bukhari, Sahih Muslim, and Riyad as-Salihin remain source-gated, not delivered as texts. Need explicit edition and distribution permission/rights plus scholarly editorial review.
- This environment can run GitHub CI but cannot physically install the APK on the user's Android phone or verify speaker/notifications/OS-specific storage permissions. No claim of device testing.

## Real-phone acceptance steps
1. Download APK from the latest successful GitHub Actions artifact and extract it.
2. Confirm Android version, install cleanly, launch without network.
3. Check all 114 surahs, first/last ayah, page navigation 1/2/604, juz 1/30 and quarter 1/240.
4. Add bookmark, close/reopen app, confirm it persists. Test backup/restore on a spare device.
5. Open adult and child memorization, choose a locally available MP3/M4A recording, test 1/3/10 repeats, pause/resume/stop and background playback. Confirm source permissions.
6. Test large text, RTL, TalkBack, light/dark, low-memory phone and offline state.
7. Check signing identity and upgrade from previous version before distributing.

## Required follow-on assets
- Source and reuse rights for exact printed Madinah Mushaf page layout (or appropriately licensed original page artwork).
- Named reciters with signed or clearly documented distribution rights for audio playback, downloads and caching.
- Documented legally distributable editions of the six Islamic library sources with references and quality control.

Release status: **development preview only** until CI, real-device checks and content licensing gates pass.
