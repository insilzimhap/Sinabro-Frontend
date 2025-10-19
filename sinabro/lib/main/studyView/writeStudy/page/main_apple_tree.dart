// lib/main/studyView/writeStudy/page/main_apple_tree.dart
import 'package:flutter/material.dart';

// ⭐ 별잇기 — 프리픽스 제거, show만 사용
import 'package:sinabro/main/studyView/writeStudy/page/level1/star_write.dart'
    show ConstellationDrawPage;

// 🍓🍇🥝 잼
import 'package:sinabro/main/studyView/writeStudy/page/level1/jam_write.dart'
    as jam;

// ✈️ 비행기
import 'package:sinabro/main/studyView/writeStudy/page/level1/plane_write.dart'
    as plane;

// 🍭 달고나/캔디
import 'package:sinabro/main/studyView/writeStudy/page/level1/candy_write.dart';

// ─ level2
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_1.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_2.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_3.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_4.dart';

// ─ level3
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_1.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_2.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_3.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_4.dart'
    as w34
    show Writing3_4_IntroPage;

enum ContentStatus { locked, available, done }

class AppleGarden extends StatefulWidget {
  final String childId;
  const AppleGarden({super.key, required this.childId});

  @override
  State<AppleGarden> createState() => _AppleGardenState();
}

class _AppleGardenState extends State<AppleGarden> {
  // 모든 사과 사용 가능(임시)
  final List<ContentStatus> status = List.generate(
    12,
    (i) => ContentStatus.available,
  );

  // 배경 기준 비율 좌표
  final List<Offset> spots = const [
    // Tree 1 (왼쪽)
    Offset(0.16, 0.36), // 0:1 (별잇기)
    Offset(0.26, 0.36), // 1:2 (잼 플로우)
    Offset(0.17, 0.50), // 2:3 (비행기)
    Offset(0.28, 0.49), // 3:4 (gold)
    // Tree 2 (가운데)
    Offset(0.47, 0.36), // 4:1
    Offset(0.57, 0.36), // 5:2
    Offset(0.47, 0.50), // 6:3
    Offset(0.58, 0.49), // 7:4 (gold)
    // Tree 3 (오른쪽)
    Offset(0.78, 0.36), // 8:1
    Offset(0.88, 0.36), // 9:2
    Offset(0.78, 0.50), // 10:3
    Offset(0.89, 0.49), // 11:4 (gold)
  ];

  Future<void> _tap(int index) async {
    if (status[index] == ContentStatus.locked) return;

    late final Widget page;
    switch (index) {
      case 0: // ⭐ 별잇기
        page = ConstellationDrawPage();
        break;

      case 1: // 🍓 잼
        page = jam.JamSpreadFlowPage();
        break;

      case 2: // ✈️ 비행기
        page = plane.PlaneWritePage();
        break;

      case 3: // 🍭 달고나(골드)
        page = CandyWritePage(childId: widget.childId);
        break;

      // level2
      case 4:
        page = Writing21Page(childId: widget.childId);
        break;
      case 5:
        page = Writing22Page(childId: widget.childId);
        break;
      case 6:
        page = Writing23Page(childId: widget.childId);
        break;
      case 7:
        page = Writing24Page(childId: widget.childId);
        break;

      // level3
      case 8:
        page = Writing3_IntroPage(childId: widget.childId);
        break;
      case 9:
        page = Writing3_2_IntroPage(childId: widget.childId);
        break;
      case 10:
        page = Writing3_3_IntroPage(childId: widget.childId);
        break;
      case 11:
        page = w34.Writing3_4_IntroPage(childId: widget.childId);
        break;

      default:
        return;
    }

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final dpr = MediaQuery.of(context).devicePixelRatio;
          final appleSize = size.width * 0.065;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 배경
              Positioned.fill(
                child: Image(
                  image: ResizeImage(
                    const AssetImage(
                      'assets/img/contents/studyWrite/apple_tree.png',
                    ),
                    width: (size.width * dpr).clamp(0, 4096).toInt(),
                    height: (size.height * dpr).clamp(0, 4096).toInt(),
                  ),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),

              // 사과들
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
    final isGold = (widget.index % 4) == 3; // 4번째 사과
    final asset =
        isGold
            ? 'assets/img/contents/studyWrite/gold_apple.png'
            : 'assets/img/contents/studyWrite/apple.png';

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
              '${(widget.index % 4) + 1}',
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
            if (isGold)
              Positioned(
                right: -widget.size * 0.12,
                bottom: -widget.size * 0.10,
                child: Icon(
                  Icons.auto_awesome,
                  size: widget.size * 0.35,
                  color: Colors.amberAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
