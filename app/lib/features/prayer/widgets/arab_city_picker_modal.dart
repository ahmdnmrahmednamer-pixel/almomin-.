import '../../../core/text/arabic_normalizer.dart';
import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/models/arab_countries.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/theme/app_theme.dart';

/// Shows the cascading Arab Country & City selection modal sheet
Future<void> showArabCityPickerModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const ArabCityPickerSheet(),
  );
}

class ArabCityPickerSheet extends StatefulWidget {
  const ArabCityPickerSheet({super.key});

  @override
  State<ArabCityPickerSheet> createState() => _ArabCityPickerSheetState();
}

class _ArabCityPickerSheetState extends State<ArabCityPickerSheet> {
  late ArabCountry _selectedCountry;
  String _citySearchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentLoc = PrayerService.instance.currentData?.locationName ?? '';
    // Determine initially selected country based on current active city
    _selectedCountry = ArabCountriesData.findCountryByCityName(currentLoc);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLoc = PrayerService.instance.currentData?.locationName ?? '';

    // Filter cities of the selected country
    final normCityQ = ArabicNormalizer.normalize(_citySearchQuery, loose: true);
    final filteredCities = _selectedCountry.cities.where((city) {
      if (_citySearchQuery.isEmpty) return true;
      return city.name.contains(_citySearchQuery) ||
          ArabicNormalizer.normalize(city.name, loose: true).contains(normCityQ);
    }).toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Drag Handle
            Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E3A2E), const Color(0xFF2D6A4F)]
                            : [AppColors.primaryGreen.withOpacity(0.15), AppColors.emeraldLight.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.4), width: 1.2),
                    ),
                    child: const Icon(Icons.public_rounded, color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختيار الدولة والمدينة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '٢٢ دولة عربية مع الضبط الفقهي والمواقيت الحية',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedText, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        ),
                        child: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Arab Country Dropdown Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF162920), const Color(0xFF1E3A2E)]
                              : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accentGold,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.flag_rounded, size: 16, color: AppColors.primaryGreen),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'اختر الدولة العربية:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<ArabCountry>(
                              value: _selectedCountry,
                              isExpanded: true,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGreen),
                              ),
                              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              items: ArabCountriesData.countries.map((country) {
                                return DropdownMenuItem<ArabCountry>(
                                  value: country,
                                  child: Row(
                                    children: [
                                      Text(country.flag, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          country.name,
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : AppColors.primaryGreen,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          '${country.cities.length} مدينة',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (newCountry) {
                                if (newCountry != null) {
                                  setState(() {
                                    _selectedCountry = newCountry;
                                    _citySearchQuery = '';
                                    _searchController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.accentGold),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'طريقة الحساب: ${_selectedCountry.methodDescription}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentGold,
                                      height: 1.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. City Search Filter within Selected Country
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مدينة في ${_selectedCountry.name}...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.mutedText,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                        suffixIcon: _citySearchQuery.isNotEmpty
                            ? IconButton(
                              tooltip: 'إغلاق أو مسح',
                                icon: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.clear_rounded, size: 16, color: Colors.black87),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _citySearchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? Colors.white10
                            : AppColors.primaryGreen.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _citySearchQuery = val.trim();
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Section Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مدن ومحافظات ${_selectedCountry.name} (${filteredCities.length})',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white70 : AppColors.primaryGreen,
                          ),
                        ),
                        if (currentLoc.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الموقع الحالي: $currentLoc',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 3. Dynamic City List with Distinct Button Rows
                    Expanded(
                      child: filteredCities.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_off_rounded,
                                    size: 48,
                                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد مدينة مطابقة لـ "$_citySearchQuery" في ${_selectedCountry.name}',
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : AppColors.mutedText,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 12),
                              itemCount: filteredCities.length,
                              itemBuilder: (context, idx) {
                                final city = filteredCities[idx];
                                final isCurrent = currentLoc.contains(city.name) ||
                                    city.name.contains(currentLoc);

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? (isDark ? const Color(0xFF1B3D2F) : const Color(0xFFE8F5E9))
                                        : (isDark ? AppColors.darkCard : Colors.white),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isCurrent
                                          ? AppColors.accentGold
                                          : (isDark ? Colors.white12 : Colors.grey.shade200),
                                      width: isCurrent ? 1.8 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isCurrent
                                            ? AppColors.accentGold.withOpacity(0.18)
                                            : Colors.black.withOpacity(0.03),
                                        blurRadius: isCurrent ? 8 : 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        final formattedName = '${city.name}، ${_selectedCountry.name}';
                                        final fullCity = CityCoordinate(
                                          formattedName,
                                          city.latitude,
                                          city.longitude,
                                          city.method,
                                          _selectedCountry.name,
                                        );

                                        await PrayerService.instance.setManualCity(fullCity);

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'تم ضبط الموقع على: $formattedName ومواقيت الصلاة تتحدث الآن باستمرار 🕌',
                                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: AppColors.primaryGreen,
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        child: Row(
                                          children: [
                                            // Distinct Leading Icon
                                            Container(
                                              padding: const EdgeInsets.all(9),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isCurrent
                                                      ? [const Color(0xFFD4AF37), const Color(0xFFB89628)]
                                                      : (isDark
                                                          ? [const Color(0xFF243B30), const Color(0xFF192A22)]
                                                          : [AppColors.primaryGreen.withOpacity(0.12), AppColors.emeraldLight.withOpacity(0.1)]),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: isCurrent
                                                    ? [
                                                        BoxShadow(
                                                          color: AppColors.accentGold.withOpacity(0.4),
                                                          blurRadius: 6,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Icon(
                                                isCurrent ? Icons.mosque_rounded : Icons.location_city_rounded,
                                                size: 20,
                                                color: isCurrent ? Colors.white : AppColors.primaryGreen,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Title & Subtitle with Crystal Clear Typography
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    city.name,
                                                    style: TextStyle(
                                                      fontSize: 15.5,
                                                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
                                                      color: isCurrent
                                                          ? AppColors.primaryGreen
                                                          : (isDark ? Colors.white : AppColors.lightText),
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    'إحداثيات: ${city.latitude.toStringAsFixed(2)}° N, ${city.longitude.toStringAsFixed(2)}° E',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark ? Colors.white54 : AppColors.mutedText,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Distinct Trailing Button Shape
                                            if (isCurrent)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.accentGold.withOpacity(0.35),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'مفعلة 🕋',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 11.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryGreen.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors.primaryGreen.withOpacity(0.3),
                                                    width: 1.2,
                                                  ),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.near_me_rounded, color: AppColors.primaryGreen, size: 14),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'اختيار 📍',
                                                      style: TextStyle(
                                                        color: AppColors.primaryGreen,
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 11.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // 4. Quick GPS Button at bottom with Prominent Shape and Gradient
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accentGold, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: PrayerService.instance.isLoading
                                ? null
                                : () async {
                                    final ok = await PrayerService.instance.requestGpsLocation();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? 'تم تحديد موقعك بدقة ومواقيت الصلاة متزامنة لحظياً'
                                                : (PrayerService.instance.errorMessage ?? 'تعذر تحديد الموقع'),
                                            style: const TextStyle(fontWeight: FontWeight.w800),
                                          ),
                                          backgroundColor: ok ? AppColors.primaryGreen : Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (PrayerService.instance.isLoading)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.satellite_alt_rounded, size: 18, color: AppColors.accentGold),
                                    ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Text(
                                      'تحديد موقعي الجغرافي تلقائياً عبر الأقمار الصناعية (GPS)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
