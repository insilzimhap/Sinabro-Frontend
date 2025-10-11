import 'package:flutter/material.dart';
import 'model/routine_content.dart';

class SortPage extends StatelessWidget {
  final List<RoutineContent> stories; // 숫자, 손, 과일 3개
  final int number; // 현재 숫자 (1~10)
  final VoidCallback onNext; // 다음 루틴으로 이동

  const SortPage({
    super.key,
    required this.stories,
    required this.number,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 텍스트 설정 (5, 10일 때는 특별 문장)
    final String text = (number == 5 || number == 10)
        ? "이건 모두 $number이에요\n1부터 $number까지 전부 익혔어요!"
        : "이건 모두 $number이에요\n다음 숫자를 알아볼까요?";

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: onNext,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼 이미지 3개 가로 나열
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    stories.length,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        stories[i].imagePath ?? "",
                        width: MediaQuery.of(context).size.width * 0.18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 📝 텍스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "화면을 터치하면 다음으로 넘어갑니다",
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
