// lib/main/studyView/listenStudy/level2/story2/topic_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/model/routine_content.dart';

/// 🧩 Story2 - 감정 토픽 페이지
/// 인트로 다음에 등장.
/// - 한 가지 감정(예: 좋아요, 배고파요 등)을 대표.
/// - 사용자가 이미지를 탭하면 다음 단계(키워드 페이지)로 이동.

class TopicPage extends StatefulWidget {
  final RoutineContent topic;
  final VoidCallback onNext;
  final String childId; // 자녀 아이디

  const TopicPage({
    super.key,
    required this.topic,
    required this.onNext,
    required this.childId,
  });

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _canNavigate = false;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _canNavigate = true);
    });

    if (widget.topic.audioPath != null) {
      _audioPlayer.play(AssetSource(widget.topic.audioPath!));
    } else {
      // 오디오가 없으면 바로 탭 가능하게
      setState(() => _canNavigate = true);
    }
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
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        onTap: _canNavigate ? widget.onNext : null, // 👈 클릭 시 다음으로 이동
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ 감정 대표 이미지
                Image.asset(
                  widget.topic.imagePath ?? "",
                  width: MediaQuery.of(context).size.width * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                // 🧠 감정 이름 텍스트
                Text(
                  widget.topic.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown),
                ),
                // 💬 안내 문구
                const SizedBox(height: 40),
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
