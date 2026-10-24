# Quran source and license

Source: https://tanzil.net/download/ — Uthmani v1.1.

The official text is downloaded by POST, stored verbatim as `quran-uthmani.txt`, and parsed into `quran.json` without changing verse text. The verifier compares every JSON verse against the downloaded source bytes and checks the source SHA-256, all 114 surahs, 6236 verses and sequential ayah numbering.

**Important:** This is source-integrity validation, not independent scholarly verification or comparison to a trusted pinned hash. Review Tanzil licensing and publication notice before release. The application UI must show attribution and a working link to https://tanzil.net/.

Run GitHub Actions workflow **Import verified Tanzil Quran** manually, then inspect its result. This workflow needs Actions write permission to commit content.
