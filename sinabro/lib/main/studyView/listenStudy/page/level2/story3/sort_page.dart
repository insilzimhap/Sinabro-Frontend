// lib/main/studyView/listenStudy/page/level2/story3/sort_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/model/routine_content.dart';

class SortPage extends StatefulWidget {
  final List<RoutineContent> stories; // 숫자, 손, 과일 3개
  final int number; // 현재 숫자 (1~10)
  final VoidCallback onNext; // 다음 루틴으로 이동

  const SortPage({
    super.key,
    required this.stories,
    required this.number,
    required this.onNext,
  });

  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _canNavigate = false;
  StreamSubscription? _playerCompleteSubscription;

  /// ✅ 텍스트 설정 5, 10일 때는 다른 TTS
  String get _text {
    if (widget.number == 5) return "이건 모두 5에요\n1부터 5까지 전부 익혔어요!";
    if (widget.number == 10) return "이건 모두 10이에요\n6부터 10까지 전부 익혔어요!";
    return "이건 모두 ${widget.number}이에요\n다음 숫자를 알아볼까요?";
  }

  /// 오디오 파일 경로 설정
  String get _audioPath {
    final basePath = 'audio/tts/studyListen/level2/numbers';
    if (widget.number == 5) return '$basePath/num_05_outro.mp3';
    if (widget.number == 10) return '$basePath/num_10_outro.mp3';
    final numString = widget.number.toString().padLeft(2, '0');
    return '$basePath/num_${numString}_next.mp3';
  }

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _canNavigate = true);
    });

    _audioPlayer.play(AssetSource(_audioPath));
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        // 오디오가 끝나야만 onNext 함수가 호출
        onTap: _canNavigate ? widget.onNext : null,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼 이미지 3개 가로 나열
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.stories.length,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        widget.stories[i].imagePath ?? "",
                        width: MediaQuery.of(context).size.width * 0.18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 📝 텍스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                // 오디오가 끝나면 안내 문구
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
        ),
      ),
    );
  }
}
