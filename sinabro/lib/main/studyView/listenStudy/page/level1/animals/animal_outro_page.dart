// lib/main/studyView/listenStudy/page/level1/animals/animal_outro_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/data/animal_study_models.dart';

class AnimalOutroPage extends StatefulWidget {
  const AnimalOutroPage({
    super.key,
    required this.animalData,
    required this.groupData,
    required this.isFinalAnimalInGroup,
    required this.onOutroCompleted,
    required this.childId,
  });

  final AnimalGroupData groupData;
  final AnimalContentData animalData;
  final bool isFinalAnimalInGroup;
  final VoidCallback onOutroCompleted;
  final String childId;

  @override
  State<AnimalOutroPage> createState() => _AnimalOutroPageState();
}

class _AnimalOutroPageState extends State<AnimalOutroPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;
  int _step = 0; // 0: 동물 고유, 1: 다음 예고, 2: 그룹 완료

  @override
  void initState() {
    super.initState();
    _playCurrent();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playCurrent() async {
    await _sub?.cancel();
    String audioPath = '';

    if (_step == 0) {
      // 동물 고유 아웃트로
      audioPath = widget.animalData.outroAudio;
    } else if (_step == 1) {
      // "다음 친구를 만나러~" (마지막 동물이 아닐 때)
      audioPath =
          'assets/audio/tts/studyListen/level1/animals/animals_common3.mp3';
    } else {
      // 그룹 완료 (마지막 동물일 때)
      audioPath = widget.groupData.finalOutroAudio;
    }

    try {
      await _player.setAsset(audioPath);
      await _player.play();
    } catch (e) {
      debugPrint('${widget.animalData.name} Outro audio error: $e');
    }

    _sub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        _goNextStep();
      }
    });
  }

  void _goNextStep() {
    if (_step == 0) {
      // 동물 고유 아웃트로 끝
      // 마지막 동물이면 그룹 완료로, 아니면 다음 예고로
      setState(() => _step = widget.isFinalAnimalInGroup ? 2 : 1);
      _playCurrent();
    } else {
      // 다음 예고 또는 그룹 완료 끝
      widget.onOutroCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaBoard(
      baseWidth: 2000,
      baseHeight: 1200,
      builder: (context, scale, dx, dy) {
        final u = FigmaUnits(scale, dx, dy);

        if (_step == 2) {
          // 그룹 완료 화면
          return Stack(
            children: [
              Positioned.fill(child: Container(color: const Color(0xFFFFF2E5))),
              Positioned(
                left: u.sx(576),
                top: u.sy(0),
                width: u.sw(848),
                height: u.sw(848),
                child: Image.asset(
                    'assets/img/contents/studyListen/level1/animals/animal4.png'),
              ),
              Positioned(
                left: u.sx(276),
                top: u.sy(753),
                width: u.sw(1448),
                child: Text(
                  widget.groupData.finalOutroText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF7C685F),
                    fontSize: u.sp(100),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          );
        }

        // 동물 고유 또는 다음 예고 화면
        String textToShow = '';
        if (_step == 0) textToShow = widget.animalData.outroText;
        if (_step == 1) textToShow = '다음 친구를 만나러 가볼까요?';

        return Stack(
          children: [
            Positioned.fill(
                child: Image.asset(widget.animalData.outroImage,
                    fit: BoxFit.cover)),
            Positioned(
              left: u.sx(172),
              top: u.sy(998),
              width: u.sw(1655),
              height: u.sw(133),
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: u.sw(7), color: const Color(0xFFD5D5D5)),
                    borderRadius: BorderRadius.circular(u.sw(50)),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: u.sw(6)),
                    child: Text(
                      textToShow,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF626262),
                        fontSize: u.sp(80),
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
