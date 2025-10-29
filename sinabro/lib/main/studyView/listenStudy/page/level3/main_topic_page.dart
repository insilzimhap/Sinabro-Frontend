// lib/main/studyView/listenStudy/page/level3/main_topic_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/style.dart';

class MainTopicPage extends StatefulWidget {
  final String topicImagePath; // 토픽 이미지
  final String title;
  final String? audioPath; // 오디오 경로 추가
  final VoidCallback onTap;
  final String childId;

  const MainTopicPage({
    super.key,
    required this.topicImagePath,
    required this.title,
    this.audioPath,
    required this.onTap,
    required this.childId,
  });

  @override
  State<MainTopicPage> createState() => _MainTopicPageState();
}

class _MainTopicPageState extends State<MainTopicPage> {
  // 오디오 관련 변수
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _canNavigate = true);
    });

    // 오디오 경로가 있으면 재생, 없으면 바로 탭 가능
    if (widget.audioPath != null && widget.audioPath!.isNotEmpty) {
      _audioPlayer.play(AssetSource(widget.audioPath!));
    } else {
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
      backgroundColor: AppStyle.background,
      body: InkWell(
        // 오디오가 끝나야 탭 가능
        onTap: _canNavigate ? widget.onTap : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Center(
                child: Image.asset(
                  widget.topicImagePath,
                  height: AppStyle.mainTopicImageHeight(context),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: AppStyle.mainTopicSpacing(context)),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppStyle.mainTopicTitle(context),
                ),
              ),
            ),
            // 오디오 완료 후 안내 문구 표시 (Spacer 대신 사용)
            Expanded(
              flex: 1,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _canNavigate ? 1.0 : 0.0,
                  child: const Text(
                    "화면을 터치하면 다음으로 넘어갑니다",
                    style: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
