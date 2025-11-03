/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1 결과 화면]
 *  - 게임 완료 후 성공/실패 여부에 따라 다른 이미지와 대사 출력
 *  - <다시하기> 버튼으로 테마 선택 페이지로 복귀
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/common/api/child_state.dart';

//changed-start
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_flow.dart';
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
//changed-end

import 'package:sinabro/main/gameView/listenGame/controller/audio_helper.dart'; // ✅ 추가

class Level1ResultPage extends StatelessWidget {
  final int themeId;
  final bool success;

  const Level1ResultPage({
    super.key,
    required this.themeId,
    required this.success,
  });

  // 💡 TTS 재생 키 결정
  String _getTtsKey(int themeId, bool success) {
    if (!success) return 'fail';
    return 'success_t$themeId';
  }

  @override
  Widget build(BuildContext context) {
    // 결과 페이지 진입 시 TTS 재생
    final ttsKey = _getTtsKey(themeId, success);
    // themeId를 넘겨서 AudioHelper가 해당 단계 폴더를 찾도록 유도
    AudioHelper.playAudio(ttsKey, isTts: true, themeId: themeId);

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),

          // 오른쪽 위 말풍선
          Positioned(
            right: 20,
            top: 120,
            child: Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1B3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "양지",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
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
                ],
              ),
            ),
          ),

          // 오른쪽 아래 버튼
          Positioned(
            right: 32,
            bottom: 32,
            child: ElevatedButton(
              onPressed: () {
                FruitState.instance.clear(); // ✅ 이전 세션 초기화

                Navigator.of(context).pushAndRemoveUntil(
                  //changed-start
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Level1Flow(
                      childId: ChildState.instance.childId ?? '',
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration:
                        const Duration(milliseconds: 450), //changed-end
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                elevation: 3,
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
