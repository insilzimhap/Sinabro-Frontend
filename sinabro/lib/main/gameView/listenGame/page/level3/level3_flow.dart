/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 3의 플로우 ]
 *  - 레벨 3의 게임 진행 흐름
 *  - 챕터 선택(레벨3) 
 *    -> 인트로(level1_intro_page.dart)
 *    -> 테마 선택(level3_theme_select.dart)
 *    -> 공통 - 게임 전환 화면(listen_game_transition.dart)
 *    -> 게임 진행 화면(level3_game_page.dart)
 *    -> 게임 결과 화면(level3_result_page.dart)
 *        -> 테마 선택으로 이동
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_game_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_theme_select.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_result.dart';
import 'package:sinabro/main/gameView/listenGame/data/level3_data.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';

class Level3Flow extends StatefulWidget {
  const Level3Flow({super.key});

  @override
  State<Level3Flow> createState() => _Level3FlowState();
}

class _Level3FlowState extends State<Level3Flow> {
  void _onThemeSelected(BuildContext context, int themeIndex) {
    final startIndex = themeIndex * 5;
    final selectedSet = level3GameData.sublist(startIndex, startIndex + 5);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListenGameTransition(
          nextPage: ListenGamePage(
            gameData: selectedSet,
            onFinished: (int correctCount) {
              final bool success = correctCount >= 3;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Level3ResultPage(
                    themeId: themeIndex + 1,
                    success: success,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Level3ThemeSelectPage(
      onThemeSelected: (index) => _onThemeSelected(context, index),
    );
  }
}
