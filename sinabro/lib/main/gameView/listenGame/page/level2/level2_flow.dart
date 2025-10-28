import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_game_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_theme_select.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_clear.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_fail.dart';
import 'package:sinabro/main/gameView/listenGame/data/level2_data.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';

class Level2Flow extends StatefulWidget {
  const Level2Flow({super.key});

  @override
  State<Level2Flow> createState() => _Level2FlowState();
}

class _Level2FlowState extends State<Level2Flow> {
  void _onThemeSelected(BuildContext context, int themeIndex) {
    final startIndex = themeIndex * 5;
    final selectedSet = level2GameData.sublist(startIndex, startIndex + 5);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListenGameTransition(
          nextPage: ListenGamePage(
            gameData: selectedSet,
            onFinished: (int correctCount) {
              if (correctCount >= 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Level2ClearPage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Level2FailPage()),
                );
              }
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
    );
  }
}
