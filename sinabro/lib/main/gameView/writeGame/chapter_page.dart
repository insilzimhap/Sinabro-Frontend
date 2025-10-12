import 'package:flutter/material.dart';
import 'dart:math' as math;

class ListenGameChapterPage extends StatefulWidget {
  const ListenGameChapterPage({super.key});

  @override
  State<ListenGameChapterPage> createState() => _ListenGameChapterPageState();
}

class _ListenGameChapterPageState extends State<ListenGameChapterPage>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _cloudController;
  double _characterX = 0.1;
  double _characterY = 0.75;
  bool _isMoving = false;
  String _charImage = 'assets/img/chapter/stand(-).png';

  final List<Offset> stagePositions = const [
    Offset(0.2, 0.75), // 시작점
    Offset(0.5, 0.35), // 1단계
    Offset(0.75, 0.7), // 2단계
  ];

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  Future<void> _moveToStage(int stageIndex) async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _charImage = 'assets/img/chapter/move.png';
    });

    final start = Offset(_characterX, _characterY);
    final end = stagePositions[stageIndex];

    final animation = Tween(begin: start, end: end).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );

    _moveController.reset();
    _moveController.forward();

    animation.addListener(() {
      setState(() {
        _characterX = animation.value.dx;
        _characterY = animation.value.dy;
      });
    });

    await _moveController.forward();

    // 도착 후 멈춤 상태
    setState(() {
      _charImage = 'assets/img/chapter/stand.png';
      _isMoving = false;
    });

    // 2초 후 해당 챕터로 이동
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _getLevelPage(stageIndex),
        ),
      );
    }
  }

  Widget _getLevelPage(int stageIndex) {
    switch (stageIndex) {
      case 0:
        return const Placeholder(); // Level 1 page
      case 1:
        return const Placeholder(); // Level 2 page
      case 2:
        return const Placeholder(); // Level 3 page
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
          // 🌤️ 배경
          Positioned.fill(
            child: Image.asset(
              'assets/img/chapter/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ☁️ 구름 (살짝 움직이기)
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              final dx = math.sin(_cloudController.value * 2 * math.pi) * 50;
              return Positioned(
                top: 50,
                left: size.width / 2 - 100 + dx,
                child: Image.asset(
                  'assets/img/chapter/cloud.png',
                  width: 200,
                ),
              );
            },
          ),

          // 🌈 곡선 길(선택지 경로) - CustomPainter로도 가능
          Positioned.fill(
            child: CustomPaint(
              painter: _PathPainter(),
            ),
          ),

          // 📍 스테이지 버튼
          for (int i = 0; i < stagePositions.length; i++)
            Positioned(
              left: stagePositions[i].dx * size.width - 40,
              top: stagePositions[i].dy * size.height - 40,
              child: GestureDetector(
                onTap: () => _moveToStage(i),
                child: Image.asset(
                  'assets/img/chapter/stage_${i + 1}.png',
                  width: 80,
                ),
              ),
            ),

          // 🧍‍♂️ 캐릭터 (이동 중 or 대기)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _characterX * size.width - 30,
            top: _characterY * size.height - 60,
            child: Image.asset(
              _charImage,
              width: 100,
            ),
          ),

          // 🔙 뒤로가기
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🟢 곡선 경로 그림 (샘플)
class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5BB76E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.05, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
        size.width * 0.45, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.2,
        size.width * 0.9, size.height * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
