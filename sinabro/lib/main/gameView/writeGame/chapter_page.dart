import 'package:flutter/material.dart';
// import 'package:sinabro/main/gameView/writeGame/page/level1/level1_flow.dart';

/// ✏️ 쓰기 게임 챕터 선택 화면
/// - 챕터 1~3 섬 선택 가능
/// - 각 섬을 누르면 캐릭터가 이동하며 다음 단계로 전환
class GameWriteChapterScreen extends StatefulWidget {
  const GameWriteChapterScreen({super.key});

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
    )..forward(); // 첫 등장 시 애니메이션 실행
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 캐릭터 이동 + 페이지 전환 로직
  Future<void> _moveCharacterTo(Offset target, Widget nextPage) async {
    // 1️⃣ 캐릭터 사라짐 (축소 + fade out)
    await _controller.reverse(from: 1);
    setState(() => _isVisible = false);

    // 2️⃣ 캐릭터 이동
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _charPosition = target);

    // 3️⃣ 캐릭터 다시 나타남 (확대 + fade in)
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isVisible = true);
    await _controller.forward(from: 0);

    // 4️⃣ 페이지 이동
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
          // ────────────────────────────────
          // 🏝️ 챕터 섬 1
          Positioned(
            left: size.width * 0.08,
            top: size.height * 0.28,
            child: GestureDetector(
              onTap: () => _moveCharacterTo(
                Offset(size.width * 0.18, size.height * 0.58),
                const _DummyLevelPage(level: 2), // TODO: Level1교체 예정
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
                const _DummyLevelPage(level: 2), // TODO: Level2 교체 예정
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
                const _DummyLevelPage(level: 3), // TODO: Level3 교체 예정
              ),
              child: Image.asset(
                'assets/img/contents/gameWrite/chapter/level3.png',
                width: size.width * 0.25,
              ),
            ),
          ),

          // ────────────────────────────────
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

          // ────────────────────────────────
          // 📘 상단 타이틀
          Positioned(
            top: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '쓰기 챕터 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C3B1E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 임시 페이지 (레벨별로 연결될 페이지 자리)
class _DummyLevelPage extends StatelessWidget {
  final int level;
  const _DummyLevelPage({required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        title: Text('Write Level $level'),
        backgroundColor: const Color(0xFFFFE0B2),
      ),
      body: Center(
        child: Text(
          'Write Level $level Page!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3B1E),
          ),
        ),
      ),
    );
  }
}
