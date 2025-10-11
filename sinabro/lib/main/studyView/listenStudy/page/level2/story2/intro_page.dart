import 'package:flutter/material.dart';

/// 🍊 Story2 - 감정 인트로 페이지
/// 감정 학습 시작 화면.
/// 탭하면 감정 토픽(예: 좋아요, 배고파요)으로 이동.
class Story2IntroPage extends StatelessWidget {
  final VoidCallback onNext;
  const Story2IntroPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        onTap: onNext,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ 감정 대표 이미지
                Image.asset(
                  "assets/img/contents/studyListen/level2/face.png",
                  width: screenWidth * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // ✨ 인트로 텍스트
                const Text(
                  "짠! 오늘은 감정에 대해서 알아볼까요?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.brown,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "기쁨, 무서움, 놀람 같은 감정을 함께 배워봐요 🍎",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 60),

                // 💬 안내 문구
                const Text(
                  "화면을 터치하면 시작됩니다",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
