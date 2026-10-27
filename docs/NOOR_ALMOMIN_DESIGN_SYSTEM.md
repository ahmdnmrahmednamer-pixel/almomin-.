# Noor Noor Al-Momin (نور المؤمن) — Design System

> Version: **1.0 (draft)** · Companion to `NOOR_ALMOMIN_ENGINEERING_SPEC.md` (§9) and `ALMOMIN_IMAGE_PROMPTS.md`
> Platform: Android / Flutter · Language: Arabic only, RTL · Themes: Light, Sepia, Dark, True Black (OLED)

---

## 0. Purpose and Rules of Use

This document defines the visual language, tokens, components, and Flutter theme code for the app. It is the contract between design and engineering.

1. **Tokens first.** Screens MUST use tokens (colors, spacing, radii, text styles). No hard-coded hex values, no magic numbers in widgets.
2. **One change path.** Any change to a token or component is made here first (PR), then in code, then golden tests are updated.
3. **Quran text is special.** Quran typography and Mushaf colors have their own tokens and MUST NOT be restyled by feature code.
4. Items marked **[VERIFY]** depend on external facts (font licenses, library APIs) and must be checked at implementation time.

---

## 1. Design Principles

| Principle | Meaning in practice |
|-----------|---------------------|
| **Reverent calm** | Quiet colors, generous space, no loud animation, no gamified pressure. |
| **Text is the hero** | Quran, tafsir, and adhkar readability beats decoration every time. |
| **Fast and light** | Works smoothly on low-end Android; few shadows, no heavy blur, small assets. |
| **Familiar and consistent** | Standard Material 3 behavior with an Islamic identity layered on top. |
| **Inclusive** | Large text, high contrast options, screen-reader support, one-handed use. |
| **No living beings in imagery** | Respect for Islamic artistic conventions: geometry, architecture, nature, light. |

---

## 2. Color

### 2.1 Brand Palette (reference swatches)

| Name | Hex | Role |
|------|-----|------|
| Emerald 900 | `#0A3D2E` | Deepest brand green (gradients, pressed states) |
| **Emerald 700 (Primary)** | `#0F5B45` | Primary brand color (light themes) |
| Emerald 300 | `#5FC29A` | Primary on dark themes |
| Mint 100 | `#D7EBE2` | Primary container (light) |
| **Gold 500** | `#B8893A` | Accent: ornaments, icons, thin lines (decorative) |
| Gold 700 | `#7A5818` | Gold used for **text** on light backgrounds (AA contrast) |
| Gold 300 | `#D9B25F` | Gold on dark themes |
| Paper 50 | `#FBF8F1` | Light background (warm off-white) |
| Night 900 | `#0F1714` | Dark background (green-black) |

> Contrast targets are **WCAG AA** (4.5:1 body text, 3:1 large text/icons). Values below were chosen to meet them but MUST be validated with a contrast checker in M0 and in golden-test review.

### 2.2 Theme Tokens

| Token | Light | Sepia | Dark | True Black |
|-------|-------|-------|------|------------|
| `background` | `#FBF8F1` | `#F3E7CB` | `#0F1714` | `#000000` |
| `surface` | `#FFFFFF` | `#F8EFD9` | `#16211D` | `#0B0F0D` |
| `surfaceVariant` | `#F1EBDD` | `#EADBB6` | `#1F2D27` | `#141A17` |
| `primary` | `#0F5B45` | `#2F5A3F` | `#5FC29A` | `#5FC29A` |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | `#06281C` | `#06281C` |
| `primaryContainer` | `#D7EBE2` | `#D5E2C6` | `#1D4A3A` | `#14372B` |
| `onPrimaryContainer` | `#062E22` | `#1E3A28` | `#CFEFE2` | `#CFEFE2` |
| `secondary` (gold) | `#B8893A` | `#8F6A22` | `#D9B25F` | `#D9B25F` |
| `goldText` | `#7A5818` | `#6B4E14` | `#E6C57A` | `#E6C57A` |
| `textPrimary` | `#1B2420` | `#3A2D17` | `#E8EEE9` | `#EDEFEA` |
| `textSecondary` | `#4A5750` | `#5A4A2D` | `#A9B7AF` | `#A9B7AF` |
| `textTertiary` | `#5F6A64` | `#6E5C3A` | `#8A9A91` | `#8A9A91` |
| `divider` | `#E2DCCB` | `#D9C9A0` | `#2A3B34` | `#1E2824` |
| `outline` | `#C9C2AD` | `#BFAE82` | `#3A4F46` | `#2C3A34` |
| `error` | `#B3261E` | `#A32B22` | `#F2B8B5` | `#F2B8B5` |
| `success` | `#2E7D32` | `#3B6B2E` | `#81C784` | `#81C784` |
| `warning` | `#B26A00` | `#9A5B00` | `#FFB74D` | `#FFB74D` |
| `scrim` | `#000000` @ 40% | `#000000` @ 40% | `#000000` @ 60% | `#000000` @ 70% |

