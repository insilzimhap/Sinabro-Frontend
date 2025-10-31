import 'package:flutter/material.dart';

class Level3ThemeSelectPage extends StatelessWidget {
  final Function(int) onThemeSelected;

  const Level3ThemeSelectPage({
    super.key,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themePaths = List.generate(
      2,
      (i) => 'assets/img/contents/gameListen/level3/theme/theme_${i + 1}.png',
    );
    const decoPath = 'assets/img/contents/gameListen/level3/theme/theme_deco.png';
    const bgPath = 'assets/img/contents/gameListen/level3/theme/background.png';

    final rects = [
      const Rect.fromLTWH(80, 220, 120, 120), // theme_1 (왼쪽)
      const Rect.fromLTWH(220, 230, 120, 120), // theme_2 (오른쪽, 반짝)
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

            _ThemeButton(
              rect: rects[0],
              imagePath: themePaths[0],
              onTap: () => onThemeSelected(0),
            ),
            _ThemeButton(
              rect: rects[1],
              imagePath: themePaths[1],
              onTap: () => onThemeSelected(1),
              isShiny: true,
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
