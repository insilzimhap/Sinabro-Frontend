import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/stage_fruit_map.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';

/// 듣기 / 쓰기 공용 열매 렌더러

typedef FruitTapCallback = void Function(String fruitId);

Widget buildTreeCommon(
  String stageId,
  TreeProgress progress,
  String category, {
  FruitTapCallback? onFruitTap,
}) {
  final fruits = stageFruitMap[stageId];
  if (fruits == null || fruits.isEmpty) return const SizedBox.shrink();

  final positions = _fruitPositions(fruits.length);
  return Stack(
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
    final entry = fruitImageMap[fruitId];
    if (entry == null) return const SizedBox.shrink();

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: () => onTap?.call(fruitId),
        child: Image.asset(
          active ? entry.active : entry.inactive,
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

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
      return List.generate(count, (i) => Offset(40.0 + (i * 40), 80));
  }
}
