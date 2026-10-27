# ADR-0002: Quran Core Reader, Canonical Metadata, and Search Indexing

## Status
Accepted

## Context
Milestone M1 delivers the core Quran viewing, indexing, and search capabilities. Requirements dictate:
1. Canonical structural integrity: exactly 114 Surahs, 6236 Ayahs, 604 Pages, 30 Juz.
2. Basmala rendered as an independent decorative header, not counted as an ayah except for Al-Fatihah (1:1), and omitted completely for Surah 9 (At-Tawbah).
3. Ayah sharing/copying must export canonical text with surah/ayah citations, never font glyph codes.
4. Fast offline search combining Arabic normalization (Appendix A) and SQLite FTS5.

## Decisions
1. **Metadata Architecture**: Bundled JSON datasets (`surahs.json` and `juz.json`) paired with SQLite `quran.db` for instant offline boot and high-efficiency querying.
2. **Reading Flow**: `SurahReaderScreen` text-mode with dynamic font scaling (18–30sp), ayah end ornaments `﴿١﴾`, and bottom-sheet interactive actions.
3. **Interactive Actions**: `AyahActionSheet` provides unified access to recitation playback, tafsir viewer, clipboard copying with citation, and local bookmarking.
4. **Search Experience**: `QuranSearchScreen` supports real-time search across surah names and ayah references with normalized query matching.

## Consequences
- Complete offline availability of all 114 Surahs and 30 Juz.
- Zero runtime mutation of canonical Quran texts.
- All integrity tests pass automated CI gates.
