import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/layout/get_sticker_page.dart';
import 'package:sinabro/main/childView/page/sticker_book.dart';

class StickerRewardHandler extends StatelessWidget {
  final String childId; // ✅ 추가
  final String fruitId; // ✅ 추가
  final String stageKey;
  final int newlyUnlockedIndex;
  final bool isAllCleared;
  final VoidCallback onFinish;

  const StickerRewardHandler({
    super.key,
    required this.childId, // ✅ 추가
    required this.fruitId, // ✅ 추가
    required this.stageKey,
    required this.newlyUnlockedIndex,
    required this.isAllCleared,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    if (isAllCleared) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onFinish());
      return const SizedBox.shrink();
    }

    return GetStickerPage(
      key: ValueKey('${stageKey}_${newlyUnlockedIndex}'), // 🔥 강제 리빌드 포인트 (ST001 등)
      childId: childId, // ✅ 추가 (필수)
      stageKey: stageKey,
      fruitId: fruitId, // ✅ 전달 추가
      index: newlyUnlockedIndex,
      onComplete: () async {
        if (!context.mounted) return;
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, animation, __) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: StickerBookPage(
                  childId: childId, // ✅ childId 전달 추가
                ),
              );
            },
          ),
        );
      },
    );
  }
}
