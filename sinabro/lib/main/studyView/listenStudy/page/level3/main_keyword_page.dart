import 'package:flutter/material.dart';
import 'style.dart';
import 'model/routine_content.dart';
import 'story_page.dart';

class MainKeywordPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const MainKeywordPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E5),
      body: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              top: h * 0.05,
              left: w * 0.2,
              right: w * 0.2,
              child: Image.asset(
                imagePath,
                width: w * 0.6,
                height: w * 0.6,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: h * 0.1,
              left: w * 0.1,
              right: w * 0.1,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.1,
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