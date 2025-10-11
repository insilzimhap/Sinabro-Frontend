import 'package:flutter/material.dart';
import 'level2/routine_flow.dart'; // ✅ 루틴 실행 분리 불러오기
import 'level3/routine_flow.dart'; // ✅ 루틴 실행 분리 불러오기

enum ContentStatus { locked, available, done }

class ListenAppleSelect extends StatefulWidget {
  final String childId;
  const ListenAppleSelect({super.key, required this.childId});

  @override
  State<ListenAppleSelect> createState() => _ListenAppleSelectState();
}

class _ListenAppleSelectState extends State<ListenAppleSelect> {
  final List<ContentStatus> status =
      List.generate(14, (i) => ContentStatus.available);

  // 배경 기준 비율 좌표
  final List<Offset> spots = const [
    // 첫 번째 나무 (왼쪽) 5개
    Offset(0.14, 0.35),
    Offset(0.23, 0.38),
    Offset(0.09, 0.48),
    Offset(0.18, 0.53),
    Offset(0.27, 0.50),

    // 두 번째 나무 (가운데) 5개
    Offset(0.46, 0.35),
    Offset(0.55, 0.38),
    Offset(0.41, 0.48),
    Offset(0.50, 0.53),
    Offset(0.59, 0.50),

    // 세 번째 나무 (오른쪽) 4개
    Offset(0.80, 0.35), // 10 : 1번 루틴
    Offset(0.89, 0.41), // 11 : 2번 루틴
    Offset(0.77, 0.50), // 12 : 3번 루틴
    Offset(0.87, 0.56), // 13 : 4번 루틴
  ];

  // ✅ 사과 탭 → 루틴 실행
  Future<void> _tap(int index) async {
    if (status[index] == ContentStatus.locked) return;

    switch (index) {
      // 두 번째 나무 (5~9) → 레벨2 루틴 실행
      case 5:
        startLevel2Routine(context); // story1
        break;
      case 6:
        startLevel2Routine2(context, 0); // story2 - routine_data_1.dart
        break;
      case 7:
        startLevel2Routine2(context, 1); // story2 - routine_data_2.dart
        break;
      case 8:
        startLevel2Routine3(context, 2); // story3
        break;
      case 9:
        startLevel2Routine3(context, 3); // story3
        break;

      // 세 번째 나무 (10~13) → 레벨3 루틴 실행
      case 10:
        startLevel3Routine(context, 0);
        break;
      case 11:
        startLevel3Routine(context, 1);
        break;
      case 12:
        startLevel3Routine(context, 2);
        break;
      case 13:
        startLevel3Routine(context, 3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final appleSize = size.width * 0.06;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/img/contents/studyListen/apple_tree.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              for (int i = 0; i < spots.length; i++)
                Positioned(
                  left: spots[i].dx * size.width - appleSize / 2,
                  top: spots[i].dy * size.height - appleSize / 2,
                  child: _Apple(
                    index: i,
                    size: appleSize,
                    status: status[i],
                    onTap: () => _tap(i),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Apple extends StatefulWidget {
  final int index;
  final double size;
  final ContentStatus status;
  final VoidCallback onTap;

  const _Apple({
    required this.index,
    required this.size,
    required this.status,
    required this.onTap,
    super.key,
  });

  @override
  State<_Apple> createState() => _AppleState();
}

class _AppleState extends State<_Apple> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isGold = (widget.index == 4 || widget.index == 9 || widget.index == 13);
    final asset = isGold
        ? 'assets/img/contents/studyListen/gold_apple.png'
        : 'assets/img/contents/studyListen/apple.png';

    int number;
    if (widget.index <= 4) {
      number = widget.index + 1;
    } else if (widget.index <= 9) {
      number = widget.index - 4;
    } else {
      number = widget.index - 9;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.95 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              asset,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
            Text(
              '$number',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: widget.size * 0.45,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}