import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/quran_repository.dart';
import '../services/settings_service.dart';
import 'fast_audio_service.dart';

class AyahAudioPlayer {
  static final AyahAudioPlayer instance = AyahAudioPlayer._internal();
  StreamSubscription<PlayerState>? _playerStateSub;

  AyahAudioPlayer._internal() {
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        final finishedKey = currentPlayingKey.value;
        currentPlayingKey.value = null;
        isPlaying.value = false;
        if (finishedKey != null && SettingsService.instance.autoPlayNextAyah) {
          _advanceToNextAyahIfPossible(finishedKey);
        }
      } else {
        isPlaying.value = state.playing;
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<String?> currentPlayingKey = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  String? _lastSurahName;
  String? _playingReciterId;

  Future<void> _advanceToNextAyahIfPossible(String finishedKey) async {
    try {
      final parts = finishedKey.split(':');
      if (parts.length != 2) return;
      final surahId = int.tryParse(parts[0]);
      final ayahNumber = int.tryParse(parts[1]);
      if (surahId == null || ayahNumber == null) return;

      final surahs = await QuranRepository.loadSurahs();
      final surah = surahs.where((s) => s.id == surahId).firstOrNull;
      if (surah != null && ayahNumber < surah.ayahCount) {
        final nextAyah = ayahNumber + 1;
        final reciter = SettingsService.instance.currentReciter;
        final primaryUrl = SettingsService.instance.getAyahAudioUrl(surahId, nextAyah);
        final fallbackSurahUrl = SettingsService.instance.getSurahAudioUrl(surahId, reciter.id);
        currentPlayingKey.value = '$surahId:$nextAyah';
        _playingReciterId = reciter.id;
        isPlaying.value = true;

        final cacheKey = 'ayah_${reciter.id}_${surahId}_$nextAyah';
        final ok = await FastAudioService.instance.playResilient(
          primaryUrl,
          player: _player,
          primaryUrl: primaryUrl,
          fallbackUrls: [fallbackSurahUrl],
          cacheKey: cacheKey,
          onStopCallback: stop,
        );
        if (!ok) {
          currentPlayingKey.value = null;
          isPlaying.value = false;
          return;
        }

        if (nextAyah < surah.ayahCount) {
          final prefetchUrl = SettingsService.instance.getAyahAudioUrl(surahId, nextAyah + 1);
          final prefetchKey = 'ayah_${reciter.id}_${surahId}_${nextAyah + 1}';
          unawaited(FastAudioService.instance.prefetchAudio(prefetchUrl, prefetchKey));
        }
      }
    } catch (_) {
      currentPlayingKey.value = null;
      isPlaying.value = false;
    }
  }

  Future<void> playAyah(BuildContext context, int surahId, int ayahNumber, {String? surahName}) async {
    final key = '$surahId:$ayahNumber';
    final reciter = SettingsService.instance.currentReciter;
    if (surahName != null) _lastSurahName = surahName;

    // Only toggle pause if the EXACT same ayah AND the EXACT same reciter is currently playing
    if (currentPlayingKey.value == key &&
        _playingReciterId == reciter.id &&
        _player.playing) {
      await _player.pause();
      isPlaying.value = false;
      return;
    }

    try {
      await _player.stop();
      final primaryUrl = SettingsService.instance.getAyahAudioUrl(surahId, ayahNumber);
      // Fallback to the EXACT SAME reciter's surah stream if EveryAyah subfolder is unavailable
      final fallbackSurahUrl = SettingsService.instance.getSurahAudioUrl(surahId, reciter.id);

      currentPlayingKey.value = key;
      _playingReciterId = reciter.id;
      isPlaying.value = true;

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تلاوة ${surahName ?? _lastSurahName ?? "السورة"} (آية $ayahNumber) — القارئ: ${reciter.nameAr}',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF1B4332),
          ),
        );
      }

      final cacheKey = 'ayah_${reciter.id}_${surahId}_$ayahNumber';
      final ok = await FastAudioService.instance.playResilient(
        primaryUrl,
        player: _player,
        primaryUrl: primaryUrl,
        fallbackUrls: [fallbackSurahUrl],
        cacheKey: cacheKey,
        onStopCallback: stop,
      );

      if (!ok) {
        throw Exception('Could not stream reciter ${reciter.id}');
      }

      final surahs = await QuranRepository.loadSurahs();
      final surah = surahs.where((s) => s.id == surahId).firstOrNull;
      if (surah == null || ayahNumber < surah.ayahCount) {
        final nextUrl = SettingsService.instance.getAyahAudioUrl(surahId, ayahNumber + 1);
        final nextCacheKey = 'ayah_${reciter.id}_${surahId}_${ayahNumber + 1}';
        unawaited(FastAudioService.instance.prefetchAudio(nextUrl, nextCacheKey));
      }
    } catch (e) {
      currentPlayingKey.value = null;
      isPlaying.value = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تشغيل صوت القارئ ${reciter.nameAr}. يرجى التحقق من الاتصال بالإنترنت.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Plays a quick voice preview of any Reciter (Surah Al-Fatihah) so the user hears that exact Sheikh's voice
  Future<bool> playReciterPreview(ReciterInfo reciter) async {
    try {
      if (_playingReciterId == reciter.id &&
          currentPlayingKey.value == 'preview_${reciter.id}' &&
          _player.playing) {
        await stop();
        return false;
      }
      await _player.stop();
      _playingReciterId = reciter.id;
      currentPlayingKey.value = 'preview_${reciter.id}';
      isPlaying.value = true;

      final surahUrl = SettingsService.instance.getSurahAudioUrl(1, reciter.id);
      final ayahUrl =
          'https://everyayah.com/data/${reciter.subfolder}/001002.mp3';

      final ok = await FastAudioService.instance.playResilient(
        surahUrl,
        player: _player,
        primaryUrl: surahUrl,
        fallbackUrls: [ayahUrl],
        cacheKey: 'preview_reciter_${reciter.id}',
        onStopCallback: stop,
      );
      if (!ok) {
        currentPlayingKey.value = null;
        isPlaying.value = false;
      }
      return ok;
    } catch (_) {
      currentPlayingKey.value = null;
      isPlaying.value = false;
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    currentPlayingKey.value = null;
    isPlaying.value = false;
  }

  void dispose() {
    _playerStateSub?.cancel();
    _playerStateSub = null;
    _player.dispose();
  }
}
