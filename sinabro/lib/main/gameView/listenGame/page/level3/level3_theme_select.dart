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
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2E6B3D)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(themePaths.length, (index) {
                    return _ThemeButton(
                      index: index + 1,
                      imagePath: themePaths[index],
                      onTap: () => onThemeSelected(index),
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
    final isCenter = widget.index == 2;

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
