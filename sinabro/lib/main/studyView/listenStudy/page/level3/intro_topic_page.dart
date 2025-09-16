import 'package:flutter/material.dart';
import 'dart:math' as math;

class IntroTopicPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  const IntroTopicPage({
    Key? key,
    required this.title,
    required this.imagePath,
    this.onTap,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 600),
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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E5),
      body: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            // 뒤로가기 버튼
            Positioned(
              top: h * 0.02,
              left: w * 0.02,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.grey, size: 40),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 시계 (x축 이동)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double dx = 20 * math.sin(_controller.value * 2 * math.pi);
                  return Transform.translate(
                    offset: Offset(dx, 0), // x축으로 좌우 이동
                    child: Image.asset(
                      widget.imagePath,
                      width: w * 0.6,
                      height: w * 0.6,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

            // 텍스트
            Positioned(
              bottom: h * 0.1,
              left: w * 0.1,
              right: w * 0.1,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C685F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
