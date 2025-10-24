// lib/main/studyView/listenStudy/page/level2/story3/story_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/model/number_story_item.dart';

/// 레벨2 스토리 (가족 구성원별 단일 페이지) -> 숫자 학습 페이지
/// - stories: 숫자-손-과일 순서의 스토리 목록
/// - onFinished: 모든 스토리가 끝나면 호출되는 콜백
class StoryPage extends StatefulWidget {
  final List<NumberStoryItem> stories; // 숫자-손-과일 순
  final VoidCallback onFinished;
  final String childId;

  const StoryPage({
    super.key,
    required this.stories,
    required this.onFinished,
    required this.childId,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int _currentIndex = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;
  bool _canNavigate = false; // 탭 가능 여부를 제어하는 변수

  @override
  void initState() {
    super.initState();
    // 오디오 재생이 완료되면 _canNavigate를 true로 변경
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() => _canNavigate = true);
      }
    });
    _playCurrentAudio();
  }

  @override
  void dispose() {
    // 페이지가 닫힐 때 오디오 관련 리소스를 모두 정리
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// 현재 장면에 해당하는 오디오를 재생하는 함수
  Future<void> _playCurrentAudio() async {
    setState(() => _canNavigate = false); // 다음 장면이 시작되면 탭을 막음
    final story = widget.stories[_currentIndex];
    if (story.audioPath != null && story.audioPath!.isNotEmpty) {
      await _audioPlayer.play(AssetSource(story.audioPath!));
    } else {
      // 오디오 파일이 없는 경우, 잠시 후 탭이 가능하도록 합니다.
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _canNavigate = true);
    }
  }

  /// 화면을 탭했을 때 다음 페이지로 넘어가는 함수
  Future<void> _nextPage() async {
    // 오디오 재생이 끝나야만 다음으로
    if (!_canNavigate) return;

    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _playCurrentAudio(); // 다음 장면의 오디오를 재생
    } else {
      widget.onFinished(); // 모든 스토리가 끝나면 콜백을 호출
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _nextPage,
        child: SafeArea(
          child: Center(
            // 장면이 바뀔 때 부드러운 전환 효과를 위해 AnimatedSwitcher 사용
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Column(
                // key를 변경해야 AnimatedSwitcher가 위젯이 변경되었음을 인지
                key: ValueKey<int>(_currentIndex),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🖼 이미지
                  Image.asset(
                    story.imagePath ?? "",
                    width: MediaQuery.of(context).size.height * 0.45,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),

                  // 📝 텍스트
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      story.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 📍 안내 문구
                  // 오디오가 끝나면 안내 문구가 나타나도록 AnimatedOpacity 추가
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
      ),
    );
  }
}
