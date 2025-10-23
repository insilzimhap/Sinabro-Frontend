// lib/main/studyView/listenStudy/level2/story2/story_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/model/routine_content.dart';

/// 🎞️ Story2 - 감정 스토리 페이지
/// 3개의 감정 스토리를 자동으로 순차 재생.
/// (탭하지 않아도 3~4초마다 다음 이미지로 넘어감)
class StoryPage extends StatefulWidget {
  final List<RoutineContent> data; // 3개의 스토리
  final VoidCallback onFinished; // 다음 감정으로 이동
  final String childId; // 자녀 아이디

  const StoryPage(
      {super.key,
      required this.data,
      required this.onFinished,
      required this.childId});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int _currentIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    // 오디오 재생이 끝나면 _goToNextScene을 호출하도록 설정
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _goToNextScene();
    });
    // 첫 번째 장면의 오디오를 재생
    _playCurrentScene();
  }

  // 현재 장면에 맞는 오디오를 재생하는 함수
  void _playCurrentScene() {
    if (_currentIndex < widget.data.length) {
      final currentStory = widget.data[_currentIndex];
      if (currentStory.audioPath != null &&
          currentStory.audioPath!.isNotEmpty) {
        _audioPlayer.play(AssetSource(currentStory.audioPath!));
      } else {
        // 오디오 없으면 1.5초 후 자동으로 다음 장면으로 넘어감
        Future.delayed(const Duration(milliseconds: 1500), _goToNextScene);
      }
    }
  }

  // 다음 장면으로 이동하거나 학습을 종료하는 함수
  void _goToNextScene() {
    if (!mounted) return;
    if (_currentIndex < widget.data.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playCurrentScene();
    } else {
      // 모든 장면이 끝나면 onFinished 콜백을 호출
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    // 페이지가 닫힐 때 리스너와 플레이어를 모두 정리
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.data[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ 이미지
              // 이미지가 바뀔 때 부드러운 전환 효과를 위해 AnimatedSwitcher 사용
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  story.imagePath ?? "",
                  // key를 변경하여 AnimatedSwitcher가 위젯이 변경되었음을 인지하게 함
                  key: ValueKey<int>(_currentIndex),
                  width: MediaQuery.of(context).size.width * 0.4,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // 🧠 텍스트
              Text(
                story.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 40),

              // 📍 진행 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.data.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i == _currentIndex ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? Colors.brown
                          : Colors.brown.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
