import 'package:flutter/material.dart';
import 'dart:math' as math;

// ✅ 각 레벨의 테마 선택 페이지 import
import '../listenGame/page/level1/level1_theme_select.dart';
import '../listenGame/page/level2/level2_theme_select.dart';
import '../listenGame/page/level3/level3_theme_select.dart';

class ListenGameChapterPage extends StatefulWidget {
  const ListenGameChapterPage({super.key});

  @override
  State<ListenGameChapterPage> createState() => _ListenGameChapterPageState();
}

class _ListenGameChapterPageState extends State<ListenGameChapterPage>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _cloudController;
  late AnimationController _jumpController;
  late AnimationController _footFadeController;

  double _characterX = 0.1;
  double _characterY = 0.8;
  bool _isMoving = false;
  String _charImage = 'assets/img/character/stand.png';

  final List<Offset> _footsteps = [];

  final List<Offset> stagePositions = const [
    Offset(0.20, 0.80),
    Offset(0.55, 0.45),
    Offset(0.85, 0.70),
  ];

  final List<String> stageImages = const [
    'assets/img/contents/gameListen/chapter/house_1.png',
    'assets/img/contents/gameListen/chapter/house_2.png',
    'assets/img/contents/gameListen/chapter/house_3.png',
  ];

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _footFadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _cloudController.dispose();
    _jumpController.dispose();
    _footFadeController.dispose();
    super.dispose();
  }

  Future<void> _moveToStage(int stageIndex) async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _charImage = 'assets/img/character/move.png';
    });

    final start = Offset(_characterX, _characterY);
    final end = stagePositions[stageIndex];
    final animation = Tween(begin: start, end: end).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );

    _moveController.reset();
    _jumpController.repeat(reverse: true);

    animation.addListener(() {
      setState(() {
        _characterX = animation.value.dx;
        _characterY = animation.value.dy;

        // 발자국 기록 (이전 위치와 간격 두기)
        if (_footsteps.isEmpty ||
            (animation.value.dx - _footsteps.last.dx).abs() > 0.08) {
          _footsteps.add(animation.value);
          _footFadeController
            ..reset()
            ..forward();
        }
      });
    });

    await _moveController.forward();

    _jumpController.stop();
    setState(() {
      _charImage = 'assets/img/character/stand.png';
      _isMoving = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _getThemeSelectPage(stageIndex)),
      );
    }
  }

  /// 🎯 각 스테이지 → Theme Select 페이지 매핑
  Widget _getThemeSelectPage(int stageIndex) {
    switch (stageIndex) {
      case 0:
        return const Level1ThemeSelectPage();
      case 1:
        return const Level2ThemeSelectPage();
      case 2:
        return const Level3ThemeSelectPage();
      default:
        return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 배경
          Positioned.fill(
            child: Image.asset(
              'assets/img/contents/gameListen/chapter/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ☁️ 구름 애니메이션
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              final dx = math.sin(_cloudController.value * 2 * math.pi) * 50;
              return Positioned(
                top: 60,
                left: size.width / 2 - 100 + dx,
                child: Image.asset(
                  'assets/img/contents/gameListen/chapter/cloud.png',
                  width: 220,
                ),
              );
            },
          ),

          // 🌈 언덕길 + 발자국 페이드
          AnimatedBuilder(
            animation: _footFadeController,
            builder: (context, child) {
              final opacity =
                  1.0 - _footFadeController.value.clamp(0.0, 1.0); // 페이드 아웃
              return Positioned.fill(
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: _PathPainter(
                      footsteps: _footsteps,
                      footOpacity: opacity,
                    ),
                  ),
                ),
              );
            },
          ),

          // 🏠 스테이지
          for (int i = 0; i < stagePositions.length; i++)
            Positioned(
              left: stagePositions[i].dx * size.width - 50,
              top: stagePositions[i].dy * size.height - 100,
              child: GestureDetector(
                onTap: () => _moveToStage(i),
                child: Image.asset(
                  stageImages[i],
                  width: 110,
                ),
              ),
            ),

          // 🧍 캐릭터 (점프)
          AnimatedBuilder(
            animation: _jumpController,
            builder: (context, child) {
              final jumpOffset =
                  math.sin(_jumpController.value * math.pi) * 20;
              return Positioned(
                left: _characterX * size.width - 40,
                top: _characterY * size.height - 80 - jumpOffset,
                child: Image.asset(
                  _charImage,
                  width: 100,
                ),
              );
            },
          ),

          // 🚩 시작 깃발
          Positioned(
            left: size.width * 0.05,
            top: size.height * 0.75,
            child: Image.asset(
              'assets/img/contents/gameListen/chapter/flag_start.png',
              width: 80,
            ),
          ),

          // ⬅️ 뒤로가기 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 언덕길 PathPainter (+ 발자국 페이드)
class _PathPainter extends CustomPainter {
  final List<Offset> footsteps;
  final double footOpacity;
  _PathPainter({this.footsteps = const [], this.footOpacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = const Color(0x335C8A47)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final paint = Paint()
      ..color = const Color(0xFF7BC47F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.95,
          size.width * 0.45, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.30,
          size.width * 0.90, size.height * 0.75);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // ✨ 발자국 페이드아웃
    final footPaint = Paint()
      ..color = Color.fromRGBO(85, 68, 34, (0.5 * footOpacity).clamp(0, 1))
      ..style = PaintingStyle.fill;

    for (final step in footsteps) {
      final dx = step.dx * size.width;
      final dy = step.dy * size.height;
      canvas.drawCircle(Offset(dx, dy + 8), 4, footPaint);
    }
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) =>
      oldDelegate.footsteps != footsteps ||
      oldDelegate.footOpacity != footOpacity;
}
