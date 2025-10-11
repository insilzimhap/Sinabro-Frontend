import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/dog_reveal_page.dart';

enum ExplorerCharacter { mungji, gonyam, ojjang, tosoom, gomjae }

String _characterAsset(ExplorerCharacter ch) {
  switch (ch) {
    case ExplorerCharacter.mungji:
      return 'assets/img/character/mungji_explorer.png';
    case ExplorerCharacter.gonyam:
      return 'assets/img/character/gonyam_explorer.png';
    case ExplorerCharacter.ojjang:
      return 'assets/img/character/ojjang_explorer.png';
    case ExplorerCharacter.tosoom:
      return 'assets/img/character/tosoom_explorer.png';
    case ExplorerCharacter.gomjae:
      return 'assets/img/character/gomjae_explorer.png';
  }
}

class AnimalsIntroPage1 extends StatefulWidget {
  const AnimalsIntroPage1({
    super.key,
    this.selectedCharacter = ExplorerCharacter.mungji,
    this.houseAsset =
        'assets/img/contents/studyListen/level1/animals/animal1.png',
    // 나중에 실제 파일명으로 교체 가능
    this.step0Audio =
        'assets/audio/tts/studyListen/level1/animals/animals_common1.mp3',
    this.step1Audio =
        'assets/audio/tts/studyListen/level1/animals/animals_step1.mp3',
    this.afterStep1Delay = const Duration(milliseconds: 800),
  });

  static const routeName = '/listen/animals/intro1';

  final ExplorerCharacter selectedCharacter;
  final String houseAsset;

  /// 1번/2번 화면에서 재생할 오디오
  final String step0Audio;
  final String step1Audio;

  /// 2번 오디오가 끝난 뒤 추가 지연
  final Duration afterStep1Delay;

  @override
  State<AnimalsIntroPage1> createState() => _AnimalsIntroPage1State();
}

class _AnimalsIntroPage1State extends State<AnimalsIntroPage1> {
  int _step = 0;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    // 1번 화면 오디오 재생
    _playStep0Audio();

    debugPrint(
      '[ExploreIntro] selectedCharacter = ${widget.selectedCharacter.name} '
      '(asset: ${_characterAsset(widget.selectedCharacter)})',
    );
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playStep0Audio() async {
    try {
      await _player.setAsset(widget.step0Audio);
      unawaited(_player.play());
    } catch (e) {
      debugPrint('Step0 audio error: $e');
    }
  }

  Future<void> _playStep1ThenGoReveal() async {
    // 이전 재생 중단
    await _player.stop();
    _playerSub?.cancel();

    try {
      await _player.setAsset(widget.step1Audio);
      await _player.play();
    } catch (e) {
      debugPrint('Step1 audio error: $e');
    }

    // 오디오 완료 감지 후 딜레이 → DogRevealPage
    _playerSub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        _playerSub?.cancel();
        if (!mounted) return;
        await Future.delayed(widget.afterStep1Delay);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, DogRevealPage.routeName);
      }
    });
  }

  void _handleTap() {
    // 1번 -> 2번은 터치로
    if (_step == 0) {
      setState(() => _step = 1);
      _playStep1ThenGoReveal(); // 2번 오디오 재생 + 자동 이동
    }
    // _step == 1 인 상태에선 터치 필요 없음(자동 이동)
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: StudyBackLayout(
        onBack: () => Navigator.of(context).maybePop(),
        body: FigmaBoard(
          baseWidth: 2000,
          baseHeight: 1200,
          builder: (context, scale, dx, dy) {
            final u = FigmaUnits(scale, dx, dy);
            return Stack(
              children: [
                Positioned.fill(
                    child: Container(color: const Color(0xFFFFF2E5))),

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
                        fontFamily: 'Inter',
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
                    child: Image.asset(
                      _characterAsset(widget.selectedCharacter),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                // STEP 1: “이번에는 집 주변으로 가볼까요?” + 집 일러스트
                if (_step == 1) ...[
                  Positioned(
                    left: u.sx(207),
                    top: u.sy(909),
                    child: Text(
                      '이번에는 집 주변으로 가볼까요?',
                      style: TextStyle(
                        color: const Color(0xFF7C685F),
                        fontSize: u.sp(120),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: u.sx(550),
                    top: u.sy(60),
                    width: u.sw(900),
                    height: u.sw(900),
                    child: Image.asset(
                      widget.houseAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
