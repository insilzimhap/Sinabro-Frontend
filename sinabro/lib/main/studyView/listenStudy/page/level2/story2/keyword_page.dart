// lib/main/studyView/listenStudy/level2/story2/keyword_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/model/routine_content.dart';

class KeywordPage extends StatefulWidget {
  final RoutineContent keyword;
  final VoidCallback onNext;
  final String childId; // 자녀 아이디
  const KeywordPage(
      {super.key,
      required this.keyword,
      required this.onNext,
      required this.childId});

  @override
  State<KeywordPage> createState() => _KeywordPageState();
}

class _KeywordPageState extends State<KeywordPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _canNavigate = false;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    // 오디오 재생이 완료되면 _canNavigate를 true로 변경
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _canNavigate = true);
    });

    // 위젯에 전달된 audioPath가 있는지 확인하고 재생
    if (widget.keyword.audioPath != null) {
      _audioPlayer.play(AssetSource(widget.keyword.audioPath!));
    } else {
      // 오디오 경로가 없으면 즉시 다음으로
      setState(() => _canNavigate = true);
    }
  }

  @override
  void dispose() {
    // 페이지가 사라질 때 플레이어 + 리스너 정리
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        // ✨ [수정] _canNavigate가 true일 때만 onNext 함수가 실행됩니다.
        onTap: _canNavigate ? widget.onNext : null,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.keyword.imagePath ?? "",
                  width: MediaQuery.of(context).size.height * 0.5,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  widget.keyword.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),
                //  _canNavigate 값에 따라 안내 문구가 부드럽게 나타납니다.
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
