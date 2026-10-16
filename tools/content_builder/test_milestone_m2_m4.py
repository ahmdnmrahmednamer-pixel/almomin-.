import os
import json
import sqlite3
import unittest
from datetime import date
from reciters_catalog import RECITERS_35
from prayer_engine import compute_qibla_bearing, compute_prayer_times
from pack_builder import build_tafsir_muyassar_sample_pack, generate_manifest, compute_file_sha256

class TestMilestonesM2ToM4(unittest.TestCase):
    def setUp(self):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.tmp_pack = os.path.join(self.base_dir, "test_output", "tafsir_muyassar.db")
        self.tmp_manifest = os.path.join(self.base_dir, "test_output", "manifest.json")

    def test_reciters_catalog_35_integrity(self):
        self.assertEqual(len(RECITERS_35), 35, "Reciters catalog must have exactly 35 reciters")
        ids = [r[0] for r in RECITERS_35]
        self.assertEqual(len(ids), len(set(ids)), "Reciter IDs must be strictly unique")
        # Ensure top Egyptian reciters are at the top
        self.assertEqual(ids[0], "husary_murattal")
        self.assertEqual(ids[2], "minshawi_murattal")
        self.assertEqual(ids[4], "abdulbasit_murattal")

    def test_prayer_engine_and_qibla(self):
        # Cairo coordinates
        cairo_lat = 30.0444
        cairo_lng = 31.2357

        # Qibla bearing from Cairo to Makkah should be approximately 136 degrees (+/- 2 deg)
        qibla = compute_qibla_bearing(cairo_lat, cairo_lng)
        self.assertAlmostEqual(qibla, 136.0, delta=2.0)

        # Cairo prayer times for a reference date (Summer / May 15)
        times = compute_prayer_times(
            target_date=date(2026, 5, 15),
            lat=cairo_lat,
            lng=cairo_lng,
            timezone_offset_hours=3.0, # Egypt summer time
            method_key="egypt"
        )
        self.assertIn("fajr", times)
        self.assertIn("sunrise", times)
        self.assertIn("dhuhr", times)
        self.assertIn("asr", times)
        self.assertIn("maghrib", times)
        self.assertIn("isha", times)

        # Basic chronological sanity checks
        self.assertTrue(times["fajr"] < times["sunrise"])
        self.assertTrue(times["sunrise"] < times["dhuhr"])
        self.assertTrue(times["dhuhr"] < times["asr"])
        self.assertTrue(times["asr"] < times["maghrib"])
        self.assertTrue(times["maghrib"] < times["isha"])

    def test_pack_builder_and_manifest(self):
        pack_info = build_tafsir_muyassar_sample_pack(self.tmp_pack)
        self.assertTrue(os.path.exists(self.tmp_pack))
        self.assertEqual(pack_info["id"], "tafsir_muyassar")
        self.assertGreater(pack_info["size_bytes"], 0)

        # Verify SQLite contents
        conn = sqlite3.connect(self.tmp_pack)
        cur = conn.cursor()
        count = cur.execute("SELECT COUNT(*) FROM tafsir_entry").fetchone()[0]
        self.assertEqual(count, 7, "Al-Fatihah should have 7 tafsir entries")
        conn.close()

        # Verify manifest generation
        manifest = generate_manifest([pack_info], self.tmp_manifest)
        self.assertTrue(os.path.exists(self.tmp_manifest))
        self.assertEqual(len(manifest["packs"]), 1)
        self.assertEqual(manifest["packs"][0]["sha256"], pack_info["sha256"])

    def tearDown(self):
        if os.path.exists(self.tmp_pack):
            os.remove(self.tmp_pack)
        if os.path.exists(self.tmp_manifest):
            os.remove(self.tmp_manifest)
        tmp_dir = os.path.join(self.base_dir, "test_output")
        if os.path.exists(tmp_dir) and not os.listdir(tmp_dir):
            os.rmdir(tmp_dir)

if __name__ == "__main__":
    unittest.main()
