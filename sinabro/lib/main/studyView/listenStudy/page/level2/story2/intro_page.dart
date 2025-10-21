// lib/main/studyView/listenStudy/level2/story2/intro_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// 🍊 Story2 - 감정 인트로 페이지
/// 감정 학습 시작 화면.
/// 탭하면 감정 토픽(예: 좋아요, 배고파요)으로 이동.
class Story2IntroPage extends StatefulWidget {
  final VoidCallback onNext;
  const Story2IntroPage({super.key, required this.onNext});

  @override
  State<Story2IntroPage> createState() => _Story2IntroPageState();
}

class _Story2IntroPageState extends State<Story2IntroPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _canNavigate = false;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _canNavigate = true);
    });
    _audioPlayer.play(
        AssetSource('audio/tts/studyListen/level2/emotions/emo_intro1.mp3'));
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        // ✨ [수정] 오디오가 끝나야 탭 가능
        onTap: _canNavigate ? widget.onNext : null,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  // 🖼️ 감정 대표 이미지
                  "assets/img/contents/studyListen/level2/face.png",
                  width: screenWidth * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                const Text(
                  // ✨ 인트로 텍스트
                  "짠! 오늘은 감정에 대해서 알아볼까요?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.brown,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "기쁨, 무서움, 놀람 같은 감정을 함께 배워봐요 🍎",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.brown),
                ),
                const SizedBox(height: 60),
                // ✨ [수정] 오디오 끝나면 안내 문구 나타나도록
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _canNavigate ? 1.0 : 0.0,
                  child: const Text(
                    // 💬 안내 문구
                    "화면을 터치하면 시작됩니다",
                    style: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
