import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// StatefulWidget에서 오디오 재생/관리를 쉽게 할 수 있도록 도와주는 Mixin입니다.
/// 효과음(SFX)과 TTS(대사)를 위한 별도의 플레이어를 관리합니다.
mixin AudioHandlerMixin<T extends StatefulWidget> on State<T> {
  // 효과음 전용 플레이어
  final AudioPlayer _sfxPlayer = AudioPlayer();
  // TTS(대사) 전용 플레이어
  final AudioPlayer _ttsPlayer = AudioPlayer();

  /// [추가] 외부에서 플레이어의 상태(재생, 정지, 완료 등)를 알 수 있도록 Stream을 제공합니다.
  Stream<PlayerState> get sfxStateStream => _sfxPlayer.onPlayerStateChanged;
  Stream<PlayerState> get ttsStateStream => _ttsPlayer.onPlayerStateChanged;

  /// 지정된 오디오 파일을 재생합니다. (효과음 또는 TTS)
  ///
  /// playerType 에 'sfx' 또는 'tts'를 지정하여 사용할 플레이어를 선택합니다.
  Future<void> playAudio(String assetPath, {String playerType = 'tts'}) async {
    final player = playerType == 'sfx' ? _sfxPlayer : _ttsPlayer;
    try {
      // 혹시 이전에 재생 중인 소리가 있다면 정지시킵니다.
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('오디오 재생 중 오류 발생 ($assetPath): $e');
    }
  }

  /// 두 개의 오디오 파일을 순차적으로 재생합니다. (예: 효과음 -> TTS)
  /// [추가] 선택적으로 두 오디오 사이에 `delay`를 줄 수 있습니다.
  Future<void> playAudioSequentially({
    required String sfxPath,
    required String ttsPath,
    Duration delay = Duration.zero, // 기본 딜레이는 0초
  }) async {
    try {
      // 1. 효과음(sfx)을 먼저 재생합니다.
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(sfxPath));

      // 2. 효과음 재생이 끝나면, 지정된 시간만큼 기다렸다가 TTS를 재생합니다.
      _sfxPlayer.onPlayerStateChanged
          .firstWhere((state) => state == PlayerState.completed)
          .then((_) async {
        // async 추가

        await Future.delayed(delay); // 👈 여기에 딜레이를 적용합니다.

        if (mounted) {
          playAudio(ttsPath, playerType: 'tts');
        }
      });
    } catch (e) {
      debugPrint('순차 오디오 재생 중 오류 발생: $e');
    }
  }

  /// 위젯이 화면에서 사라질 때 모든 오디오 플레이어를 정리합니다.
  /// 반드시 State의 dispose() 메소드 안에서 호출해야 합니다.
  void disposeAudioPlayers() {
    _sfxPlayer.dispose();
    _ttsPlayer.dispose();
  }

  // State의 dispose가 호출될 때 자동으로 플레이어를 정리하도록 합니다.
  @override
  void dispose() {
    disposeAudioPlayers();
    super.dispose();
  }
}
