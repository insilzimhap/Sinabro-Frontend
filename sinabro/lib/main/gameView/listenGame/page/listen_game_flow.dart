// lib/main/gameView/common/listenGame/listen_game_flow.dart
import 'package:flutter/material.dart';

// 레벨1
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_tutorial.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_theme_select.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';

// 레벨2
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_story.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_theme_select.dart';

// 레벨3
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_story.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_theme_select.dart';

/// 레벨1 Flow
/// - 튜토리얼 → Transition → 테마 선택
class Level1Flow extends StatelessWidget {
  const Level1Flow({super.key});

  @override
  Widget build(BuildContext context) {
    return Level1TutorialPage(
      onTutorialEnd: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ListenGameTransition(
                  nextPage: const Level1ThemeSelectPage(),
                ),
          ),
        );
      },
    );
  }
}

/// 레벨2 Flow
/// - 스토리 → Transition → 테마 선택
class Level2Flow extends StatelessWidget {
  const Level2Flow({super.key});

  @override
  Widget build(BuildContext context) {
    return Level2StoryPageWrapper();
  }
}

class Level2StoryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Level2StoryPage(
      // 스토리 끝나면 Transition → ThemeSelect
      onStoryEnd: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ListenGameTransition(
                  nextPage: const Level2ThemeSelectPage(),
                ),
          ),
        );
      },
    );
  }
}

/// 레벨3 Flow
/// - 스토리 → Transition → 테마 선택
class Level3Flow extends StatelessWidget {
  const Level3Flow({super.key});

  @override
  Widget build(BuildContext context) {
    return Level3StoryPageWrapper();
  }
}

class Level3StoryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Level3StoryPage(
      // 스토리 끝나면 Transition → ThemeSelect
      onStoryEnd: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ListenGameTransition(
                  nextPage: const Level3ThemeSelectPage(),
                ),
          ),
        );
      },
    );
  }
}
