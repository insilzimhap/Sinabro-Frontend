import 'package:flutter/material.dart';

class StoryPage extends StatefulWidget {
  final String imagePath;
  final String text;
  final VoidCallback onFinished;

  const StoryPage({
    super.key,
    required this.imagePath,
    required this.text,
    required this.onFinished,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  void initState() {
    super.initState();
    // 20초 뒤 자동 콜백 실행
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              widget.imagePath,
              width: w * 0.5,
              height: w * 0.5,
              fit: BoxFit.contain,
            ),
            SizedBox(height: h * 0.05),
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: w * 0.06,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7C685F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
