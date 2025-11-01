/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1의 플로우 (최종 수정)]
 *  - 챕터 선택(레벨1)
 *    -> 인트로(level1_intro_page.dart)
 *    -> 테마 선택(level1_theme_select.dart)
 *    -> (테마1-1일 경우) 튜토리얼(level1_tutorial.dart)
 *    -> 공통 - 게임 전환 화면(listen_game_transition.dart)
 *    -> 게임 진행 화면(level1_game_page.dart)
 *    -> 게임 결과 화면(level1_result.dart)
 *        -> 테마 선택으로 이동
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
  const Level1Flow({super.key});

  @override
  State<Level1Flow> createState() => _Level1FlowState();
}

class _Level1FlowState extends State<Level1Flow> {
  bool _tutorialDone = false;

  void _onThemeSelected(BuildContext context, int themeIndex) {
    final startIndex = themeIndex * 5;
    final selectedSet = level1GameData.sublist(startIndex, startIndex + 5);

    void goToResultPage(int correctCount) {
      final success = correctCount >= 3;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Level1ResultPage(
            themeId: themeIndex + 1,
            success: success,
          ),
        ),
      );
    }

    // ✅ 테마1-1 (themeIndex == 0)일 때 튜토리얼 먼저 실행
    if (themeIndex == 0 && !_tutorialDone) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Level1TutorialPage(
            onTutorialEnd: () {
              setState(() => _tutorialDone = true);
              // 튜토리얼 → 전환 화면 → 1-1 게임
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListenGameTransition(
                    nextPage: ListenGamePage(
                      gameData: selectedSet,
                      onFinished: goToResultPage,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListenGameTransition(
            nextPage: ListenGamePage(
              gameData: selectedSet,
              onFinished: goToResultPage,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Level1ThemeSelectPage(
      onThemeSelected: (index) => _onThemeSelected(context, index),
    );
  }
}
