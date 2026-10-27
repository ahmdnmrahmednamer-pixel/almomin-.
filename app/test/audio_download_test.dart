import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/audio_download_service.dart';
import 'package:almomin/features/audio/downloads_manager_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DownloadedSurahInfo Model Tests', () {
    test('formats file size correctly in KB and MB', () {
      final infoKb = DownloadedSurahInfo(
        reciterId: 'mishari_alafasy',
        reciterName: 'مشاري العفاسي',
        surahId: 1,
        surahName: 'الفاتحة',
        localPath: '/tmp/test.mp3',
        fileSizeBytes: 50 * 1024, // 50 KB
        downloadedAt: DateTime.now(),
      );
      expect(infoKb.formattedSize, '50.0 KB');

      final infoMb = DownloadedSurahInfo(
        reciterId: 'mishari_alafasy',
        reciterName: 'مشاري العفاسي',
        surahId: 2,
        surahName: 'البقرة',
        localPath: '/tmp/test2.mp3',
        fileSizeBytes: 25 * 1024 * 1024, // 25 MB
        downloadedAt: DateTime.now(),
      );
      expect(infoMb.formattedSize, '25.0 MB');

      final infoZero = DownloadedSurahInfo(
        reciterId: 'test',
        reciterName: 'test',
        surahId: 3,
        surahName: 'test',
        localPath: '/tmp/zero.mp3',
        fileSizeBytes: 0,
        downloadedAt: DateTime.now(),
      );
      expect(infoZero.formattedSize, '0 MB');
    });

    test('serializes to and from JSON correctly', () {
      final original = DownloadedSurahInfo(
        reciterId: 'abdul_basit_murattal',
        reciterName: 'عبد الباسط عبد الصمد',
        surahId: 36,
        surahName: 'يس',
        localPath: '/storage/quran_audio/abdul_basit_36.mp3',
        fileSizeBytes: 15400000,
        downloadedAt: DateTime(2026, 10, 16, 12, 0),
      );

      final json = original.toJson();
      final restored = DownloadedSurahInfo.fromJson(json);

      expect(restored.reciterId, original.reciterId);
      expect(restored.reciterName, original.reciterName);
      expect(restored.surahId, 36);
      expect(restored.surahName, 'يس');
      expect(restored.localPath, original.localPath);
      expect(restored.fileSizeBytes, 15400000);
      expect(restored.downloadedAt, original.downloadedAt);
    });
  });

  group('AudioDownloadService Unit Tests', () {
    test('default status without downloads', () {
      final service = AudioDownloadService.instance;
      expect(service.isDownloaded('non_existent', 999), isFalse);
      expect(service.isDownloading('non_existent', 999), isFalse);
      expect(service.getLocalAudioPath('non_existent', 999), isNull);
      expect(service.getDownloadProgress('non_existent', 999), 0.0);
    });

    test('formattedTotalStorage returns 0 MB when empty', () {
      final service = AudioDownloadService.instance;
      expect(service.totalStorageUsedBytes, 0);
      expect(service.formattedTotalStorage, '0 MB');
    });
  });

  group('DownloadsManagerScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders AppBar and Noble Dedication for Momin Ibrahim', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DownloadsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مركز التنزيلات والاستماع دون إنترنت'), findsOneWidget);
      expect(
        find.text('مكتبة التلاوات المحملة — استمع في أي وقت وأي مكان بدون إنترنت'),
        findsOneWidget,
      );
      expect(find.text('المساحة المستهلكة على الهاتف'), findsOneWidget);
      expect(find.text('لا توجد تنزيلات حالياً على الهاتف'), findsOneWidget);
    });
  });
}
