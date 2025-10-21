import 'package:flutter/material.dart';

// 각 레벨별 테마 선택 페이지 import
import '../../listenGame/page/level1/level1_theme_select.dart';
import '../../listenGame/page/level2/level2_theme_select.dart';
import '../../listenGame/page/level3/level3_theme_select.dart';

/// 🎉 일반 클리어 팝업
/// - 5초 후 현재 레벨의 테마 선택 페이지로 자동 이동
Future<void> showClearPopup(BuildContext context, int level) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: curved,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/icon/popup/clap.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '이번 단계를 클리어했어요!\n다음 단계도 도전해봐요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                      color: Color(0xFF5A3E1B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  // ⏱ 5초 후 테마 선택 페이지로 이동
  await Future.delayed(const Duration(seconds: 5));

  if (!context.mounted) return;

  Navigator.of(context, rootNavigator: true).pop(); // 팝업 닫기

  Widget nextPage;
  switch (level) {
    case 1:
      nextPage = const Level1ThemeSelectPage();
      break;
    case 2:
      nextPage = const Level2ThemeSelectPage();
      break;
    case 3:
      nextPage = const Level3ThemeSelectPage();
      break;
    default:
      nextPage = const Placeholder();
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => nextPage),
    (route) => route.isFirst,
  );
}
