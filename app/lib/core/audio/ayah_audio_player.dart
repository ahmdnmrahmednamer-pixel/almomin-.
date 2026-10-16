import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/settings_service.dart';

class AyahAudioPlayer {
  static final AyahAudioPlayer instance = AyahAudioPlayer._internal();
  AyahAudioPlayer._internal() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        currentPlayingKey.value = null;
        isPlaying.value = false;
      } else {
        isPlaying.value = state.playing;
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<String?> currentPlayingKey = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  Future<void> playAyah(BuildContext context, int surahId, int ayahNumber, {String? surahName}) async {
    final key = '$surahId:$ayahNumber';

    // If already playing this ayah, toggle pause/play
    if (currentPlayingKey.value == key && _player.playing) {
      await _player.pause();
      isPlaying.value = false;
      return;
    }

    try {
      final reciter = SettingsService.instance.currentReciter;
      final url = SettingsService.instance.getAyahAudioUrl(surahId, ayahNumber);

      currentPlayingKey.value = key;
      isPlaying.value = true;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تلاوة ${surahName ?? "السورة"} (آية $ayahNumber) — القارئ: ${reciter.nameAr}',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFF1B4332),
        ),
      );

      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      currentPlayingKey.value = null;
      isPlaying.value = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تشغيل التلاوة. يرجى التحقق من الاتصال بالإنترنت.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> stop() async {
    await _player.stop();
    currentPlayingKey.value = null;
    isPlaying.value = false;
  }

  void dispose() {
    _player.dispose();
  }
}
