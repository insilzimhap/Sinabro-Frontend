import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'style.dart';

class IntroTopicPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const IntroTopicPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  State<IntroTopicPage> createState() => _IntroTopicPageState();
}

class _IntroTopicPageState extends State<IntroTopicPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // 좌우 왕복
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      body: InkWell(
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   // 세로 중앙
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙
          children: [
            // 좌우 흔들리는 시계
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // -20px ~ +20px 좌우 이동
                double dx = math.sin(_controller.value * 2 * math.pi) * 20;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
              },
              child: Image.asset(
                widget.imagePath,
                height: AppStyle.introImageHeight(context),
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: AppStyle.introSpacing(context)),

            // 텍스트
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppStyle.introTitle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