### 2.3 Mushaf / Quran-Specific Tokens

| Token | Light | Sepia | Dark | True Black |
|-------|-------|-------|------|------------|
| `mushafPaper` | `#FFFDF7` | `#F6EACB` | `#121A17` | `#000000` |
| `quranText` | `#1B1B18` | `#2E2312` | `#F2EFE6` | `#F2EFE6` |
| `ayahPlaying` (current ayah highlight) | `#CFE8DC` | `#D3E0BE` | `#1F3A30` | `#17302A` |
| `ayahSelected` | `#F3E3B8` | `#E8D49A` | `#3A3019` | `#2E2713` |
| `ayahMarker` (end-of-ayah ornament) | `#B8893A` | `#8F6A22` | `#D9B25F` | `#D9B25F` |
| `pageFrame` (page border) | `#C9B47A` | `#B39B5E` | `#3A4F46` | `#2C3A34` |

Rules:
- **Never** put colored text on `ayahPlaying`/`ayahSelected` other than `quranText`.
- Highlight is a background tint, never a text-color change, so tashkeel stays readable.
- Bookmark color choices (user-pickable): green `#2E9E6B`, gold `#B8893A`, blue `#2F6FB5`, rose `#B5476B`, violet `#6B4FB5`. Always shown with a shape/label too (not color alone).

### 2.4 Tajweed Palette (proposal — v1.2) **[VERIFY with the Review Board / source dataset classes]**

| Rule (Arabic label) | Light-theme color | Note |
|---------------------|-------------------|------|
| غنة | `#2E9E6B` | |
| إخفاء | `#C2410C` | |
| إدغام | `#0E7490` | |
| إقلاب | `#7C3AED` | |
| قلقلة | `#2563EB` | |
| مد (أنواع) | `#B45309` → `#D97706` | different shades per type |
| حروف لا تُنطق | `#8B8B85` | grey |

Dark themes: lighten each by ~20–30% lightness and re-check contrast against `mushafPaper`. A legend screen lists **names + colors** (never color alone).

### 2.5 Usage Rules
- Primary green = main actions, active states, key icons. Gold = ornament and highlights, **not** primary buttons.
- Maximum **one** accent (gold) element per card.
- Gold as text color uses `goldText`, never `secondary`.
- Dark themes avoid pure white; text max `#EDEFEA`.
- Sepia theme exists mainly for long reading sessions (Mushaf, tafsir, library).

---

## 3. Typography

### 3.1 Families

| Use | Family | License | Notes |
|-----|--------|---------|-------|
| UI text | **IBM Plex Sans Arabic** (primary) — fallback **Noto Naskh Arabic** | SIL OFL | Weights 400, 500, 600, 700 bundled. Decide final choice in M0 after readability test at 14–18 sp; Cairo/Tajawal are alternates. |
| Quran text mode | **KFGQPC Uthmanic Script HAFS** (King Fahd Complex) | **[VERIFY]** redistribution terms | Never substituted. |
| Quran page mode | Madinah per-page glyph fonts (QPC style) | **[VERIFY]** | Rendered only by `MushafPageView`. Glyph text is not real Unicode (see Engineering Spec §11.4). |
| Digits | Arabic-Indic (`٠١٢٣`) by default; Western optional | — | Applies to all numerals in UI, including counters and times. |

### 3.2 UI Type Scale (sp; scales with system font size)

| Style | Size / Line height | Weight | Use |
|-------|--------------------|--------|-----|
| `display` | 32 / 44 | 700 | Onboarding titles, big countdown |
| `headline` | 24 / 34 | 700 | Screen titles on Home sections |
| `title` | 20 / 30 | 600 | App bar titles, card titles |
| `bodyLarge` | 18 / 30 | 400 | Tafsir, adhkar reading text |
| `bodyMedium` | 16 / 26 | 400 | Default body |
| `bodySmall` | 14 / 22 | 400 | Secondary text, captions |
| `label` | 14 / 20 | 600 | Buttons, chips, tabs |
| `caption` | 12 / 18 | 500 | Metadata, never for essential info |

Arabic needs taller line height than Latin: keep ≥ 1.5× font size for body text.

### 3.3 Quran Text Scale (text mode)

