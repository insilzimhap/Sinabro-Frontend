// lib/main/studyView/listenStudy/page/level1/animals/animal_intro_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/data/animal_study_models.dart';

class AnimalIntroPage extends StatefulWidget {
  const AnimalIntroPage({
    super.key,
    required this.groupData,
    required this.onIntroCompleted,
  });

  final AnimalGroupData groupData;
  final VoidCallback onIntroCompleted;

  @override
  State<AnimalIntroPage> createState() => _AnimalIntroPageState();
}

class _AnimalIntroPageState extends State<AnimalIntroPage> {
  int _step = 0;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    _playStep0Audio();
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playStep0Audio() async {
    try {
      // 공통 오디오 재생
      await _player.setAsset(
          'assets/audio/tts/studyListen/level1/animals/animals_common1.mp3');
      unawaited(_player.play());
    } catch (e) {
      debugPrint('Intro Step0 audio error: $e');
    }
  }

  Future<void> _playStep1AndComplete() async {
    await _player.stop();
    _playerSub?.cancel();

    try {
      // 그룹별 고유 오디오 재생
      await _player.setAsset(widget.groupData.introAudio);
      await _player.play();
    } catch (e) {
      debugPrint('Intro Step1 audio error: $e');
    }

    _playerSub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        _playerSub?.cancel();
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        widget.onIntroCompleted();
      }
    });
  }

  void _handleTap() {
    if (_step == 0) {
      setState(() => _step = 1);
      _playStep1AndComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: FigmaBoard(
        baseWidth: 2000,
        baseHeight: 1200,
        builder: (context, scale, dx, dy) {
          final u = FigmaUnits(scale, dx, dy);
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: const Color(0xFFFFF2E5)),
              ),
              // STEP 0: “동물 친구들을 찾아 여행을 떠나요!” + 탐험복 캐릭터
              if (_step == 0) ...[
                Positioned(
                  left: u.sx(152),
                  top: u.sy(909),
                  child: Text(
                    '동물 친구들을 찾아 여행을 떠나요!',
                    style: TextStyle(
                      color: const Color(0xFF7C685F),
                      fontSize: u.sp(120),
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  left: u.sx(650),
                  top: u.sy(100),
                  width: u.sw(800),
                  height: u.sw(800),
                  child: Image.asset(widget.groupData.introCharacter),
                ),
              ],
              // STEP 1: 그룹별 텍스트 + 그룹별 배경 이미지
              if (_step == 1) ...[
                Positioned(
                  left: u.sx(200), // 공통 좌표로 조정
                  top: u.sy(909),
                  width: u.sw(1600), // 가운데 정렬을 위해 너비 확보
                  child: Text(
                    widget.groupData.introText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7C685F),
                      fontSize: u.sp(120),
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  left: u.sx(488),
                  top: u.sy(1),
                  width: u.sw(1024),
                  height: u.sw(1024),
                  child: Image.asset(widget.groupData.introBgImage),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
