import 'package:equatable/equatable.dart';
import 'package:cache_audio_player_plus/cache_audio_player_plus.dart';
import 'package:audioplayers/audioplayers.dart' show AudioPlayer, PlayerState;

abstract class QuranAudioState extends Equatable {
  const QuranAudioState();

  @override
  List<Object?> get props => [];
}

class QuranAudioInitial extends QuranAudioState {}

class QuranAudioLoading extends QuranAudioState {}

class QuranAudioPlaying extends QuranAudioState {
  final PlayerState playerState;
  final String reciterId;
  final int ayahNumber;

  const QuranAudioPlaying(this.playerState, this.reciterId, this.ayahNumber);

  @override
  List<Object?> get props => [playerState, reciterId, ayahNumber];
}

class QuranAudioPaused extends QuranAudioState {}

class QuranAudioStopped extends QuranAudioState {}

class QuranAudioError extends QuranAudioState {
  final String message;

  const QuranAudioError(this.message);

  @override
  List<Object?> get props => [message];
}
