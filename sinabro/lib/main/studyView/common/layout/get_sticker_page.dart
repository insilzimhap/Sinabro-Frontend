import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/childView/page/sticker_book.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart';
import 'package:sinabro/main/childView/data/sticker_image_map.dart';

class GetStickerPage extends StatefulWidget {
  final String stageKey;
  final int index;
  final VoidCallback onComplete;

  final String childId; 
  final String fruitId;

  const GetStickerPage({
    super.key,
    required this.stageKey,
    required this.index,
    required this.onComplete,
    required this.childId,   // ✅ 필수 추가
    required this.fruitId,  // ✅ 필수 추가
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

  //String get stickerName => '${widget.stageKey}${widget.index + 1}';

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

  /// 🔑 fruitId (FR_LS_001)를 StickerKey (ST_LS_001)로 변환
  String _convertFruitToStickerKey(String fruitId) {
    if (!fruitId.startsWith('FR_')) return fruitId;
    return fruitId.replaceFirst('FR_', 'ST_');
  }

  @override
  Widget build(BuildContext context) {
    // 1. fruitId를 StickerKey로 변환 (FR_LS_001 -> ST_LS_001)
    final stickerKey = _convertFruitToStickerKey(widget.fruitId);
    // 2. stickerImageMap에서 경로 찾기
    final StickerImageEntry? entry = stickerImageMap[stickerKey];

    // 3. 이미지 경로 설정 (매핑 실패 시 default 경로 사용)
    final darkImage = entry?.inactive ??
        'assets/img/contents/stickerBook/stickers/default_dark.png';
    final stickerImage = entry?.active ??
        'assets/img/contents/stickerBook/stickers/default.png';

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
                  stickerImage, //매핑된 활성 이미지 사용
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
                      //홈으로 이동 버튼(chilId전달)
                      ElevatedButton(
                        onPressed: () {
                          // onComplete() 호출 시 StickerRewardHandler가 로비로 이동 처리 -> 나무로 수정
                          widget.onComplete(); 
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
                          '🌳 나무로',
                          //'🏠 홈으로',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // 도감으로 이동 버튼 (childId 전달)
                      ScaleTransition(
                        scale: _pulseController,
                        child: ElevatedButton(
                          onPressed: () {
                            // 도감으로 이동 후 onComplete 호출
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StickerBookPage(
                                  childId: widget.childId,
                                ),
                              ),
                            ).then((_) => widget.onComplete()); // 이동 후 콜백 호출
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
