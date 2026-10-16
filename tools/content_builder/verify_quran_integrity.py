import unittest
from surahs_metadata import CANONICAL_SURAHS, CANONICAL_JUZ

class TestQuranIntegrity(unittest.TestCase):
    def test_surah_counts_and_structure(self):
        # 1. Total Surahs must be exactly 114
        self.assertEqual(len(CANONICAL_SURAHS), 114, "Total surahs must be 114")

        # 2. Total Ayahs must be exactly 6,236
        total_ayahs = sum(s[5] for s in CANONICAL_SURAHS)
        self.assertEqual(total_ayahs, 6236, f"Total ayahs must be 6236, found {total_ayahs}")

        # 3. First page must be 1, last page must be 604
        self.assertEqual(CANONICAL_SURAHS[0][7], 1, "First surah page_start must be 1")
        self.assertEqual(CANONICAL_SURAHS[-1][8], 604, "Last surah page_end must be 604")

        # 4. Basmala check: Surah 9 (At-Tawbah) has_basmala must be 0, all others 1
        for s in CANONICAL_SURAHS:
            surah_id, name_ar, _, _, _, _, has_basmala, _, _ = s
            if surah_id == 9:
                self.assertEqual(has_basmala, 0, "Surah At-Tawbah must not have Basmala")
            else:
                self.assertEqual(has_basmala, 1, f"Surah {name_ar} must have Basmala")

    def test_juz_counts(self):
        # Total Juz must be exactly 30
        self.assertEqual(len(CANONICAL_JUZ), 30, "Total Juz must be 30")
        self.assertEqual(CANONICAL_JUZ[0][0], 1)
        self.assertEqual(CANONICAL_JUZ[-1][0], 30)

if __name__ == "__main__":
    unittest.main()
