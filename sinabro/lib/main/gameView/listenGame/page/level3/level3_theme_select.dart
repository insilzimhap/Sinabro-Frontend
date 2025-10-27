// lib/main/gameView/listenGame/page/level3/level3_theme_select.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_story.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_game.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_result.dart';

class Level3ThemeSelectPage extends StatefulWidget {
  const Level3ThemeSelectPage({super.key});

  @override
  State<Level3ThemeSelectPage> createState() => _Level3ThemeSelectPageState();
}

class _Level3ThemeSelectPageState extends State<Level3ThemeSelectPage>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themes = List.generate(2, (index) {
      return {
        "id": index + 1,
        "imagePath":
            "assets/img/contents/gameListen/level3/theme_${index + 1}.png",
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("레벨3 테마 선택"),
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            final isOpened = true;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Level3StoryPage(
                        themeId:
                            theme["id"] as int), // (수정) - level3_story.dart
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final dy = sin(_floatController.value * 2 * pi) * 6;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Opacity(
                          opacity: isOpened ? 1.0 : 0.3,
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      theme["imagePath"] as String,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
