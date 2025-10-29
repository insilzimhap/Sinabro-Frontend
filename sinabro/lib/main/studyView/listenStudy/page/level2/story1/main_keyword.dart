// lib/main/studyView/listenStudy/page/level2/story1/main_keyword.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/models.dart';

class MainKeywordPage extends StatefulWidget {
  final int index; // 1~6
  final Gender gender;
  final VoidCallback onNext;
  final String childId; // 자녀 아이디

  const MainKeywordPage({
    super.key,
    required this.index,
    required this.gender,
    required this.onNext,
    required this.childId,
  });

  @override
  State<MainKeywordPage> createState() => _MainKeywordPageState();
}

class _MainKeywordPageState extends State<MainKeywordPage> {
  // ✨ [수정] AudioPlayer 추가
  final AudioPlayer _audioPlayer = AudioPlayer();

  String get _title {
    switch (widget.index) {
      case 1:
        return "엄마";
      case 2:
        return "아빠";
      case 3:
        return widget.gender == Gender.male ? "누나" : "언니";
      case 4:
        return widget.gender == Gender.male ? "형" : "오빠";
      case 5:
        return "나";
      case 6:
        return "동생";
      default:
        return "";
    }
  }

  String get _imagePath {
    const base = "assets/img/contents/studyListen/level2/main_keyword";
    if (widget.index == 5) {
      return "$base/1-5(${widget.gender == Gender.male ? "boy" : "girl"}).png";
    }
    return "$base/1-${widget.index}.png";
  }

  // 오디오 파일명을 가져오는 함수
  String get _audioFileName {
    switch (widget.index) {
      case 1:
        return "fam_mom.mp3";
      case 2:
        return "fam_dad.mp3";
      case 3:
        return widget.gender == Gender.male ? "fam_nuna.mp3" : "fam_eonni.mp3";
      case 4:
        return widget.gender == Gender.male ? "fam_hyeong.mp3" : "fam_oppa.mp3";
      case 5:
        return "fam_me.mp3";
      case 6:
        return "fam_younger.mp3";
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_audioFileName.isNotEmpty) {
      await _audioPlayer.play(
          AssetSource('audio/tts/studyListen/level2/family/$_audioFileName'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: InkWell(
        onTap: widget.onNext,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _imagePath,
                  width: MediaQuery.of(context).size.width * 0.3,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.brown,
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
