import 'package:flutter/material.dart';

class Level1ThemeSelectPage extends StatelessWidget {
  final Function(int) onThemeSelected;

  const Level1ThemeSelectPage({
    super.key,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themes = List.generate(
      5,
      (i) => 'assets/img/contents/gameListen/level1/theme/theme_${i + 1}.png',
    );

    final rects = [
      const Rect.fromLTWH(40, 120, 100, 100),   // 1번 위치
      const Rect.fromLTWH(160, 90, 100, 100),   // 2번 위치
      const Rect.fromLTWH(280, 140, 100, 100),  // 3번 위치
      const Rect.fromLTWH(100, 260, 100, 100),  // 4번 위치
      const Rect.fromLTWH(230, 280, 100, 100),  // 5번 위치 (특별)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFB05E2E),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 왼쪽 책 → theme_1.png
            _ThemeButton(
              rect: rects[0],
              imageAsset: themes[0],
              semanticLabel: '왼쪽 책',
              onTap: () => onThemeSelected(0),
            ),

            // 중앙 위 책 → theme_2.png
            _ThemeButton(
              rect: rects[1],
              imageAsset: themes[1],
              semanticLabel: '중앙 위 책',
              onTap: () => onThemeSelected(1),
            ),

            // 오른쪽 책 → theme_3.png
            _ThemeButton(
              rect: rects[2],
              imageAsset: themes[2],
              semanticLabel: '오른쪽 책',
              onTap: () => onThemeSelected(2),
            ),

            // 왼쪽 아래 책 → theme_4.png
            _ThemeButton(
              rect: rects[3],
              imageAsset: themes[3],
              semanticLabel: '왼쪽 아래 책',
              onTap: () => onThemeSelected(3),
            ),

            // 오른쪽 아래 책 → theme_5.png (특별)
            _ThemeButton(
              rect: rects[4],
              imageAsset: themes[4],
              semanticLabel: '오른쪽 아래 책',
              isSpecial: true,
              onTap: () => onThemeSelected(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatefulWidget {
  final Rect rect;
  final String imageAsset;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool isSpecial;

  const _ThemeButton({
    required this.rect,
    required this.imageAsset,
    required this.semanticLabel,
    required this.onTap,
    this.isSpecial = false,
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.05).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                widget.imageAsset,
                fit: BoxFit.contain,
                semanticLabel: widget.semanticLabel,
              ),
              if (widget.isSpecial)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.amber.withOpacity(0.8),
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
