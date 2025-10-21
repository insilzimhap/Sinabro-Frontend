// lib/main/studyView/listenStudy/page/level3/story_page.dart

import 'dart:async'; // ✨ 1. import 추가
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // ✨ 2. import 추가
// ✨ 3. 절대 경로로 수정
import 'package:sinabro/main/studyView/listenStudy/page/level3/style.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/model/story_item.dart';

class StoryPage extends StatefulWidget {
  // ✨ 4. String 대신 StoryItem 객체를 받도록 수정
  final StoryItem story;
  final VoidCallback onFinished;

  const StoryPage({
    super.key,
    required this.story,
    required this.onFinished,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  // ✨ 5. 오디오 관련 변수 추가
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();

    // ✨ 6. 오디오가 끝나면 onFinished 콜백 실행
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) widget.onFinished(); // mounted 체크 필수
    });

    _playAudio();
  }

  /// 현재 장면에 맞는 오디오를 재생하는 함수
  Future<void> _playAudio() async {
    final audioPath = widget.story.audioPath;

    if (audioPath != null && audioPath.isNotEmpty) {
      // 오디오가 있으면 재생
      await _audioPlayer.play(AssetSource(audioPath));
    } else {
      // 오디오 파일이 없으면, 1.5초 기다린 후 자동으로 onFinished 호출
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) widget.onFinished();
      });
    }
  }

  @override
  void dispose() {
    // ✨ 7. 오디오 리소스 정리
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙
          children: [
            // 이미지
            Image.asset(
              widget.story.imagePath, // ✨ 8. story 객체에서 직접 가져옴
              height: AppStyle.storyImageHeight(context),
              fit: BoxFit.contain,
            ),

            SizedBox(height: AppStyle.storySpacing(context)),

            // 텍스트
            Text(
              widget.story.text, // ✨ 9. story 객체에서 직접 가져옴
              textAlign: TextAlign.center, // 가운데 정렬
              style: AppStyle.storyTitle(context),
            ),
          ],
        ),
      ),
    );
  }
}
