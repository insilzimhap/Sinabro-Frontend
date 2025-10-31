import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main3.dart';

class GameWriteChapterScreen extends StatefulWidget {
  final String childId; // ✅ 자녀 ID 추가

  const GameWriteChapterScreen({
    super.key,
    required this.childId,
  });

  @override
  State<GameWriteChapterScreen> createState() => _GameWriteChapterScreenState();
}

class _GameWriteChapterScreenState extends State<GameWriteChapterScreen>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  Offset _charPosition = const Offset(60, 520);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _moveCharacterTo(Offset target, Widget nextPage) async {
    await _controller.reverse(from: 1);
    setState(() => _isVisible = false);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _charPosition = target);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isVisible = true);
    await _controller.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      body: Stack(
        children: [
          // 🏝️ 챕터 섬 1
          Positioned(
            left: size.width * 0.08,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.18, size.height * 0.58),
                WriteGameMainPage(childId: widget.childId),
              ),
              child: Image.asset(
                'assets/img/contents/gameWrite/chapter/level1.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // 🏝️ 챕터 섬 2
          Positioned(
            left: size.width * 0.38,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.48, size.height * 0.58),
                WriteGameMain2Page(childId: widget.childId),
              ),
              child: Image.asset(
                'assets/img/contents/gameWrite/chapter/level2.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // 🏝️ 챕터 섬 3
          Positioned(
            right: size.width * 0.08,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.78, size.height * 0.58),
                WriteGameMain3Page(childId: widget.childId),
              ),
              child: Image.asset(
                'assets/img/contents/gameWrite/chapter/level3.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // 🎈 캐릭터 (토숨)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            left: _charPosition.dx,
            top: _charPosition.dy,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                ),
                child: Image.asset(
                  'assets/img/pageMain/tosoom.png',
                  width: size.width * 0.13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
