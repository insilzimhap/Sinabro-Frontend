// lib/main/studyView/common/widget/apple_popup.dart

/*
 * ----------------------------------------------------------------
 * [공통 - 학습/게임 완료 팝업 위젯]
 *
 * 학습(Study) 또는 게임(Game)의 한 열매(Fruit) 또는
 * 한 스테이지(Stage) 완료 시 표시되는 팝업입니다.
 *
 * - 일반 사과(isGold=false)와 황금 사과(isGold=true)에 따라
 * 다른 이미지와 텍스트를 보여줍니다.
 * - 팝업은 5초 동안 자동으로 표시된 후 사라집니다.
 * - 팝업이 닫힌 후에는 지정된 경로(보통 열매 선택 트리 화면)로 돌아갑니다.
 * - childId를 받아 향후 API 연동 확장을 대비합니다.
 * ----------------------------------------------------------------
 */
import 'dart:async'; // Future.delayed 사용 위해 import
import 'package:flutter/material.dart';

// ✅ [추가] 열매 선택 페이지의 routeName import (경로 확인 필요!)
// 만약 AppConstants 파일을 사용한다면 그 파일을 import 하세요.
// import 'package:sinabro/main/studyView/common/constants/app_constants.dart';
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart'; // 임시 경로

/// 🍎 학습/게임 완료 시 표시되는 사과 팝업
///
/// @param context BuildContext for showing the dialog.
/// @param isGold 황금 사과(스테이지 완료)인지 여부.
/// @param childId 현재 학습/게임을 진행한 자녀의 ID (향후 API 연동용).
Future<void> showApplePopup(BuildContext context,
    {required bool isGold, required String childId}) async {
  // ✅ childId 추가
  debugPrint('[ApplePopup] Showing popup for child: $childId, isGold: $isGold');

  // 비동기 팝업 표시 (showGeneralDialog 사용)
  showGeneralDialog(
    context: context,
    barrierDismissible: false, // 팝업 외부 탭해도 닫히지 않음
    barrierColor: Colors.black38, // 반투명 검정 배경
    transitionDuration: const Duration(milliseconds: 300), // 나타나는 애니메이션 속도
    pageBuilder: (context, animation, secondaryAnimation) {
      // pageBuilder 자체는 사용하지 않으므로 빈 위젯 반환
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // 애니메이션 효과 (Fade + Scale)
      final curved = CurvedAnimation(
          parent: animation, curve: Curves.easeOutBack); // 통통 튀는 효과

      return FadeTransition(
        opacity: curved, // 부드럽게 나타남
        child: ScaleTransition(
          scale: curved, // 약간 커지면서 나타남
          child: Center(
            // 팝업 내용 위젯 (_ApplePopupContent)
            child: _ApplePopupContent(
                isFinal: isGold, childId: childId), // ✅ childId 전달
          ),
        ),
      );
    },
  );

  // 팝업 자동 닫기 (5초 후)
  await Future.delayed(const Duration(seconds: 5));

  // 팝업 닫기 (mounted 체크 추가)
  if (context.mounted) {
    // rootNavigator: true를 사용하여 앱 전체 context에서 팝업을 닫음
    Navigator.of(context, rootNavigator: true).pop();
  }

  // 팝업 닫힌 후, 열매 선택 화면(ListenAppleSelect)으로 복귀
  await Future.delayed(const Duration(milliseconds: 200)); // 자연스러운 전환 딜레이
  if (context.mounted) {
    // ✅ [수정] route.isFirst 대신 명시적인 routeName으로 변경
    // ListenAppleSelect.routeName 또는 AppRouteNames.listenAppleSelect 사용
    Navigator.popUntil(
        context, ModalRoute.withName(ListenAppleSelect.routeName));
  }
}

/// 팝업 내용을 구성하는 내부 위젯
class _ApplePopupContent extends StatefulWidget {
  final bool isFinal; // 황금 사과(스테이지 완료) 여부
  final String childId; // 자녀 ID (UI 표시는 안 하지만 받아둠)

  const _ApplePopupContent({required this.isFinal, required this.childId});

  @override
  State<_ApplePopupContent> createState() => _ApplePopupContentState();
}

class _ApplePopupContentState extends State<_ApplePopupContent>
    with SingleTickerProviderStateMixin {
  // 황금 사과 반짝이 효과를 위한 애니메이션 컨트롤러 (현재는 사용 안 함)
  // late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    // 반짝이 효과 컨트롤러 초기화 (필요시 활성화)
    // _shineController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 1),
    // )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    // _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 팝업 UI 구성
    return Material(
      // Dialog는 기본적으로 Material 위젯 위에서 렌더링되어야 함
      color: Colors.transparent, // Material 기본 배경색 제거
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75, // 화면 너비의 75%
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E8), // 팝업 배경색 (옅은 노랑)
          borderRadius: BorderRadius.circular(20), // 둥근 모서리
          boxShadow: [
            // 그림자 효과
            BoxShadow(
              color: Colors.brown.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞게 높이 조절
          children: [
            // 사과 이미지 영역 (Stack으로 감싸 추후 효과 추가 용이)
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  // isFinal 값에 따라 황금 사과 또는 일반 사과 이미지 표시
                  widget.isFinal
                      ? "assets/img/icon/popup/apple_gold.png" // TODO: AppConstants 사용
                      : "assets/img/icon/popup/apple_red.png", // TODO: AppConstants 사용
                  width: 90, // 이미지 너비 고정
                ),
                // TODO: 여기에 반짝이 효과(AnimatedBuilder 등) 추가 가능
              ],
            ),
            const SizedBox(height: 20), // 이미지와 텍스트 사이 간격

            // 텍스트 내용
            Text(
              // isFinal 값에 따라 다른 메시지 표시
              widget.isFinal
                  ? "이번 나무의 사과를 획득했어요!\n황금사과까지 전부 모았어요!\n다음 나무의 사과도 부탁해~"
                  : "이번 나무의 사과를 획득했어요!\n잠시 후 나무로 돌아가요~",
              textAlign: TextAlign.center, // 가운데 정렬
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500, // 약간 두껍게
                height: 1.5, // 줄 간격
                color: Color(0xFF5A3E1B), // 텍스트 색상 (짙은 갈색)
              ),
            ),
            // TODO: 확인 버튼 등 추가 UI 요소 배치 가능 (현재는 자동 닫힘)
          ],
        ),
      ),
    );
  }
}