| Step | Size (sp) | Line height multiplier |
|------|-----------|------------------------|
| XS | 22 | 2.0 |
| S | 26 | 2.0 |
| **M (default)** | 30 | 2.05 |
| L | 36 | 2.1 |
| XL | 44 | 2.15 |
| XXL | 54 | 2.2 |

- Never apply letter-spacing to Arabic. Never use `FontWeight` other than regular for Quran text.
- Justified alignment ONLY in page mode (handled by glyph layout). Text mode is right-aligned (start in RTL).
- Tafsir/book text uses `bodyLarge` by default and shares the user's reading font-size multiplier (0.85×–1.6×).

---

## 4. Layout and Spacing

### 4.1 Grid and Spacing Scale (4 dp base)

`space.x1 = 4` · `x2 = 8` · `x3 = 12` · `x4 = 16` · `x5 = 20` · `x6 = 24` · `x8 = 32` · `x10 = 40` · `x12 = 48` · `x16 = 64`

- Screen horizontal padding: **16 dp** (phones), 24 dp (≥ 600 dp wide).
- Vertical rhythm between sections: 24 dp; between related items: 8–12 dp.
- Minimum touch target: **48 × 48 dp**.

### 4.2 Breakpoints
| Class | Width | Behavior |
|-------|-------|----------|
| Compact | < 600 dp | Single column, bottom navigation |
| Medium | 600–839 dp | Two-column lists where useful, bottom navigation |
| Expanded | ≥ 840 dp | Navigation rail; Mushaf can show two pages side by side (landscape tablets) |

### 4.3 RTL Rules
- App is RTL-only. Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end`, never `left/right`.
- Mirror directional icons (back, forward, send, list-progress direction).
- Do **not** mirror: the play triangle (keep it pointing right, as on every Android media player), pause, clocks, checkmarks.
- Next/previous skip icons: decide in M0 with a quick usability test whether they follow RTL reading order or the standard media-player convention, then record the decision as an ADR.
- Progress bars and sliders fill from right to left.
- Numbers inside Arabic text stay in Arabic-Indic digits; times formatted `٠٥:١٢ ص`.

### 4.4 Safe Areas
Support edge-to-edge (Android 15+): content respects system bar insets; Mushaf background extends under the status bar; bottom navigation adds the bottom inset.

---

## 5. Shape, Elevation, Borders

| Token | Value | Use |
|-------|-------|-----|
| `radius.sm` | 8 | Chips, small inputs |
| `radius.md` | 12 | Buttons, list tiles |
| `radius.lg` | 16 | Cards |
| `radius.xl` | 24 | Bottom sheets (top corners), hero cards |
| `radius.full` | 999 | Pills, FABs, avatars |

- **Prefer tonal surfaces and 1 dp borders (`divider`) over shadows** (cheaper and calmer on low-end devices).
- Elevation levels: 0 (flat), 1 (cards, subtle), 3 (bottom sheets, mini-player). Shadows are soft, `#000` at ≤ 12%.
- Ornamental dividers (thin gold line with a small diamond) are allowed between Quran sections only.

---

## 6. Iconography

- Base set: **Material Symbols Rounded** (outlined, weight 400, optical size 24). Fill only for the active state.
- Sizes: 20 (inline), 24 (default), 28 (bottom nav), 32+ (empty states). Stroke consistency across custom icons.
- Custom icons (to be drawn as SVG, 24 dp grid, 2 dp stroke): Mushaf, Ayah-end marker, Rub el Hizb (۞), Qibla, Tasbih bead, Hijri calendar, Prayer rug, Adhan speaker, Tafsir, I'rab, Sabab (reason), Khatma.
- No faces, human figures, or animals in any icon.
- Android notification small icon: pure white silhouette on transparent, drawn separately (do **not** derive from AI images).

---

## 7. Imagery and Patterns

### 7.1 Sources
Backgrounds and brand imagery are produced from `ALMOMIN_IMAGE_PROMPTS.md`. Every image has a provenance record (prompt, model, date, edits).

### 7.2 Usage Rules
| Rule | Detail |
|------|--------|
| Text over images | ALWAYS add a scrim gradient (token `scrim`, bottom-to-top or top-to-bottom) so text meets contrast 4.5:1 (check worst-case pixel region). |
| Quran text never over busy imagery | Quran text sits on `mushafPaper` or on a plain tinted card, never directly on photos/art. Share-image cards are the one exception, using designated "calm" backgrounds with a scrim. |
| Pattern opacity | Geometric tiles used as texture at **4–8% opacity** on surfaces. |
| No living beings | No people, faces, hands, animals, or birds. |
| No text in images | Images contain no letters/calligraphy; all text is real, selectable app text. |
| Performance | Bundled images ≤ 150 KB each (WebP). Larger or optional sets ship as downloadable packs. |
| Dark variants | Provide dark-friendly versions for hero/prayer backgrounds, or apply a 40–55% dark overlay. |

