// lib/main/studyView/listenStudy/page/level3/intro_topic_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:sinabro/main/studyView/listenStudy/page/level3/style.dart';

class IntroTopicPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final String childId;

  const IntroTopicPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    required this.childId,
  });

  @override
  State<IntroTopicPage> createState() => _IntroTopicPageState();
}

class _IntroTopicPageState extends State<IntroTopicPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 오디오 관련 변수
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // 좌우 왕복

    // 오디오 완료 시 탭 가능하도록 설정
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _canNavigate = true);
    });
    // 인트로 오디오 재생
    _audioPlayer.play(
        AssetSource('audio/tts/studyListen/level3/daily/daily_intro_01.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _playerCompleteSubscription?.cancel(); // 리스너 정리
    _audioPlayer.dispose(); // 오디오 플레이어 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      body: InkWell(
        // 오디오가 끝나야 탭 가능
        onTap: _canNavigate ? widget.onTap : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙
          children: [
            // 좌우 흔들리는 시계
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // -20px ~ +20px 좌우 이동
                double dx = math.sin(_controller.value * 2 * math.pi) * 20;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
              },
              child: Image.asset(
                widget.imagePath,
                height: AppStyle.introImageHeight(context),
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: AppStyle.introSpacing(context)),

            // 텍스트
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppStyle.introTitle(context),
              ),
            ),

            // 오디오 완료 후 안내 문구 표시
            const SizedBox(height: 30),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _canNavigate ? 1.0 : 0.0,
              child: const Text(
                "화면을 터치하면 다음으로 넘어갑니다",
                style: TextStyle(color: Colors.black45, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
