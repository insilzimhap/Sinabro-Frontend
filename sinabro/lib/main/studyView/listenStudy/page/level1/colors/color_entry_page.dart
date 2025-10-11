import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_lesson_host_page.dart';

/// 색깔 학습 - 공통 인트로 페이지 ("짠! 오늘의 색깔 친구는~?")
class ColorEntryPage extends StatefulWidget {
  final List<ColorLessonData> lessonsToShow;
  const ColorEntryPage({super.key, required this.lessonsToShow});

  static const routeName = '/study/listen/color-entry';

  @override
  State<ColorEntryPage> createState() => _ColorEntryPageState();
}

class _ColorEntryPageState extends State<ColorEntryPage>
    with AudioHandlerMixin {
  bool _isReadyToTap = false;
  bool _isFlowRunning = false;
  // 다음 Reveal의 fromColor로 사용하기 위해 상태 변수로 변경
  Color? _prevColor;

  @override
  void initState() {
    super.initState();
    // [추가] 시작 시 전달 리스트 확인 로그
    debugPrint('[Entry] lessonsToShow length = ${widget.lessonsToShow.length}');

    // TTS가 끝나면 탭 가능
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

  /// 학습 흐름을 시작하는 함수
  void _startLessonFlow() {
    if (_isFlowRunning) return;
    if (widget.lessonsToShow.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // 👇 [디버그 추가] 전체 학습 흐름 시작을 알리는 로그
    debugPrint("==================================================");
    debugPrint("[Entry] User tapped. Starting the lesson flow...");

    setState(() {
      _isFlowRunning = true;
      _isReadyToTap = false; // 흐름이 시작되면 탭 비활성화
    });

    // 0번 인덱스부터 학습 시작
    _runLessonAtIndex(0);
  }

  /// 특정 인덱스의 학습을 실행하고, 완료되면 다음 학습을 재귀적으로 호출하는 함수
  void _runLessonAtIndex(int index) {
    // 모든 학습이 끝났는지 확인
    if (!mounted || index >= widget.lessonsToShow.length) {
      // 👇 [디버그 추가] 모든 학습이 끝나고 EntryPage가 종료됨을 알리는 로그
      debugPrint("[Entry] All lessons completed. Popping EntryPage now.");
      debugPrint("==================================================");
      if (mounted) Navigator.of(context).pop(); // 전체 루틴 종료
      return;
    }

    final lesson = widget.lessonsToShow[index];
    final isLast = (index == widget.lessonsToShow.length - 1);

    // 첫 색은 베이지에서, 그다음부터는 이전 색에서 Reveal
    final fromColor = (index == 0)
        ? const Color(0xFFFFF2E5)
        : (_prevColor ?? const Color(0xFFFFF2E5));

    debugPrint(
        '[Entry] >>> PUSHING HOST for ${lesson.name} (index $index/${widget.lessonsToShow.length - 1}), isLast=$isLast');

    // [수정] RevealPage 대신 ColorLessonHostPage를 호출합니다.
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

      // ✅ true면 다음 색 진행, false면 전체 루틴 종료(pop)
      if (result == true) {
        setState(() {
          _prevColor = lesson.primaryColor; // 다음 Reveal의 시작색
        });
        debugPrint(
            '[Entry] continue to next color. prevColor set to ${_prevColor.toString()}');

        // 👇 [디버그 추가] 다음 학습으로 넘어가는 것을 명확히 보여주는 로그
        debugPrint(
            "[Entry] --->>> Preparing to run next lesson at index: ${index + 1}");
        _runLessonAtIndex(index + 1); // 다음 학습 진행
      } else if (result == false) {
        if (!mounted) return;
        debugPrint('[Entry] last color finished → pop Entry.');
        Navigator.of(context).pop(); // 전체 루틴 종료
      } else {
        // [수정] result == null → 더 이상 진행하지 않고 "중단" (다음 색으로 넘어가지 않음)
        debugPrint('[Entry][오류] result==null 수신. 라우팅 실패/중복내비 가능성 → 흐름 중단');
        if (!mounted) return;
        setState(() {
          _isFlowRunning = false;
          _isReadyToTap = true; // 다시 시작할 수 있도록 탭 활성화
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
