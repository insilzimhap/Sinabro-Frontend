import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/layout/get_sticker_page.dart';
import 'package:sinabro/main/childView/page/sticker_book.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart'; // ✅ LobbyChildScreen import
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart'; // ✅ ListenAppleSelect import

class StickerRewardHandler extends StatelessWidget {
  final String childId; // ✅ 추가
  final String fruitId; // ✅ 추가
  final String stageKey;
  final int newlyUnlockedIndex;
  final bool isAllCleared;
  final VoidCallback onFinish;

  // ✅ [새로 추가] 최종적으로 이동할 목적지 위젯을 인자로 받습니다.
  final Widget finalDestination;

  const StickerRewardHandler({
    super.key,
    required this.childId, // ✅ 추가
    required this.fruitId, // ✅ 추가
    required this.stageKey,
    required this.newlyUnlockedIndex,
    required this.isAllCleared,
    required this.onFinish,
    required this.finalDestination, // ✅ [필수] 생성자에 추가
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
      // onComplete: 로비 -> 나무 화면으로 이동하는 로직을 깔끔하게 정리
      onComplete: () async {


        // 1. StickerRewardHandler를 스택에서 제거하고
        // 2. LobbyChildScreen으로 대체합니다.
        if (!context.mounted) return;

        // 1. StickerRewardHandler를 스택에서 제거하고
        // 2. LobbyChildScreen으로 대체합니다.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => finalDestination,
          ),
        );

        //await Future.delayed(const Duration(seconds: 2));

        // Navigator.of(context).pushReplacement(
        //   PageRouteBuilder(
        //     transitionDuration: const Duration(milliseconds: 800),
        //     pageBuilder: (_, animation, __) {
        //       return FadeTransition(
        //         opacity: CurvedAnimation(
        //           parent: animation,
        //           curve: Curves.easeInOut,
        //         ),
        //         child: StickerBookPage(
        //           childId: childId, // ✅ childId 전달 추가
        //         ),
        //       );
        //     },
        //   ),
        // );
      },
    );
  }
}
