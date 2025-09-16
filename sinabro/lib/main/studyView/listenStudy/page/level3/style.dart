import 'package:flutter/material.dart';

class AppStyle {
  // 전체 레이아웃 사이즈
  static const double screenWidth = 2000;
  static const double screenHeight = 1200;

  // 색상
  static const Color background = Color(0xFFFFF3E5); // 배경
  static const Color text = Color(0xFF626262);       // 텍스트
  static const Color accent = Color(0xFFE1D1C0);     // 멍지
  static const Color strongText = Color(0xFF7C685F); // 강조 텍스트

  // 텍스트 스타일
  static const TextStyle title = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w500,
    color: text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 32,
    color: text,
  );

  // 버튼 스타일
  static ButtonStyle backButton = IconButton.styleFrom(
    backgroundColor: accent,
    iconSize: 64,
  );
}
