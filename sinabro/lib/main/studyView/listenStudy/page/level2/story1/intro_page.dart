import 'package:flutter/material.dart';

class Level2IntroPage extends StatefulWidget {
  final VoidCallback onFinished; // ✅ 콜백 추가
  const Level2IntroPage({super.key, required this.onFinished});

  @override
  State<Level2IntroPage> createState() => _Level2IntroPageState();
}

class _Level2IntroPageState extends State<Level2IntroPage>
    with SingleTickerProviderStateMixin {
  final List<bool> _dustVisible = [true, true, true];
  bool _allCleared = false;

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearDust(int index) {
    setState(() => _dustVisible[index] = false);

    if (_dustVisible.every((v) => v == false)) {
      setState(() => _allCleared = true);
      _controller.forward();

      Future.delayed(const Duration(seconds: 1), widget.onFinished); // ✅ 콜백 실행
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "어라? 먼지 쌓인 무언가를 발견했어요\n먼지를 털어서 확인해볼까?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder:
                        (context, child) => Transform.scale(
                          scale: _scale.value,
                          child: Opacity(
                            opacity: _opacity.value,
                            child: Image.asset(
                              "assets/img/contents/studyListen/level2/family_frame.png",
                              height: 260,
                            ),
                          ),
                        ),
                  ),
                  for (int i = 0; i < _dustVisible.length; i++)
                    if (_dustVisible[i])
                      Positioned(
                        top: [40, 100, 180][i].toDouble(),
                        left: [60, 180, 100][i].toDouble(),
                        child: GestureDetector(
                          onTap: () => _clearDust(i),
                          child: AnimatedOpacity(
                            opacity: _dustVisible[i] ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Image.asset(
                              "assets/img/contents/studyListen/level2/dust.png",
                              height: 80,
                            ),
                          ),
                        ),
                      ),
                  if (_allCleared)
                    FadeTransition(
                      opacity: _opacity,
                      child: const Text(
                        "짜잔!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
