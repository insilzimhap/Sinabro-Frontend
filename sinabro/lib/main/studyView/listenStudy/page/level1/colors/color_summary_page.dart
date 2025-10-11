import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

/// 변신했던 사물들을 요약해서 보여주는 페이지입니다.
class ColorSummaryPage extends StatefulWidget {
  const ColorSummaryPage({
    super.key,
    required this.lessonData,
    required this.isLastLesson,
    required this.onSummaryCompleted,
  });

  final ColorLessonData lessonData;
  final bool isLastLesson;
  final VoidCallback onSummaryCompleted;

  @override
  State<ColorSummaryPage> createState() => _ColorSummaryPageState();
}

class _ColorSummaryPageState extends State<ColorSummaryPage>
    with AudioHandlerMixin {
  late final List<_SummaryFlowStep> _flowSteps;
  int _currentStepIndex = 0;
  late List<bool> _itemVisibility;
  bool _isTitleEmphasized = false;
  int _sceneToken = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _flowSteps = [
      ...widget.lessonData.summarySteps.map((step) => _SummaryFlowStep(
          type: _StepType.item,
          audioAsset: step.audioAsset,
          minDurationMs: step.minDurationMs)),
      _SummaryFlowStep(
          type: _StepType.title,
          audioAsset: widget.lessonData.ttsPaths.summaryTitle,
          minDurationMs: 1000),
    ];

    _itemVisibility =
        List.generate(widget.lessonData.summarySteps.length, (_) => false);

    ttsStateStream.listen((state) {
      if (state == PlayerState.completed) {
        _advanceStepIfTokenMatches(_sceneToken);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrentStep());
  }

  void _playCurrentStep() {
    _sceneToken++;
    final currentFlowStep = _flowSteps[_currentStepIndex];

    if (currentFlowStep.type == _StepType.item) {
      setState(() {
        _itemVisibility[_currentStepIndex] = true;
      });
    } else {
      setState(() {
        _isTitleEmphasized = true;
      });
    }

    playAudio(currentFlowStep.audioAsset, playerType: 'tts');
  }

  void _advanceStepIfTokenMatches(int token) {
    if (!mounted || token != _sceneToken) return;

    if (_currentStepIndex < _flowSteps.length - 1) {
      setState(() => _currentStepIndex++);
      _playCurrentStep();
    } else {
      if (_completed) return;
      _completed = true;
      widget.onSummaryCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonData = widget.lessonData;
    final primaryColor = lessonData.primaryColor;

    // ✨ [수정] 색상이 밝은지 확인하는 변수 추가
    final bool isLightColor = primaryColor.computeLuminance() > 0.9;
    final Color textColor =
        isLightColor ? const Color(0xFF626262) : Colors.white;

    return FigmaBoard(
      baseWidth: 2000,
      baseHeight: 1200,
      alignToSafeTop: true,
      builder: (context, scale, dx, dy) {
        final u = FigmaUnits(scale, dx, dy);

        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.white)),

            // --- 상단 바 ---
            Positioned(
              left: 0,
              top: u.sy(-45),
              width: u.sw(2000),
              height: u.sw(350),
              // ✨ [수정] 밝은 색일 경우 테두리(stroke)를 추가합니다.
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  border: isLightColor
                      ? Border(
                          bottom: BorderSide(
                            width: 4,
                            color: const Color(0xFFD5D5D5),
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // --- 상단 타이틀 ---
            Positioned(
              left: u.sx(624),
              top: u.sy(62),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                scale: _isTitleEmphasized ? 1.06 : 1.0,
                child: Text(
                  '우리는 ${lessonData.name}',
                  style: TextStyle(
                    // ✨ [수정] 밝은 색일 경우 글자색을 회색으로 변경합니다.
                    color: textColor,
                    fontSize: u.sp(150),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // --- 요약 아이템 목록 ---
            ...lessonData.summarySteps.asMap().entries.map((entry) {
              final index = entry.key;
              final stepData = entry.value;

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _itemVisibility[index] ? 1.0 : 0.0,
                child: Stack(
                  children: [
                    Positioned(
                      left: u.sx(stepData.figmaRect.left),
                      top: u.sy(stepData.figmaRect.top),
                      width: u.sw(stepData.figmaRect.width),
                      height: u.sw(stepData.figmaRect.height),
                      child:
                          Image.asset(stepData.imagePath, fit: BoxFit.contain),
                    ),
                    Positioned(
                      left: u.sx(stepData.labelPosition.dx),
                      top: u.sy(stepData.labelPosition.dy),
                      child: Text(
                        stepData.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // ✨ [수정] 밝은 색일 경우 라벨 색상을 회색으로, 아닐 경우 primaryColor로 설정
                          color: isLightColor
                              ? const Color(0xFF626262)
                              : primaryColor,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: u.sp(120),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// 이 페이지 내부에서만 사용할 간단한 순서 제어용 클래스
enum _StepType { item, title }

class _SummaryFlowStep {
  final _StepType type;
  final String audioAsset;
  final int minDurationMs;
  _SummaryFlowStep(
      {required this.type,
      required this.audioAsset,
      required this.minDurationMs});
}
