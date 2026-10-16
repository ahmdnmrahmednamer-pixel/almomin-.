import os
import json
import unittest
from normalizer import normalize_arabic

class TestArabicNormalizer(unittest.TestCase):
    def setUp(self):
        vectors_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "app", "test", "fixtures", "normalizer_vectors.json"
        )
        with open(vectors_path, "r", encoding="utf-8") as f:
            self.vectors = json.load(f)

    def test_golden_vectors(self):
        for case in self.vectors:
            actual = normalize_arabic(case["input"], loose=True)
            expected = case["expected_loose"]
            self.assertEqual(
                actual,
                expected,
                f"Failed for input '{case['input']}': expected '{expected}', got '{actual}' ({case['description']})"
            )

    def test_search_match_equivalences(self):
        # Verify that search queries match their canonical counterparts
        self.assertEqual(normalize_arabic("الرحمن"), normalize_arabic("الرَّحْمَٰنِ"))
        self.assertEqual(normalize_arabic("الله"), normalize_arabic("ٱللَّهُ"))
        self.assertEqual(normalize_arabic("موسى"), normalize_arabic("مُوسَىٰ"))
        self.assertEqual(normalize_arabic("مؤمن"), normalize_arabic("مُؤْمِنٌ"))

if __name__ == "__main__":
    unittest.main()
