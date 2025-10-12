// lib/main/studyView/listenGame/page/level2/theme_select_page.dart
import 'package:flutter/material.dart';
import '../listen_game_page.dart';
import '../../data/level2_data.dart';

class Level2ThemeSelectPage extends StatelessWidget {
  const Level2ThemeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themePaths = [
      'assets/img/contents/listenGame/level2/theme/theme_1.png',
      'assets/img/contents/listenGame/level2/theme/theme_2.png',
      'assets/img/contents/listenGame/level2/theme/theme_3.png',
    ];
    const decoPath =
        'assets/img/contents/listenGame/level2/theme/theme_deco.png';
    const bgPath =
        'assets/img/contents/listenGame/level2/theme/background.png';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 🟢 배경
            Positioned.fill(
              child: Image.asset(
                bgPath,
                fit: BoxFit.cover,
              ),
            ),

            // 🌿 하단 풀 장식
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(decoPath, fit: BoxFit.cover, height: 100),
            ),

            // 🔙 뒤로가기
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2E6B3D)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 🍀 테마 선택 버튼
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        final selected = level2GameData.sublist(start, end);

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
    final isCenter = widget.index == 2; // 가운데만 반짝이

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            widget.imagePath,
            width: MediaQuery.of(context).size.width * 0.25,
          ),
          if (isCenter)
            FadeTransition(
              opacity: Tween(begin: 0.4, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: const Icon(Icons.star_rounded,
                  color: Colors.amber, size: 40),
            ),
        ],
      ),
    );
  }
}
