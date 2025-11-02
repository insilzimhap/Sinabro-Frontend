/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 3 결과 화면]
 *  - 게임 완료 후 성공/실패 여부에 따라 다른 이미지와 대사 출력
 *  - <다시하기> 버튼으로 테마 선택 페이지로 복귀
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
//changed-start
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_flow.dart';
import 'package:sinabro/main/gameView/writeGame/api/child_state.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_flow.dart';
import 'package:sinabro/main/gameView/writeGame/api/fruit_state.dart';

//changed-end
class Level3ResultPage extends StatelessWidget {
  final int themeId;
  final bool success;

  const Level3ResultPage({
    super.key,
    required this.themeId,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = success
        ? "assets/img/contents/gameListen/level3/theme_clear.png"
        : "assets/img/contents/gameListen/level3/theme_fail.png";

    final Map<int, String> successDialogue = {
      1: "심부름을 끝냈다고크! 네 덕분이야크!",
      2: "도움을 줘서 고맙다고크!",
    };

    final List<String> dialogue = success
        ? [successDialogue[themeId] ?? ""]
        : ["뭔가 잘못 산 것 같다고크! 다시해보자크!"];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Positioned(
            right: 24,
            top: 36,
            child: ElevatedButton(
              onPressed: () {
                FruitState.instance.clear(); // ✅ 이전 세션 초기화

                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder( //changed-start
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Level3Flow(
                          childId: ChildState.instance.childId ?? '', //추가
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500), //changed-end
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
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                elevation: 3,
              ),
              child: const Text(
                "다시하기",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE1E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "크크",
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
                          textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }
}
