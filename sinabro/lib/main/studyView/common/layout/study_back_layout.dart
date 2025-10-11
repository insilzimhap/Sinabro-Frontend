import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/widget/rounded_back_icon_button.dart';

class StudyBackLayout extends StatelessWidget {
  const StudyBackLayout({
    super.key,
    required this.body,
    this.prevRouteName,
    this.onBack,
    this.baseWidth = 2000, // Figma 기준
    this.baseHeight = 1200, // Figma 기준
    this.btnLeft = 53,
    this.btnTop = 45,
    this.btnSize = 69,
    this.btnIconSize = 28,
  }) : assert(prevRouteName != null || onBack != null);

  final Widget body;
  final String? prevRouteName;
  final VoidCallback? onBack;

  // Figma 기준값
  final double baseWidth;
  final double baseHeight;
  final double btnLeft;
  final double btnTop;
  final double btnSize;
  final double btnIconSize;

  void _goBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      // pushReplacementNamed 대신, 정상적인 pop을 호출해야 합니다.
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaleW = size.width / baseWidth;
    final scaleH = size.height / baseHeight;
    final scale = scaleW < scaleH ? scaleW : scaleH;
    final dx = (size.width - baseWidth * scale) / 2;
    final dy = (size.height - baseHeight * scale) / 2;

    final left = dx + btnLeft * scale;
    final top = dy + btnTop * scale;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: body),
          // Figma 좌표계에 맞춰 정확 포지셔닝
          Positioned(
            left: left,
            top: top,
            width: btnSize * scale,
            height: btnSize * scale,
            child: RoundedBackIconButton(
              size: btnSize * scale,
              iconSize: btnIconSize * scale,
              onPressed: () => _goBack(context),
            ),
          ),
        ],
      ),
    );
  }
}
