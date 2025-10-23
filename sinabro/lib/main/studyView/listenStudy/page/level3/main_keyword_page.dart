// lib/main/studyView/listenStudy/page/level3/main_keyword_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/style.dart';

class MainKeywordPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String? audioPath;
  final VoidCallback onTap;
  final String childId;

  const MainKeywordPage({
    super.key,
    required this.imagePath,
    required this.title,
    this.audioPath,
    required this.onTap,
    required this.childId,
  });

  @override
  State<MainKeywordPage> createState() => _MainKeywordPageState();
}

class _MainKeywordPageState extends State<MainKeywordPage> {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
            children: [
              // 키워드 이미지
              Image.asset(
                widget.imagePath,
                height: AppStyle.keywordImageHeight(context),
                fit: BoxFit.contain,
              ),

              SizedBox(height: AppStyle.keywordSpacing(context)),

              // 키워드 텍스트
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppStyle.keywordTitle(context),
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
      ),
    );
  }
}
