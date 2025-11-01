/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2 테마 선택 화면]
 *  - 챕터(레벨 2)의 테마(열매) 3개 중 하나를 선택하는 페이지
 *  - 각 테마 이미지를 터치하면 해당 테마 진입
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';

class Level2ThemeSelectPage extends StatelessWidget {
  final Function(int) onThemeSelected;

  const Level2ThemeSelectPage({
    super.key,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themePaths = List.generate(
      3,
      (i) => 'assets/img/contents/gameListen/level2/theme/theme_${i + 1}.png',
    );
    const decoPath = 'assets/img/contents/gameListen/level2/theme/theme_deco.png';
    const bgPath = 'assets/img/contents/gameListen/level2/theme/background.png';

    final rects = [
      const Rect.fromLTWH(60, 220, 110, 110),   // 1번 (왼쪽)
      const Rect.fromLTWH(160, 160, 120, 120),  // 2번 (가운데)
      const Rect.fromLTWH(270, 210, 110, 110),  // 3번 (오른쪽, 반짝)
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(bgPath, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(decoPath, fit: BoxFit.cover, height: 100),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF2E6B3D),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 왼쪽 테마 → theme_1.png
            _ThemeButton(
              rect: rects[0],
              imagePath: themePaths[0],
              onTap: () => onThemeSelected(0),
            ),

            // 중앙 테마 → theme_2.png
            _ThemeButton(
              rect: rects[1],
              imagePath: themePaths[1],
              onTap: () => onThemeSelected(1),
            ),

            // 오른쪽 테마 → theme_3.png (반짝)
            _ThemeButton(
              rect: rects[2],
              imagePath: themePaths[2],
              onTap: () => onThemeSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatefulWidget {
  final Rect rect;
  final String imagePath;
  final VoidCallback onTap;
  final bool isShiny;

  const _ThemeButton({
    required this.rect,
    required this.imagePath,
    required this.onTap,
    this.isShiny = false,
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
    return Positioned(
      left: widget.rect.left,
      top: widget.rect.top,
      width: widget.rect.width,
      height: widget.rect.height,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              widget.imagePath,
              fit: BoxFit.contain,
            ),
            if (widget.isShiny)
              FadeTransition(
                opacity: Tween(begin: 0.4, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
