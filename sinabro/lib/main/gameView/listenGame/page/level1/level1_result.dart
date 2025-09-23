import 'package:flutter/material.dart';
import 'level1_theme_select.dart';

class Level1ResultPage extends StatelessWidget {
  final int themeId;
  final bool isClear;

  const Level1ResultPage({
    super.key,
    required this.themeId,
    required this.isClear,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 클리어 이미지 (파일명 theme_X_clear.png)
    final clearData = {
      1: {
        "image": "assets/img/contents/gameListen/level1/theme_1_clear.png",
        "dialogue": "드디어 무지개를 만들었어요! 감사해요",
      },
      2: {
        "image": "assets/img/contents/gameListen/level1/theme_2_clear.png",
        "dialogue": "덕분에 사탕을 많이 만들 수 있었어요!",
      },
      3: {
        "image": "assets/img/contents/gameListen/level1/theme_3_clear.png",
        "dialogue": "제 친구들과 마법을 더 잘 할 거예요!",
      },
      4: {
        "image": "assets/img/contents/gameListen/level1/theme_4_clear.png",
        "dialogue": "이번 시험도 걱정 없을 것 같아요",
      },
      5: {
        "image": "assets/img/contents/gameListen/level1/theme_5_clear.png",
        "dialogue": "도와주신 덕분에 마법 완성이에요~!",
      },
    };

    // 🔹 실패 이미지 (임시 placeholder, 나중에 교체 가능)
    final failData = {
      1: {
        "image": "assets/img/contents/gameListen/level1/theme_1_fail.png",
        "dialogue": "무지개 만들기 실패... 다시 해볼까요?",
      },
      2: {
        "image": "assets/img/contents/gameListen/level1/theme_2_fail.png",
        "dialogue": "사탕 마법 실패... 아쉽네요!",
      },
      3: {
        "image": "assets/img/contents/gameListen/level1/theme_3_fail.png",
        "dialogue": "친구들이 슬퍼하고 있어요...",
      },
      4: {
        "image": "assets/img/contents/gameListen/level1/theme_4_fail.png",
        "dialogue": "이번엔 조금 부족했어요",
      },
      5: {
        "image": "assets/img/contents/gameListen/level1/theme_5_fail.png",
        "dialogue": "마법 실패... 다시 도전해요!",
      },
    };

    final data = isClear ? clearData[themeId]! : failData[themeId]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이미지 (사이즈 고정)
              Image.asset(
                data["image"]!,
                width: 240,
                height: 240,
              ),
              const SizedBox(height: 20),

              // 말풍선 (고정 레이아웃)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEED7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEC186)),
                ),
                child: Text(
                  data["dialogue"]!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Level1ThemeSelectPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "테마 선택으로 돌아가기",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
