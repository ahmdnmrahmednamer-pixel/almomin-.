# Noor Noor Al-Momin (نور المؤمن) — Full Engineering Specification

> Status: **Draft v1.0** · Platform: **Android (Google Play)** · UI language: **Arabic only (RTL)** · Documentation/code language: **English**
> Project type: **Sadaqa Jariya (charitable endowment), free, no ads, no tracking, open source**

---

## 0. How to Use This Document

This file is the single source of truth for building the app. It is written so that:

- A developer or an AI coding assistant can implement it milestone by milestone.
- A non-technical contributor (content reviewer, designer, scholar, tester) can understand what is expected of them.

**Conventions**

- **MUST / MUST NOT** = mandatory. **SHOULD** = strongly recommended. **MAY** = optional.
- IDs: `FR-*` functional requirement, `NFR-*` non-functional, `D-*` decision, `R-*` risk, `S-*` spike (time-boxed research), `T-*` task.
- Every statement marked **[VERIFY]** is an external fact (license, API, store policy, library version) that changes over time and MUST be re-checked before implementation.
- User-facing text is Arabic. Code, comments, commit messages, issues, and docs are English.

---

## 1. Product Overview

### 1.1 Vision
A comprehensive, trustworthy, ad-free Islamic app in Arabic: the Quran with many reciters, tafsir, an Islamic library, daily worship tools, and learning features — built as a sadaqa jariya whose reward continues for everyone who contributed.

### 1.2 Product Principles
1. **Accuracy of the Quran text is sacred.** No code path may alter, reorder, or "clean" Quran text (see §8.3).
2. **Offline first.** Everything essential works with no internet after content is on the device.
3. **No ads, no analytics SDKs, no data selling, no account required.**
4. **Light and fast on low-end Android devices** (common in the target market).
5. **Calm UX.** No streak pressure, no guilt notifications, no gamification that creates riya' (showing off).
6. **Scholarly review is a release gate** for all religious content.
7. **Transparent and open**: source code public, content sources and reviewers credited in the app.

### 1.3 Non-Goals (v1.x)
- iOS, web, desktop (architecture must not prevent them later).
- User accounts, cloud sync, social features, user-generated content (planned for v2.0).
- Riwayat other than Hafs ʿan ʿĀṣim (planned later).
- Fatwa Q&A, live streaming, e-commerce, donations handled by the app itself.

### 1.4 Target Users
Arabic-speaking Muslims, primarily in Egypt and the Arab world; ages from children (guided) to elderly (large text). Many use mid/low-range Android phones with limited storage and unstable internet.

---

## 2. Decisions Log

### 2.1 Resolved Decisions

| ID | Decision | Source |
|----|----------|--------|
| D-01 | Platform: **Android only** initially, Google Play. | Owner |
| D-02 | UI is **Arabic only**; still use localization files (single `ar` locale) so no string is hard-coded. | Owner |
| D-03 | **No Google accounts / no sync in v1.** All user data is local. | Owner |
| D-04 | **Hafs ʿan ʿĀṣim only** in v1; data model must support multiple riwayat later. | Owner |
| D-05 | **~35 reciters** at launch (shortlist in Appendix B). | Owner |
| D-06 | Tafsir set: Al-Muyassar, As-Saʿdi, Ibn Kathir, At-Tabari, Al-Qurtubi (+ Hadith books in the library release). | Owner |
| D-07 | Mushaf rendering: **both** Madinah page-layout mode and Uthmani text (ayah-list) mode. | Owner |
| D-08 | Code is **open source**. | Owner |
| D-09 | Team: owner + friends from different specializations (not all developers). | Owner |
| D-10 | Tech stack: **Flutter (Dart)**, offline-first, SQLite. Rationale in §5.1. | Engineering |
| D-11 | I'rab data: Quranic Arabic Corpus (structured) + classical i'rab texts (§6). | Engineering |

### 2.2 Open Decisions (defaults apply until the owner overrides)

| ID | Question | Default used in this spec |
|----|----------|---------------------------|
| D-12 | Monthly budget | **$0–20/month**: GitHub + Cloudflare free tiers, one-time Play developer fee, optional domain. |
| D-13 | Release scope | **Staged releases** (§3). v1.0 = MVP; everything requested is planned, not dropped. |
| D-14 | Minimum Android | **minSdk 23 (Android 6.0)** or the Flutter-stable minimum if higher. |
| D-15 | Visual identity | Proposed in §9 (calm green/gold palette, Uthmani + Naskh typography). |
| D-16 | App name / package ID | Working name **"المؤمن"**; placeholder package `org.almomin.app`. **Package ID cannot change after first Play upload — decide before M5.** Check name availability on Play and trademark conflicts. |
| D-17 | Sharia review board | **Unassigned. BLOCKING for public release** (R-01). |
| D-18 | Code license | **GPL-3.0-or-later** (see §15.1 for rationale and the iOS caveat). |
| D-19 | Meaning of "Translation" feature | Since UI is Arabic-only: treat as **optional downloadable translation-of-meanings packs** (e.g. English, French) shipped after v1.0, plus **word meanings (ghareeb al-Quran) in Arabic**. Confirm with owner. |
| D-20 | Play developer account type | **Organization account preferred** (shared ownership, continuity for a sadaqa jariya). **[VERIFY]** current Play requirements for new personal accounts (closed-testing requirement). |

---

## 3. Scope and Release Plan

| Release | Theme | Contents |
|---------|-------|----------|
| **v0.x** | Internal alpha | Milestones M0–M4 builds, testers only. |
| **v1.0 (MVP)** | Core worship | Mushaf (page + text modes), 35 reciters (stream + download + background), tafsir packs (5), Quran search, bookmarks/favorites/last-read, prayer times + adhan + qibla, Hijri/Gregorian calendar, adhkar (text) + tasbih, settings, full offline. |
| **v1.1** | Understanding | I'rab, asbab al-nuzul, word meanings, ayah-level actions polish, adhkar audio, share ayah as image. |
| **v1.2** | Habit & memorization | Khatma plans, reading progress, memorization mode (repeat, hide words, spaced review), tajweed coloring. |
| **v1.3** | Library | Islamic library reader, hadith (six books + grading), stories of the prophets and Quran stories, zakat calculator, home-screen widgets. |
| **v1.4** | Reach | Topic browsing, kids section, Wear OS / Android Auto (optional), translation-of-meanings packs. |
| **v2.0** | Community | Optional accounts, sync, group khatma, dua-request wall (needs backend + moderation). Additional riwayat may ship earlier as content packs. |

---

## 4. Functional Requirements

### 4.1 Mushaf (Quran Reader) — `FR-MSH`

- **FR-MSH-001** Two reading modes, switchable instantly, preserving position:
  - **Page mode:** Madinah Mushaf layout, 604 pages, exact line breaks.
  - **Text mode:** continuous list of ayahs, Uthmani script, adjustable size, optional per-ayah action bar.
