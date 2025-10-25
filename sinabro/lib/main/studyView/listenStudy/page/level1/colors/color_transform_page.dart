import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

/// [수정] 캐릭터 변신 과정만 담당하는 위젯. Navigator를 직접 호출하지 않습니다.
class ColorTransformPage extends StatefulWidget {
  const ColorTransformPage({
    super.key,
    required this.lessonData,
    required this.isLastLesson,
    required this.onTransformCompleted, // ✨ [추가] 과정 완료 후 호출될 콜백 함수
    required this.childId,
  });

  final ColorLessonData lessonData;
  final bool isLastLesson;
  final VoidCallback onTransformCompleted; // ✨ [추가]
  final String childId;

  @override
  State<ColorTransformPage> createState() => _ColorTransformPageState();
}

class _ColorTransformPageState extends State<ColorTransformPage>
    with AudioHandlerMixin {
  late final List<TransformStep> _allSteps;
  int _currentStepIndex = 0;
  int _sceneToken = 0;
  bool _completed = false; // 콜백 중복 호출 방지 가드

  TransformStep get _currentStep => _allSteps[_currentStepIndex];

  @override
  void initState() {
    super.initState();

    _allSteps = [
      TransformStep(
        imagePath: widget.lessonData.characterImagePath,
        line: '자, 이제! 내가 변신해볼게!',
        audioAsset: widget.lessonData.ttsPaths.transformIntro,
        minDurationMs: 2400,
        figmaRect: const Rect.fromLTWH(488, 34, 1024, 1024),
      ),
      TransformStep(
        imagePath: widget.lessonData.magicWandImagePath,
        line: '자, 이제! 내가 변신해볼게!',
        audioAsset: widget.lessonData.sfxPaths.transform,
        minDurationMs: 2400,
        figmaRect: const Rect.fromLTWH(665, 114, 670, 670),
      ),
      ...widget.lessonData.transformSteps,
    ];

    ttsStateStream.listen((state) {
      if (state == PlayerState.completed) {
        _advanceStepIfTokenMatches(_sceneToken);
      }
    });
    sfxStateStream.listen((state) {
      if (state == PlayerState.completed) {
        _advanceStepIfTokenMatches(_sceneToken);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrentStep());
  }

  void _playCurrentStep() {
    _sceneToken++;
    final playerType = _currentStepIndex == 1 ? 'sfx' : 'tts';
    playAudio(_currentStep.audioAsset, playerType: playerType);
  }

  void _advanceStepIfTokenMatches(int token) {
    if (!mounted || token != _sceneToken) return;

    if (_currentStepIndex < _allSteps.length - 1) {
      setState(() => _currentStepIndex++);
      _playCurrentStep();
    } else {
      // ❗️[수정] 모든 단계가 끝났으면 Navigator 대신 콜백을 호출합니다.
      if (_completed) return;
      _completed = true;
      widget.onTransformCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonData = widget.lessonData;
    final primaryColor = lessonData.primaryColor;

    // [수정] StudyBackLayout과 PopScope(WillPopScope)를 제거하고 순수 위젯만 반환합니다.
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
              left: u.sx(_currentStep.figmaRect.left),
              top: u.sy(_currentStep.figmaRect.top),
              width: u.sw(_currentStep.figmaRect.width),
              height: u.sw(_currentStep.figmaRect.height),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                child: Image.asset(
                  _currentStep.imagePath,
                  key: ValueKey(_currentStep.imagePath),
                  fit: BoxFit.contain,
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
                  padding: EdgeInsets.symmetric(horizontal: u.sw(71)),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale:
                            Tween<double>(begin: 0.98, end: 1.0).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Align(
                      key: ValueKey(_currentStep.line),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _currentStep.line,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
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
          ],
        );
      },
    );
  }
}
