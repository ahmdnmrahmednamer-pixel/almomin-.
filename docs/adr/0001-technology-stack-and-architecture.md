# ADR-0001: Technology Stack and Architectural Foundations for Al-Momin

## Status
Accepted

## Context
Al-Momin (المؤمن) is an open-source, ad-free Islamic app targeting Arabic-speaking users on Android. The requirements emphasize:
1. Sacred accuracy of the Quran text (dual-source diff, zero runtime mutation).
2. 100% offline-first operation.
3. High performance and low memory consumption on entry-level Android devices.
4. Seamless Arabic RTL user experience with authentic Uthmani & Naskh typography.

## Decisions
1. **Frontend Architecture**: Flutter (Dart 3) targeting Android (Google Play), architected cleanly to keep future iOS/desktop expansion unblocked.
2. **State Management & Navigation**: `flutter_riverpod` + `go_router`.
3. **Database Engine**: `drift` + `sqlite3_flutter_libs` with SQLite FTS5 for instant Arabic text search.
4. **Content Delivery Pipeline**: Build-time pre-compiled, Ed25519-signed SQLite content packs for Tafsir and content libraries.
5. **Localization**: Strict Arabic-only UI (`ar` locale via ARB) with zero hardcoded strings.
6. **Code License**: GPL-3.0-or-later.

## Consequences
- High maintainability and predictable offline behavior.
- Clean separation between immutable Quran core (`quran.db`), user state (`user.db`), and optional modular content packs.