### 7.3 Prayer-Time Mood Mapping
Fajr (blue hour) · Sunrise (gold) · Dhuhr (bright pale) · Asr (amber) · Maghrib (sunset to teal) · Isha (night stars). The prayer screen header and next-prayer card use the matching background.

---

## 8. Motion

| Token | Duration | Curve | Use |
|-------|----------|-------|-----|
| `motion.fast` | 120 ms | `easeOut` | Taps, toggles |
| `motion.base` | 200 ms | `easeOutCubic` | Sheets, expansions, fades |
| `motion.slow` | 320 ms | `easeInOutCubic` | Page transitions, hero changes |

- Page turn in Mushaf: native `PageView` physics; no 3D page-curl effects.
- Ayah highlight transitions: 150 ms fade of the background tint.
- Respect system "Remove animations": all durations → 0.
- No confetti or flashy celebrations; completion moments use a soft gold glow + a short dua.

---

## 9. Components

Each component MUST have: all states (default, pressed, focused, disabled, loading, error where relevant), light + dark golden tests, 1.0× and 2.0× font scale tests, and TalkBack labels.

### 9.1 Buttons
| Type | Spec |
|------|------|
| **Primary (Filled)** | Height 52, radius `md`, bg `primary`, text `onPrimary` (`label`). Full-width on mobile forms. |
| **Secondary (Tonal)** | bg `primaryContainer`, text `onPrimaryContainer`. |
| **Outlined** | 1 dp `outline`, text `primary`. |
| **Text** | No container, text `primary`, min 48 dp touch target. |
| **Icon button** | 48 × 48 target, 24 icon; filled-tonal variant for player controls. |
| **Play FAB** | 64 dp circle, `primary`, icon `onPrimary`. |

### 9.2 App Bar
Height 56, background `background` (no elevation; 1 dp divider when scrolled), title `title`, actions max 3 icons. Mushaf app bar auto-hides with the reading chrome.

### 9.3 Bottom Navigation
5 destinations (Home, Quran, Listen, Prayer, More). Height 72 + inset. Icon 28 + label `caption` (never hide labels). Active: filled icon + `primaryContainer` pill indicator.

### 9.4 Cards
- Standard card: `surface`, radius `lg`, 1 dp `divider` border, padding 16.
- Hero card (next prayer, continue reading): radius `xl`, background image (from prompts) + scrim, text `onPrimary`-style white (verify contrast).
- Card tap feedback: ripple tinted `primary` @ 12%.

### 9.5 Lists
- List tile: min height 64, leading (number badge/icon), title `title`/`bodyMedium`, subtitle `bodySmall`, trailing icon/status.
- **Surah tile:** right: number inside an 8-point star badge (gold outline), center: surah name (Quran font? **No** — UI font `title`) + subtitle "مكية • ٧ آيات" using `bodySmall`; trailing: download/play state.
- Dividers: `divider` 1 dp, inset by 16.

### 9.6 Ayah Row (text mode)
- Container: full width, padding 16/12.
- Ayah text in Quran font at user size; ayah end marker `ayahMarker` with number inside an ornamental circle (custom painter or font glyph; number in Arabic-Indic).
- States: normal, **playing** (`ayahPlaying` background), **selected** (`ayahSelected`), bookmarked (small ribbon icon at the start edge).
- Long-press/tap → Ayah Action Sheet.

### 9.7 Ayah Action Sheet (bottom sheet)
Radius `xl` top corners, drag handle, header shows "سورة … • آية …". Primary row of 4–5 large actions (استمع، تفسير، علامة، نسخ، مشاركة); secondary list below (v1.1+: إعراب، أسباب النزول، معاني الكلمات). Max height 70% of screen; scrollable.

### 9.8 Mini Player
Height 64, `surface` with elevation 3, radius `lg` top corners, shows reciter + current surah/ayah, play/pause, next, thin progress line on the top edge. Tapping expands to the full player (shared-element-like transition 320 ms).

### 9.9 Full Player
Reciter name and style, surah name (`headline`), current ayah preview in Quran text (optional), seek bar with elapsed/remaining times, transport controls, secondary row: speed, sleep timer, repeat, download, playlist. Background: calm gradient from `primaryContainer` to `background` (no busy image).

