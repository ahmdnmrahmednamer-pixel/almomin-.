import os
import json
import sqlite3
import unittest
from normalizer import normalize_arabic
from surahs_metadata import CANONICAL_SURAHS, CANONICAL_JUZ

class TestMilestoneM1QuranCore(unittest.TestCase):
    def setUp(self):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.db_path = os.path.join(self.base_dir, "..", "..", "app", "assets", "data", "quran.db")
        self.surahs_json = os.path.join(self.base_dir, "..", "..", "app", "assets", "data", "surahs.json")
        self.juz_json = os.path.join(self.base_dir, "..", "..", "app", "assets", "data", "juz.json")

    def test_database_tables_and_row_counts(self):
        self.assertTrue(os.path.exists(self.db_path), f"quran.db must exist at {self.db_path}")
        conn = sqlite3.connect(self.db_path)
        cur = conn.cursor()

        # Check tables
        tables = [r[0] for r in cur.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
        required_tables = ['riwaya', 'surah', 'ayah', 'word', 'ayah_fts', 'reciter', 'audio_timing']
        for t in required_tables:
            self.assertIn(t, tables, f"Table '{t}' must exist in quran.db")

        # Surah count must be 114
        surah_count = cur.execute("SELECT COUNT(*) FROM surah").fetchone()[0]
        self.assertEqual(surah_count, 114, "quran.db must contain exactly 114 surahs")

        # Reciters count per Appendix B
        reciters_count = cur.execute("SELECT COUNT(*) FROM reciter").fetchone()[0]
        self.assertEqual(reciters_count, 35, "quran.db must contain exactly 35 reciters per Appendix B")

        conn.close()

    def test_json_assets_completeness(self):
        self.assertTrue(os.path.exists(self.surahs_json))
        with open(self.surahs_json, "r", encoding="utf-8") as f:
            surahs = json.load(f)
        self.assertEqual(len(surahs), 114, "surahs.json must have 114 items")
        total_ayahs = sum(s["ayah_count"] for s in surahs)
        self.assertEqual(total_ayahs, 6236, "Total ayahs in surahs.json must be 6236")

        self.assertTrue(os.path.exists(self.juz_json))
        with open(self.juz_json, "r", encoding="utf-8") as f:
            juz = json.load(f)
        self.assertEqual(len(juz), 30, "juz.json must have 30 items")

    def test_fts5_fulltext_search(self):
        conn = sqlite3.connect(self.db_path)
        cur = conn.cursor()

        # Query normalized term
        query = normalize_arabic("الرحمن")
        rows = cur.execute("SELECT rowid FROM ayah_fts WHERE ayah_fts MATCH ?", (query,)).fetchall()
        self.assertGreaterEqual(len(rows), 2, "FTS5 query for 'الرحمن' must return matches")

        conn.close()

if __name__ == "__main__":
    unittest.main()
