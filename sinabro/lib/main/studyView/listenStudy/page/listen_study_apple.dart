import 'package:flutter/material.dart';
import 'level2/routine_flow.dart'; // ✅ 루틴 실행 분리 불러오기
import 'level3/routine_flow.dart'; // ✅ 루틴 실행 분리 불러오기

import '../../common/widget/apple_popup.dart';

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

Future<void> _tap(int index) async {
  if (status[index] == ContentStatus.locked) return;

  // ✅ 골드 사과 위치만 true
  final bool isGold = (index == 9 || index == 13);

  switch (index) {
    // 두 번째 나무 (5~9)
    case 5:
      await startLevel2Routine(context, isGold: isGold);
      break;
    case 6:
      await startLevel2Routine2(context, 0, isGold: isGold);
      break;
    case 7:
      await startLevel2Routine2(context, 1, isGold: isGold);
      break;
    case 8:
      await startLevel2Routine3(context, 2, isGold: isGold);
      break;
    case 9:
      await startLevel2Routine3(context, 3, isGold: isGold);
      break;

    // 세 번째 나무 (10~13)
    case 10:
      await startLevel3Routine(context, 0, isGold: isGold);
      break;
    case 11:
      await startLevel3Routine(context, 1, isGold: isGold);
      break;
    case 12:
      await startLevel3Routine(context, 2, isGold: isGold);
      break;
    case 13:
      await startLevel3Routine(context, 3, isGold: isGold);
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