### 9.10 Prayer Time Card
- **Next-prayer hero:** large countdown (`display`), prayer name (`headline`), time, background by prayer mood.
- **Today list:** 6 rows (الفجر، الشروق، الظهر، العصر، المغرب، العشاء), the current prayer row tinted `primaryContainer`, the bell icon toggles notification state (off / silent / adhan) with a clear label on long-press.

### 9.11 Dhikr Card and Counter
Card with dhikr text in `bodyLarge` (tashkeel supported), source line `caption`, repeat badge, tap area for counting (entire card), circular progress ring (primary on `surfaceVariant`), subtle haptic on each count and stronger on completion. "Next" auto-advances after a 300 ms pause.

### 9.12 Download Tile
Leading icon (reciter/pack), title, size, state: *not downloaded* (cloud-download icon), *downloading* (determinate ring + percent + cancel), *paused*, *downloaded* (check, tap for delete), *error* (retry). Wi-Fi-only chip when applicable.

### 9.13 Search Field
Height 52, radius `full`, leading search icon, clear action, placeholder "ابحث في القرآن أو اكتب رقم الآية". Results list with matched-word highlight (`ayahSelected` background).

### 9.14 Chips and Tabs
Chips: height 36, radius `sm`, selected = `primaryContainer`. Tabs (Index screen): text tabs with 3 dp primary indicator, scrollable.

### 9.15 Dialogs, Snackbars, Banners
- Dialogs: radius `xl`, title `title`, 2 actions max, destructive action text uses `error`.
- Snackbars: bottom, 4 s, with Undo where reversible; Arabic imperative short text.
- Inline banners (e.g., "لم يتم تفعيل صلاحية التنبيهات") use `warning` tint and a clear action button.

### 9.16 Empty / Error / Loading States
- **Empty:** simple geometric illustration (from the prompts, flat, no figures) + one sentence + one action.
- **Error:** polite message + "إعادة المحاولة" button; never expose raw exceptions.
- **Loading:** skeleton shimmer for lists (≤ 400 ms before showing), circular progress for short operations; no blocking full-screen spinners except first content-pack install.

### 9.17 Sliders and Toggles
Switch: standard Material 3 with `primary` track. Slider thumb 20 dp, track 4 dp; font-size slider shows a live preview line of Quran text.

---

## 10. Screen Layout Recipes

| Screen | Layout summary |
|--------|----------------|
| **Home** | Greeting + Hijri date (top) → Next-prayer hero → "Continue reading" card → Ayah-of-the-day card → 2×2 shortcuts (أذكار، ختمة، استماع، قبلة) → (later) daily habits. |
| **Mushaf (page mode)** | Full-bleed `mushafPaper`; page centered with `pageFrame` border; header strip (surah, juz, page number) at `caption`; chrome auto-hides, tap toggles; mini-player docks at the bottom. |
| **Mushaf (text mode)** | Surah header ornament (not an ayah) → basmala (Quran font, centered) → ayah rows. Sticky position indicator. |
| **Index** | Tabs: السور، الأجزاء، الصفحات، العلامات. Search icon in app bar. |
| **Listen** | Horizontal featured reciters row → searchable reciters list → recent. Reciter detail: surah list with download state. |
| **Prayer** | Prayer hero (by mood) → today's list → Qibla entry → reliability banner if permissions missing. |
| **Adhkar** | Category grid (2 columns, icon + title) → dhikr reader (swipe between items, counter ring). |
| **Settings** | Grouped lists; each group header `label` in `goldText`; live preview for reading settings at the top. |
| **Library (v1.3)** | Category chips → book cards grid (2 columns) → reader with sepia default. |

---

## 11. Accessibility Checklist (per screen, before merge)

- [ ] All touch targets ≥ 48 dp; spacing ≥ 8 dp between targets.
- [ ] Text contrast ≥ 4.5:1 (3:1 for large text and icons) in all four themes.
- [ ] Layout intact at 200% font scale; no clipped/overlapping text; vertical scrolling available.
- [ ] Every control has a Semantics label in Arabic; images are decorative (`excludeFromSemantics`) or labeled.
- [ ] Mushaf page mode exposes canonical ayah text for screen readers (not glyph codes).
- [ ] No information by color alone (icons/labels accompany color).
- [ ] Reduce-motion respected; no auto-playing audio without user action.
- [ ] Focus order follows RTL reading order; hardware keyboard navigation works.

---

## 12. Arabic Voice and Copy Guidelines

- Modern Standard Arabic, warm and respectful, short sentences. Avoid slang in religious contexts.
- Use second-person singular neutral forms; prefer verbs for actions ("حمّل"، "استمع").
- No exclamation marks except in celebratory completion messages (max one).
- Standard terms: **علامة** (bookmark), **المفضلة** (favorites), **التفسير**، **الإعراب**، **أسباب النزول**، **الختمة**، **الأذكار**، **القبلة**، **مواقيت الصلاة**.
- Notification copy is brief and gentle ("حان الآن موعد صلاة العصر"), no guilt language.
- Errors: say what happened + what to do next.

