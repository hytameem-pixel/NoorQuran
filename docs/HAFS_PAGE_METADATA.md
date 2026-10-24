# Hafs 604-page navigation — source and scope

Source: https://github.com/quran-center/quran-meta
Source file: src/lists/HafsLists.ts (PageList, JuzList, HizbQuarterList)
License: MIT, © original contributors; preserve source attribution and repository LICENSE terms.
The app bundles page start verse IDs (604), juz start IDs (30), and hizb-quarter start IDs (240), using the Hafs narration.

Important distinction:
- The new UI groups complete verses by the **page on which the verse starts**. It offers reliable page-number lookup, page navigation, juz labels and bookmark buttons.
- It **does not** reproduce the original 15-line Madinah typesetting. Verses that cross physical page boundaries are displayed in full on the page where they start. Do not market it as a facsimile or exact printed-page layout.
- True facsimile requires properly licensed page artwork or line/word layout and verified page-boundary splitting; text and layout must be reviewed by a Quran specialist.
- The original Quran text remains from Tanzil, and is not replaced with metadata-source text.
- Page data is for Hafs only; other recitations require distinct verified maps.