- **FR-MSH-002** Page navigation follows natural RTL book direction (swipe from left to right goes to the next page).
- **FR-MSH-003** Index screen with tabs: Surah, Juz, Hizb/Rub, Page, Bookmarks. Surah list shows name, ayah count, Makki/Madani.
- **FR-MSH-004** Last-read position saved automatically (page + ayah) and offered on the home screen.
- **FR-MSH-005** Tap an ayah → **Ayah Action Sheet**: play from here, tafsir, (i'rab, asbab, word meanings in v1.1), bookmark, favorite, copy, share, add note (v1.2+).
- **FR-MSH-006** Long-press/drag selection of a range of ayahs for copy, share, and repeat-play.
- **FR-MSH-007** Reading settings: font size (5+ steps, up to very large), theme (light, sepia, dark, true-black), keep screen on, tashkeel always on, Arabic-Indic or Western numerals (default Arabic-Indic).
- **FR-MSH-008** Surah headers and basmala rendered as **separate decorative elements**, never counted as ayahs (except Al-Fatiha 1:1). Surah At-Tawbah has no basmala.
- **FR-MSH-009** Sajdah marks (15 positions), juz/hizb/rub markers, and ayah-end markers shown per the Madinah Mushaf convention.
- **FR-MSH-010** Copy/share MUST output canonical Quran text from the database, **never** glyph codes from page fonts (§11.4).
- **Acceptance:** all 6,236 ayahs render; page 1–604 match the printed Madinah Mushaf boundaries; no clipped text at 200% system font scale; switching mode keeps the same ayah visible.

### 4.2 Audio Player — `FR-AUD`

- **FR-AUD-001** 35 reciters at v1.0 (Appendix B), all Hafs. Each has Arabic name, optional style tag (مرتل / مجود / المعلم).
- **FR-AUD-002** Play from: a surah, an ayah, a range, a page, a juz.
- **FR-AUD-003** **Stream** over the internet or **play from downloaded files** — transparently chosen (downloaded copy wins).
- **FR-AUD-004** **Download** per surah per reciter; also "download whole reciter" with size estimate and Wi-Fi-only option. Resume after interruption. Pause/cancel/delete. Storage manager screen.
- **FR-AUD-005** Background playback with media notification, lock-screen controls, Bluetooth/headset buttons, audio focus handling (pause on call, duck for navigation voice).
- **FR-AUD-006** Controls: play/pause, next/previous surah or ayah, seek, speed (0.75×–1.5×), **sleep timer** (15/30/45/60 min, end of surah, custom) with gradual fade-out.
- **FR-AUD-007** **Current-ayah highlight** while playing (both mushaf modes), with auto-scroll/auto page-turn that can be disabled.
- **FR-AUD-008** Repeat controls: repeat ayah N times, repeat range N times, repeat surah, continue to next surah.
- **FR-AUD-009** Mini-player persistent across screens; full player screen.
- **FR-AUD-010** Resume last playback (reciter, surah, position) on app start (not auto-play).
- **FR-AUD-011** Reciter capabilities are data-driven: `has_ayah_files`, `has_surah_file`, `has_timings` (§5.6). Highlighting uses ayah-file playlists or timing segments; if neither exists for a reciter, highlight is disabled for that reciter only (UI states this politely).
- **Acceptance:** playback continues with screen off for 60+ minutes on a low-end device; killing the UI does not kill playback; downloads survive app restart and network loss; deleting a download frees the space shown in storage manager.

### 4.3 Tafsir — `FR-TAF`

- **FR-TAF-001** Tafsir shown for an ayah or ayah group (many classical tafsirs group ayahs; entry has `ayah_from..ayah_to`).
- **FR-TAF-002** Five tafsirs at v1.0 as **downloadable packs** (§5.5): Al-Muyassar, As-Saʿdi, Ibn Kathir, At-Tabari, Al-Qurtubi. Muyassar and As-Saʿdi are recommended defaults for general readers.
- **FR-TAF-003** Tafsir viewer: bottom sheet (quick) and full screen (deep). Switch tafsir without losing place. Previous/next ayah navigation.
- **FR-TAF-004** Quoted ayahs inside tafsir text are rendered with the Quran font and are tappable (v1.1: jump).
- **FR-TAF-005** Font size shared with reading settings; copy/share with attribution line (tafsir name + ayah reference).
- **FR-TAF-006** Pack manager: download/update/delete with size shown. Muyassar MAY be bundled with the app for first-run usefulness.

### 4.4 Quran Search — `FR-SRC`

- **FR-SRC-001** Search ayahs by Arabic text **ignoring tashkeel and orthographic variants** (normalization spec: Appendix A).
- **FR-SRC-002** Search by reference: `2:255`, `البقرة ٢٥٥`, `البقرة 255`, surah names, and a small alias table (e.g. آية الكرسي → 2:255).
- **FR-SRC-003** Results show surah name, ayah number, matched words highlighted, tap to open at that ayah.
- **FR-SRC-004** Search history (local, clearable). Debounced input (≤150 ms perceived latency for results).
- **FR-SRC-005** (v1.1+) Search inside installed tafsir packs; (v1.3) inside library books.

### 4.5 Bookmarks, Favorites, Notes — `FR-BKM`

- **FR-BKM-001** Bookmark an ayah or a page, with optional color and label. Favorites are quick-star on ayahs, surahs, reciters, books, adhkar.
- **FR-BKM-002** Bookmarks screen: grouped by type, sortable, searchable, swipe to delete with undo.
- **FR-BKM-003** **Local backup/restore**: export user data to a single file (JSON) via the Android share sheet / file picker; import with merge or replace. This replaces cloud sync in v1.
- **FR-BKM-004** (v1.2) Free-text notes on ayahs.

### 4.6 Prayer Times, Adhan, Qibla — `FR-PRY`

- **FR-PRY-001** Compute prayer times **offline** from location + method. Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha; also Duha start and last third of the night (displayed info).
- **FR-PRY-002** Methods: Egyptian General Authority of Survey (Fajr 19.5°, Isha 17.5°) as **default for Egypt**, Umm al-Qura, Muslim World League, Karachi, ISNA, Kuwait, Qatar, Dubai/Gulf, custom angles. Asr juristic method (Shafiʿi/Hanafi). Per-prayer manual offset (±30 min). **[VERIFY]** each method's parameters against the chosen library's documentation.
- **FR-PRY-003** Location: one-time coarse GPS fetch with explicit permission; **manual city selection** from a bundled offline city list; manual coordinates. App must be fully usable if location permission is denied.
- **FR-PRY-004** Time zone and DST come from the device/tz database, **never a fixed offset** (Egypt reinstated DST in 2023; rules can change).
- **FR-PRY-005** Notifications per prayer with options: silent notification, default sound, or Adhan sound (choice of ≥3 adhans), optional pre-prayer reminder (5–30 min), Fajr special setting. Each prayer can be toggled independently.
- **FR-PRY-006** Notifications MUST be rescheduled after: device reboot, time/timezone change, location change, app update. Schedule rolling window (e.g. next 7 days) and refresh whenever the app runs.
- **FR-PRY-007** Home screen shows next prayer + countdown. (v1.3: home-screen widget.)
- **FR-PRY-008** Qibla compass using location + magnetometer, with accuracy warning (calibration hint), and a static bearing-in-degrees fallback when no compass sensor exists.
- **FR-PRY-009** (v1.2) Prayer tracker: mark prayers, sunnah rawatib, optional; gentle, never punitive.
- **Acceptance:** computed times for Cairo match the Egyptian Survey authority timetable within ±1 minute on 10 sample dates (including a DST-transition week); notification delivered within ±60 s on Android 8–15 devices with default battery settings after the user completes the exact-alarm/battery guidance flow.

### 4.7 Calendar — `FR-CAL`

- **FR-CAL-001** Hijri ↔ Gregorian calendar with month view and date converter.
- **FR-CAL-002** Hijri date shown on home; **user adjustment ±2 days** (sighting vs. astronomical differences, e.g. Egypt's Dar al-Ifta announcements).
- **FR-CAL-003** Islamic occasions: Ramadan, Eids, Day of ʿArafah, Ashura (9–10 Muharram), White Days (13–15), Mondays/Thursdays, first 10 of Dhul-Hijjah, Laylat al-Qadr nights. Optional reminders (local notifications).
- **FR-CAL-004** (v1.2) Ramadan mode: imsakiyyah table, fasting tracker.

### 4.8 Adhkar & Tasbih — `FR-ADH`

- **FR-ADH-001** Categories: morning, evening, after prayer, sleep, waking, home, food, travel, etc. (based on Hisn al-Muslim structure).
- **FR-ADH-002** Each dhikr: Arabic text with tashkeel, repeat count, source (Quran/hadith reference), virtue note where authentic.
- **FR-ADH-003** Counter per dhikr with haptic feedback (toggle), progress ring, auto-advance, reset.
- **FR-ADH-004** Morning/evening reminders tied to prayer times (e.g. after Fajr/Asr) or custom time. Notification text is short and non-intrusive.
- **FR-ADH-005** (v1.1) Audio for adhkar: in-house recorded or properly licensed; play/pause per dhikr, play-all.
- **FR-ADH-006** Free tasbih: custom phrase, target, history locally; background-safe counting.
- **FR-ADH-007** Duʿā' collections (Quranic/prophetic) as a separate list.

### 4.9 I'rab, Asbab al-Nuzul, Word Meanings — `FR-UND` (v1.1)

- **FR-UND-001** **I'rab** per ayah (grammatical analysis): text i'rab from classical works + (optional) word-level morphology from the Quranic Arabic Corpus. Shown in a tab on the ayah sheet.
- **FR-UND-002** **Asbab al-nuzul** per ayah/range: text, narrator source, authenticity note where available. Ayahs with no authentic reason show nothing (no empty "N/A" clutter).
- **FR-UND-003** **Word meanings (ghareeb)**: tap a word → meaning in Arabic + root. Requires word-level tokens (§7).
- **FR-UND-004** All three are **content packs** with their own license and review record.

### 4.10 Memorization & Khatma — `FR-MEM` (v1.2)

- **FR-MEM-001** Select ayah range → loop playback (repeat each ayah N times, then range M times), choose reciter.
- **FR-MEM-002** Hide mode: hide words progressively (every Nth word, last half, whole ayah) with tap-to-reveal.
- **FR-MEM-003** Review scheduler using a simple **Leitner/spaced-repetition** scheme (intervals 1, 3, 7, 14, 30 days); items rated Easy/Hard/Forgot.
- **FR-MEM-004** Khatma plan: choose duration (30 days, Ramadan, custom) → pages/day = `ceil(604 / days)`; optional alignment to juz; daily reminder; catch-up recalculation if the user falls behind.
- **FR-MEM-005** Progress: pages read, khatmas completed, optional private streak. No leaderboards.

### 4.11 Islamic Library — `FR-LIB` (v1.3)

- **FR-LIB-001** Categories: Tafsir, Hadith, Fiqh, Aqeedah, Seerah, Language, Tazkiyah, Usul. Book cards show title, author, death year (H), size.
- **FR-LIB-002** Books are **downloadable packs** (SQLite) with table of contents → chapters → pages; smooth text reading (not images), adjustable typography, night mode, last-read per book.
- **FR-LIB-003** In-book search and cross-library search (FTS, Appendix A).
- **FR-LIB-004** Highlights (colors), notes, bookmarks, quote-share as image.
- **FR-LIB-005** **Hadith:** six books (Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasa'i, Ibn Majah) with hadith number, chapter, narrator, and **grading (sahih/hasan/daʿif)** with the grading source named. Display a clear note that grading is from the cited scholar.
- **FR-LIB-006** Only books with a verified license/public-domain status enter the catalog (§6).

### 4.12 Stories — `FR-STR` (v1.3)

- **FR-STR-001** Stories of the Prophets and Quranic stories as sectioned articles with inline ayah references (tappable), optional audio narration.
- **FR-STR-002** Authoring rule: Quran and authentic hadith first; no Isra'iliyyat narrations presented as fact; every story reviewed by the Review Board and cites sources. Base text may adapt public-domain classical works (e.g. Ibn Kathir) rewritten in clear modern Arabic.

### 4.12b Tajweed Coloring, Topics, Kids — (v1.2–v1.4)

- **FR-TJW-001** Optional tajweed color layer in the mushaf with a legend; data from a vetted tajweed-annotated text source (§6).
- **FR-TPC-001** Browse Quran by topic (patience, provision, repentance, family…) backed by a curated, reviewed ayah-index.
- **FR-KID-001** Kids section: short surahs with repeat-after-me, simple adhkar, narrated stories, no external links, no data collection (comply with Play **Families Policy** if targeting children **[VERIFY]**).

### 4.13 Zakat Calculator — `FR-ZKT` (v1.3)

- Inputs entered manually (offline): cash, gold grams, silver grams, trade goods, debts due, gold price per gram, silver price per gram.
- Rules: rate 2.5%; nisab = 85 g of gold or 595 g of silver (user picks basis; app explains lower-nisab silver view); one hijri year (hawl) reminder. Output is **advisory**, with an "ask a scholar" note. Inheritance (mawarith) calculator is **out of scope** until a scholar-reviewed algorithm exists.

### 4.14 Settings & Onboarding — `FR-SET`

- **FR-SET-001** First-run: short (≤3 screens) — optional location for prayer times, choose default reciter and calculation method, optional notification permission request (Android 13+). Every step skippable.
- **FR-SET-002** Settings sections: Reading, Audio, Prayer & notifications, Downloads & storage, Appearance, Backup/restore, About.
- **FR-SET-003** **About screen:** app purpose (sadaqa jariya), content sources and licenses, Review Board names/dates, contributors, source-code link, privacy statement, version/build.
- **FR-SET-004** No account, no analytics prompts, no rating nag more than once per 30 days (and only after a successful khatma-type milestone; MAY be omitted entirely).

---

## 5. Technical Architecture

### 5.1 Technology Choice (D-10)

**Flutter (stable channel, Dart 3), Android-first, single codebase.**

Why: one codebase leaves iOS open; strong Arabic/RTL text rendering and custom font support; mature packages for audio, background downloads, notifications; large Quran-app ecosystem to learn from. A native Kotlin + Jetpack Compose app would also be a valid choice; **revisit only if** S-01/S-03 spikes expose blocking limitations.

**Core stack (verify latest stable versions at implementation start — [VERIFY])**

| Concern | Choice |
|---------|--------|
| Language/framework | Dart 3 / Flutter stable |
| State management | `flutter_riverpod` (with code-gen optional) |
| Navigation | `go_router` |
| Local DB | `drift` + `sqlite3_flutter_libs` (bundled SQLite with **FTS5**) |
| Preferences | `shared_preferences` (simple flags) + `settings` table for structured |
| Audio | `just_audio` + `audio_service` (ExoPlayer/Media3 underneath) |
| Downloads | `background_downloader` (resumable, background) |
| HTTP | `dio` (content packs only; no analytics) |
| Notifications | `flutter_local_notifications` + `timezone` + `flutter_timezone` |
| Prayer calc | `adhan_dart` (port of Adhan library) **[VERIFY]** or an in-house port with tests |
| Hijri | `hijri` package or in-house Umm al-Qura tables **[VERIFY]** |
| Location | `geolocator` |
| Compass | `flutter_compass` or `sensors_plus` |
| Permissions | `permission_handler` |
| Models/serialization | `freezed` + `json_serializable` |
| Sharing | `share_plus` |
| Home widget (v1.3) | `home_widget` |
| Lint | `very_good_analysis` (or `flutter_lints` + stricter rules) |
| Tests | `flutter_test`, `mocktail`, `integration_test`, golden tests |

**Rule:** every dependency MUST be justified in an ADR (architecture decision record) if it is not on this list. Prefer fewer, maintained packages. No dependency may add telemetry.

### 5.2 Layered, Feature-First Structure

```
almomin/
├─ app/                          # Flutter application
│  ├─ lib/
│  │  ├─ main.dart
│  │  ├─ app/                    # App widget, router, theme, DI providers
│  │  ├─ core/
│  │  │  ├─ db/                  # drift databases, migrations, FTS setup
│  │  │  ├─ audio/               # audio handler, queue, timing logic
│  │  │  ├─ downloads/           # download manager, pack installer
│  │  │  ├─ notifications/       # channels, scheduler, boot rescheduling
│  │  │  ├─ text/                # arabic_normalizer.dart, number formatting
│  │  │  ├─ packs/               # manifest, signature verify, versioning
│  │  │  ├─ errors/  logging/  utils/
│  │  ├─ features/
│  │  │  ├─ mushaf/  audio/  tafsir/  search/  bookmarks/
│  │  │  ├─ prayer/  qibla/  calendar/  adhkar/  tasbih/
│  │  │  ├─ understanding/       # i'rab, asbab, word meanings (v1.1)
│  │  │  ├─ memorization/  khatma/  library/  stories/  zakat/
│  │  │  └─ settings/  onboarding/  about/
│  │  └─ l10n/ app_ar.arb
│  ├─ assets/ (quran.db, fonts, adhan audio, city list)
│  └─ test/  integration_test/
├─ tools/content_builder/        # Python pipeline that builds & signs content packs
├─ content/                      # source manifests, review records, checksums (NOT raw copyrighted dumps)
├─ docs/                         # this spec, ADRs, design, store listing text
└─ .github/                      # workflows, issue/PR templates, CODEOWNERS
```

Each feature folder: `data/` (data sources, repositories impl, DTOs) · `domain/` (entities, repository interfaces, small use cases) · `presentation/` (screens, widgets, Riverpod notifiers). Pragmatic rule: skip the use-case layer when it would only forward calls.

### 5.3 Databases

- **`quran.db`** (bundled, read-only): surahs, ayahs, words, page/juz/hizb metadata, search-normalized text. Small (low MBs).
- **`user.db`** (read-write, local): bookmarks, favorites, reading position, notes, khatma, memorization items, download records, settings, tracker data. Versioned migrations with tests. **Never** stores secrets; backups are plain JSON export (§4.5).
- **Content packs** (downloaded, read-only SQLite): one file per tafsir/book/i'rab/asbab/etc. Opened separately; no cross-DB foreign keys — link by `(surah, ayah)` or global `ayah_id`.

### 5.4 Source of Truth for Content: Build Time, Not Runtime

The app MUST NOT depend on third-party content APIs at runtime for text. All text content is **pre-built at build time** by `tools/content_builder` into versioned, checksummed, **signed** packs hosted on our own static hosting. Third-party servers are used at runtime **only for audio streaming** (until mirrored, §12).

### 5.5 Content Pack System

Manifest (`manifest.json`, served over HTTPS, signed):

```json
{
  "schema": 1,
  "generated_at": "2026-10-12T00:00:00Z",
  "packs": [
    {
      "id": "tafsir_muyassar",
      "type": "tafsir",
      "title_ar": "التفسير الميسر",
      "version": 3,
      "min_app_build": 10,
      "size_bytes": 4200000,
      "sha256": "<hex>",
      "url": "https://cdn.example.org/packs/tafsir_muyassar_v3.db.zst",
      "license": "see THIRD_PARTY_LICENSES.md#muyassar",
      "reviewed_by": "<reviewer id>",
      "reviewed_at": "2026-10-01"
    }
  ],
  "signature": "<base64 Ed25519 signature of canonical manifest>"
}
```

Rules:
- The app embeds an **Ed25519 public key**; it MUST reject a manifest or pack whose signature/SHA-256 fails (prevents tampering of Quran-related content via CDN compromise).
- Packs are compressed (zstd or gzip), downloaded to app-private storage, verified, then moved into place atomically; partial/failed installs never replace a working pack.
- Pack updates are optional and user-initiated (or Wi-Fi-only auto-update setting, off by default).
- `min_app_build` prevents installing a pack the app can't read.

### 5.6 Audio Architecture

- **Reciter metadata** (build time): `reciters.json` with id, Arabic name, style, base URLs, file naming scheme, bitrate, `has_ayah_files`, `has_surah_file`, `has_timings`.
- **Two playback strategies**
  1. **Ayah-file playlist** (per-ayah MP3s, e.g. EveryAyah-style). Gapless-ish queue; enables exact highlight, per-ayah repeat, memorization. Needs many small requests; download per surah = N files stored in a folder.
  2. **Surah file** (one MP3 per surah, e.g. mp3quran-style). Efficient for long listening and small downloads. Highlight requires **timing segments** (`ayah → start_ms,end_ms`) from a timing dataset **[VERIFY availability per reciter]**. Without timings: no highlight.
- `AudioHandler` (audio_service) owns the queue; UI observes `PlaybackState` + `currentAyah` streams. Highlight is derived from position and timings via binary search.
- Downloaded files live in **app-specific external storage** (no storage permission needed). The Storage screen shows per-reciter size and delete controls. Approximate size: **hundreds of MB per reciter** for full Quran depending on bitrate — show estimates before download.
- Foreground service type for playback MUST be declared (Android 14+) (§11.2).

### 5.7 Mushaf Rendering Architecture

- **Page mode** uses Madinah Mushaf **per-page glyph fonts** (KFGQPC/QPC v1 or v2 style, as used by Quran.com) so each page lays out exactly like the printed mushaf, scales crisply, and avoids shipping 604 images. Data per word: `page`, `line_number`, glyph code. **[VERIFY]** the chosen font set's license terms.
- Alternative if fonts prove too heavy or inaccurate (spike S-01): pre-rendered page images served as on-demand pack (larger, not scalable, no night mode without inversion tricks).
- **Text mode** uses a single Uthmani Hafs font (e.g. KFGQPC Uthmanic Script HAFS) over canonical Uthmani text.
- Page mode glyph text is **not real Unicode Arabic**; therefore accessibility, copy, share, and search MUST use canonical text from `quran.db` (§11.4).
- Font bundle strategy decided by S-01: **bundle** page fonts if base install stays under budget (NFR-PRF-004); otherwise an "Mushaf pages" pack downloaded on first run with a clear one-time prompt, while text mode works immediately.

### 5.8 Search Architecture

- `ayah.text_search` stores **normalized** text (Appendix A). FTS5 virtual table with `unicode61` tokenizer, prefix indexes. Query text is normalized with the **same function** (single shared implementation + shared test vectors, also used by the content builder to avoid drift).
- Reference parser (regex + surah-name alias table incl. common spellings) runs before FTS.

### 5.9 Notifications & Prayer Scheduling

- Local notifications only (no FCM, no server).
- **One notification channel per adhan sound** (Android freezes channel sound after creation; use versioned channel IDs when changing sounds).
- Schedule the next N days of prayers using exact alarms where allowed (see §11.2), rescheduled by: app start, boot receiver, timezone/time change broadcast, settings change, daily background refresh (WorkManager/AlarmManager-based).
- In-app "Reliability checklist" screen: exact-alarm permission, notification permission, battery-optimization exemption guidance with OEM-specific hints (Xiaomi, Oppo/Realme, Vivo, Samsung, Huawei, Infinix/Tecno — popular in the target market).

### 5.10 Error Handling and Logging

- Typed failures (`NetworkFailure`, `StorageFailure`, `IntegrityFailure`, `PermissionFailure`) mapped to polite Arabic messages with retry actions.
- Logging is **local, in-memory ring buffer**, optionally exported by the user from Settings ("Share diagnostic log") — never uploaded automatically. No PII in logs.

---

## 6. Data Sources and Licensing Matrix

> Legal status changes. **Every row is [VERIFY]** — before ingesting any source, record its license text/URL and permission emails in `content/sources/<source>.md`, add it to `THIRD_PARTY_LICENSES.md`, and get owner sign-off. When a license is unclear, **ask the rights holder in writing** or choose another source. Do not rely on "it's freely available online."

| Need | Candidate sources | Notes / constraints |
|------|-------------------|---------------------|
| Quran text (Uthmani, Hafs) | **Tanzil** project; **King Fahd Glorious Quran Printing Complex** (KFGQPC) text/fonts; **Quranic Universal Library (QUL, by Tarteel)** exports | Tanzil's terms require text **unmodified** and attribution (typically CC BY-ND). Keep text byte-identical; do transformations only into *separate* derived columns. |
| Madinah page layout + glyph fonts | KFGQPC/QPC fonts via Quran Foundation/QUL | Verify redistribution terms; never modify glyph fonts. |
| Word-by-word (tokens, meanings, glyph positions) | QUL / Quran Foundation datasets | Needed for word meanings, memorization hide-mode, glyph rendering. |
| Audio — full-surah files | **mp3quran.net** (reciter catalog + server URLs) | Request **written permission** for in-app streaming and mirroring/downloading. |
| Audio — per-ayah files | **EveryAyah.com** | Same: permission + attribution; check per-reciter terms. |
| Audio timing segments | Quran Foundation / QUL audio segment datasets | Coverage varies by reciter. |
| Tafsir | Al-Muyassar (KFGQPC), As-Saʿdi, Ibn Kathir, At-Tabari, Al-Qurtubi — via QUL / Quran Foundation tafsir datasets or open text repositories | Classical authors are public domain; **editions/tahqiq and digital encodings may be licensed**. Record edition used. |
| **I'rab (structured)** | **Quranic Arabic Corpus** (corpus.quran.com): morphology + syntactic treebank, word-level | Licensed under GPL (verify version) → another reason D-18 defaults to GPL-3.0. Source is English-labeled; build Arabic grammatical-term mapping table reviewed by an Arabic grammarian. |
| **I'rab (textual)** | Classical i'rab works in the public domain: **Al-Nahhas** (إعراب القرآن), **Al-ʿUkbari** (التبيان في إعراب القرآن), **Makki ibn Abi Talib** (مشكل إعراب القرآن), **As-Samin al-Halabi** (الدر المصون) | Sources: Shamela/OpenITI/Turath text corpora — **[VERIFY]** their licenses; modern works (e.g. Darwish, Safi) are **copyrighted — do not ingest without permission**. Requires mapping each passage to ayah ranges (semi-automatic + review). |
| Asbab al-nuzul | **Al-Wahidi** (أسباب النزول), **As-Suyuti** (لباب النقول) — classical, public domain texts | Mapping to ayahs + authenticity grading note by reviewer. Modern grading works (e.g. Al-Wadiʿi) copyrighted. |
| Adhkar | Hisn al-Muslim (Sa'id al-Qahtani) data repositories, plus Quran/hadith verification against hadith books | **Verify license of the specific dataset**; Hisn al-Muslim text is widely distributed but confirm. Reviewer verifies every text and source reference. |
| Hadith (six books + grading) | Open hadith datasets (JSON editions on GitHub), Dorar.net for gradings | Grading datasets are often copyrighted or restricted — **get permission** or limit to gradings included in the books themselves (e.g. Tirmidhi's). |
| Library books | Public-domain classics; **Hindawi** (CC-licensed modern titles, check each); Arabic Wikisource; OpenITI | Per-book license tracking mandatory. |
| Tajweed-annotated text | Quran.com / QUL tajweed text/fonts | Verify license. |
| Prophets' stories | Original rewriting of public-domain works (Ibn Kathir) + Quran/hadith sources | Review Board approval per story. |
| Cities (offline) | GeoNames `cities15000` subset | CC BY 4.0 — attribution required. |
| Fonts (UI) | **Noto Naskh Arabic / IBM Plex Sans Arabic / Cairo / Tajawal / Almarai** | SIL OFL — free to bundle. |
| Adhan audio | Own recordings or explicit written permission | Do not rip adhan clips from the internet. |

---

## 7. Data Model (SQLite)

### 7.1 `quran.db` (read-only)

```sql
CREATE TABLE riwaya (
  id INTEGER PRIMARY KEY,               -- 1 = hafs
  code TEXT NOT NULL UNIQUE,            -- 'hafs'
  name_ar TEXT NOT NULL
);

CREATE TABLE surah (
  id INTEGER PRIMARY KEY,               -- 1..114
  name_ar TEXT NOT NULL,
  name_simple TEXT,
  revelation_place TEXT CHECK (revelation_place IN ('makkah','madinah')),
  revelation_order INTEGER,
  ayah_count INTEGER NOT NULL,
  has_basmala INTEGER NOT NULL DEFAULT 1,   -- 0 for surah 9
  page_start INTEGER NOT NULL,
  page_end INTEGER NOT NULL
);

CREATE TABLE ayah (
  id INTEGER PRIMARY KEY,               -- global 1..6236
  surah_id INTEGER NOT NULL REFERENCES surah(id),
  ayah_number INTEGER NOT NULL,
  juz INTEGER NOT NULL,                 -- 1..30
  hizb INTEGER NOT NULL,                -- 1..60
  rub INTEGER NOT NULL,                 -- 1..240
  page INTEGER NOT NULL,                -- 1..604
  sajdah INTEGER NOT NULL DEFAULT 0,    -- 0 none, 1 recommended, 2 obligatory (per Hafs data source)
  text_uthmani TEXT NOT NULL,           -- canonical, byte-identical to source
  text_imlaei TEXT,                     -- simple Arabic script for accessibility/share-readability
  text_search TEXT NOT NULL,            -- normalized (Appendix A)
  UNIQUE (surah_id, ayah_number)
);
CREATE INDEX idx_ayah_page ON ayah(page);
CREATE INDEX idx_ayah_juz ON ayah(juz);

CREATE TABLE word (
  id INTEGER PRIMARY KEY,
  ayah_id INTEGER NOT NULL REFERENCES ayah(id),
  position INTEGER NOT NULL,            -- 1-based within ayah
  text_uthmani TEXT NOT NULL,
  glyph_code TEXT,                      -- page-font glyph(s) for page mode
  page INTEGER,
  line_number INTEGER,
  char_type TEXT,                       -- 'word' | 'end' (ayah marker) | 'pause' ...
  root TEXT,
  meaning_ar TEXT,                      -- v1.1, nullable until pack present
  UNIQUE (ayah_id, position)
);

CREATE VIRTUAL TABLE ayah_fts USING fts5(
  text_search, content='ayah', content_rowid='id',
  tokenize='unicode61 remove_diacritics 0', prefix='2 3 4'
);

CREATE TABLE reciter (
  id TEXT PRIMARY KEY,                  -- 'alafasy', 'husary_murattal', ...
  name_ar TEXT NOT NULL,
  style_ar TEXT,
  sort_order INTEGER,
  bitrate_kbps INTEGER,
  has_ayah_files INTEGER NOT NULL,
  has_surah_file INTEGER NOT NULL,
  has_timings INTEGER NOT NULL,
  ayah_url_template TEXT,               -- e.g. https://host/path/{ayah_global_3}.mp3 or {surah_3}{ayah_3}
  surah_url_template TEXT,              -- e.g. https://host/path/{surah_3}.mp3
  source_note TEXT
);

CREATE TABLE audio_timing (             -- optional, for surah-file highlighting
  reciter_id TEXT NOT NULL,
  surah_id INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  start_ms INTEGER NOT NULL,
  end_ms INTEGER NOT NULL,
  PRIMARY KEY (reciter_id, surah_id, ayah_number)
);
```

Integrity constants (also enforced in tests): **114 surahs, 6,236 ayahs, 604 pages, 30 juz, 60 hizb, 240 rub, 15 sajdah positions** (Hafs, per source convention). Basmala is a separate rendered element, not stored as the first ayah text of surahs other than Al-Fatiha. Verify the source's basmala convention in the importer test.

### 7.2 Content Pack Schemas

```sql
-- tafsir_<id>.db
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);   -- name_ar, author_ar, edition, license, version, reviewer
CREATE TABLE tafsir_entry (
  id INTEGER PRIMARY KEY,
  ayah_from INTEGER NOT NULL,           -- global ayah id
  ayah_to   INTEGER NOT NULL,
  text      TEXT NOT NULL,              -- AppText markup (§7.4)
  text_search TEXT                      -- normalized, optional (v1.1 search)
);
CREATE INDEX idx_tafsir_from ON tafsir_entry(ayah_from);

-- irab_<id>.db / asbab_<id>.db share the same shape plus 'source_ref' and optional 'grade_note'

-- book_<id>.db
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);   -- title_ar, author_ar, author_death_h, category, license, edition
CREATE TABLE section (
  id INTEGER PRIMARY KEY, parent_id INTEGER, title TEXT NOT NULL,
  order_index INTEGER NOT NULL, start_page_id INTEGER
);
CREATE TABLE page (
  id INTEGER PRIMARY KEY, volume INTEGER, page_number INTEGER,
  text TEXT NOT NULL, text_search TEXT
);
CREATE VIRTUAL TABLE page_fts USING fts5(text_search, content='page', content_rowid='id', tokenize='unicode61');

-- hadith_<book>.db
CREATE TABLE hadith (
  id INTEGER PRIMARY KEY, number INTEGER, chapter TEXT, narrator TEXT,
  text TEXT NOT NULL, grade TEXT, grade_source TEXT, text_search TEXT
);
```

### 7.3 `user.db` (read-write)

```sql
CREATE TABLE bookmark (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  kind TEXT NOT NULL CHECK (kind IN ('ayah','page','book_page','dhikr')),
  ref TEXT NOT NULL,                    -- ayah_id | page | 'bookId:pageId' | dhikr id
  label TEXT, color INTEGER,
  created_at INTEGER NOT NULL
);
CREATE TABLE favorite (
  kind TEXT NOT NULL, ref TEXT NOT NULL, created_at INTEGER NOT NULL,
  PRIMARY KEY (kind, ref)
);
CREATE TABLE reading_position (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  ayah_id INTEGER, page INTEGER, mode TEXT, updated_at INTEGER
);
CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT, ayah_id INTEGER, text TEXT, created_at INTEGER, updated_at INTEGER);
CREATE TABLE download_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  kind TEXT NOT NULL,                   -- 'audio_surah' | 'pack'
  key TEXT NOT NULL UNIQUE,             -- 'alafasy:2' | 'tafsir_muyassar'
  path TEXT, size_bytes INTEGER, status TEXT, version INTEGER, completed_at INTEGER
);
CREATE TABLE khatma_plan (id INTEGER PRIMARY KEY, start_date TEXT, days INTEGER, pages_per_day INTEGER, current_page INTEGER, completed_count INTEGER);
CREATE TABLE memorization_item (
  id INTEGER PRIMARY KEY, ayah_from INTEGER, ayah_to INTEGER,
  box INTEGER NOT NULL DEFAULT 0, next_review TEXT, last_result TEXT
);
CREATE TABLE prayer_log (date TEXT NOT NULL, prayer TEXT NOT NULL, done INTEGER NOT NULL, PRIMARY KEY (date, prayer));
CREATE TABLE tasbih_counter (id INTEGER PRIMARY KEY, phrase TEXT, target INTEGER, count INTEGER, updated_at INTEGER);
CREATE TABLE setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
```

### 7.4 AppText Markup (for tafsir/book text)

Plain UTF-8 text with minimal conventions rendered by a custom parser (no full HTML engine):
- `\n\n` paragraph break; `# `/`## ` heading lines.
- `﴿ ... ﴾` marks Quran quotations → rendered in the Quran font; MAY carry an ayah reference token `{{q:2:255}}` for tapping.
- `«...»` marks hadith/quote spans (style only).
- `**bold**` for emphasis; footnotes `[^n]` with a footnote block at the end.
The content builder validates markup and rejects unbalanced markers.

---

## 8. Content Pipeline and Integrity

### 8.1 Pipeline (`tools/content_builder`, Python 3.11+)

1. **Fetch** source files (documented URLs, pinned versions/hashes) into a local cache (not committed if license forbids redistribution).
2. **Normalize/convert** into the schemas above. Deterministic: same inputs → same bytes.
3. **Validate** (see 8.3).
4. **Pack:** compress, compute SHA-256, write manifest entry.
5. **Sign** manifest with the offline Ed25519 private key (kept by two maintainers, never in the repo or CI logs).
6. **Publish** to static hosting (§12). Update `THIRD_PARTY_LICENSES.md` and review record.

### 8.2 Review Records

`content/REVIEW.md` table: pack id, version, source edition, reviewer name, review date, scope reviewed, notes. A pack cannot be listed in the public manifest without a row here (CI check). The same names appear in the About screen.

### 8.3 Quran Text Integrity (MUST)

- `content/quran/CHECKSUMS.txt` stores SHA-256 of the canonical Uthmani text file(s).
- CI test fails if: counts differ from §7.1 constants; any ayah text differs from the reference by even one codepoint; Unicode normalization (NFC/NFD) is applied accidentally; `quran.db` ayahs differ from the pinned source.
- `CODEOWNERS` requires approval from the Review Board member **and** a maintainer for any change under `content/quran/` or the Quran data import code.
- Transformations (imlaei, search normalization) go into **separate columns**; canonical column is never post-processed.
- Cross-check against a **second independent source** at import (e.g., Tanzil vs QUL/KFGQPC) and diff the results; any non-trivial diff is investigated by the reviewer.

### 8.4 Other Packs
- Tafsir/I'rab/Asbab: automated checks (every entry maps to valid ayah ids; no overlapping duplicates; markup valid; coverage report for ayahs without entries) + human sampling review (≥5% of entries or all of a high-risk subset).
- Hadith: reference numbering verified against a second edition; grading source mandatory per hadith.
- Adhkar: each text verified word-by-word against its source; reviewer signs off.

---

## 9. UX / UI Specification

### 9.1 Language and Layout
- **RTL only.** `Directionality` fixed to RTL; no LTR fallbacks. Icons that imply direction (back, next) mirrored correctly. Arabic-Indic numerals by default (setting to switch).
- Copy: Modern Standard Arabic, respectful and concise; no emojis in religious content; consistent terminology (a glossary file in `docs/arabic-copy-glossary.md`).
- All strings in `app_ar.arb`; no concatenated sentences (use ICU placeholders).

### 9.2 Visual Identity (proposal, D-15)
- Palette: deep green (primary), warm gold (accent), off-white paper (light), warm dark (dark), pure black (OLED). Quran page background options: white, cream, sepia.
- Typography: Quran = KFGQPC Uthmani fonts; UI = Noto Naskh Arabic or IBM Plex Sans Arabic or Cairo (choose one in M0 by readability tests); line-height tuned for tashkeel (≥1.8 for Quran text).
- Components: a small design system in `app/lib/app/theme` with tokens (colors, spacing 4-pt grid, radii, elevation) and reusable widgets; all screens MUST use tokens (no hard-coded colors).
- Motion: subtle; respect "reduce animations".

### 9.3 Navigation
Bottom navigation (5): **الرئيسية** Home · **المصحف** Quran · **الاستماع** Listen · **الصلاة** Prayer & Adhkar · **المزيد** More (library, settings, calendar, tools). Library gets its own tab in v1.3 if it fits.

### 9.4 Key Screens
1. **Home:** continue reading card; next prayer + countdown; Hijri date; "ayah of the day" (curated list, reviewed); shortcuts (adhkar, khatma, listen).
2. **Mushaf:** minimal chrome that auto-hides; tap toggles; mini-player; page/juz/surah indicator; bookmark ribbon.
3. **Ayah Action Sheet** (central interaction).
4. **Index/Search.**
5. **Listen:** reciters grid/list with search & favorites; surah list per reciter with download state; full player.
6. **Downloads & Storage.**
7. **Tafsir viewer.**
8. **Prayer:** today's times, method/location, notification settings, reliability checklist, qibla.
9. **Adhkar & Tasbih.**
10. **Calendar.**
11. **Settings / About.**
12. (later) Library, Book reader, Memorization, Khatma, Stories, Zakat.

### 9.5 Accessibility
- Works at **200% font scale**; touch targets ≥ 48 dp; contrast WCAG AA; TalkBack labels for every control.
- Mushaf page mode exposes **semantic labels per ayah** using canonical text (since glyph fonts read as gibberish).
- Large-text "easy mode" for elderly users (bigger buttons, fewer items on Home).
- Haptics and sounds optional; no information conveyed by color alone (tajweed legend uses names too).

---

## 10. Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-PRF-001 | Cold start to usable Home on a low-end device (2 GB RAM, Android 8–10 class) | ≤ 2.5 s |
| NFR-PRF-002 | Mushaf page swipe | 60 fps typical; no jank > 100 ms |
| NFR-PRF-003 | Search results latency (local) | ≤ 150 ms |
| NFR-PRF-004 | **Download size** (AAB → device APK, base) | Target ≤ 60 MB; hard cap 100 MB (decide fonts/Muyassar bundling by S-01) |
| NFR-PRF-005 | Memory, Mushaf screen | ≤ 250 MB peak on low-end device |
| NFR-PRF-006 | Battery | No wake locks beyond playback; audio/alarms only. < 2%/hr during audio playback screen-off (indicative) |
| NFR-REL-001 | Crash-free sessions | ≥ 99.5% (Play Console vitals) |
| NFR-REL-002 | Prayer notification delivery | ≥ 99% within ±60 s on tested devices after reliability checklist |
| NFR-OFF-001 | Offline | Quran text, installed tafsir, adhkar, prayer times, calendar, downloaded audio all work in airplane mode |
| NFR-SEC-001 | No analytics, ads, or third-party tracking SDKs; no network calls except content packs and audio | Verified by CI dependency audit + manual network inspection |
| NFR-SEC-002 | Content integrity (signed manifest + SHA-256) | 100% of packs verified before use |
| NFR-PRV-001 | Data stays on device; location used only for prayer times and never leaves device; no contact/storage scans | Stated in privacy policy |
| NFR-A11Y-001 | Accessibility per §9.5 | Pass manual TalkBack audit |
| NFR-MNT-001 | Test coverage | ≥ 70% on `core/` and domain logic; 100% on normalizer, prayer scheduler logic, khatma, zakat |
| NFR-LIC-001 | Every bundled/downloaded asset has a recorded license | `THIRD_PARTY_LICENSES.md` complete before release |

---

## 11. Android Platform Details

### 11.1 Versions
- `minSdk`: 23 (D-14). `targetSdk`: **the level Google Play requires for new apps/updates at submission time** (the 2026 requirement is expected to be API 36 — **[VERIFY]**). Re-check each year.
- Build **Android App Bundle (AAB)**. Test native libs for **16 KB page-size** compatibility (Play requirement for newer targets — **[VERIFY]**).
- Enable R8/ProGuard shrinking; split by ABI/density via AAB; compress assets.

### 11.2 Permissions and Services (justify each in the Play declaration)

| Permission / component | Why | Notes |
|------------------------|-----|-------|
| `INTERNET`, `ACCESS_NETWORK_STATE` | Pack download, audio streaming | |
| `POST_NOTIFICATIONS` (API 33+) | Prayer/adhkar reminders, media notification | Ask in context, not on first launch |
| `ACCESS_COARSE_LOCATION` | Prayer times/qibla | **Coarse only**, foreground only, optional |
| `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Background audio | Declare type (API 34+) |
| `FOREGROUND_SERVICE_DATA_SYNC` (if used by downloader) | Large downloads | Prefer downloader's WorkManager approach; declare if required **[VERIFY]** |
| `WAKE_LOCK` | Audio playback (via libraries) | |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications after reboot | |
| `SCHEDULE_EXACT_ALARM` | On-time adhan | User-grantable special access; guide user with settings deep link. `USE_EXACT_ALARM` is restricted by Play policy to alarm/calendar-core apps — **[VERIFY]** whether a prayer-time app qualifies before using it. Provide a graceful inexact fallback. |
| `VIBRATE` | Tasbih haptics | |
| `USE_FULL_SCREEN_INTENT` | **Do not request.** | Not needed |

No storage permissions (use app-specific directories and the system file picker/Share sheet for export/import). No `READ_PHONE_STATE`, no contacts, no advertising ID.

### 11.3 OEM Background Restrictions
Aggressive task killers on some OEMs break alarms/audio. Deliver the **Reliability checklist** (§5.9), keep a docs page of per-OEM steps, and include real-device tests (§13).

### 11.4 Glyph-Font Pitfalls (must handle)
- Copy/share/screen-reader/search in page mode MUST map back to canonical text by `(ayah_id)`.
- Font fallback must never substitute a system font for Quran glyphs; preload page fonts before first paint of a page to avoid flicker.
- Test on Android 8–15 and with system font scale 100–200%.

---

## 12. Infrastructure and Hosting

| Component | Choice | Notes |
|-----------|--------|-------|
| Source code | GitHub public repo | Organization account recommended |
| Issues/Discussions | GitHub | Arabic and English accepted |
| Content packs + manifest | **Cloudflare R2 + Pages** (or GitHub Releases as fallback) | Low/zero egress fees; HTTPS; versioned URLs |
| Audio | v1.0: stream from the reciter source servers **with written permission**; plan **mirror of popular reciters** to R2 when permitted and budget allows | Do not hammer third-party servers: add client-side caching/download encouragement |
| Backend/API | **None in v1.x** | v2.0 will add a small backend (accounts, group khatma, dua wall) |
| Crash reporting | **Google Play Console vitals** (no SDK). Optional user-initiated diagnostic log export | Any future crash SDK must be opt-in, self-hostable (e.g. GlitchTip), and ADR-approved |
| Domain | Optional (privacy policy page, store links, CDN domain) | Needed for the privacy policy URL — GitHub Pages is enough |

Bus-factor and continuity (sadaqa jariya must outlive individuals): at least **two owners** on the Play Console, GitHub org, and Cloudflare; signing/upload key backup procedure documented privately; 2-factor authentication mandatory; a written handover document in the private team vault.

---

## 13. Testing Strategy

- **Unit tests:** normalizer (golden vectors), reference parser, prayer-time calculations (golden files vs authority timetables), khatma planner, zakat math, Hijri conversion, timing lookup, pack verifier (tampered pack must fail), migrations.
- **Data tests:** Quran integrity (§8.3), pack schema validation, FTS correctness (known queries return known ayahs).
- **Widget/golden tests:** Home, Mushaf text mode, Ayah sheet, player, at font scales 1.0/1.5/2.0 and light/dark.
- **Integration tests:** first-run flow, download → play offline, switch mode preserves position, notification scheduling logic (with fake clock).
- **Device matrix (manual before each release):** at least one each of: Samsung (One UI), Xiaomi/Redmi (MIUI/HyperOS), Oppo/Realme, Infinix/Tecno, Pixel; Android 8, 10, 12, 14/15; a 2 GB RAM device; slow 3G network test; airplane mode test; TalkBack pass.
- **Scholarly QA:** reviewers receive a checklist per pack (§8.2), including random-sample verification screens exported from the app.
- **Beta:** Play internal → closed → (open) testing tracks.

---

## 14. CI/CD and Release

### 14.1 Branching and Quality Gates
- Trunk-based: `main` always releasable; short-lived feature branches; PRs require **1 approval** (2 for `content/` and `core/db`); Conventional Commits; semantic versioning (`MAJOR.MINOR.PATCH`, build number increments per upload).
- CI (GitHub Actions) on every PR: `flutter analyze`, format check, unit/widget tests, content integrity tests, license-scan of dependencies, build debug APK.
- CI on tag: build **signed AAB**, run tests, upload to Play **internal track** (via Gradle Play Publisher/fastlane supply), attach release notes from CHANGELOG.
- Secrets (keystore, Play service account) in GitHub encrypted secrets; **use Play App Signing**; never commit keys.

### 14.2 Play Console Checklist (before first public release)
- [ ] Developer account created (org preferred), 2FA, ≥2 owners (D-20)
- [ ] Package ID finalized (D-16) and app name verified
- [ ] Privacy policy URL (states: no ads, no analytics, location use, local data, backup export)
- [ ] **Data safety form** (data collected: none off-device; location processed on-device only — fill exactly per final behavior)
- [ ] Content rating questionnaire; category (e.g. Books & Reference or Lifestyle)
- [ ] Declarations: foreground service types, exact alarm use, notification use
- [ ] Target API level compliance, 16 KB page size, 64-bit
- [ ] Store listing in Arabic: title, short/full description, 8 screenshots (phone), feature graphic, icon; optional tablet screenshots
- [ ] Closed testing completed per current Play rules (**[VERIFY]** tester count/duration for the account type)
- [ ] Review Board sign-offs recorded; About screen credits complete
- [ ] `THIRD_PARTY_LICENSES.md` complete; source repo public with license file
- [ ] Staged rollout (e.g., 10% → 50% → 100%) with vitals monitoring

---

## 15. Open-Source Governance

### 15.1 License (D-18)
- **Code:** GPL-3.0-or-later (default). Rationale: prevents closed, ad-injected forks of a sadaqa jariya; compatible with GPL-licensed data such as the Quranic Arabic Corpus. **Caveat:** GPL distribution through Apple's App Store is legally problematic — if iOS is pursued later, either relicense (needs contributor agreement — so adopt a **DCO/CLA now**) or isolate the licensed parts. If the team prefers maximum adoption, Apache-2.0 is the alternative.
- **Content:** each pack keeps its original license; project-authored content (stories, UI copy) under CC BY-SA 4.0 or as decided by the owner.
- Quran text MUST remain unmodified regardless of repo license.

### 15.2 Repository Files
`README.md` (Arabic + English short intro), `LICENSE`, `THIRD_PARTY_LICENSES.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CODEOWNERS`, `CHANGELOG.md`, issue templates (bug, feature, **content error report**), PR template with checklist (tests, strings in ARB, no new tracking, license recorded).

### 15.3 Content Errors
A dedicated, easy "Report a content error" path (GitHub issue template + in-app link opening a prefilled email/issue) with a **48-hour triage target** for Quran text/audio errors.

---

## 16. Team Roles and Workflow

Because the team has mixed specializations, roles are defined by responsibility (one person may hold several):

| Role | Responsibilities |
|------|------------------|
| Product owner (Ahmed) | Priorities, decisions (D-*), release approval, external permissions |
| Tech lead | Architecture, ADRs, code review, spikes, CI/CD |
| Mobile developer(s) | Features per milestone |
| Data/content engineer | Content builder pipeline, packs, integrity tests |
| **Sharia reviewer(s)** | Quran text verification, tafsir/i'rab/asbab/adhkar/hadith/story review, sign-offs |
| Arabic language reviewer | UI copy, grammar terms, i'rab term mapping |
| UI/UX designer | Design tokens, screens, assets, store graphics |
| QA/tester(s) | Device matrix, regression, accessibility |
| Audio engineer / coordinator | Reciter permissions, adhkar/adhan audio, file QA |
| Community/legal liaison | Permission emails, license records |

**Workflow:** 2-week iterations; each milestone has a demo build; definition of done (below); weekly 30-minute sync; all decisions as ADRs in `docs/adr/`.

**Definition of Done:** acceptance criteria met · tests added and green · no analyzer warnings · strings in ARB · accessibility checked · docs/ADR updated · license recorded for any new asset · reviewed and merged · tested on at least two real devices.

**Using AI coding assistants:** give them this spec + the specific milestone/task ID. Rules to paste into the assistant's context: never modify Quran text; no new dependencies without ADR; no telemetry; all UI strings Arabic via ARB; write tests with each task; keep changes small and reviewable.

---

## 17. Roadmap: Milestones and Tasks

Effort sizes: **S** ≤ 2 days · **M** ≤ 1 week · **L** ≤ 2 weeks · **XL** > 2 weeks (split further).

### M0 — Foundations and Spikes
| ID | Task | Size | Acceptance |
|----|------|------|-----------|
| T-001 | Create repo, license, README, CODEOWNERS, templates | S | Public repo builds an empty Flutter app |
| T-002 | CI pipeline (analyze, test, build) | M | PR checks green |
| T-003 | Design tokens + theme + RTL scaffold + ARB setup | M | Light/dark themes; Arabic-only strings |
| T-004 | App shell + navigation + placeholder tabs | S | 5-tab navigation works |
| S-01 | **Mushaf rendering spike**: page-glyph fonts vs images; measure size, rendering accuracy, performance, license | L | ADR with decision, size budget numbers |
| S-02 | **Audio spike**: ayah playlist vs surah file; timing data availability for 35 reciters; just_audio/audio_service background behavior | M | Table of reciters with capabilities (feeds reciter.json) |
| S-03 | **Notifications spike**: exact alarms, boot reschedule, OEM behavior, adhan channels | M | ADR + proof-of-concept on 4+ device brands |
| S-04 | **Arabic FTS spike**: normalization + FTS5 correctness/perf | S | Golden test vectors + latency measurement |
| S-05 | Permission requests: mp3quran, EveryAyah, font/text/data owners | M | Written replies stored in `content/sources/` |
| D-gate | Owner resolves D-12…D-20 (esp. D-16, D-17) | S | Decisions recorded |

### M1 — Quran Core
| ID | Task | Size | Acceptance |
|----|------|------|-----------|
| T-101 | Content builder: import Quran text + metadata, second-source diff, integrity tests | L | §8.3 CI passes |
| T-102 | `quran.db` generation + drift schema + repository | M | Counts match constants |
| T-103 | Text-mode reader (ayah list, sizes, themes) | M | FR-MSH-001/007 text mode |
| T-104 | Page-mode reader (per S-01 decision) | XL | 604 pages verified vs reference; FR-MSH-002/009 |
| T-105 | Index screens (surah/juz/hizb/page) | M | FR-MSH-003 |
| T-106 | Reading position persistence + Home "continue" | S | FR-MSH-004 |
| T-107 | Ayah Action Sheet (copy, share text, bookmark, favorite) | M | FR-MSH-005/010, FR-BKM-001 |
| T-108 | Bookmarks screen | S | FR-BKM-002 |
| T-109 | Quran search (normalizer, FTS, reference parser) | M | FR-SRC-001..004 |
| T-110 | Accessibility semantics for page mode | M | TalkBack reads canonical ayah text |

### M2 — Audio
| ID | Task | Size | Acceptance |
|----|------|------|-----------|
| T-201 | Reciter dataset (35) + builder + capability flags | M | Matches S-02 table |
| T-202 | Audio handler, queue, background + notification | L | FR-AUD-005 |
| T-203 | Listen screens (reciters, surah list, player, mini-player) | L | FR-AUD-001/002/009 |
| T-204 | Ayah highlight + auto-scroll | M | FR-AUD-007 |
| T-205 | Download manager (resume, Wi-Fi only, storage screen) | L | FR-AUD-004 |
| T-206 | Repeat, speed, sleep timer with fade | M | FR-AUD-006/008 |
| T-207 | Resume-last-playback + audio focus edge cases | S | FR-AUD-010 |

### M3 — Packs, Tafsir, Backup
| ID | Task | Size | Acceptance |
|----|------|------|-----------|
| T-301 | Pack system: manifest, signing, verification, installer | L | Tampered pack rejected (test) |
| T-302 | Content builder: 5 tafsirs → packs | XL | Coverage reports; reviewer samples signed |
| T-303 | Tafsir viewer (sheet + full), tafsir switcher | M | FR-TAF-001..005 |
| T-304 | Pack manager UI | S | FR-TAF-006 |
| T-305 | Backup/restore (JSON export/import) | M | FR-BKM-003; round-trip test |

### M4 — Worship Tools
| ID | Task | Size | Acceptance |
|----|------|------|-----------|
| T-401 | Prayer engine + methods + offsets + tests vs authority timetable | M | §4.6 acceptance |
| T-402 | Location flow + offline city list + manual entry | M | FR-PRY-003 |
| T-403 | Notification scheduler + adhan channels + reboot/timezone rescheduling | L | FR-PRY-005/006 |
| T-404 | Reliability checklist screen + OEM guide | M | Works on S-03 devices |
| T-405 | Qibla compass | M | FR-PRY-008 |
| T-406 | Hijri calendar + converter + adjustments + occasions | M | FR-CAL-001..003 |
| T-407 | Adhkar content pack/builder + reviewer sign-off | L | Every dhikr verified |
| T-408 | Adhkar UI + counter + reminders + tasbih | L | FR-ADH-001..004/006 |
| T-409 | Adhan audio (licensed/recorded) | M | Rights recorded |

### M5 — Hardening and v1.0 Release
| ID | Task | Size | Acceptance |
|----|------|------|-----------|
| T-501 | Onboarding + Settings + About (credits, licenses, review board) | M | FR-SET-001..003 |
| T-502 | Performance tuning vs NFR-PRF | L | Targets met on low-end device |
| T-503 | Accessibility audit and fixes | M | NFR-A11Y-001 |
| T-504 | Full device-matrix QA, bug bash | L | No P0/P1 open |
| T-505 | Store listing, privacy policy, data safety, declarations | M | Checklist §14.2 |
| T-506 | Closed testing → staged production rollout | M | Vitals within NFR-REL |
| T-507 | Review Board final sign-off | S | REVIEW.md complete |

### v1.1 → v2.0 (summarized backlog; each becomes a milestone with its own task table)
- **v1.1:** I'rab pack + UI, asbab pack + UI, word-meaning data + UI, adhkar audio, share-as-image, ayah-quote tappable links.
- **v1.2:** Khatma, progress, memorization (loop, hide, spaced review), tajweed coloring, prayer tracker, Ramadan mode, notes.
- **v1.3:** Library reader + catalog, hadith six books, stories, zakat, widgets.
- **v1.4:** Topics, kids section, translation packs, (optional) Android Auto / Wear OS.
- **v2.0:** Backend (small, privacy-preserving), accounts (optional), sync, group khatma, dua wall with moderation + Play UGC compliance **[VERIFY]**, additional riwayat packs.

---

## 18. Risk Register

| ID | Risk | Impact | Mitigation |
|----|------|--------|-----------|
| R-01 | No Sharia review board | Cannot release; credibility | Recruit 2+ reviewers (Al-Azhar graduates/faculty, Dar al-Ifta-affiliated scholars) **before M3**; D-17 gate |
| R-02 | Licensing/permission failures for text, audio, books | Takedown from Play/GitHub | §6 process; written permissions; only vetted sources; prefer public-domain + explicit-license content |
| R-03 | Third-party audio servers unavailable or rate-limit | Playback broken | Permission + mirror popular reciters; encourage downloads; retry/backoff; reciter health check |
| R-04 | Quran text corruption | Severe religious/legal harm | §8.3 integrity rules, dual-source diff, CODEOWNERS |
| R-05 | Prayer notifications unreliable on OEM devices | Core feature failure, bad reviews | S-03 spike, reliability checklist, exact-alarm handling, real-device tests |
| R-06 | Page-glyph fonts heavy or license-restricted | App size, legal | S-01 spike; fallback to images pack or text mode only for v1.0 |
| R-07 | Play Console account/policy issues (new account testing rules, policy changes) | Release delay | Org account, early setup, follow policy checklists, avoid restricted permissions |
| R-08 | Team availability (volunteers) | Delays | Small milestones, backlog hygiene, bus-factor docs, scope staged (D-13) |
| R-09 | Scope creep (huge feature list) | Never ships | Stage gates §3; v1.0 scope frozen after M0 |
| R-10 | Incorrect hadith grading/adhkar attribution | Misguidance | Reviewer sign-off, cite grading source, avoid unreviewed packs |
| R-11 | Storage bloat (audio) on low-end devices | Uninstalls | Clear size estimates, storage manager, no auto-downloads |
| R-12 | GPL vs future iOS | Relicensing friction | DCO/CLA now; decide before iOS work |
| R-13 | Privacy mistakes (data safety form mismatch) | Play rejection | Dependency audit, network inspection test, form reviewed by 2 people |

---

## 19. Immediate Next Steps (First 14 Days)

1. Owner confirms or overrides **D-12 … D-20** (priority: D-16 name/package, D-17 reviewers, D-18 license).
2. Create GitHub organization + repo; add a second owner; set up Cloudflare and password vault.
3. Start permission outreach (S-05) — it has the longest lead time.
4. Run spikes S-01…S-04 and record ADRs.
5. Recruit Sharia and Arabic-language reviewers; agree on the review checklist.
6. Build M0 shell; produce first design tokens and 3 key screen mockups (Home, Mushaf, Player).

---

## Appendix A — Arabic Search Normalization (Reference Algorithm)

Used identically by the content builder and the app (shared test vectors in `app/test/fixtures/normalizer_vectors.json`).

Steps for `normalizeArabic(input)`:

1. Convert to Unicode **NFC**? — **No** for canonical Quran text (never altered). This function produces a *derived* string only.
2. Remove **tashkeel and Quranic marks**: U+0610–U+061A, U+064B–U+065F, U+0670, U+06D6–U+06ED, U+08D3–U+08FF (+ U+0640 tatweel).
3. Remove Quranic annotation characters that are not letters (small high marks, end-of-ayah sign U+06DD, etc.) — covered by step 2 plus explicit list from the font vendor documentation.
4. Normalize letters:
   - `أ إ آ ٱ` → `ا`
   - `ى` → `ي` (alef maqsura to ya)
   - `ؤ` → `و`, `ئ` → `ي` (optional "loose" mode; default ON)
   - `ة` → `ه` (optional; default ON for search only)
   - Persian/Urdu variants: `ی` → `ي`, `ک` → `ك`
5. Convert Arabic-Indic and Extended Arabic-Indic digits to ASCII digits for reference parsing.
6. Collapse whitespace; trim.

Notes:
- Two search modes MAY be exposed: **loose** (default) and **strict** (keeps hamza/ta marbuta distinctions).
- Quran Uthmani text uses special small letters (e.g. dagger alef U+0670, small waw/ya); step 2 handles them. A word like "الرحمن" must match "الرَّحْمَٰنِ".
- Test vectors MUST include: الرحمن/الرَّحْمَٰنِ, الله/ٱللَّهُ, موسى/مُوسَىٰ, رحمة/رَحْمَةً, آية/ءَايَةٌ, مؤمن/مُؤْمِنٌ.

## Appendix B — Reciter Shortlist (35, all Hafs) — subject to source availability and permission (S-02, S-05)

Egyptian reciters are listed first because the primary audience is Egyptian.

1. Mahmoud Khalil Al-Husary (Murattal) — محمود خليل الحصري (مرتل)
2. Mahmoud Khalil Al-Husary (Al-Muallim) — الحصري (المعلم)
3. Muhammad Siddiq Al-Minshawi (Murattal) — محمد صديق المنشاوي (مرتل)
4. Muhammad Siddiq Al-Minshawi (Mujawwad) — المنشاوي (مجود)
5. Abdul Basit Abdul Samad (Murattal) — عبد الباسط عبد الصمد (مرتل)
6. Abdul Basit Abdul Samad (Mujawwad) — عبد الباسط (مجود)
7. Mustafa Ismail — مصطفى إسماعيل
8. Mahmoud Ali Al-Banna — محمود علي البنا
9. Muhammad Rifaat — محمد رفعت
10. Muhammad Mahmoud Al-Tablawi — محمد محمود الطبلاوي
11. Ahmed Naina — أحمد نعينع
12. Mishary Rashid Alafasy — مشاري راشد العفاسي
13. Maher Al-Muaiqly — ماهر المعيقلي
14. Abdulrahman Al-Sudais — عبدالرحمن السديس
15. Saud Al-Shuraim — سعود الشريم
16. Saad Al-Ghamdi — سعد الغامدي
17. Yasser Al-Dosari — ياسر الدوسري
18. Nasser Al-Qatami — ناصر القطامي
19. Ahmad Al-Ajmi — أحمد العجمي
20. Hani Ar-Rifai — هاني الرفاعي
21. Abu Bakr Al-Shatri — أبو بكر الشاطري
22. Idris Abkar — إدريس أبكر
23. Abdullah Basfar — عبدالله بصفر
24. Ali Al-Hudhaify — علي الحذيفي
25. Abdullah Awad Al-Juhany — عبدالله عواد الجهني
26. Salah Bukhatir — صلاح بو خاطر
27. Fares Abbad — فارس عباد
28. Muhammad Ayyub — محمد أيوب
29. Abdulbari Ath-Thubaity — عبدالباري الثبيتي
30. Khalid Al-Jalil — خالد الجليل
31. Ibrahim Al-Akhdar — إبراهيم الأخضر
32. Ali Jaber — علي جابر
33. Wadee Hammadi Al-Yamani — وديع اليمني
34. Mansour Al-Salimi — منصور السالمي
35. Raad Muhammad Al-Kurdi — رعد محمد الكردي

Alternates if a reciter lacks permission/files: Muhammad Al-Luhaidan, Salman Al-Utaybi, Khalifa Al-Tunaiji, Nabil Ar-Rifai, Muhammad Jibril.

## Appendix C — Algorithms

**Khatma planner**
```
pagesPerDay = ceil(604 / days)
dayIndex(date) = daysBetween(startDate, date)
targetPage(date) = min(604, (dayIndex + 1) * pagesPerDay)
// If behind: remainingPages = 604 - currentPage; remainingDays = days - dayIndex; newPerDay = ceil(remainingPages / remainingDays)
```
Ramadan (30 days) ≈ 21 pages/day (about one juz); optional per-prayer split: `ceil(pagesPerDay / 5)`.

**Spaced review (Leitner)**: box 0→1→2→3→4→5 intervals `[0, 1, 3, 7, 14, 30]` days; Easy: box+1; Hard: stay; Forgot: box = 0.

**Zakat (money)**
```
nisabGoldGrams = 85; nisabSilverGrams = 595
nisabValue = chosenBasis == gold ? 85 * goldPricePerGram : 595 * silverPricePerGram
zakatable = cash + goldValue + silverValue + tradeGoods - debtsDueNow
zakat = zakatable >= nisabValue ? zakatable * 0.025 : 0
```
Display assumptions and an "ask a scholar" note. (Scholar review of rules required before v1.3.)

**Ayah highlight from timings**
```
currentAyah = binarySearch(timings[reciter][surah], positionMs)   // largest start_ms <= positionMs
```

**Hijri adjustment**
`displayedHijri = hijriFrom(gregorianDate + userAdjustmentDays)`, adjustment ∈ [-2, +2], stored in `setting`.

## Appendix D — Glossary

- **Hafs ʿan ʿĀṣim:** the most widely used Quranic recitation (riwaya) in the Islamic world.
- **Riwaya / Qira'a:** a transmitted recitation tradition (Hafs, Warsh, Qalun, ad-Duri…).
- **Mushaf:** a written copy of the Quran. **Madinah Mushaf:** the King Fahd Complex print, 604 pages.
- **Tafsir:** exegesis. **I'rab:** grammatical analysis. **Asbab al-Nuzul:** reasons/occasions of revelation.
- **Ghareeb al-Quran:** meanings of rare/difficult Quranic words.
- **Tajweed:** rules of correct recitation. **Basmala:** "Bismillah ir-Rahman ir-Rahim".
- **Sadaqa Jariya:** ongoing charity whose reward continues.
- **Pack:** a versioned, signed, downloadable content database.
- **ADR:** Architecture Decision Record — a short document explaining a technical decision.

---

*End of specification. Any change to Decisions (§2), scope (§3), or integrity rules (§8.3) MUST be recorded in the changelog at the top of the next version of this file.*