---

## 13. Flutter Implementation

File layout: `app/lib/app/theme/` → `tokens.dart`, `app_colors.dart`, `app_theme.dart`, `quran_text.dart`.

### 13.1 `tokens.dart`

```dart
import 'package:flutter/material.dart';

/// Spacing scale (4 dp base)
abstract final class Space {
  static const double x1 = 4, x2 = 8, x3 = 12, x4 = 16, x5 = 20, x6 = 24,
      x8 = 32, x10 = 40, x12 = 48, x16 = 64;
}

abstract final class Radii {
  static const double sm = 8, md = 12, lg = 16, xl = 24, full = 999;
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Curve easeBase = Curves.easeOutCubic;
}

/// Extra tokens that do not exist in Material's ColorScheme.
@immutable
class AlMominTokens extends ThemeExtension<AlMominTokens> {
  const AlMominTokens({
    required this.gold,
    required this.goldText,
    required this.mushafPaper,
    required this.quranText,
    required this.ayahPlaying,
    required this.ayahSelected,
    required this.ayahMarker,
    required this.pageFrame,
    required this.success,
    required this.warning,
    required this.scrim,
    required this.textTertiary,
  });

  final Color gold;
  final Color goldText;
  final Color mushafPaper;
  final Color quranText;
  final Color ayahPlaying;
  final Color ayahSelected;
  final Color ayahMarker;
  final Color pageFrame;
  final Color success;
  final Color warning;
  final Color scrim;
  final Color textTertiary;

  @override
  AlMominTokens copyWith({
    Color? gold, Color? goldText, Color? mushafPaper, Color? quranText,
    Color? ayahPlaying, Color? ayahSelected, Color? ayahMarker, Color? pageFrame,
    Color? success, Color? warning, Color? scrim, Color? textTertiary,
  }) {
    return AlMominTokens(
      gold: gold ?? this.gold,
      goldText: goldText ?? this.goldText,
      mushafPaper: mushafPaper ?? this.mushafPaper,
      quranText: quranText ?? this.quranText,
      ayahPlaying: ayahPlaying ?? this.ayahPlaying,
      ayahSelected: ayahSelected ?? this.ayahSelected,
      ayahMarker: ayahMarker ?? this.ayahMarker,
      pageFrame: pageFrame ?? this.pageFrame,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      scrim: scrim ?? this.scrim,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AlMominTokens lerp(ThemeExtension<AlMominTokens>? other, double t) {
    if (other is! AlMominTokens) return this;
    return AlMominTokens(
      gold: Color.lerp(gold, other.gold, t)!,
      goldText: Color.lerp(goldText, other.goldText, t)!,
      mushafPaper: Color.lerp(mushafPaper, other.mushafPaper, t)!,
      quranText: Color.lerp(quranText, other.quranText, t)!,
      ayahPlaying: Color.lerp(ayahPlaying, other.ayahPlaying, t)!,
      ayahSelected: Color.lerp(ayahSelected, other.ayahSelected, t)!,
      ayahMarker: Color.lerp(ayahMarker, other.ayahMarker, t)!,
      pageFrame: Color.lerp(pageFrame, other.pageFrame, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

extension AlMominThemeX on BuildContext {
  AlMominTokens get tokens => Theme.of(this).extension<AlMominTokens>()!;
}
```

### 13.2 `app_colors.dart` (the four themes)

