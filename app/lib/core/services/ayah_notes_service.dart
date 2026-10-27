import '../text/arabic_normalizer.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah_note.dart';

/// Service managing personal Quranic reflections and free-text notes on Ayahs (FR-BKM-004 / T-110)
class AyahNotesService extends ChangeNotifier {
  static final AyahNotesService instance = AyahNotesService._internal();
  AyahNotesService._internal();

  static const String _storageKey = 'user_ayah_notes_v1';

  final Map<String, AyahNote> _notes = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  int get notesCount => _notes.length;

  /// Initializes the service from persistent storage
  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = json.decode(jsonStr);
        _notes.clear();
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final note = AyahNote.fromJson(item);
            _notes[note.id] = note;
          }
        }
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AyahNotesService init error: $e');
      _isInitialized = true;
    }
  }

  /// Checks if an Ayah has an existing reflection
  bool hasNote(int surahId, int ayahNumber) {
    return _notes.containsKey(AyahNote.generateId(surahId, ayahNumber));
  }

  /// Gets the existing reflection for an Ayah, or null
  AyahNote? getNote(int surahId, int ayahNumber) {
    return _notes[AyahNote.generateId(surahId, ayahNumber)];
  }

  /// Saves or updates a reflection for an Ayah
  Future<bool> saveNote({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
    required String noteText,
    int pageNumber = 1,
  }) async {
    await init();
    final cleanNote = noteText.trim();
    if (cleanNote.isEmpty) {
      return deleteNote(surahId, ayahNumber);
    }

    final id = AyahNote.generateId(surahId, ayahNumber);
    final existing = _notes[id];
    final now = DateTime.now();

    final note = AyahNote(
      id: id,
      surahId: surahId,
      surahName: surahName,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      noteText: cleanNote,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      pageNumber: pageNumber > 0 ? pageNumber : (existing?.pageNumber ?? 1),
    );

    _notes[id] = note;
    await _persist();
    notifyListeners();
    return true;
  }

  /// Deletes a reflection
  Future<bool> deleteNote(int surahId, int ayahNumber) async {
    await init();
    final id = AyahNote.generateId(surahId, ayahNumber);
    if (_notes.containsKey(id)) {
      _notes.remove(id);
      await _persist();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Returns all reflections, optionally filtered by query or surah
  List<AyahNote> getAllNotes({String? searchQuery, int? filterSurahId}) {
    var list = _notes.values.toList();

    if (filterSurahId != null && filterSurahId > 0) {
      list = list.where((n) => n.surahId == filterSurahId).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      final normQ = ArabicNormalizer.normalize(searchQuery, loose: true);
      list = list.where((n) {
        return n.noteText.toLowerCase().contains(q) ||
            ArabicNormalizer.normalize(n.noteText, loose: true).contains(normQ) ||
            n.surahName.contains(q) ||
            ArabicNormalizer.normalize(n.surahName, loose: true).contains(normQ) ||
            n.ayahText.contains(q) ||
            ArabicNormalizer.normalize(n.ayahText, loose: true).contains(normQ) ||
            n.ayahNumber.toString() == normQ;
      }).toList();
    }

    // Sort by latest updated first
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Clears all notes
  Future<void> clearAllNotes() async {
    _notes.clear();
    await _persist();
    notifyListeners();
  }

  /// Exports notes list for backup integration (FR-BKM-003)
  List<Map<String, dynamic>> exportNotesList() {
    return _notes.values.map((n) => n.toJson()).toList();
  }

  /// Restores notes from backup data
  Future<void> restoreNotesList(List<dynamic> list, {bool replace = false}) async {
    await init();
    if (replace) {
      _notes.clear();
    }

    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final note = AyahNote.fromJson(item);
        if (replace || !_notes.containsKey(note.id)) {
          _notes[note.id] = note;
        } else {
          // Merge: keep the newer note
          final existing = _notes[note.id]!;
          if (note.updatedAt.isAfter(existing.updatedAt)) {
            _notes[note.id] = note;
          }
        }
      }
    }

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _notes.values.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(list));
    } catch (e) {
      debugPrint('AyahNotesService persist error: $e');
    }
  }
}
