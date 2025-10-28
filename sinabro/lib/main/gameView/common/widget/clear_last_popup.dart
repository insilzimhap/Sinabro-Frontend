import 'package:flutter/material.dart';
import '../../../gameView/listenGame/chapter_page.dart';

/// 🏁 마지막 클리어 팝업
/// - 5초 후 챕터 선택 페이지로 이동
Future<void> showClearLastPopup(BuildContext context) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: curved,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
                    '마지막 단계를 클리어했어요!\n다음 챕터로 넘어가봐요',
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

  // ⏱ 5초 후 챕터 선택 페이지로 이동
  await Future.delayed(const Duration(seconds: 5));

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GameListenChapterScreen()),
      (route) => route.isFirst,
    );
  }
}
