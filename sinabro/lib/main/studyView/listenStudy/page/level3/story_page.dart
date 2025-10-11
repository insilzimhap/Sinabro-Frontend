import 'package:flutter/material.dart';
import 'style.dart';

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
    return Scaffold(
      backgroundColor: AppStyle.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙
          children: [
            // 이미지
            Image.asset(
              widget.imagePath,
              height: AppStyle.storyImageHeight(context),
              fit: BoxFit.contain,
            ),

            SizedBox(height: AppStyle.storySpacing(context)),

            // 텍스트
            Text(
              widget.text,
              textAlign: TextAlign.center, // 가운데 정렬
              style: AppStyle.storyTitle(context),
            ),
          ],
        ),
      ),
    );
  }
}
