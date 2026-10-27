/// Type-safe paths to canonical app assets per Noor Noor Al-Momin Design System §14 & assets-provenance.csv.
abstract final class AppAssets {
  // -------------------------------------------------------------
  // BACKGROUNDS
  // -------------------------------------------------------------
  static const String bgSplashHero = 'assets/images/backgrounds/bg_01_splash_hero.svg';
  static const String bgHomeHeaderBanner = 'assets/images/backgrounds/bg_02_home_header_banner.svg';
  static const String bgMushafPaperTexture = 'assets/images/backgrounds/bg_03_mushaf_paper_texture.svg';

  // Prayer Time Backgrounds
  static const String bgPrayerFajr = 'assets/images/backgrounds/bg_06_prayer_fajr.svg';
  static const String bgPrayerSunrise = 'assets/images/backgrounds/bg_07_prayer_sunrise.svg';
  static const String bgPrayerDhuhr = 'assets/images/backgrounds/bg_08_prayer_dhuhr.svg';
  static const String bgPrayerAsr = 'assets/images/backgrounds/bg_09_prayer_asr.svg';
  static const String bgPrayerMaghrib = 'assets/images/backgrounds/bg_10_prayer_maghrib.svg';
  static const String bgPrayerIsha = 'assets/images/backgrounds/bg_11_prayer_isha.svg';

  // Adhkar & Qibla
  static const String bgAdhkarMorning = 'assets/images/backgrounds/bg_12_adhkar_morning.svg';
  static const String bgAdhkarEvening = 'assets/images/backgrounds/bg_13_adhkar_evening.svg';
  static const String bgQiblaBackdrop = 'assets/images/backgrounds/bg_14_qibla_backdrop.svg';

  // -------------------------------------------------------------
  // PATTERNS
  // -------------------------------------------------------------
  static const String patternTileLight = 'assets/images/patterns/bg_04_pattern_tile_light.svg';
  static const String patternTileDark = 'assets/images/patterns/bg_05_pattern_tile_dark.svg';

  // -------------------------------------------------------------
  // BRAND & LOGO
  // -------------------------------------------------------------
  static const String logoMark = 'assets/images/brand/logo_mark.svg';
  static const String appIconForeground = 'assets/images/brand/app_icon_foreground.svg';
  static const String playFeatureGraphic = 'assets/images/brand/br_04_play_feature_graphic.svg';

  // -------------------------------------------------------------
  // OCCASIONS
  // -------------------------------------------------------------
  static const String occasionRamadan = 'assets/images/occasions/bg_15_occasion_ramadan.svg';
  static const String occasionEid = 'assets/images/occasions/bg_16_occasion_eid.svg';
  static const String occasionLastTenNights = 'assets/images/occasions/bg_17_occasion_last_ten_nights.svg';
  static const String occasionFriday = 'assets/images/occasions/bg_18_occasion_friday.svg';

  // -------------------------------------------------------------
  // SHARE CARDS
  // -------------------------------------------------------------
  static const String shareEmeraldWatercolor = 'assets/images/share/bg_19_share_emerald_watercolor.svg';
  static const String shareNightSky = 'assets/images/share/bg_20_share_night_sky.svg';
  static const String shareCreamGoldCorners = 'assets/images/share/bg_21_share_cream_gold_corners.svg';
  static const String shareDesertDusk = 'assets/images/share/bg_22_share_desert_dusk.svg';
  static const String shareMistyMountains = 'assets/images/share/bg_23_share_misty_mountains.svg';
  static const String shareOceanSunrise = 'assets/images/share/bg_24_share_ocean_sunrise.svg';

  // -------------------------------------------------------------
  // ASSET COLLECTIONS
  // -------------------------------------------------------------
  static const List<String> backgrounds = [
    bgSplashHero,
    bgHomeHeaderBanner,
    bgMushafPaperTexture,
    bgPrayerFajr,
    bgPrayerSunrise,
    bgPrayerDhuhr,
    bgPrayerAsr,
    bgPrayerMaghrib,
    bgPrayerIsha,
    bgAdhkarMorning,
    bgAdhkarEvening,
    bgQiblaBackdrop,
  ];

  static const List<String> patterns = [
    patternTileLight,
    patternTileDark,
  ];

  static const List<String> brand = [
    logoMark,
    appIconForeground,
    playFeatureGraphic,
  ];

  static const List<String> occasions = [
    occasionRamadan,
    occasionEid,
    occasionLastTenNights,
    occasionFriday,
  ];

  static const List<String> shareBackgrounds = [
    shareEmeraldWatercolor,
    shareNightSky,
    shareCreamGoldCorners,
    shareDesertDusk,
    shareMistyMountains,
    shareOceanSunrise,
  ];

  static const List<String> allAssets = [
    ...backgrounds,
    ...patterns,
    ...brand,
    ...occasions,
    ...shareBackgrounds,
  ];

  /// Maps prayer name to its canonical background asset
  static String backgroundForPrayer(String prayerName) {
    final normalized = prayerName.trim().toLowerCase();
    switch (normalized) {
      case 'الفجر':
      case 'fajr':
        return bgPrayerFajr;
      case 'الشروق':
      case 'sunrise':
        return bgPrayerSunrise;
      case 'الظهر':
      case 'dhuhr':
        return bgPrayerDhuhr;
      case 'العصر':
      case 'asr':
        return bgPrayerAsr;
      case 'المغرب':
      case 'maghrib':
        return bgPrayerMaghrib;
      case 'العشاء':
      case 'isha':
        return bgPrayerIsha;
      default:
        return bgHomeHeaderBanner;
    }
  }
}
