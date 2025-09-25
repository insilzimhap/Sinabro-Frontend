import 'package:flutter/material.dart';
import 'dart:math';
import 'level1_story.dart'; // 스토리 페이지 연결
import 'level1_game.dart';
import 'level1_result.dart';

class Level1ThemeSelectPage extends StatefulWidget {
  const Level1ThemeSelectPage({super.key});

  @override
  State<Level1ThemeSelectPage> createState() => _Level1ThemeSelectPageState();
}

class _Level1ThemeSelectPageState extends State<Level1ThemeSelectPage>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();

    // 책 둥실둥실 (2초 주기)
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    // 별 반짝임 (1초 주기)
    _starController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themes = List.generate(5, (index) {
      return {
        "id": index + 1,
        "imagePath":
            "assets/img/contents/gameListen/level1/theme_${index + 1}.png",
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("레벨1 테마 선택"),
        backgroundColor: Colors.orange[200],
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
            final isOpened = true; // 전체 오픈 상태

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Level1StoryPage(themeId: theme["id"] as int),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 책 이미지 (둥실둥실)
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final dy = sin(_floatController.value * 2 * pi) * 6;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      theme["imagePath"]!,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 반짝이는 별 (열린 경우만 → 지금은 전체 적용)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _starController,
                        builder: (context, child) {
                          final opacity =
                              0.5 + 0.5 * sin(_starController.value * 2 * pi);
                          return Opacity(
                            opacity: opacity,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Icon(Icons.star,
                                      color: Colors.yellow[600], size: 20),
                                ),
                                Positioned(
                                  top: 20,
                                  right: 15,
                                  child: Icon(Icons.star,
                                      color: Colors.yellow[700], size: 16),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 25,
                                  child: Icon(Icons.star,
                                      color: Colors.yellow[500], size: 18),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
