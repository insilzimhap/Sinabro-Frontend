/*
 * ------------------------------------------------------------------------------
 * [듣기 게임 - 챕터 선택 페이지]
 *
 * - 듣기 게임의 모든 챕터(=레벨, 나무)를 표시함
 * ------------------------------------------------------------------------------
 */
import 'package:flutter/material.dart';

// 레벨 1
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_intro_page.dart';

// 레벨 2
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_intro_page.dart';

// 레벨 3
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_intro_page.dart';

class GameListenChapterScreen extends StatefulWidget {
  final String childId; // ✅ childId 필드 추가

  const GameListenChapterScreen({
    super.key,
    required this.childId, // ✅ 생성자에 required 추가
  });

  @override
  State<GameListenChapterScreen> createState() => _GameListenChapterScreenState();
}

class _GameListenChapterScreenState extends State<GameListenChapterScreen>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  Offset _charPosition = const Offset(60, 520);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
          ..forward();
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
          // 🏝️ 챕터 1
          Positioned(
            left: size.width * 0.08,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.18, size.height * 0.58),
                Level1IntroPage(
                  onNext: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Level1Flow(),
                    ),
                  ),
                ),
              ),
              child: Image.asset(
                'assets/img/contents/gameListen/chapter/level1.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // 🏝️ 챕터 2
          Positioned(
            left: size.width * 0.38,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.48, size.height * 0.58),
                Level2IntroPage(
                  onNext: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Level2Flow(),
                    ),
                  ),
                ),
              ),
              child: Image.asset(
                'assets/img/contents/gameListen/chapter/level2.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // 🏝️ 챕터 3
          Positioned(
            right: size.width * 0.08,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.78, size.height * 0.58),
                Level3IntroPage(
                  onNext: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Level3Flow(),
                    ),
                  ),
                ),
              ),
              child: Image.asset(
                'assets/img/contents/gameListen/chapter/level3.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // 🎈 캐릭터
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
