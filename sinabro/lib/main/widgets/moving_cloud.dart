import 'package:flutter/material.dart';

class MovingCloud extends StatelessWidget {
  final Animation<double> animation;
  final double topPosition;
  final double screenWidth;
  final String imagePath;
  final double width;

  const MovingCloud({
    Key? key,
    required this.animation,
    required this.topPosition,
    required this.screenWidth,
    required this.imagePath,
    this.width = 1000, // ✅ 기본값 1000으로!
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final position = animation.value * screenWidth;

        return Stack(
          children: [
            // 첫 번째 구름
            Positioned(top: topPosition, left: position, child: child!),
            // 두 번째 구름 (빈틈 없이 이어지도록!)
            Positioned(
              top: topPosition,
              left: position + screenWidth,
              child: child,
            ),
          ],
        );
      },
      child: Image.asset(imagePath, width: width),
    );
  }
}
