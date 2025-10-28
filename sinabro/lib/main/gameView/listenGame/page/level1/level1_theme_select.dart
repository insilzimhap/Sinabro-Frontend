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

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFB05E2E),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final themePath = themes[index];

                    return _ThemeBook(
                      index: index + 1,
                      imagePath: themePath,
                      onTap: () => onThemeSelected(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeBook extends StatefulWidget {
  final int index;
  final String imagePath;
  final VoidCallback onTap;

  const _ThemeBook({
    required this.index,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_ThemeBook> createState() => _ThemeBookState();
}

class _ThemeBookState extends State<_ThemeBook>
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
    final isSpecial = widget.index == 5;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween(begin: 0.98, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              widget.imagePath,
              width: 420,
              fit: BoxFit.contain,
            ),
            if (isSpecial)
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
    );
  }
}
