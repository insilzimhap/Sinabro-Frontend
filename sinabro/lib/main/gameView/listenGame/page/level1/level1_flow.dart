import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_game_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_theme_select.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/tutorial_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_clear.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_fail.dart';
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
      if (correctCount >= 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Level1ClearPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Level1FailPage()),
        );
      }
    }

    if (themeIndex == 0 && !_tutorialDone) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TutorialPage(
            onTutorialComplete: () {
              setState(() => _tutorialDone = true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ListenGameTransition(
                    nextPage: ListenGamePage(
                      gameData: selectedSet,
                      onFinished: (correctCount) => goToResultPage(correctCount),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListenGameTransition(
            nextPage: ListenGamePage(
              gameData: selectedSet,
              onFinished: (correctCount) => goToResultPage(correctCount),
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
