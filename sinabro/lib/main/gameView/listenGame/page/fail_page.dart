// lib/main/studyView/listenGame/page/levelX/result/fail_page.dart
import 'package:flutter/material.dart';

class ListenGameFailPage extends StatelessWidget {
  final int level;
  final VoidCallback onRetry;
  const ListenGameFailPage({
    super.key,
    required this.level,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath =
        'assets/img/contents/listenGame/level${level}/result/fail.jpg';

    return Scaffold(
      body: Stack(
        children: [
          // 📸 배경 이미지
          Positioned.fill(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),

          // 🔙 뒤로가기
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 🔁 다시하기 버튼
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    "다시하기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