```dart
import 'package:flutter/material.dart';
import 'tokens.dart';

enum AppThemeMode { light, sepia, dark, black }

abstract final class AppColors {
  // ---------- LIGHT ----------
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F5B45),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD7EBE2),
    onPrimaryContainer: Color(0xFF062E22),
    secondary: Color(0xFFB8893A),
    onSecondary: Color(0xFF1B1405),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B2420),
    surfaceContainerHighest: Color(0xFFF1EBDD),
    onSurfaceVariant: Color(0xFF4A5750),
    outline: Color(0xFFC9C2AD),
    outlineVariant: Color(0xFFE2DCCB),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
  );
  static const AlMominTokens lightTokens = AlMominTokens(
    gold: Color(0xFFB8893A),
    goldText: Color(0xFF7A5818),
    mushafPaper: Color(0xFFFFFDF7),
    quranText: Color(0xFF1B1B18),
    ayahPlaying: Color(0xFFCFE8DC),
    ayahSelected: Color(0xFFF3E3B8),
    ayahMarker: Color(0xFFB8893A),
    pageFrame: Color(0xFFC9B47A),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB26A00),
    scrim: Color(0x66000000),
    textTertiary: Color(0xFF5F6A64),
  );
  static const Color lightBackground = Color(0xFFFBF8F1);

  // ---------- SEPIA ----------
  static const ColorScheme sepiaScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2F5A3F),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD5E2C6),
    onPrimaryContainer: Color(0xFF1E3A28),
    secondary: Color(0xFF8F6A22),
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFF8EFD9),
    onSurface: Color(0xFF3A2D17),
    surfaceContainerHighest: Color(0xFFEADBB6),
    onSurfaceVariant: Color(0xFF5A4A2D),
    outline: Color(0xFFBFAE82),
    outlineVariant: Color(0xFFD9C9A0),
    error: Color(0xFFA32B22),
    onError: Color(0xFFFFFFFF),
  );
  static const AlMominTokens sepiaTokens = AlMominTokens(
    gold: Color(0xFF8F6A22),
    goldText: Color(0xFF6B4E14),
    mushafPaper: Color(0xFFF6EACB),
    quranText: Color(0xFF2E2312),
    ayahPlaying: Color(0xFFD3E0BE),
    ayahSelected: Color(0xFFE8D49A),
    ayahMarker: Color(0xFF8F6A22),
    pageFrame: Color(0xFFB39B5E),
    success: Color(0xFF3B6B2E),
    warning: Color(0xFF9A5B00),
    scrim: Color(0x66000000),
    textTertiary: Color(0xFF6E5C3A),
  );
  static const Color sepiaBackground = Color(0xFFF3E7CB);

  // ---------- DARK ----------
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5FC29A),
    onPrimary: Color(0xFF06281C),
    primaryContainer: Color(0xFF1D4A3A),
    onPrimaryContainer: Color(0xFFCFEFE2),
    secondary: Color(0xFFD9B25F),
    onSecondary: Color(0xFF2A1F05),
    surface: Color(0xFF16211D),
    onSurface: Color(0xFFE8EEE9),
    surfaceContainerHighest: Color(0xFF1F2D27),
    onSurfaceVariant: Color(0xFFA9B7AF),
    outline: Color(0xFF3A4F46),
    outlineVariant: Color(0xFF2A3B34),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF3B0A07),
  );
  static const AlMominTokens darkTokens = AlMominTokens(
    gold: Color(0xFFD9B25F),
    goldText: Color(0xFFE6C57A),
    mushafPaper: Color(0xFF121A17),
    quranText: Color(0xFFF2EFE6),
    ayahPlaying: Color(0xFF1F3A30),
    ayahSelected: Color(0xFF3A3019),
    ayahMarker: Color(0xFFD9B25F),
    pageFrame: Color(0xFF3A4F46),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    scrim: Color(0x99000000),
    textTertiary: Color(0xFF8A9A91),
  );
  static const Color darkBackground = Color(0xFF0F1714);

  // ---------- TRUE BLACK (OLED) ----------
  static final ColorScheme blackScheme = darkScheme.copyWith(
    surface: const Color(0xFF0B0F0D),
    primaryContainer: const Color(0xFF14372B),
    surfaceContainerHighest: const Color(0xFF141A17),
    outline: const Color(0xFF2C3A34),
    outlineVariant: const Color(0xFF1E2824),
  );
  static final AlMominTokens blackTokens = darkTokens.copyWith(
    mushafPaper: const Color(0xFF000000),
    pageFrame: const Color(0xFF2C3A34),
    ayahPlaying: const Color(0xFF17302A),
    ayahSelected: const Color(0xFF2E2713),
    scrim: const Color(0xB3000000),
  );
  static const Color blackBackground = Color(0xFF000000);
}
```

### 13.3 `quran_text.dart`

```dart
import 'package:flutter/material.dart';

/// Quran text styles. Fonts are declared in pubspec.yaml (see §14).
abstract final class QuranText {
  static const String fontFamily = 'KFGQPCHafs'; // [VERIFY] exact family name from the font file
  static const List<double> sizes = [22, 26, 30, 36, 44, 54];
  static const List<double> heights = [2.0, 2.0, 2.05, 2.1, 2.15, 2.2];

  static TextStyle style({required int sizeStep, required Color color}) {
    final i = sizeStep.clamp(0, sizes.length - 1);
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: sizes[i],
      height: heights[i],
      color: color,
      fontWeight: FontWeight.w400,
      letterSpacing: 0, // never add spacing to Arabic
    );
  }
}
```

### 13.4 `app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'tokens.dart';

