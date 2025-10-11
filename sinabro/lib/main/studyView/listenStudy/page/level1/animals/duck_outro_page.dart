// lib/main/studyView/listenStudy/animals/duck_outro_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
// 다음 동물로 교체
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/bird_reveal_page.dart';

class DuckOutroPage extends StatefulWidget {
  const DuckOutroPage({
    super.key,
    this.onFinished,
  });

  static const routeName = '/listen/animals/duck-outro';

  /// 마지막 문구까지 재생 완료 후 호출(다음 동물 실루엣으로 이동 등에 사용)
  final VoidCallback? onFinished;

  @override
  State<DuckOutroPage> createState() => _DuckOutroPageState();
}

class _DuckOutroPageState extends State<DuckOutroPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;

  // 🔧 경로와 문구(피그마 좌표는 FigmaBoard로 스케일 처리)
  static const _bgAsset =
      'assets/img/contents/studyListen/level1/animals/duck_06.png';
  static const _stepAudios = <String>[
    'assets/audio/tts/studyListen/level1/animals/duck06.mp3',
    'assets/audio/tts/studyListen/level1/animals/animals_common3.mp3',
  ];
  static const _stepTexts = <String>[
    '오리가 어푸어푸 헤엄쳐 갔어요',
    '다음 친구를 만나러 가볼까요?',
  ];

  int _step = 0;

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
    // 이전 구독 해제
    await _sub?.cancel();

    try {
      await _player.setAsset(_stepAudios[_step]);
      await _player.play();
    } catch (e) {
      debugPrint('DuckOutro audio error: $e');
    }

    // 오디오 완료 감지 → 0.8초 후 다음 행동
    _sub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;

        if (_step < _stepTexts.length - 1) {
          setState(() => _step++);
          _playCurrent();
        } else {
          widget.onFinished?.call();
          if (widget.onFinished == null && mounted) {
            Navigator.pushReplacementNamed(context, BirdRevealPage.routeName);
          }
        }
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
              // 배경 전체(피그마: 2000x1200, cover)
              Positioned.fill(
                child: Image.asset(_bgAsset, fit: BoxFit.cover),
              ),

              // 하단 말풍선(피그마 좌표 그대로 스케일링)
              Positioned(
                left: u.sx(172),
                top: u.sy(998),
                width: u.sw(1655),
                height: u.sw(133),
                child: Container(
                  clipBehavior: Clip.antiAlias,
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
                      padding: EdgeInsets.only(bottom: u.sw(6)), // 미세 보정
                      child: Text(
                        _stepTexts[_step],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF626262),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: u.sp(80),
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
      ),
    );
  }
}
