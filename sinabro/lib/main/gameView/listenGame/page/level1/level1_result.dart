// lib/main/gameView/common/listenGame/page/level1/level1_result.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_theme_select.dart';

class Level1ResultPage extends StatelessWidget {
  final int themeId;
  final bool success;

  const Level1ResultPage({
    super.key,
    required this.themeId,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = success
        ? "assets/img/contents/gameListen/level1/theme_${themeId}_clear.png"
        : "assets/img/contents/gameListen/level1/theme_fail.png";

    final Map<int, String> successDialogue = {
      1: "드디어 무지개를 만들었어요! 감사해요",
      2: "덕분에 사탕을 많이 만들 수 있었어요!",
      3: "제 친구들보다 마법을 더 잘 쓸 거예요!",
      4: "이번 시험도 걱정 없을 것 같아요",
      5: "도와주신 덕분에 마법 만점이에요~!",
    };

    final List<String> dialogue = success
        ? [successDialogue[themeId] ?? ""]
        : ["앗! 마법으로 만들어지지 않았어요", "만드는걸 다시 도와주실래요?"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("결과"),
        backgroundColor: Colors.orange[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 250, fit: BoxFit.contain),
            const SizedBox(height: 24),
            ...dialogue.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  line,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Level1ThemeSelectPage(
                      onThemeSelected: (index) {
                        // 테마 선택 시 처리 로직 (예: 다음 화면 이동)
                        print('선택된 테마: $index');
                      },
                    ),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "테마 선택으로 돌아가기",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
