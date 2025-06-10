import 'package:flutter/material.dart';

class SoundButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SoundButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Color(0x00FFFFFF), // ✅ 투명한 흰색 (약 30%)
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }
}
