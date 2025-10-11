import 'package:flutter/material.dart';
import 'model/routine_content.dart';

/// 🧩 Story2 - 감정 토픽 페이지
/// 인트로 다음에 등장.
/// - 한 가지 감정(예: 좋아요, 배고파요 등)을 대표.
/// - 사용자가 이미지를 탭하면 다음 단계(키워드 페이지)로 이동.
class TopicPage extends StatelessWidget {
  final RoutineContent topic;
  final VoidCallback onNext;

  const TopicPage({
    super.key,
    required this.topic,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        onTap: onNext, // 👈 클릭 시 다음으로 이동
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ 감정 대표 이미지
                Image.asset(
                  topic.imagePath ?? "",
                  width: MediaQuery.of(context).size.width * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // 🧠 감정 이름 텍스트
                Text(
                  topic.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),

                // 💬 안내 문구
                const Text(
                  "화면을 터치하면 다음으로 넘어갑니다",
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
