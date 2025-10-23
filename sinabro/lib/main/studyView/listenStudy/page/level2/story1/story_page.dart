// lib/main/studyView/listenStudy/page/level2/story1/story_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/models.dart';

/// 레벨2 스토리 (가족 구성원별 단일 페이지)
/// - index: 1~6 (엄마~동생)
/// - gender: 성별에 따라 이미지 및 텍스트 분기
/// - onFinished: 다음 단계로 넘어가는 콜백

class StoryPage extends StatefulWidget {
  final int index;
  final Gender gender;
  final VoidCallback onFinished;
  final String childId; // 자녀 아이디

  const StoryPage({
    super.key,
    required this.index,
    required this.gender,
    required this.onFinished,
    required this.childId,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  String get _imagePath {
    final base = "assets/img/contents/studyListen/level2/story";
    switch (widget.index) {
      case 1:
        return "$base/1-1-${widget.gender == Gender.male ? 1 : 2}.png";
      case 2:
        return "$base/1-2-${widget.gender == Gender.male ? 1 : 2}.png";
      case 3:
        return "$base/1-4-${widget.gender == Gender.male ? 1 : 2}.png";
      case 4:
        return "$base/1-5-${widget.gender == Gender.male ? 1 : 2}.png";
      case 5:
        return "$base/1-6-${widget.gender == Gender.male ? 1 : 2}.png";
      case 6:
        return "$base/1-7-${widget.gender == Gender.male ? 1 : 2}.png";
      default:
        return "";
    }
  }

  String get _text {
    switch (widget.index) {
      case 1:
        return "엄마는 나와 함께 놀아줘";
      case 2:
        return "아빠는 나에게 책을 읽어줘";
      case 3:
        return widget.gender == Gender.male ? "누나는 나랑 그림을 그려" : "언니는 나랑 그림을 그려";
      case 4:
        return widget.gender == Gender.male ? "형은 나랑 블록을 쌓아" : "오빠는 나랑 블록을 쌓아";
      case 5:
        return "나는 노는걸 정말 좋아해";
      case 6:
        return "나는 동생의 손을 잡아줘";
      default:
        return "";
    }
  }

  // 오디오 파일명을 가져오는 함수
  String get _audioFileName {
    switch (widget.index) {
      case 1:
        return "fam_mom2.mp3";
      case 2:
        return "fam_dad2.mp3";
      case 3:
        return widget.gender == Gender.male
            ? "fam_nuna2.mp3"
            : "fam_eonni2.mp3";
      case 4:
        return widget.gender == Gender.male
            ? "fam_hyeong2.mp3"
            : "fam_oppa2.mp3";
      // '나'는 2개의 오디오가 필요하지만, 이 페이지 구조상 하나만 재생 가능
      // 'fam_me2.mp3'를 재생하도록 설정
      case 5:
        return "fam_me2.mp3";
      case 6:
        return "fam_younger2.mp3";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        onTap: () async {
          if (widget.index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => _ParentsStoryPage(gender: widget.gender)),
            );
          }
          if (widget.index == 6) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => _FamilyHarmonyPage(gender: widget.gender)),
            );
          }
          widget.onFinished();
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _imagePath,
                  width: MediaQuery.of(context).size.height * 0.5,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  "화면을 터치하면 다음으로 넘어갑니다",
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentsStoryPage extends StatefulWidget {
  final Gender gender;
  const _ParentsStoryPage({required this.gender});

  @override
  State<_ParentsStoryPage> createState() => __ParentsStoryPageState();
}

class __ParentsStoryPageState extends State<_ParentsStoryPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.play(AssetSource(
        'audio/tts/studyListen/level2/family/fam_parents_love.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = "assets/img/contents/studyListen/level2/story";
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "$base/1-3-${widget.gender == Gender.male ? 1 : 2}.png",
                  width: MediaQuery.of(context).size.height * 0.7,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                const Text("부모님은 나를 사랑해!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown)),
                const SizedBox(height: 40),
                const Text("화면을 터치하면 다음으로 넘어갑니다",
                    style: TextStyle(color: Colors.black45, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyHarmonyPage extends StatefulWidget {
  final Gender gender;
  const _FamilyHarmonyPage({required this.gender});

  @override
  State<_FamilyHarmonyPage> createState() => __FamilyHarmonyPageState();
}

class __FamilyHarmonyPageState extends State<_FamilyHarmonyPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _canNavigate = false;
  // 오디오 플레이어 상태를 확인 위한 변수
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    // 오디오 재생이 끝나면 _canNavigate를 true로 변경하도록
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _canNavigate = true;
        });
      }
    });

    // 오디오 재생 시작
    _audioPlayer
        .play(AssetSource('audio/tts/studyListen/level2/family/fam_outro.mp3'));
  }

  @override
  void dispose() {
    // ✨ [수정] 페이지가 닫힐 때 리스너와 플레이어 모두 정리
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = "assets/img/contents/studyListen/level2/story";
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        // _canNavigate가 true일 때만 pop이 실행되도록 변경
        onTap: _canNavigate ? () => Navigator.pop(context) : null,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "$base/1-8-${widget.gender == Gender.male ? 1 : 2}.png",
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                const Text("우리 가족은 화목해~",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown)),
                const SizedBox(height: 40),
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
    );
  }
}
