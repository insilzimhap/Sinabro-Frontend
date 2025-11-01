/*
 * ------------------------------------------------------------------------------
 * [듣기 게임 - 챕터 선택 페이지]
 * ------------------------------------------------------------------------------
 */
import 'package:flutter/material.dart';

// 각 레벨의 Flow
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_flow.dart';

// 각 레벨 인트로
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_intro_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_intro_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_intro_page.dart';

class GameListenChapterScreen extends StatefulWidget {
  final String childId;

  const GameListenChapterScreen({
    super.key,
    required this.childId,
  });

  @override
  State<GameListenChapterScreen> createState() =>
      _GameListenChapterScreenState();
}

class _GameListenChapterScreenState extends State<GameListenChapterScreen>
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
          // 🎋 레벨(챕터) 1
          _buildChapterIcon(
            context,
            size,
            left: size.width * 0.08,
            top: size.height * 0.28,
            image: 'assets/img/contents/gameListen/chapter/level1.png',
            targetOffset: Offset(size.width * 0.18, size.height * 0.58),
            nextPage: Level1IntroPage(
              onNext: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Level1Flow()),
              ),
            ),
          ),

          // 🎋 레벨(챕터) 2
          _buildChapterIcon(
            context,
            size,
            left: size.width * 0.38,
            top: size.height * 0.28,
            image: 'assets/img/contents/gameListen/chapter/level2.png',
            targetOffset: Offset(size.width * 0.48, size.height * 0.58),
            nextPage: Level2IntroPage(
              onNext: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Level2Flow()),
              ),
            ),
          ),

          // 🎋 레벨(챕터) 3
          _buildChapterIcon(
            context,
            size,
            right: size.width * 0.08,
            top: size.height * 0.28,
            image: 'assets/img/contents/gameListen/chapter/level3.png',
            targetOffset: Offset(size.width * 0.78, size.height * 0.58),
            nextPage: Level3IntroPage(
              onNext: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Level3Flow()),
              ),
            ),
          ),

          // 🐣 캐릭터
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            left: _charPosition.dx,
            top: _charPosition.dy,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutBack,
                  ),
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

  Widget _buildChapterIcon(
    BuildContext context,
    Size size, {
    double? left,
    double? right,
    required double top,
    required String image,
    required Offset targetOffset,
    required Widget nextPage,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: GestureDetector(
        onTap: () => _moveCharacterTo(targetOffset, nextPage),
        child: Image.asset(image, width: size.width * 0.25),
      ),
    );
  }
}
