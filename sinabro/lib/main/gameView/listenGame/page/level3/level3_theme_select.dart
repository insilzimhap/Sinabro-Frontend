// lib/main/studyView/listenGame/page/level3/theme_select_page.dart
import 'package:flutter/material.dart';
import '../listen_game_page.dart';
import '../../data/level3_data.dart';

class Level3ThemeSelectPage extends StatelessWidget {
  const Level3ThemeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgPath =
        'assets/img/contents/listenGame/level3/theme/background.png';
    const decoPath =
        'assets/img/contents/listenGame/level3/theme/theme_deco.png';
    final themePaths = [
      'assets/img/contents/listenGame/level3/theme/theme_1.png',
      'assets/img/contents/listenGame/level3/theme/theme_2.png',
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 🌊 배경
            Positioned.fill(
              child: Image.asset(
                bgPath,
                fit: BoxFit.cover,
              ),
            ),

            // 🏝️ 모래 데코
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(decoPath, fit: BoxFit.cover, height: 100),
            ),

            // ⬅️ 뒤로가기
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0D4F79)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 🐠 테마 선택 (2개)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(themePaths.length, (index) {
                    final path = themePaths[index];
                    return _ThemeButton(
                      index: index + 1,
                      imagePath: path,
                      onTap: () {
                        final start = index * 5;
                        final end = start + 5;
                        final selected = level3GameData.sublist(start, end);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListenGamePage(
                              gameData: selected,
                              onFinished: () => Navigator.popUntil(
                                  context, (route) => route.isFirst),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatefulWidget {
  final int index;
  final String imagePath;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.index,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<_ThemeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRight = widget.index == 2;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            widget.imagePath,
            width: MediaQuery.of(context).size.width * 0.35,
          ),
          if (isRight)
            FadeTransition(
              opacity: Tween(begin: 0.4, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child:
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
            ),
        ],
      ),
    );
  }
}
