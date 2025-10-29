import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

/// [수정] 색깔 캐릭터 소개만 담당하는 위젯. Navigator를 직접 호출하지 않습니다.
class ColorIntroPage extends StatefulWidget {
  const ColorIntroPage({
    super.key,
    required this.lessonData,
    required this.isLastLesson,
    required this.onIntroCompleted, // ✨ [추가] 과정 완료 후 호출될 콜백 함수
    required this.childId,
  });

  final ColorLessonData lessonData;
  final bool isLastLesson;
  final VoidCallback onIntroCompleted; // ✨ [추가]
  final String childId;

  @override
  State<ColorIntroPage> createState() => _ColorIntroPageState();
}

class _ColorIntroPageState extends State<ColorIntroPage>
    with SingleTickerProviderStateMixin, AudioHandlerMixin {
  late final AnimationController _controller;
  late final Animation<double> _revealAnimation;
  late final Animation<double> _characterFade;
  late final Animation<double> _characterScale;
  late final Animation<double> _textFade;

  bool _completed = false; // 콜백 중복 호출 방지 가드

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // --- 애니메이션 정의 ---
    _revealAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _characterFade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.8, curve: Curves.easeIn));
    _characterScale = Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 0.8, curve: Curves.easeOutBack)));
    _textFade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn));

    // [수정] TTS 오디오 재생이 완료되면 Navigator 대신 콜백을 호출합니다.
    ttsStateStream.listen((state) {
      if (state == PlayerState.completed && mounted) {
        if (_completed) return;
        _completed = true;

        // ❗️[수정] Navigator.pushReplacementNamed(...) 코드를 모두 제거하고,
        // 아래 콜백 호출 코드로 대체합니다.
        widget.onIntroCompleted();
      }
    });

    // --- 오디오 재생 및 애니메이션 시작 ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      playAudioSequentially(
        sfxPath: widget.lessonData.sfxPaths.intro,
        ttsPath: widget.lessonData.ttsPaths.intro,
        delay: const Duration(seconds: 1),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 가독성을 위해 변수로 추출
    final lessonData = widget.lessonData;
    final primaryColor = lessonData.primaryColor;

    // [수정] StudyBackLayout과 PopScope(WillPopScope)를 제거하고 순수 위젯만 반환합니다.
    return FigmaBoard(
      baseWidth: 2000,
      baseHeight: 1200,
      alignToSafeTop: true,
      builder: (context, scale, dx, dy) {
        final u = FigmaUnits(scale, dx, dy);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: primaryColor)),
                const Positioned.fill(child: ColoredBox(color: Colors.white)),
                Positioned(
                  left: u.sx(488),
                  top: u.sy(22),
                  width: u.sw(1024),
                  height: u.sw(1024),
                  child: FadeTransition(
                    opacity: _characterFade,
                    child: ScaleTransition(
                      scale: _characterScale,
                      child: Image.asset(
                        lessonData.characterImagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
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
                      child: FadeTransition(
                        opacity: _textFade,
                        child: Text(
                          lessonData.ttsPaths.introLine,
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
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: _RevealOverlayPainter(
                    progress: _revealAnimation.value,
                    color: primaryColor,
                  ),
                  child: const SizedBox.expand(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// 오버레이 페인터 (위젯 내부에 포함시켜 관리 용이)
class _RevealOverlayPainter extends CustomPainter {
  _RevealOverlayPainter({
    required this.progress,
    required this.color,
    this.centerBias = const Offset(0.5, 0.5),
  });

  final double progress;
  final Color color;
  final Offset centerBias;

  @override
  void paint(Canvas canvas, Size size) {
    final maxR = math.sqrt(size.width * size.width + size.height * size.height);
    final radius = (maxR * progress).clamp(0.0, maxR);
    final center =
        Offset(size.width * centerBias.dx, size.height * centerBias.dy);

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RevealOverlayPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.centerBias != centerBias;
}
