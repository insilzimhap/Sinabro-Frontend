/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1의 플로우 ]
 *  - 레벨 1의 게임 진행 흐름
 *  - 챕터 선택(레벨1) 
 *    -> 인트로(level1_intro_page.dart)
 *    -> 튜토리얼(level1_tutorial.dart)
 *    -> 테마 선택(level1_theme_select.dart)
 *    -> (테마1-1일 경우) 튜토리얼(level1_tutorial.dart)
 *    -> 공통 - 게임 전환 화면(listen_game_transition.dart)
 *    -> 게임 진행 화면(level1_game_page.dart)
 *    -> 게임 결과 화면(level1_result.dart)
 *        -> 테마 선택으로 이동
 * ----------------------------------------------------------------
 * - 테마 선택 → (1-1일 경우) 튜토리얼 → 게임 전환 → 문제 진행 → 결과 화면 순서로 진행
 * - 튜토리얼은 최초 1회만 실행되며, 종료 후 바로 1-1 게임으로 이동함
 * ----------------------------------------------------------------
 *  ✅ 전체 진행 순서
 * 
 *  1️⃣ Level1ThemeSelectPage (테마 선택)
 *      - 아이가 5개 테마 중 하나 클릭
 *      - 서버에 /start 호출 → resultId 생성
 *      - FruitState에 resultId, fruitId 저장
 *      - onThemeSelected(index) 콜백 실행
 *
 *  2️⃣ Level1Flow._onThemeSelected()
 *      - 위 콜백이 여기로 전달됨
 * 
 *      - 선택된 테마 index 기반으로 문제 세트 5개 추출
 *      - 선택된 테마가 1-1(themeIndex == 0)이고 튜토리얼 미실행 상태면
 *          → Level1TutorialPage 실행
 *          → 튜토리얼 완료 시 onTutorialEnd() 콜백 호출
 *          → ListenGameTransition(전환화면) → ListenGamePage(게임진행) 이동 (Navigator.push)
 *      - 그 외 테마는 곧바로 전환 화면 → 게임 진행 화면으로 이동
 *
 *  3️⃣ ListenGamePage (문제 진행 화면)
 *      - 문제 5개 순서대로 출력
 *      - 각 문제 선택 시 /choice 호출 (recordListeningChoice)
 *      - 마지막 문제 후 onFinished(correctCount) 콜백 실행
 *
 *  4️⃣ Level1ResultPage (결과 화면)
 *      - /complete 호출 (completeListeningGame)
 *      - 결과 표시 → 다시 테마 선택으로 이동
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_game_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_theme_select.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_tutorial.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_result.dart';
import 'package:sinabro/main/gameView/listenGame/data/level1_data.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';

class Level1Flow extends StatefulWidget {
  // ✅ 여기 추가
  final String childId;

  const Level1Flow({
    super.key,
    required this.childId, // ✅ 생성자 수정
  });

  @override
  State<Level1Flow> createState() => _Level1FlowState();
}

class _Level1FlowState extends State<Level1Flow> {
  bool _tutorialDone = false; // 튜토리얼 1회만 실행되도록 제어

  // 🎯 테마(열매)가 선택되었을 때 호출됨
  void _onThemeSelected(BuildContext context, int themeIndex) {
    //테마 번호(index)에 맞춰 문제 5개 세트 가져오기
    final startIndex = themeIndex * 5;
    final selectedSet = level1GameData.sublist(startIndex, startIndex + 5);

    // 게임 완료 후 결과 페이지로 이동
    void goToResultPage(int correctCount) {
      final success = correctCount >= 3; // 정답 3개 이상이면 "성공" 처리
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Level1ResultPage(
            themeId: themeIndex + 1,
            success: success, // ✅ 결과 페이지에 성공여부 전달
          ),
        ),
      );
    }

    // ✅ 테마1-1 (themeIndex == 0)일 때 튜토리얼 먼저 실행
    // 튜토리얼이 아직 안 끝났고, 첫 번째 테마(0번=열매1-1)일 때만 실행
    if (themeIndex == 0 && !_tutorialDone) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Level1TutorialPage(
            // 튜토리얼이 끝나면 setState로 완료 표시 후 게임으로 이동
            onTutorialEnd: () {
              setState(() => _tutorialDone = true);
              // 튜토리얼 → 전환 화면 → 1-1 게임
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListenGameTransition(
                    // 게임 전환 애니메이션 → 실제 게임 화면으로 이동
                    nextPage: ListenGamePage(
                      // 문제 세트 전달
                      gameData: selectedSet,
                      // 게임 종료 시 결과 페이지로 이동
                      onFinished: goToResultPage, // 요기 좀 달라 (결과 전달)
                      // 원래 코드는 onFinished: (correctCount) => goToResultPage(correctCount), 이거였음
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // 일반 테마는 바로 전환 화면 → 게임
      // 튜토리얼 외의 테마는 바로 게임 시작
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListenGameTransition(
            // 전환 애니메이션 후 게임 시작
            nextPage: ListenGamePage(
              // 선택된 테마 문제 5개
              gameData: selectedSet,
              onFinished: goToResultPage,
              //여기도 달러 onFinished: (correctCount) => goToResultPage(correctCount),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Level1ThemeSelectPage(
      // ✅ 테마 선택 콜백 연결
      // 이 콜백이 실행되면 → _onThemeSelected 호출됨
      onThemeSelected: (index) => _onThemeSelected(context, index),
      childId: widget.childId, // ✅ 위에서 받은 childId 그대로 전달
    );
  }
}
