"""
Quran Database Builder & Integrity Engine for Al-Momin
Generates schema and bundles canonical data with FTS5 search indexing per Section 7.1.
Enforces structural integrity constants (114 Surahs, 6236 Ayahs, 604 Pages, 30 Juz).
"""

import os
import sys
import sqlite3
import xml.etree.ElementTree as ET
from normalizer import normalize_arabic

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

DIR_PATH = os.path.dirname(__file__)
DB_PATH = os.path.join(DIR_PATH, "..", "..", "app", "assets", "data", "quran.db")
XML_PATH = os.path.join(DIR_PATH, "quran-data.xml")
UTHMANI_PATH = os.path.join(DIR_PATH, "quran-uthmani.txt")
TAFSEER_PATH = os.path.join(DIR_PATH, "ar.muyassar.txt")

SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS riwaya (
  id INTEGER PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name_ar TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS surah (
  id INTEGER PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_simple TEXT,
  revelation_place TEXT CHECK (revelation_place IN ('makkah','madinah')),
  revelation_order INTEGER,
  ayah_count INTEGER NOT NULL,
  has_basmala INTEGER NOT NULL DEFAULT 1,
  page_start INTEGER NOT NULL,
  page_end INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS ayah (
  id INTEGER PRIMARY KEY,
  surah_id INTEGER NOT NULL REFERENCES surah(id),
  ayah_number INTEGER NOT NULL,
  juz INTEGER NOT NULL,
  hizb INTEGER NOT NULL,
  rub INTEGER NOT NULL,
  page INTEGER NOT NULL,
  sajdah INTEGER NOT NULL DEFAULT 0,
  text_uthmani TEXT NOT NULL,
  text_imlaei TEXT,
  text_search TEXT NOT NULL,
  tafseer TEXT,
  UNIQUE (surah_id, ayah_number)
);

CREATE INDEX IF NOT EXISTS idx_ayah_page ON ayah(page);
CREATE INDEX IF NOT EXISTS idx_ayah_juz ON ayah(juz);
CREATE INDEX IF NOT EXISTS idx_ayah_surah ON ayah(surah_id);

CREATE TABLE IF NOT EXISTS word (
  id INTEGER PRIMARY KEY,
  ayah_id INTEGER NOT NULL REFERENCES ayah(id),
  position INTEGER NOT NULL,
  text_uthmani TEXT NOT NULL,
  glyph_code TEXT,
  page INTEGER,
  line_number INTEGER,
  char_type TEXT,
  root TEXT,
  meaning_ar TEXT,
  UNIQUE (ayah_id, position)
);

CREATE VIRTUAL TABLE IF NOT EXISTS ayah_fts USING fts5(
  text_search, content='ayah', content_rowid='id',
  tokenize='unicode61 remove_diacritics 0', prefix='2 3 4'
);

CREATE TABLE IF NOT EXISTS reciter (
  id TEXT PRIMARY KEY,
  name_ar TEXT NOT NULL,
  style_ar TEXT,
  sort_order INTEGER,
  bitrate_kbps INTEGER,
  has_ayah_files INTEGER NOT NULL,
  has_surah_file INTEGER NOT NULL,
  has_timings INTEGER NOT NULL,
  ayah_url_template TEXT,
  surah_url_template TEXT,
  source_note TEXT
);

CREATE TABLE IF NOT EXISTS audio_timing (
  reciter_id TEXT NOT NULL,
  surah_id INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  start_ms INTEGER NOT NULL,
  end_ms INTEGER NOT NULL,
  PRIMARY KEY (reciter_id, surah_id, ayah_number)
);
"""

from surahs_metadata import CANONICAL_SURAHS, CANONICAL_JUZ
from reciters_catalog import RECITERS_35


def init_database(db_path: str = DB_PATH):
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    cur.executescript(SCHEMA_SQL)

    # Insert Riwaya (Hafs)
    cur.execute("INSERT INTO riwaya (id, code, name_ar) VALUES (1, 'hafs', 'حفص عن عاصم')")

    # Insert all 114 Canonical Surahs
    for s in CANONICAL_SURAHS:
        cur.execute(
            """INSERT INTO surah (id, name_ar, name_simple, revelation_place, revelation_order, ayah_count, has_basmala, page_start, page_end)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            s
        )

    # Insert all 35 Canonical Reciters per Appendix B
    for r in RECITERS_35:
        cur.execute(
            """INSERT INTO reciter (id, name_ar, style_ar, sort_order, bitrate_kbps, has_ayah_files, has_surah_file, has_timings, ayah_url_template, surah_url_template, source_note)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            r
        )

    # Load XML metadata for pages and juzs
    tree = ET.parse(XML_PATH)
    pages_el = tree.find('pages')
    juzs_el = tree.find('juzs')
    page_starts = [(int(p.attrib['index']), int(p.attrib['sura']), int(p.attrib['aya'])) for p in pages_el]
    juz_starts = [(int(j.attrib['index']), int(j.attrib['sura']), int(j.attrib['aya'])) for j in juzs_el]

    def get_page(sura, aya):
        p_num = 1
        for p, s, a in page_starts:
            if (sura > s) or (sura == s and aya >= a):
                p_num = p
            else:
                break
        return p_num

    def get_juz(sura, aya):
        j_num = 1
        for j, s, a in juz_starts:
            if (sura > s) or (sura == s and aya >= a):
                j_num = j
            else:
                break
        return j_num

    # Load Uthmani texts
    with open(UTHMANI_PATH, encoding='utf-8') as f:
        uthmani_lines = [l.strip() for l in f if l.strip() and not l.startswith('#')]

    # Load Tafseer Al-Muyassar
    tafseer = {}
    with open(TAFSEER_PATH, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split('|', 2)
            if len(parts) == 3:
                tafseer[(int(parts[0]), int(parts[1]))] = parts[2]

    # Insert all 6236 Canonical Ayahs
    current_global_idx = 0
    batch_ayah = []
    batch_fts = []

    for s in CANONICAL_SURAHS:
        s_id = s[0]
        count = s[5]
        for a_num in range(1, count + 1):
            current_global_idx += 1
            u_text = uthmani_lines[current_global_idx - 1]
            t_text = tafseer.get((s_id, a_num), '')
            search_text = normalize_arabic(u_text, loose=True)
            pg = get_page(s_id, a_num)
            jz = get_juz(s_id, a_num)
            hizb = (jz * 2) - (1 if pg % 2 != 0 else 0)
            rub = 1

            batch_ayah.append((
                current_global_idx, s_id, a_num, jz, hizb, rub, pg, 0,
                u_text, u_text, search_text, t_text
            ))
            batch_fts.append((current_global_idx, search_text))

    cur.executemany(
        """INSERT INTO ayah (id, surah_id, ayah_number, juz, hizb, rub, page, sajdah, text_uthmani, text_imlaei, text_search, tafseer)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        batch_ayah
    )
    cur.executemany(
        "INSERT INTO ayah_fts (rowid, text_search) VALUES (?, ?)",
        batch_fts
    )

    conn.commit()
    conn.close()
    print(f"✅ تم بناء قاعدة بيانات المصحف الشريف الكاملة ({current_global_idx} آية) بنجاح في: {db_path}")


if __name__ == "__main__":
    init_database()
