import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/childView/page/sticker_book.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart';

class GetStickerPage extends StatefulWidget {
  final String stageKey;
  final int index;
  final VoidCallback onComplete;

  const GetStickerPage({
    super.key,
    required this.stageKey,
    required this.index,
    required this.onComplete,
  });

  @override
  State<GetStickerPage> createState() => _GetStickerPageState();
}

class _GetStickerPageState extends State<GetStickerPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;

  bool _showDark = true;
  bool _showSticker = false;
  bool _showButtons = false;

  String get stickerName => '${widget.stageKey}${widget.index + 1}';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _showDark = true);

    // 두구두구 유지
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showDark = false;
      _showSticker = true;
    });
    _shakeController.stop();
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _showButtons = true);

    await Future.delayed(const Duration(milliseconds: 800));
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkImage =
        'assets/img/contents/stickerBook/stickers/${stickerName}_deactivation.png';
    final stickerImage =
        'assets/img/contents/stickerBook/stickers/${stickerName}.png';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🎆 폭죽 (맨 아래) — 이미지 뒤에서 터지지 않도록 순서 조정
          if (_showButtons)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    final random = Random();
                    final particles = List.generate(10, (i) {
                      final angle = random.nextDouble() * 2 * pi;
                      final radius =
                          Curves.easeOut.transform(_confettiController.value) *
                              (150 + random.nextDouble() * 100);
                      final dx = cos(angle) * radius;
                      final dy = sin(angle) * radius;

                      final colorList = [
                        const Color(0xFFFFD54F),
                        const Color(0xFFFFB74D),
                        const Color(0xFFFFF3E0),
                        const Color(0xFFFFA000),
                        const Color(0xFFFFE082),
                      ];

                      return Positioned(
                        top: MediaQuery.of(context).size.height / 2 + dy - 8,
                        left: MediaQuery.of(context).size.width / 2 + dx - 8,
                        child: Opacity(
                          opacity: 1 - _confettiController.value,
                          child: Icon(
                            Icons.circle,
                            color: colorList[i % colorList.length],
                            size: 8 + random.nextDouble() * 10,
                          ),
                        ),
                      );
                    });
                    return Stack(children: particles);
                  },
                ),
              ),
            ),

          // 🔥 두구두구 (deactivation)
          if (_showDark)
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset =
                    sin(_shakeController.value * pi * 8) * 8; // 좌우 진동
                return Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(offset, 0),
                    child: Image.asset(
                      darkImage,
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

          // ✨ 스티커 (기본 이미지)
          if (_showSticker)
            FadeTransition(
              opacity: _fadeController,
              child: Center(
                child: Image.asset(
                  stickerImage,
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // 🧡 텍스트 + 버튼 (맨 위)
          if (_showButtons)
            Positioned(
              bottom: 120,
              child: Column(
                children: [
                  const Text(
                    '🎉 새로운 스티커를 얻었어요!',
                    style: TextStyle(
                      color: Color(0xFF663300),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(blurRadius: 3, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LobbyChildScreen(
                                childId: 'test_child_id',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB46A32),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '🏠 홈으로',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ScaleTransition(
                        scale: _pulseController,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StickerBookPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            '📘 도감으로 이동',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
