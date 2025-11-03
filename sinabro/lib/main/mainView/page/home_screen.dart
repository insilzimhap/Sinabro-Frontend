import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/widget/main_to_userSelect_btn.dart';
import 'package:sinabro/main/mainView/page/user_select_screen.dart'; // ✅ UserSelectScreen 경로 맞게 수정해 주세요


class CloudAnimationScreen extends StatefulWidget {
  const CloudAnimationScreen({super.key});

  @override
  State<CloudAnimationScreen> createState() => _CloudAnimationScreenState();
}

class _CloudAnimationScreenState extends State<CloudAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  final List<String> _characterImages = [
    'assets/img/pageMain/tosoom.png',
    'assets/img/pageMain/gomjae.png',
    'assets/img/pageMain/ojjang.png',
    'assets/img/pageMain/meongji.png',
    'assets/img/pageMain/gonyam.png',
  ];

  final List<String> _cloudImages = [
    'assets/img/pageMain/cloud1.png',
    'assets/img/pageMain/cloud2.png',
  ];

  final List<_FloatingItem> _characters = [];
  final List<_FloatingItem> _clouds = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();

    for (int i = 0; i < 5; i++) {
      _characters.add(_createCharacter(i));
    }
    for (int i = 0; i < 6; i++) {
      _clouds.add(_createCloud());
    }
  }

  _FloatingItem _createCharacter(int index) {
    return _FloatingItem(
      image: _characterImages[index],
      x: _random.nextDouble(),
      y: 1.0 + _random.nextDouble(),
      speed: 0.8 + _random.nextDouble() * 1.2,
      scale: 0.6 + _random.nextDouble() * 0.3,
      rotation:
          (_random.nextDouble() * pi / 15) * (_random.nextBool() ? 1 : -1),
    );
  }

  _FloatingItem _createCloud() {
    return _FloatingItem(
      image: _cloudImages[_random.nextInt(_cloudImages.length)],
      x: _random.nextDouble(),
      y: -_random.nextDouble(),
      speed: 0.1 + _random.nextDouble() * 0.12,
      scale: 0.8 + _random.nextDouble() * 0.4,
      opacity: 0.8 + _random.nextDouble() * 0.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCharacter(Size size, int index) {
    final item = _characters[index];
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        double progress = (_controller.value * item.speed) % 1.0;
        double yOffset = size.height * (1.2 - progress * 1.8);
        double xOffset =
            size.width * item.x + sin((_controller.value * 2 * pi) + index) * 30;

        if (yOffset < -150) {
          _characters[index] = _createCharacter(index);
        }

        double wobbleScale =
            item.scale + sin(_controller.value * 2 * pi * 1.5) * 0.03;

        return Positioned(
          left: xOffset,
          top: yOffset,
          child: Transform.rotate(
            angle: item.rotation * sin(_controller.value * 2 * pi * item.speed),
            child: Transform.scale(scale: wobbleScale, child: child),
          ),
        );
      },
      child: Image.asset(item.image, width: size.width * 0.25),
    );
  }

  Widget _buildCloud(Size size, int index) {
    final item = _clouds[index];
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        double progress = (_controller.value * item.speed) % 1.0;
        double yOffset = size.height * (item.y + progress * 1.8);
        double xOffset =
            size.width * item.x + sin((_controller.value * 2 * pi) + index) * 25;

        if (yOffset > size.height + 100) {
          _clouds[index] = _createCloud();
        }

        return Positioned(
          left: xOffset,
          top: yOffset,
          child: Opacity(
            opacity: item.opacity,
            child: Transform.scale(scale: item.scale, child: child),
          ),
        );
      },
      child: Image.asset(item.image, width: size.width * 0.55),
    );
  }

  // ✅ 로고 + 시작하기 버튼
  Widget _buildLogoAndButton(Size size) {
    return Stack(
      children: [
        Positioned(
          bottom: 30,
          right: 25,
          child: Column(
            children: [
              Image.asset(
                'assets/img/logo/sinabro_logo.png',
                width: size.width * 0.32,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateWithCircularReveal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DA9F0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  "시작하기",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _navigateWithCircularReveal(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width * 0.9, size.height * 0.9); // 우하단 기준
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, __, ___) => const UserSelectScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return ClipPath(
            clipper: _CircularRevealClipper(
              fraction: animation.value,
              center: center,
              maxRadius: maxRadius,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF7DB8EB),
      body: Stack(
        children: [
          ...List.generate(_clouds.length, (i) => _buildCloud(size, i)),
          ...List.generate(_characters.length, (i) => _buildCharacter(size, i)),
          _buildLogoAndButton(size),
        ],
      ),
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;
  final double maxRadius;

  _CircularRevealClipper({
    required this.fraction,
    required this.center,
    required this.maxRadius,
  });

  @override
  Path getClip(Size size) {
    final radius = maxRadius * fraction;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _FloatingItem {
  String image;
  double x;
  double y;
  double speed;
  double scale;
  double rotation;
  double opacity;

  _FloatingItem({
    required this.image,
    required this.x,
    required this.y,
    required this.speed,
    required this.scale,
    this.rotation = 0,
    this.opacity = 1,
  });
}
