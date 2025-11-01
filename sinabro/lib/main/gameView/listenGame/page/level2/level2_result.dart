/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2 결과 화면]
 *  - 게임 완료 후 성공/실패 여부에 따라 다른 이미지와 대사 출력
 *  - <다시하기> 버튼으로 테마 선택 페이지로 복귀
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_theme_select.dart';

class Level2ResultPage extends StatelessWidget {
  final int themeId;
  final bool success;

  const Level2ResultPage({
    super.key,
    required this.themeId,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = success
        ? "assets/img/contents/gameListen/level2/theme_${themeId}_clear.png"
        : "assets/img/contents/gameListen/level2/theme_fail.png";

    final Map<int, String> successDialogue = {
      1: "이번에도 성공적이에요!",
      2: "행운 배달 완료!",
      3: "역시 완벽했어요!",
    };

    final List<String> dialogue = success
        ? [successDialogue[themeId] ?? "이번에도 성공적이에요!"]
        : ["행운 배달을 잘못 갔어요...", "다시 해볼까요?"];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Positioned(
            top: 80,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...dialogue.map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5E7B3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "꼬마요정",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Level2ThemeSelectPage(
                      onThemeSelected: (index) {},
                    ),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                elevation: 2,
              ),
              child: const Text(
                "다시하기",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
