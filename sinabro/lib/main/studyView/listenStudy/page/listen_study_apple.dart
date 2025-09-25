import 'package:flutter/material.dart';
import 'level3/data/routine_data.dart';
import 'level3/model/routine_content.dart';
import 'level3/intro_topic_page.dart';
import 'level3/main_topic_page.dart';
import 'level3/routine_flow.dart'; // ✅ startRoutineFlow, startStoryFlow 분리해둔 파일

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
    Offset(0.16, 0.28),
    Offset(0.26, 0.28),
    Offset(0.14, 0.42),
    Offset(0.25, 0.43),
    Offset(0.28, 0.36),

    // 두 번째 나무 (가운데) 5개
    Offset(0.46, 0.28),
    Offset(0.56, 0.28),
    Offset(0.44, 0.42),
    Offset(0.55, 0.43),
    Offset(0.59, 0.36),

    // 세 번째 나무 (오른쪽) 4개
    Offset(0.76, 0.28), // 10 : 1번 루틴
    Offset(0.86, 0.28), // 11 : 2번 루틴
    Offset(0.75, 0.42), // 12 : 3번 루틴
    Offset(0.87, 0.42), // 13 : 4번 루틴
  ];

  // ✅ 루틴 선택
  void _startRoutine(BuildContext context, int routineIndex) {
    final routine = routineContents
        .where((r) => r.id.startsWith("${routineIndex + 1}-"))
        .toList();

    if (routine.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntroTopicPage(
          title: "째깍째깍... 지금 뭐하는 시간이지?",
          imagePath: "assets/img/contents/studyListen/level3/clock.png",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainTopicPage(
                  topicImagePath: routine.first.topicImagePath,
                  title: routine.first.topic,
                  onTap: () {
                    // ✅ 실제 실행은 routine_flow.dart 에 정의
                    startRoutineFlow(context, routine, 0);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _tap(int index) async {
    if (status[index] == ContentStatus.locked) return;

    switch (index) {
      // 3번 나무 (10~13) → 루틴 실행
      case 10:
        _startRoutine(context, 0);
        break;
      case 11:
        _startRoutine(context, 1);
        break;
      case 12:
        _startRoutine(context, 2);
        break;
      case 13:
        _startRoutine(context, 3);
        break;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final appleSize = size.width * 0.07;

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
                fontSize: widget.size * 0.4,
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
