import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/studyView/common/data/study_data_maps.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';

/// ---------------------------------------------------------------------------
/// 🌳 [Tree / Fruit Renderer]
/// 듣기·쓰기 게임 공용 UI 위젯
/// ---------------------------------------------------------------------------
/// ✅ 역할
/// - 1️⃣ 각 Stage(나무)에 속한 Fruit(열매)들을 화면에 렌더링.
/// - 2️⃣ TreeProgress를 참조하여 활성/비활성 상태별로 이미지를 다르게 표시.
/// - 3️⃣ onTap 콜백을 통해 각 열매 클릭 시 이벤트 전달.
/// - 4️⃣ 상위 챕터(나무) 단위 렌더링 함수 (buildStageTree) 추가.
/// 
/// 🔹 이 파일은 “챕터 + 테마(열매)” UI를 모두 관리함.
/// ---------------------------------------------------------------------------

typedef FruitTapCallback = void Function(String fruitId);
typedef StageTapCallback = void Function(String stageId);

/// 🍎 [buildTreeCommon]
/// - 하나의 Stage(나무)에 포함된 Fruit(열매)들을 그리는 함수 위젯.
/// - TreeProgress의 active 상태를 기반으로 활성/비활성 이미지를 표시.
/// - 사용 예시:
///   ```dart
///   buildTreeCommon('ST007', progress, 'listening_game', onFruitTap: (id) { ... });
///   ```
Widget buildTreeCommon(
  String stageId,
  TreeProgress progress,
  String category, {
  FruitTapCallback? onFruitTap,
}) {
  // 1️⃣ 해당 나무(Stage)에 속한 열매 ID 목록 가져오기
  final fruits = stageFruitMap[stageId];
  if (fruits == null || fruits.isEmpty) return const SizedBox.shrink();

  // 2️⃣ 열매 개수에 따라 배치 좌표 계산
  final positions = _fruitPositions(fruits.length);

  // 3️⃣ Stack을 이용해 화면에 열매들을 겹쳐 배치
  return Stack(
    clipBehavior: Clip.none,
    children: [
      for (int i = 0; i < fruits.length; i++)
        _FruitWidget(
          fruitId: fruits[i],
          active: progress.isFruitActive(fruits[i]),
          offset: positions[i],
          onTap: onFruitTap,
        ),
    ],
  );
}

/// 🍏 [단일 열매 위젯]
/// - 활성화(active) 여부에 따라 이미지 변경.
/// - 클릭 시 onTap 콜백 호출.
class _FruitWidget extends StatelessWidget {
  final String fruitId;
  final bool active;
  final Offset offset;
  final FruitTapCallback? onTap;

  const _FruitWidget({
    required this.fruitId,
    required this.active,
    required this.offset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // fruitId → 이미지 경로 매핑 정보 불러오기
    final entry = fruitImageMap[fruitId];
    if (entry == null) {
      debugPrint('⚠️ [FruitWidget] 이미지 매핑 없음: $fruitId');
      return const SizedBox.shrink();
    }

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        // 🔹 비활성 상태라도 onTap이 있으면 누를 수 있음
        //   → 상위에서 “if (!active) return;” 처리 권장
        onTap: () => onTap?.call(fruitId),
        child: Image.asset(
          active ? entry.active : entry.inactive, // 활성/비활성 이미지 선택
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// 🧭 [열매 배치 좌표 계산기]
/// - 열매 개수에 따라 화면 상의 위치(Offset) 자동 계산.
/// - Stage마다 열매 개수가 다르므로 간단한 규칙형으로 배치.
List<Offset> _fruitPositions(int count) {
  switch (count) {
    case 1:
      return [const Offset(80, 80)];
    case 2:
      return [const Offset(40, 90), const Offset(120, 70)];
    case 3:
      return [
        const Offset(30, 100),
        const Offset(90, 60),
        const Offset(150, 100),
      ];
    case 4:
      return [
        const Offset(30, 90),
        const Offset(80, 50),
        const Offset(130, 90),
        const Offset(80, 130),
      ];
    case 5:
      return [
        const Offset(20, 100),
        const Offset(70, 50),
        const Offset(120, 80),
        const Offset(170, 60),
        const Offset(100, 130),
      ];
    default:
      // 기본값: 일정 간격으로 가로 배치
      return List.generate(count, (i) => Offset(40.0 + (i * 40), 80));
  }
}

/// ---------------------------------------------------------------------------
/// 🌲 [buildStageTree]
/// - 챕터(나무) 단위 렌더링용 함수.
/// - TreeProgress의 isStageUnlocked()으로 잠금/해금 상태를 판별.
/// - 활성/비활성 이미지 모두 지정 가능.
/// - 예시: 챕터 선택 화면에서 사용.
/// ---------------------------------------------------------------------------
Widget buildStageTree({
  required String stageId,
  required TreeProgress progress,
  required String activeImage,
  required String lockedImage,
  StageTapCallback? onTap,
}) {
  // 1️⃣ 해당 Stage(나무)의 잠금/해금 상태 확인
  final unlocked = progress.isStageUnlocked(stageId);

  // 2️⃣ 터치 가능 상태: 해금된 경우에만 onTap 실행
  return GestureDetector(
    onTap: unlocked ? () => onTap?.call(stageId) : null,
    child: Image.asset(
      unlocked ? activeImage : lockedImage,
      width: 220,
      fit: BoxFit.contain,
    ),
  );
}
