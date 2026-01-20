import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ella_lyaabdoon/utils/dio_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cache_audio_player_plus/cache_audio_player_plus.dart';
import 'quran_audio_state.dart';
import 'package:audioplayers/audioplayers.dart' show AudioPlayer, PlayerState;

class QuranAudioCubit extends Cubit<QuranAudioState> {
  final CacheAudioPlayerPlus _player = CacheAudioPlayerPlus();

  QuranAudioCubit() : super(QuranAudioInitial());

  Future<void> playAyah(String reciterId, int ayahNumber) async {
    emit(QuranAudioLoading());

    if (reciterId.isEmpty) return;

    final url128 =
        "https://cdn.islamic.network/quran/audio/128/$reciterId/$ayahNumber.mp3";
    final url64 =
        "https://cdn.islamic.network/quran/audio/64/$reciterId/$ayahNumber.mp3";

    bool started = false;

    // Listen ONCE
    late StreamSubscription sub;
    sub = _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing && !started) {
        started = true;
        emit(QuranAudioPlaying(state, reciterId, ayahNumber));
        sub.cancel();
      }
    });

    // Try 128
    _player.playerNetworkAudio(url: url128, cache: true);

    // Wait small timeout
    await Future.delayed(const Duration(milliseconds: 800));

    if (!started) {
      debugPrint('128kbps failed silently, switching to 64kbps');
      await _player.stop();
      _player.playerNetworkAudio(url: url64, cache: true);
    }
  }

  void pause() {
    _player.pause();
    emit(QuranAudioPaused());
  }

  void stop() {
    _player.stop();
    emit(QuranAudioStopped());
  }

  void resume() {
    _player.resume();
    emit(QuranAudioPlaying(_player.state, "", 0));
  }
}
