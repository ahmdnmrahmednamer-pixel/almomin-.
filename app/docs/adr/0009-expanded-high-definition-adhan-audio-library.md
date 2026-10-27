# ADR 0009: Expanded High-Definition Adhan Audio Library & Heritage Studio

## Status
Accepted & Implemented (Exit Code: 0, 23/23 Tests Passed)

## Context
The user requested significant expansion of the Adhan Audio Library in «Noor Al-Momin» (`منان طور اكتر المكتبة الصوطية الخاصة بي الاذان وضيف اذانات متعددة بجودة عالية`). The application needed a comprehensive collection of authentic, high-definition Adhans from world-renowned muezzins, holy sanctuaries, and Islamic heritages, paired with dedicated UI controls, live playback scrubbing, dedicated Fajr Adhan assignments, and drawer/modal accessibility.

## Decision
1. **Catalog Expansion (35+ High-Definition Adhans)**:
   - Added world-class voices to `IslamicAudioService.allTracks`:
     - Sheikh Nasser Al-Qatami (Riyadh, Hijaz Maqam)
     - Sheikh Majid Al-Zamil (Gentle & Serene)
     - Sheikh Mansoor Al-Salimi (Emotional & Heart-touching)
     - Sheikh Essam Bukhari (Prophet's Mosque Muezzin)
     - Sheikh Farooq Hadrawi (Haram Makkah, Rast Maqam)
     - Sheikh Naif Feeda (Senior Muezzin of Makkah)
     - Sheikh Mustafa Ismail (Historical Al-Azhar, Saba Maqam)
     - Sheikh Muhammad Omran (Master of Ibtihalat & Bayati Maqam)
     - Sheikh Islam Sobhi (Calming & Peaceful)
     - Sheikh Wadih Al-Yamani (Sanaa, Yemen)
     - Sheikh Idrees Abkar (Solemn & Moving)
     - Jamia Al-Zaytouna (Tunisia, Andalusian Maghrebi Heritage)
     - Gazi Husrev-beg Mosque (Sarajevo, Bosnia & Herzegovina)
     - Sheikh Abdulbasit Abdulsamad (Dedicated Fajr «Al-Salatu Khayrun Min Al-Nawm»)
     - Sheikh Nasser Al-Qatami (Dedicated Fajr)
     - Sheikh Hazza Al-Balushi (Sultanate of Oman)
2. **Dedicated Fajr Adhan Setting**:
   - Added `selectedFajrVoice` and `setSelectedFajrVoice(voiceKey)` in `PrayerNotificationService`.
   - Updated `AdhanControlScreen._startAudioPlayback` to automatically route Fajr prayer calls to the dedicated Fajr voice when distinct voice is enabled.
   - Added 1-tap "اعتماد للفجر 🌅" button in `_AdhanIqamahStudioSheet`.
3. **Live Playback Progress & Scrubbing**:
   - Integrated live duration/position counter and interactive slider in each track card when actively playing.
4. **App Navigation Integration**:
   - Added direct entry point in `AppNavigationDrawer`: "مكتبة الأذان واستوديو الأصوات".
   - Added shortcut button in `AdhanControlScreen` top app bar and in `_showAdhanOptionsModal`.

## Verification & Metrics
- 23/23 tests passed in `test/adhan_gestures_and_control_screen_test.dart`.
- `flutter analyze` clean (0 errors).
- Memory deliberation recorded as DELIB-1792755200.
