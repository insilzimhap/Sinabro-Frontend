/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2의 플로우 ]
 *  - 레벨 2의 게임 진행 흐름
 *  - 챕터 선택(레벨2) 
 *    -> 인트로(level1_intro_page.dart)
 *    -> 테마 선택(level2_theme_select.dart)
 *    -> 공통 - 게임 전환 화면(listen_game_transition.dart)
 *    -> 게임 진행 화면(level2_game_page.dart)
 *    -> 게임 결과 화면(level2_result_page.dart)
 *        -> 테마 선택으로 이동
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_game_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_theme_select.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_result.dart';
import 'package:sinabro/main/gameView/listenGame/data/level2_data.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';

import 'package:sinabro/main/gameView/writeGame/api/child_state.dart';

class Level2Flow extends StatefulWidget {
  final String childId;

  const Level2Flow({
    super.key,
    required this.childId,
    });
  

  @override
  State<Level2Flow> createState() => _Level2FlowState();
}

class _Level2FlowState extends State<Level2Flow> {

  void _onThemeSelected(BuildContext context, int themeIndex) {
    // 🔹 각 테마(열매)에 해당하는 문제 5개 세트 추출
    final startIndex = themeIndex * 5;
    final selectedSet = level2GameData.sublist(startIndex, startIndex + 5);

    // ✅ (추가) 각 테마별 fruitId 매핑
    final fruitIds = ['FR_LG_006', 'FR_LG_007', 'FR_LG_008'];
    final fruitId = fruitIds[themeIndex];


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
                  builder: (_) => Level2ResultPage(
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
    return Level2ThemeSelectPage(
      onThemeSelected: (index) => _onThemeSelected(context, index),
      childId: widget.childId, // ✅ 위에서 받은 childId 그대로 전달
    );
  }
}
