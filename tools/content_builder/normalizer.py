"""
Arabic Search Normalization (Appendix A Reference Algorithm)
Implements normalized string extraction for Quranic search and FTS indexing.
Matches canonical specifications in NOOR_ALMOMIN_ENGINEERING_SPEC.md.
"""

import re
import unicodedata

# Tashkeel and Quranic marks ranges:
# U+0610–U+061A (honorifics/annotations)
# U+064B–U+065F (fathatan, dammatan, kasratan, fatha, damma, kasra, shadda, sukun, etc.)
# U+0670 (superscript dagger alef)
# U+06D6–U+06ED (Quranic pause marks, sajdah, rub-el-hizb, etc.)
# U+08D3–U+08FF (Extended Arabic Quranic marks)
# U+0640 (Tatweel / Kashida)
# U+06DD (End of Ayah sign)
DIACRITICS_REGEX = re.compile(
    r"[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF\u0640\u06DD]"
)

# Digits mapping (Arabic-Indic and Eastern Arabic-Indic to ASCII)
DIGIT_MAP = str.maketrans(
    "٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹",
    "01234567890123456789"
)

# Normalization mapping for letters:
# Alef variants: أ إ آ ٱ -> ا
# Alef Maqsura: ى -> ي
# Hamza carriers: ؤ -> و, ئ -> ي (loose mode)
# Ta Marbuta: ة -> ه (search mode)
# Persian/Urdu variants: ی -> ي, ک -> ك
LETTER_MAP = str.maketrans({
    "أ": "ا",
    "إ": "ا",
    "آ": "ا",
    "ٱ": "ا",
    "ى": "ي",
    "ؤ": "و",
    "ئ": "ي",
    "ة": "ه",
    "ی": "ي",
    "ک": "ك"
})


def normalize_arabic(text: str, loose: bool = True) -> str:
    """
    Normalizes Arabic string for search and index comparison.
    Produces a derived query string without mutating canonical Quran text.
    """
    if not text:
        return ""

    # 1. Strip diacritics, tashkeel, and Quranic recitation marks
    cleaned = DIACRITICS_REGEX.sub("", text)

    # 2. Normalize letter variants
    if loose:
        cleaned = cleaned.translate(LETTER_MAP)
    else:
        # Strict mode: normalize only alef variants and tatweel
        strict_map = str.maketrans({
            "أ": "ا", "إ": "ا", "آ": "ا", "ٱ": "ا", "ی": "ي", "ک": "ك"
        })
        cleaned = cleaned.translate(strict_map)

    # 3. Convert Arabic-Indic numbers to ASCII
    cleaned = cleaned.translate(DIGIT_MAP)

    # 4. Collapse extra whitespace and strip
    cleaned = re.sub(r"\s+", " ", cleaned).strip()

    return cleaned
