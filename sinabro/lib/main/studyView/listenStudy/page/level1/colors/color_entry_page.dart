// lib/main/studyView/listenStudy/page/level1/colors/color_entry_page.dart
// 듣기 학습 레벨 1 (색상) - 열매 1,2 api 연동 완료
// ⭐️ [추가] API 연동을 위한 3개 import
import 'dart:convert';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';
import 'package:sinabro/main/studyView/common/mixin/audio_handler_mixin.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_lesson_host_page.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

import 'package:sinabro/main/studyView/common/mixin/sticker_reward_handler.dart'; // ✅ StickerRewardHandler import 추가!
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart';

/// 색깔 학습 - 공통 인트로 페이지 ("짠! 오늘의 색깔 친구는~?")
class ColorEntryPage extends StatefulWidget {
  final List<ColorLessonData> lessonsToShow;
  final bool isGold;
  final String childId;
  final String fruitId;

  const ColorEntryPage({
    super.key,
    required this.lessonsToShow,
    required this.isGold,
    required this.childId,
    required this.fruitId,
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
  bool _isCompleted = false; // ⭐️ [추가] API 중복 호출 방지

  // ⭐️ [추가] API 호출 클라이언트 및 학습 시작 시간
  final AuthClient _authClient = AuthClient();
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    // ⭐️ [추가] 학습 시작 시간 기록
    _startTime = DateTime.now();

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

  // ⭐️ [신규 추가] 학습 완료 API 호출 함수
  Future<void> _completeStudy() async {
    // ⭐️ API 중복 호출 방지
    if (_isCompleted) {
      debugPrint("[ColorEntryPage] 이미 완료 API가 호출되었습니다. 중복 호출 방지.");
      return;
    }
    _isCompleted = true; // ⭐️ 호출 플래그 세우기

    // 1. 학습 시간 계산
    final int timeSpentSecs = DateTime.now().difference(_startTime).inSeconds;

    // 2. DTO (JSON Body) 구성
    final body = jsonEncode({
      'childId': widget.childId,
      'fruitId': widget.fruitId, // ⭐️ 전달받은 fruitId 사용
      'isCompleted': true,
      'timeSpentSecs': timeSpentSecs,
    });

    // 3. API 엔드포인트
    final uri = Uri.parse('$baseUrl/api/study/listening/complete');

    // 4. API 호출
    try {
      debugPrint('[ColorEntryPage] 듣기 학습 완료 API 호출: $body');
      final response = await _authClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('[ColorEntryPage] 듣기 학습 완료 처리 성공 (fruitId: ${widget.fruitId})');
      } else {
        debugPrint('[ColorEntryPage] 학습 완료 처리 실패: (${response.statusCode}) ${response.body}');
      }
    } catch (e) {
      debugPrint('[ColorEntryPage] 학습 완료 API 호출 중 예외 발생: $e');
    }
  }

  void _runLessonAtIndex(int index) async {
    if (!mounted || index >= widget.lessonsToShow.length) {
      debugPrint("[Entry] All lessons completed. Popping EntryPage now.");
      debugPrint("==================================================");
      // 모든 학습 완료 시 팝업 호출 (안전장치)

      // ⭐️ [수정] 1. API 호출
      _completeStudy(); 

      // ✅ 2. 팝업 호출 (await 유지. 팝업이 닫힐 때까지 정확히 대기)
      //    showApplePopup이 Future를 반환해야 이 await가 풀립니다.
      await showApplePopup(context, isGold: widget.isGold, childId: widget.childId);

      debugPrint('[ColorEntryPage] 🍎 showApplePopup 완료됨');

      if (!mounted) {
        debugPrint('[ColorEntryPage] ❌ context.mounted = false (화면이 이미 pop됨)');
        return;
      }

      // ✅ 3. 팝업 닫힌 후 보상 페이지로 이동 (Navigator.pushReplacement)
      debugPrint('[ColorEntryPage] ✅ context 유효 → 보상 페이지로 이동 시작');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StickerRewardHandler(
            childId: widget.childId,
            stageKey: 'ST001', // 듣기 학습 나무1
            newlyUnlockedIndex: 0, 
            fruitId: widget.fruitId, // ✅ fruitId 전달
            isAllCleared: false,
            onFinish: () {},
            finalDestination: ListenAppleSelect(childId: widget.childId),
          ),
        ),
      );

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
          childId: widget.childId,
        ),
      ),
    )
      .then((result) async {
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
        debugPrint('[Entry] last color finished → API call & showApplePopup.');
        // 1. API 호출
        _completeStudy(); 
        // 2. 팝업 호출
        await showApplePopup(context, isGold: widget.isGold, childId: widget.childId);


        // 3. 팝업 닫힌 후 보상 페이지로 이동
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StickerRewardHandler(
              childId: widget.childId,
              stageKey: 'ST001', 
              newlyUnlockedIndex: 0, 
              fruitId: widget.fruitId,
              isAllCleared: false,
              onFinish: () {},
              finalDestination: ListenAppleSelect(childId: widget.childId),
            ),
          ),
        );

      }else {
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
