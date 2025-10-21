// lib/main/studyView/listenStudy/page/level1/colors/color_entry_page.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_lesson_host_page.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

/// 색깔 학습 - 공통 인트로 페이지 ("짠! 오늘의 색깔 친구는~?")
class ColorEntryPage extends StatefulWidget {
  final List<ColorLessonData> lessonsToShow;
  final bool isGold;

  const ColorEntryPage({
    super.key,
    required this.lessonsToShow,
    required this.isGold,
  });

  static const routeName = '/study/listen/color-entry';

  @override
  State<ColorEntryPage> createState() => _ColorEntryPageState();
}

class _ColorEntryPageState extends State<ColorEntryPage>
    with AudioHandlerMixin {
  bool _isReadyToTap = false;
  bool _isFlowRunning = false;
  Color? _prevColor;

  @override
  void initState() {
    super.initState();
    debugPrint('[Entry] lessonsToShow length = ${widget.lessonsToShow.length}');
    ttsStateStream.listen((state) {
      if (state == PlayerState.completed && mounted) {
        setState(() => _isReadyToTap = true);
      }
    });
    _playInitialAudio();
  }

  void _playInitialAudio() {
    playAudioSequentially(
      sfxPath: 'audio/effect/color_effect1.mp3',
      ttsPath: 'audio/tts/studyListen/level1/colors/color_common1.mp3',
    );
  }

  void _startLessonFlow() {
    if (_isFlowRunning) return;
    if (widget.lessonsToShow.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    debugPrint("==================================================");
    debugPrint("[Entry] User tapped. Starting the lesson flow...");
    setState(() {
      _isFlowRunning = true;
      _isReadyToTap = false;
    });
    _runLessonAtIndex(0);
  }

  void _runLessonAtIndex(int index) {
    if (!mounted || index >= widget.lessonsToShow.length) {
      debugPrint("[Entry] All lessons completed. Popping EntryPage now.");
      debugPrint("==================================================");
      // 모든 학습 완료 시 팝업 호출 (안전장치)
      showApplePopup(context, isGold: widget.isGold);
      return;
    }

    final lesson = widget.lessonsToShow[index];
    final isLast = (index == widget.lessonsToShow.length - 1);
    final fromColor = (index == 0)
        ? const Color(0xFFFFF2E5)
        : (_prevColor ?? const Color(0xFFFFF2E5));

    debugPrint(
        '[Entry] >>> PUSHING HOST for ${lesson.name} (index $index/${widget.lessonsToShow.length - 1}), isLast=$isLast');

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ColorLessonHostPage(
          fromColor: fromColor,
          lessonData: lesson,
          isLastLesson: isLast,
        ),
      ),
    )
        .then((result) {
      if (!mounted) return;
      debugPrint(
          '[Entry] <<< POP FROM HOST for ${lesson.name} with result=$result (type=${result.runtimeType})');

      if (result == true) {
        // 다음 색 진행
        setState(() => _prevColor = lesson.primaryColor);
        debugPrint(
            '[Entry] continue to next color. prevColor set to ${_prevColor.toString()}');
        debugPrint(
            "[Entry] --->>> Preparing to run next lesson at index: ${index + 1}");
        _runLessonAtIndex(index + 1);
      } else if (result == false) {
        // 마지막 색 완료
        debugPrint('[Entry] last color finished → showApplePopup.');
        // 마지막 학습 완료 시 Navigator.pop() 대신 팝업 호출
        showApplePopup(context, isGold: widget.isGold);
      } else {
        // 중간에 뒤로가기로 종료
        debugPrint('[Entry][오류] result==null 수신. 라우팅 실패/중복내비 가능성 → 흐름 중단');
        setState(() {
          _isFlowRunning = false;
          _isReadyToTap = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StudyBackLayout(
      prevRouteName: '/listen_study_page',
      body: GestureDetector(
        onTap: (!_isReadyToTap || _isFlowRunning) ? null : _startLessonFlow,
        child: Container(
          color: const Color(0xFFFFF2E5),
          child: FigmaBoard(
            baseWidth: 2000,
            baseHeight: 1200,
            child: Stack(
              children: [
                Positioned(
                  left: 557,
                  top: 40,
                  width: 938,
                  height: 763,
                  child: Image.asset(
                    'assets/img/contents/studyListen/level1/colors/box.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Positioned(
                  left: 367,
                  top: 909,
                  child: Text(
                    '짠! 오늘의 색깔 친구는~?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF7C685F),
                      fontSize: 120,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
