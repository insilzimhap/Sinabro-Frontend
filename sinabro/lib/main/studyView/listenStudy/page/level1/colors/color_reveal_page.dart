import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/widget/clockwise_reveal.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

/// [수정] 색상 애니메이션만 담당하는 위젯. Navigator를 직접 호출하지 않습니다.
class ColorRevealPage extends StatefulWidget {
  const ColorRevealPage({
    super.key,
    required this.fromColor,
    required this.lessonData,
    required this.onRevealCompleted, // ✨ [추가] 애니메이션 완료 후 호출될 콜백 함수
    required this.childId,
  });

  final Color fromColor;
  final ColorLessonData lessonData;
  final VoidCallback onRevealCompleted; // ✨ [추가]
  final String childId;

  @override
  State<ColorRevealPage> createState() => _ColorRevealPageState();
}

class _ColorRevealPageState extends State<ColorRevealPage>
    with AudioHandlerMixin {
  bool _completed = false; // 콜백 중복 호출을 방지하기 위한 가드

  @override
  void initState() {
    super.initState();
    // 페이지가 화면에 그려진 직후, Reveal 효과음을 재생합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playAudio(widget.lessonData.sfxPaths.reveal, playerType: 'sfx');
    });
  }

  @override
  Widget build(BuildContext context) {
    // [수정] StudyBackLayout이나 PopScope 없이 ClockwiseReveal 위젯만 반환합니다.
    return ClockwiseReveal(
      bgColor: widget.fromColor,
      revealColor: widget.lessonData.primaryColor,
      duration: const Duration(milliseconds: 2800),
      onCompleted: () {
        // [수정] 애니메이션이 끝나면 Navigator를 호출하는 대신, 부모에게 완료 신호를 보냅니다.
        if (_completed || !mounted) return;
        _completed = true;

        widget.onRevealCompleted();
      },
    );
  }
}
