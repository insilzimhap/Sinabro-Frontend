// lib/main/studyView/listenStudy/page/level2/story1/gender_select_page.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models.dart';

class GenderSelectPage extends StatefulWidget {
  final ValueChanged<Gender> onSelected;
  const GenderSelectPage({super.key, required this.onSelected});

  @override
  State<GenderSelectPage> createState() => _GenderSelectPageState();
}

class _GenderSelectPageState extends State<GenderSelectPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playAudio('fam_gender.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 오디오 재생 헬퍼
  Future<void> _playAudio(String fileName) async {
    await _audioPlayer
        .play(AssetSource('audio/tts/studyListen/level2/family/$fileName'));
  }

  void _choose(BuildContext context, Gender gender) {
    Navigator.pop(context);
    Future.microtask(() => widget.onSelected(gender));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("성별 선택")),
      backgroundColor: const Color(0xFFFDF7F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "어떤 모습이야?",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderCard(
                  context,
                  imagePath: "assets/img/contents/studyListen/level2/girl.png",
                  label: "나는 여자아이야",
                  onTap: () {
                    // 여자아이 오디오 재생 후 선택
                    _playAudio('fam_girl.mp3');
                    _choose(context, Gender.female);
                  },
                ),
                const SizedBox(width: 20),
                _genderCard(
                  context,
                  imagePath: "assets/img/contents/studyListen/level2/boy.png",
                  label: "나는 남자아이야",
                  onTap: () {
                    // 남자아이 오디오 재생 후 선택
                    _playAudio('fam_boy.mp3');
                    _choose(context, Gender.male);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderCard(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.brown.withOpacity(0.2),
                offset: const Offset(2, 3),
                blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 120),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
