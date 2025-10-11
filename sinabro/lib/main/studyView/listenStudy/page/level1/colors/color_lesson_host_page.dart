import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_intro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_transform_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_summary_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_outro_page.dart';

/// 한 색상 학습의 모든 단계를 관리하고 전환하는 호스트(Host) 위젯입니다.
class ColorLessonHostPage extends StatefulWidget {
  const ColorLessonHostPage({
    super.key,
    required this.fromColor,
    required this.lessonData,
    required this.isLastLesson,
  });

  final Color fromColor;
  final ColorLessonData lessonData;
  final bool isLastLesson;

  @override
  State<ColorLessonHostPage> createState() => _ColorLessonHostPageState();
}

// 학습의 각 단계를 나타내는 열거형(enum)입니다.
enum _LessonPhase {
  reveal,
  intro,
  transform,
  summary,
  outro,
}

class _ColorLessonHostPageState extends State<ColorLessonHostPage> {
  // 현재 어떤 단계를 보여줄지 상태로 관리합니다. 시작은 reveal 단계입니다.
  _LessonPhase _currentPhase = _LessonPhase.reveal;

  // 각 단계의 페이지들이 완료되었을 때 호출할 콜백 함수들입니다.
  // 콜백이 호출되면 setState를 통해 다음 단계로 상태를 변경합니다.
  void _onRevealCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _LessonPhase.intro);
  }

  void _onIntroCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _LessonPhase.transform);
  }

  void _onTransformCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _LessonPhase.summary);
  }

  void _onSummaryCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _LessonPhase.outro);
  }

  void _onOutroCompleted() {
    if (!mounted) return;
    // 모든 과정이 끝나면, EntryPage로 결과를 반환하며 이 페이지를 닫습니다.
    final result = widget.isLastLesson ? false : true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    // PopScope와 StudyBackLayout으로 전체 학습 흐름을 한번만 감싸줍니다.
    return PopScope(
      canPop: false,
      // 👇 [수정] 사용하시는 버전에 맞게 파라미터를 하나만 받도록 변경했습니다.
      onPopInvoked: (bool didPop) {
        // canPop이 false이므로 didPop은 항상 false입니다.
        // 시스템 뒤로가기 제스처를 막는 역할만 합니다.
      },
      child: StudyBackLayout(
        // 뒤로가기 버튼을 누르면 null을 반환하여 EntryPage에서 흐름을 중단시킵니다.
        onBack: () => Navigator.of(context).pop(null),
        body: _buildCurrentPhaseWidget(),
      ),
    );
  }

  /// 현재 학습 단계(_currentPhase)에 맞는 위젯을 반환하는 함수입니다.
  Widget _buildCurrentPhaseWidget() {
    switch (_currentPhase) {
      case _LessonPhase.reveal:
        return ColorRevealPage(
          fromColor: widget.fromColor,
          lessonData: widget.lessonData,
          onRevealCompleted: _onRevealCompleted,
        );
      case _LessonPhase.intro:
        return ColorIntroPage(
          lessonData: widget.lessonData,
          isLastLesson: widget.isLastLesson, // IntroPage가 이 파라미터를 필요로 할 수 있음
          onIntroCompleted: _onIntroCompleted,
        );
      case _LessonPhase.transform:
        return ColorTransformPage(
          lessonData: widget.lessonData,
          isLastLesson: widget.isLastLesson,
          onTransformCompleted: _onTransformCompleted,
        );
      case _LessonPhase.summary:
        return ColorSummaryPage(
          lessonData: widget.lessonData,
          isLastLesson: widget.isLastLesson,
          onSummaryCompleted: _onSummaryCompleted,
        );
      case _LessonPhase.outro:
        return ColorOutroPage(
          lessonData: widget.lessonData,
          isLastLesson: widget.isLastLesson,
          onOutroCompleted: _onOutroCompleted,
        );
    }
  }
}
