import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

/// [수정] 학습 마무리만 담당하는 위젯. Navigator를 직접 호출하지 않습니다.
class ColorOutroPage extends StatefulWidget {
  const ColorOutroPage({
    super.key,
    required this.lessonData,
    required this.isLastLesson,
    required this.onOutroCompleted, // ✨ [추가] 과정 완료 후 호출될 콜백 함수
  });

  final ColorLessonData lessonData;
  final bool isLastLesson;
  final VoidCallback onOutroCompleted; // ✨ [추가]

  @override
  State<ColorOutroPage> createState() => _ColorOutroPageState();
}

class _ColorOutroPageState extends State<ColorOutroPage>
    with SingleTickerProviderStateMixin, AudioHandlerMixin {
  late final AnimationController _coverController;
  late final Animation<double> _coverAnimation;
  bool _completed = false; // 콜백 중복 호출 방지 가드

  @override
  void initState() {
    super.initState();
    debugPrint(
        '[Outro] init for ${widget.lessonData.name}, isLast=${widget.isLastLesson}');

    _coverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _coverAnimation =
        CurvedAnimation(parent: _coverController, curve: Curves.easeInOut);

    ttsStateStream.listen((state) {
      if (state == PlayerState.completed && mounted) {
        _startOutroSequence();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playAudio(widget.lessonData.ttsPaths.outro, playerType: 'tts');
    });
  }

  Future<void> _startOutroSequence() async {
    if (!mounted || _completed) return;
    _completed = true;

    final coverFuture = _coverController.forward(from: 0);
    playAudio(widget.lessonData.sfxPaths.outro, playerType: 'sfx');
    final sfxDone =
        sfxStateStream.firstWhere((s) => s == PlayerState.completed);

    await coverFuture;
    debugPrint('[Outro] cover anim done');
    await sfxDone;
    debugPrint('[Outro] cover sfx done');

    if (!mounted) return;

    // ❗️[수정] 모든 과정이 끝나면 Navigator.pop 대신 콜백을 호출합니다.
    widget.onOutroCompleted();
  }

  @override
  void dispose() {
    _coverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonData = widget.lessonData;
    final primaryColor = lessonData.primaryColor;

    // [수정] StudyBackLayout과 PopScope를 제거하고 순수 위젯만 반환합니다.
    return FigmaBoard(
      baseWidth: 2000,
      baseHeight: 1200,
      alignToSafeTop: true,
      builder: (context, scale, dx, dy) {
        final u = FigmaUnits(scale, dx, dy);

        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            Positioned(
              left: u.sx(488),
              top: u.sy(34),
              width: u.sw(1024),
              height: u.sw(1024),
              child: Image.asset(
                lessonData.characterImagePath,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: u.sx(330),
              top: u.sy(939),
              child: Container(
                width: u.sw(1340),
                height: u.sw(173),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: u.sw(4), color: const Color(0xFFD5D5D5)),
                    borderRadius: BorderRadius.circular(u.sw(50)),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: u.sw(71), top: u.sw(61), right: u.sw(40)),
                  child: Text(
                    '앞으로 나를 기억해줘! ${lessonData.name}${lessonData.name}~',
                    style: TextStyle(
                      color: const Color(0xFF3C3C3C),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: u.sp(60),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: u.sx(367),
              top: u.sy(875),
              child: Container(
                width: u.sw(269),
                height: u.sw(100),
                decoration: ShapeDecoration(
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(u.sw(40)),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  lessonData.name,
                  style: TextStyle(
                    color: primaryColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: u.sp(60),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _coverAnimation,
              builder: (context, _) {
                final v = _coverAnimation.value;
                final w = u.sw(2000);
                final h = u.sw(1200);
                final dx = (w / 2) * v;
                final dy = (h / 2) * v;

                return Stack(
                  children: [
                    Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: dx,
                        child: ColoredBox(color: primaryColor)),
                    Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: dx,
                        child: ColoredBox(color: primaryColor)),
                    Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: dy,
                        child: ColoredBox(color: primaryColor)),
                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: dy,
                        child: ColoredBox(color: primaryColor)),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
