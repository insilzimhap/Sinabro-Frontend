import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/rabbit_story_page.dart';

class RabbitRevealPage extends StatefulWidget {
  const RabbitRevealPage({super.key});

  static const routeName = '/listen/animals/rabbit-reveal';

  @override
  State<RabbitRevealPage> createState() => _RabbitRevealPageState();
}

class _RabbitRevealPageState extends State<RabbitRevealPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    _playAndNavigate();
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAndNavigate() async {
    try {
      await _player.setAsset(
        'assets/audio/tts/studyListen/level1/animals/animals_common2.mp3',
      );
      await _player.play();
    } catch (e) {
      debugPrint('RabbitReveal audio error: $e');
    }

    // 오디오 완료되면 다음 화면으로 이동
    _playerSub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        _playerSub?.cancel();
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, RabbitStoryPage.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StudyBackLayout(
      onBack: () => Navigator.of(context).maybePop(),
      body: FigmaBoard(
        baseWidth: 2000,
        baseHeight: 1200,
        builder: (context, scale, dx, dy) {
          final u = FigmaUnits(scale, dx, dy);

          return Stack(
            children: [
              Positioned.fill(child: Container(color: const Color(0xFFFFF2E5))),

              // 캐릭터 실루엣
              Positioned(
                left: u.sx(265),
                top: u.sy(34),
                width: u.sw(1375),
                height: u.sw(916),
                child: Image.asset(
                  'assets/img/contents/studyListen/level1/animals/rabbit_00.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 텍스트 1
              Positioned(
                left: u.sx(400),
                top: u.sy(805),
                child: Text(
                  '새로운 친구를 만났어요!',
                  style: TextStyle(
                    color: const Color(0xFF7C685F),
                    fontSize: u.sp(120),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // 텍스트 2
              Positioned(
                left: u.sx(574),
                top: u.sy(950),
                child: Text(
                  '안녕? 넌 누구야?',
                  style: TextStyle(
                    color: const Color(0xFF7C685F),
                    fontSize: u.sp(120),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // 물음표 1
              Positioned(
                left: u.sx(1428.37),
                top: u.sy(132.83),
                child: Transform.rotate(
                  angle: 0.26,
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: const Color(0xFF7C685F),
                      fontSize: u.sp(120),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // 물음표 2
              Positioned(
                left: u.sx(557),
                top: u.sy(600.09),
                child: Transform.rotate(
                  angle: -0.27,
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: const Color(0xFF7C685F),
                      fontSize: u.sp(120),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