abstract final class AppTheme {
  static const String uiFont = 'IBMPlexSansArabic'; // fallback: NotoNaskhArabic

  static ThemeData of(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return _build(AppColors.lightScheme, AppColors.lightTokens, AppColors.lightBackground);
      case AppThemeMode.sepia:
        return _build(AppColors.sepiaScheme, AppColors.sepiaTokens, AppColors.sepiaBackground);
      case AppThemeMode.dark:
        return _build(AppColors.darkScheme, AppColors.darkTokens, AppColors.darkBackground);
      case AppThemeMode.black:
        return _build(AppColors.blackScheme, AppColors.blackTokens, AppColors.blackBackground);
    }
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    TextStyle s(double size, double lineHeightPx, FontWeight w, Color c) => TextStyle(
          fontFamily: uiFont,
          fontSize: size,
          height: lineHeightPx / size,
          fontWeight: w,
          color: c,
          letterSpacing: 0,
        );
    return TextTheme(
      displayMedium: s(32, 44, FontWeight.w700, primary),
      headlineMedium: s(24, 34, FontWeight.w700, primary),
      titleLarge: s(20, 30, FontWeight.w600, primary),
      bodyLarge: s(18, 30, FontWeight.w400, primary),
      bodyMedium: s(16, 26, FontWeight.w400, primary),
      bodySmall: s(14, 22, FontWeight.w400, secondary),
      labelLarge: s(14, 20, FontWeight.w600, primary),
      labelSmall: s(12, 18, FontWeight.w500, secondary),
    );
  }

  static ThemeData _build(ColorScheme scheme, AlMominTokens tokens, Color background) {
    final text = _textTheme(scheme.onSurface, scheme.onSurfaceVariant);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: uiFont,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[tokens],
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48), textStyle: text.labelLarge),
      ),
      // NOTE: In recent Flutter versions use CardThemeData / DialogThemeData. [VERIFY]
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
        side: BorderSide(color: scheme.outline),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: Space.x4, vertical: Space.x4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.full), borderSide: BorderSide.none),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
      sliderTheme: SliderThemeData(trackHeight: 4, thumbColor: scheme.primary, activeTrackColor: scheme.primary),
    );
  }
}
```

Usage in widgets:

```dart
final t = Theme.of(context).extension<AlMominTokens>()!;
Container(color: isPlaying ? t.ayahPlaying : Colors.transparent, /* ... */);
```

Notes:
- Force RTL at the app root: `Directionality(textDirection: TextDirection.rtl, child: ...)` and `locale: Locale('ar')`.
- Respect system font scale; clamp only extreme values (e.g. max 2.0) via `MediaQuery.withClampedTextScaling`.
- Theme switching is persisted in `setting` table (`theme_mode`).

---

## 14. Assets: Naming, Formats, Sizes

```
app/assets/
  fonts/              IBMPlexSansArabic-*.ttf, KFGQPCHafs.ttf, (page fonts as pack)
  images/
    backgrounds/      bg_prayer_fajr.webp, bg_home_header.webp, ...
    patterns/         pattern_khatam_light.webp, pattern_khatam_dark.webp
    brand/            logo_mark.svg, app_icon_foreground.svg ...
    illustrations/    empty_*.svg
  audio/adhan/        adhan_<name>.ogg
```

- Naming: `snake_case`, prefix by type (`bg_`, `pattern_`, `empty_`, `logo_`), suffix `_dark` for variants.
- Raster: **WebP**, quality ~80; provide 1× and 2× only for UI-critical images; full-bleed backgrounds 1080 px wide (phones) are enough. Budget ≤ 150 KB each when bundled.
- Vector (SVG) for icons, ornaments, logo, empty states.
- App icon: Android **adaptive icon** (foreground + background layers, key shape inside the central ~66% safe zone) + monochrome themed icon layer. Redraw the final icon as vector; use AI output only as a concept reference.
- Declare fonts and assets in `pubspec.yaml`; record each asset's license/provenance in `THIRD_PARTY_LICENSES.md` and `docs/assets-provenance.csv`.

---

## 15. Governance and Quality

- **Golden tests** for: buttons, cards, ayah row (all states), prayer card, mini-player, dhikr card, bottom sheet — in 4 themes × (1.0×, 2.0×) font scale.
- Design review checklist in PR template: tokens only · RTL verified · contrast verified · TalkBack labels · no living-being imagery · no text baked in images.
- Token changes bump the minor version of this document and are noted in `docs/design-changelog.md`.
- A living Figma file mirrors these tokens (Figma Variables with the same names) — source of truth remains this document + `tokens.dart` until Figma is set up.

---

*End of Design System.*
