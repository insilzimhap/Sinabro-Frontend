import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_game_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_theme_select.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_clear.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_fail.dart';
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
              if (correctCount >= 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Level3ClearPage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Level3FailPage()),
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
    return Level3ThemeSelectPage(
      onThemeSelected: (index) => _onThemeSelected(context, index),
    );
  }
}
