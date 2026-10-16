import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/ayah_note.dart';
import 'package:almomin/core/services/ayah_notes_service.dart';
import 'package:almomin/core/services/backup_restore_service.dart';
import 'package:almomin/features/mushaf/quran_notes_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AyahNote Model Tests', () {
    test('serializes to and from JSON accurately', () {
      final original = AyahNote(
        id: '2_255',
        surahId: 2,
        surahName: 'البقرة',
        ayahNumber: 255,
        ayahText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        noteText: 'أعظم آية في كتاب الله تعالى، تفيض بجلال التوحيد وكمال قيوميته سبحانه.',
        createdAt: DateTime(2026, 10, 16, 10, 0),
        updatedAt: DateTime(2026, 10, 16, 11, 0),
        pageNumber: 42,
      );

      final json = original.toJson();
      final restored = AyahNote.fromJson(json);

      expect(restored.id, '2_255');
      expect(restored.surahId, 2);
      expect(restored.surahName, 'البقرة');
      expect(restored.ayahNumber, 255);
      expect(restored.noteText, original.noteText);
      expect(restored.pageNumber, 42);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('copyWith modifies attributes correctly', () {
      final original = AyahNote(
        id: '1_1',
        surahId: 1,
        surahName: 'الفاتحة',
        ayahNumber: 1,
        ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        noteText: 'البدء باسم الله استعانة وتبركاً',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(noteText: 'نص محدث');
      expect(updated.noteText, 'نص محدث');
      expect(updated.surahId, 1);
      expect(updated.id, '1_1');
    });
  });

  group('AyahNotesService Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AyahNotesService.instance.clearAllNotes();
    });

    test('add, read, and delete notes lifecycle', () async {
      final service = AyahNotesService.instance;
      expect(service.notesCount, 0);
      expect(service.hasNote(18, 10), isFalse);

      await service.saveNote(
        surahId: 18,
        surahName: 'الكهف',
        ayahNumber: 10,
        ayahText: 'إِذْ أَوَى الْفِتْيَةُ إِلَى الْكَهْفِ',
        noteText: 'دعاء الفتية بالرحمة والرشد عند اشتداد الفتن.',
        pageNumber: 294,
      );

      expect(service.notesCount, 1);
      expect(service.hasNote(18, 10), isTrue);

      final note = service.getNote(18, 10);
      expect(note, isNotNull);
      expect(note!.noteText, contains('دعاء الفتية'));
      expect(note.pageNumber, 294);

      // Deleting note
      final deleted = await service.deleteNote(18, 10);
      expect(deleted, isTrue);
      expect(service.notesCount, 0);
      expect(service.hasNote(18, 10), isFalse);
    });

    test('search and filter notes by surah or keyword', () async {
      final service = AyahNotesService.instance;
      await service.saveNote(
        surahId: 2,
        surahName: 'البقرة',
        ayahNumber: 286,
        ayahText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
        noteText: 'بشارة عظيمة برحمة الله وعدم التكليف بما فوق الطاقة.',
      );
      await service.saveNote(
        surahId: 94,
        surahName: 'الشرح',
        ayahNumber: 5,
        ayahText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
        noteText: 'اليقين بأن العسر محفوف بيسرين.',
      );

      expect(service.notesCount, 2);

      // Search by keyword
      final searchRes = service.getAllNotes(searchQuery: 'طاقة');
      expect(searchRes.length, 1);
      expect(searchRes.first.surahId, 2);

      // Filter by Surah
      final filterRes = service.getAllNotes(filterSurahId: 94);
      expect(filterRes.length, 1);
      expect(filterRes.first.surahName, 'الشرح');
    });

    test('backup and restore integration for reflections', () async {
      final service = AyahNotesService.instance;
      await service.saveNote(
        surahId: 1,
        surahName: 'الفاتحة',
        ayahNumber: 5,
        ayahText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        noteText: 'الجمع بين العبادة الخالصة والاستعانة التامة.',
      );

      final exported = service.exportNotesList();
      expect(exported.length, 1);

      await service.clearAllNotes();
      expect(service.notesCount, 0);

      await service.restoreNotesList(exported, replace: true);
      expect(service.notesCount, 1);
      expect(service.hasNote(1, 5), isTrue);
    });
  });

  group('QuranNotesScreen Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AyahNotesService.instance.clearAllNotes();
    });

    testWidgets('renders AppBar, Dedication for Momin Ibrahim, and Empty State', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuranNotesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تدبراتي وخواطري القرآنية'), findsOneWidget);
      expect(
        find.text('صدقة جارية عن روح المرحوم بإذن الله: مؤمن إبراهيم رحمه الله'),
        findsOneWidget,
      );
      expect(find.text('لا توجد خواطر أو تدبرات مدونة بعد'), findsOneWidget);
      expect(find.textContaining('أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ'), findsOneWidget);
    });

    testWidgets('renders note card when reflections are added', (tester) async {
      await AyahNotesService.instance.saveNote(
        surahId: 112,
        surahName: 'الإخلاص',
        ayahNumber: 1,
        ayahText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        noteText: 'صفة الرحمن وإخلاص التوحيد له وحده لا شريك له.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: QuranNotesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سورة الإخلاص : آية 1'), findsOneWidget);
      expect(find.text('صفة الرحمن وإخلاص التوحيد له وحده لا شريك له.'), findsOneWidget);
      expect(find.text('في المصحف'), findsOneWidget);
      expect(find.text('مشاركة'), findsOneWidget);
    });
  });
}
