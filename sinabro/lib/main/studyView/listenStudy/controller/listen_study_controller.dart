import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundItem {
  final String label; // 예: '쿨쿨'
  final String audioPath; // 예: 'assets/audio/.../cool.mp3'
  final double left; // 버튼 위치 (왼쪽)
  final double top; // 버튼 위치 (위쪽)
  bool isPlayed; // 버튼이 눌렸는지 여부

  SoundItem({
    required this.label,
    required this.audioPath,
    required this.left,
    required this.top,
    this.isPlayed = false,
  });
}

class ListenStudyController with ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  List<SoundItem> soundItems = [
    SoundItem(
      label: '쿨쿨',
      audioPath: 'audio/tts/studyListen/soundWords/test/cool.mp3',
      left: 150,
      top: 250,
    ),
    SoundItem(
      label: '아장아장',
      audioPath: 'audio/tts/studyListen/soundWords/test/ajang.mp3',
      left: 620,
      top: 420,
    ),
    SoundItem(
      label: '뽀득뽀득',
      audioPath: 'audio/tts/studyListen/soundWords/test/squeak.mp3',
      left: 1000,
      top: 200,
    ),
    SoundItem(
      label: '보글보글',
      audioPath: 'audio/tts/studyListen/soundWords/test/boggle.mp3',
      left: 1000,
      top: 500,
    ),
  ];

  Future<void> playSound(int index) async {
    if (soundItems[index].isPlayed) return;

    await player.play(AssetSource(soundItems[index].audioPath));

    soundItems[index].isPlayed = true;
    notifyListeners();
  }

  bool get isAllPlayed => soundItems.every((item) => item.isPlayed);
}
