// ../../../common/widget/apple_popup.dart';
import 'package:flutter/material.dart';

/// 🍎 사과 팝업 (황금 사과 반짝이 효과 포함)
Future<void> showApplePopup(BuildContext context,
    {required bool isGold}) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: curved,
          child: Center(
            child: _ApplePopupContent(isFinal: isGold),
          ),
        ),
      );
    },
  );

  // ✅ 팝업 5초 유지
  await Future.delayed(const Duration(seconds: 5));

  // 팝업 닫기
  Navigator.of(context, rootNavigator: true).pop();

  // ✅ 나무(열매 선택 페이지)로 복귀
  await Future.delayed(const Duration(milliseconds: 300)); // 자연스러운 전환 딜레이
  Navigator.popUntil(context, (route) => route.isFirst);
}

class _ApplePopupContent extends StatefulWidget {
  final bool isFinal;
  const _ApplePopupContent({required this.isFinal});

  @override
  State<_ApplePopupContent> createState() => _ApplePopupContentState();
}

class _ApplePopupContentState extends State<_ApplePopupContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                widget.isFinal
                    ? "assets/img/icon/popup/apple_gold.png"
                    : "assets/img/icon/popup/apple_red.png",
                width: 90,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.isFinal
                ? "이번 나무의 사과를 획득했어요!\n황금사과까지 전부 모았어요!\n다음 나무의 사과도 부탁해~"
                : "이번 나무의 사과를 획득했어요!\n잠시 후 나무로 돌아가요~",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFF5A3E1B),
            ),
          ),
        ],
      ),
    );
  }
}
