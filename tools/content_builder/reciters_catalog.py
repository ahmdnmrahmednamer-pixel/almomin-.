"""
Reciter Shortlist (35, all Hafs) according to Appendix B of NOOR_ALMOMIN_ENGINEERING_SPEC.md.
Provides metadata, server endpoints, and capability flags (ayah-files, surah-file, timings).
"""

RECITERS_35 = [
    # 1. محمود خليل الحصري (مرتل)
    (
        "husary_murattal", "محمود خليل الحصري", "مرتل", 1, 128, 1, 1, 1,
        "https://everyayah.com/data/Husary_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server13.mp3quran.net/husr/{surah_3}.mp3",
        "EveryAyah/mp3quran (Egyptian authority)"
    ),
    # 2. محمود خليل الحصري (المعلم)
    (
        "husary_muallim", "محمود خليل الحصري", "المعلم", 2, 128, 1, 1, 0,
        "https://everyayah.com/data/Husary_Muallim_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server13.mp3quran.net/husr_moalm/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 3. محمد صديق المنشاوي (مرتل)
    (
        "minshawi_murattal", "محمد صديق المنشاوي", "مرتل", 3, 128, 1, 1, 1,
        "https://everyayah.com/data/Minshawy_Murattal_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server10.mp3quran.net/minsh/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 4. محمد صديق المنشاوي (مجود)
    (
        "minshawi_mujawwad", "محمد صديق المنشاوي", "مجود", 4, 128, 1, 1, 0,
        "https://everyayah.com/data/Minshawy_Mujawwad_192kbps/{surah_3}{ayah_3}.mp3",
        "https://server10.mp3quran.net/minsh_mjwd/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 5. عبد الباسط عبد الصمد (مرتل)
    (
        "abdulbasit_murattal", "عبد الباسط عبد الصمد", "مرتل", 5, 192, 1, 1, 1,
        "https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/{surah_3}{ayah_3}.mp3",
        "https://server7.mp3quran.net/basit/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 6. عبد الباسط عبد الصمد (مجود)
    (
        "abdulbasit_mujawwad", "عبد الباسط عبد الصمد", "مجود", 6, 128, 1, 1, 0,
        "https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server7.mp3quran.net/basit_mjwd/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 7. مصطفى إسماعيل
    (
        "mustafa_ismail", "مصطفى إسماعيل", "مجود", 7, 128, 1, 1, 1,
        "https://everyayah.com/data/Mustafa_Ismail_48kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/mustafa/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 8. محمود علي البنا
    (
        "banna_murattal", "محمود علي البنا", "مرتل", 8, 128, 1, 1, 1,
        "https://everyayah.com/data/Mahmoud_Ali_Al_Banna_32kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/bna/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 9. محمد رفعت
    (
        "muhammad_rifaat", "محمد رفعت", "مجود", 9, 64, 0, 1, 0,
        "",
        "https://server14.mp3quran.net/refat/{surah_3}.mp3",
        "mp3quran historical archive"
    ),
    # 10. محمد محمود الطبلاوي
    (
        "tablawi", "محمد محمود الطبلاوي", "مرتل", 10, 128, 1, 1, 1,
        "https://everyayah.com/data/Mohammad_al_Tablaway_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server12.mp3quran.net/tblawi/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 11. أحمد نعينع
    (
        "ahmed_naina", "أحمد نعينع", "مرتل", 11, 128, 1, 1, 0,
        "https://everyayah.com/data/Ahmed_Neana_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server11.mp3quran.net/neana/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 12. مشاري راشد العفاسي
    (
        "alafasy", "مشاري راشد العفاسي", "مرتل", 12, 128, 1, 1, 1,
        "https://everyayah.com/data/Alafasy_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/afs/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 13. ماهر المعيقلي
    (
        "maher_muaiqly", "ماهر المعيقلي", "مرتل", 13, 128, 1, 1, 1,
        "https://everyayah.com/data/Maher_AlMuaiqly_64kbps/{surah_3}{ayah_3}.mp3",
        "https://server12.mp3quran.net/maher/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 14. عبدالرحمن السديس
    (
        "sudais", "عبدالرحمن السديس", "مرتل", 14, 192, 1, 1, 1,
        "https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/{surah_3}{ayah_3}.mp3",
        "https://server11.mp3quran.net/sds/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 15. سعود الشريم
    (
        "shuraim", "سعود الشريم", "مرتل", 15, 128, 1, 1, 1,
        "https://everyayah.com/data/Saood_ash-Shuraym_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server7.mp3quran.net/shur/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 16. سعد الغامدي
    (
        "saad_ghamdi", "سعد الغامدي", "مرتل", 16, 128, 1, 1, 1,
        "https://everyayah.com/data/Ghamadi_40kbps/{surah_3}{ayah_3}.mp3",
        "https://server7.mp3quran.net/s_gmd/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 17. ياسر الدوسري
    (
        "yasser_dosari", "ياسر الدوسري", "مرتل", 17, 128, 1, 1, 1,
        "https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server11.mp3quran.net/yasser/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 18. ناصر القطامي
    (
        "nasser_qatami", "ناصر القطامي", "مرتل", 18, 128, 1, 1, 1,
        "https://everyayah.com/data/Nasser_Alqatami_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server6.mp3quran.net/qtm/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 19. أحمد العجمي
    (
        "ahmed_ajmi", "أحمد العجمي", "مرتل", 19, 128, 1, 1, 1,
        "https://everyayah.com/data/Ahmed_ibn_Ali_al-Ajamy_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server10.mp3quran.net/ajm/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 20. هاني الرفاعي
    (
        "hani_rifai", "هاني الرفاعي", "مرتل", 20, 192, 1, 1, 1,
        "https://everyayah.com/data/Hani_Rifai_192kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/hani/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 21. أبو بكر الشاطري
    (
        "shatri", "أبو بكر الشاطري", "مرتل", 21, 128, 1, 1, 1,
        "https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server11.mp3quran.net/shatri/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 22. إدريس أبكر
    (
        "idrees_abkar", "إدريس أبكر", "مرتل", 22, 128, 1, 1, 1,
        "https://everyayah.com/data/Idrees_Abkar_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server6.mp3quran.net/abkr/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 23. عبدالله بصفر
    (
        "abdullah_basfar", "عبدالله بصفر", "مرتل", 23, 192, 1, 1, 1,
        "https://everyayah.com/data/Abdullah_Basfar_192kbps/{surah_3}{ayah_3}.mp3",
        "https://server6.mp3quran.net/bsfr/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 24. علي الحذيفي
    (
        "ali_hudhaify", "علي الحذيفي", "مرتل", 24, 128, 1, 1, 1,
        "https://everyayah.com/data/Hudhaify_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server9.mp3quran.net/hthfi/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 25. عبدالله عواد الجهني
    (
        "abdullah_juhany", "عبدالله عواد الجهني", "مرتل", 25, 128, 1, 1, 1,
        "https://everyayah.com/data/Abdullaah_3awwaad_Al-Juhaynee_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server13.mp3quran.net/jhn/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 26. صلاح بو خاطر
    (
        "salah_bukhatir", "صلاح بو خاطر", "مرتل", 26, 128, 1, 1, 1,
        "https://everyayah.com/data/Salah_Al_Budair_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/bu_khtr/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 27. فارس عباد
    (
        "fares_abbad", "فارس عباد", "مرتل", 27, 128, 1, 1, 1,
        "https://everyayah.com/data/Fares_Abbad_64kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/frs_a/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 28. محمد أيوب
    (
        "muhammad_ayyub", "محمد أيوب", "مرتل", 28, 128, 1, 1, 1,
        "https://everyayah.com/data/Muhammad_Ayyoub_128kbps/{surah_3}{ayah_3}.mp3",
        "https://server8.mp3quran.net/ayyub/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 29. عبدالباري الثبيتي
    (
        "abdulbari_thubaity", "عبدالباري الثبيتي", "مرتل", 29, 128, 1, 1, 1,
        "https://everyayah.com/data/AbdulBaset_Murattal_192kbps/{surah_3}{ayah_3}.mp3",
        "https://server6.mp3quran.net/thbt/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 30. خالد الجليل
    (
        "khalid_jalil", "خالد الجليل", "مرتل", 30, 128, 0, 1, 0,
        "",
        "https://server10.mp3quran.net/jleel/{surah_3}.mp3",
        "mp3quran"
    ),
    # 31. إبراهيم الأخضر
    (
        "ibrahim_akhdar", "إبراهيم الأخضر", "مرتل", 31, 128, 1, 1, 1,
        "https://everyayah.com/data/Ibrahim_Akhdar_32kbps/{surah_3}{ayah_3}.mp3",
        "https://server6.mp3quran.net/akdr/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 32. علي جابر
    (
        "ali_jaber", "علي جابر", "مرتل", 32, 128, 1, 1, 1,
        "https://everyayah.com/data/Ali_Jaber_64kbps/{surah_3}{ayah_3}.mp3",
        "https://server11.mp3quran.net/a_jbr/{surah_3}.mp3",
        "EveryAyah/mp3quran"
    ),
    # 33. وديع اليمني
    (
        "wadee_yamani", "وديع اليمني", "مرتل", 33, 128, 0, 1, 0,
        "",
        "https://server6.mp3quran.net/wdee/{surah_3}.mp3",
        "mp3quran"
    ),
    # 34. منصور السالمي
    (
        "mansour_salimi", "منصور السالمي", "مرتل", 34, 128, 0, 1, 0,
        "",
        "https://server14.mp3quran.net/mansor/{surah_3}.mp3",
        "mp3quran"
    ),
    # 35. رعد محمد الكردي
    (
        "raad_kurdi", "رعد محمد الكردي", "مرتل", 35, 128, 0, 1, 0,
        "",
        "https://server6.mp3quran.net/kurdi/{surah_3}.mp3",
        "mp3quran"
    ),
]
