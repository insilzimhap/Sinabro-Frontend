// lib/main/studyView/listenGame/page/level1/theme_select_page.dart
import 'package:flutter/material.dart';
import '../listen_game_page.dart'; // 공용 게임 페이지
import '../../data/level1_data.dart';

class Level1ThemeSelectPage extends StatelessWidget {
  const Level1ThemeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = List.generate(
      5,
      (i) => 'assets/img/contents/listenGame/level1/theme/theme_${i + 1}.png',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Stack(
          children: [
            // 🟤 뒤로가기
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFB05E2E)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 📚 테마 5개
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final themePath = themes[index];
                    return _ThemeBook(
                      index: index + 1,
                      imagePath: themePath,
                      onTap: () {
                        // 테마 선택 → 데이터 구간 계산
                        final start = index * 5;
                        final end = start + 5;
                        final selectedSet =
                            level1GameData.sublist(start, end);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListenGamePage(
                              gameData: selectedSet,
                              onFinished: () {
                                // 테마 완료 후 다시 테마선택 페이지로 복귀
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              },
                            ),
                          ),
                        );
                      },
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
    // 마지막 테마(5번)에만 반짝이 효과 ✨
    final isSpecial = widget.index == 5;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween(begin: 0.98, end: 1.05)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(widget.imagePath, fit: BoxFit.contain),
            if (isSpecial)
              Positioned(
                right: 8,
                bottom: 8,
                child: Icon(Icons.auto_awesome,
                    color: Colors.amber.withOpacity(0.8), size: 28),
              ),
          ],
        ),
      ),
    );
  }
}
