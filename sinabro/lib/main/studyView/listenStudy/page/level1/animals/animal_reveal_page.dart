// lib/main/studyView/listenStudy/page/level1/animals/animal_reveal_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/data/animal_study_models.dart';

class AnimalRevealPage extends StatefulWidget {
  const AnimalRevealPage({
    super.key,
    required this.animalData,
    required this.onRevealCompleted,
  });

  final AnimalContentData animalData;
  final VoidCallback onRevealCompleted;

  @override
  State<AnimalRevealPage> createState() => _AnimalRevealPageState();
}

class _AnimalRevealPageState extends State<AnimalRevealPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    _playAndComplete();
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAndComplete() async {
    try {
      await _player.setAsset(
          'assets/audio/tts/studyListen/level1/animals/animals_common2.mp3');
      await _player.play();
    } catch (e) {
      debugPrint('${widget.animalData.name} Reveal audio error: $e');
    }

    _playerSub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        _playerSub?.cancel();
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        widget.onRevealCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FigmaBoard(
      baseWidth: 2000,
      baseHeight: 1200,
      builder: (context, scale, dx, dy) {
        final u = FigmaUnits(scale, dx, dy);

        return Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFFFFF2E5))),
            // 데이터로부터 실루엣 이미지와 좌표를 받아 동적으로 배치
            Positioned(
              left: u.sx(widget.animalData.silhouetteRect.left),
              top: u.sy(widget.animalData.silhouetteRect.top),
              width: u.sw(widget.animalData.silhouetteRect.width),
              height: u.sw(widget.animalData.silhouetteRect.height),
              child: Image.asset(widget.animalData.silhouetteImage,
                  fit: BoxFit.cover),
            ),
            // 공통 UI 요소들
            Positioned(
              left: u.sx(400),
              top: u.sy(805),
              child: Text('새로운 친구를 만났어요!', style: _commonTextStyle(u)),
            ),
            Positioned(
              left: u.sx(574),
              top: u.sy(950),
              child: Text('안녕? 넌 누구야?', style: _commonTextStyle(u)),
            ),
            Positioned(
              left: u.sx(1428),
              top: u.sy(132),
              child: Transform.rotate(
                  angle: 0.26, child: Text('?', style: _commonTextStyle(u))),
            ),
            Positioned(
              left: u.sx(557),
              top: u.sy(600),
              child: Transform.rotate(
                  angle: -0.27, child: Text('?', style: _commonTextStyle(u))),
            ),
          ],
        );
      },
    );
  }

  TextStyle _commonTextStyle(FigmaUnits u) => TextStyle(
        color: const Color(0xFF7C685F),
        fontSize: u.sp(120),
        fontWeight: FontWeight.w700,
      );
}
