import 'package:flutter/material.dart';

/// 공통 뒤로가기 버튼
/// =================
/// - 기본 크기: 69x69 (Figma 기준)
/// - 기본 배경: #E0D1BF
/// - 아이콘 색상: #5C534A
/// - onPressed 지정 안 하면 Navigator.pop() 실행
class RoundedBackIconButton extends StatelessWidget {
  const RoundedBackIconButton({
    super.key,
    this.size = 69,
    this.iconSize = 28,
    this.backgroundColor = const Color(0xFFE0D1BF),
    this.iconColor = const Color(0xFF5C534A),
    this.onPressed,
  });

  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        iconSize: iconSize,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        tooltip: '이전으로',
      ),
    );
  }
}
