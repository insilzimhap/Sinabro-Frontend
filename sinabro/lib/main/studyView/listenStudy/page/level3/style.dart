import 'package:flutter/material.dart';

class AppStyle {
  // ===== 색상 =====
  static const Color background = Color(0xFFFFF3E5); // 배경
  static const Color text = Color(0xFF626262); // 기본 텍스트
  static const Color accent = Color(0xFFE1D1C0); // 포인트 배경
  static const Color strongText = Color(0xFF7C685F); // 강조 텍스트

  // ===== 텍스트 스타일 =====
  static TextStyle title(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return TextStyle(
      fontSize: size.width * 0.05,
      fontWeight: FontWeight.bold,
      color: text,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return TextStyle(
      fontSize: size.width * 0.035,
      fontWeight: FontWeight.w500,
      color: text,
    );
  }

  static TextStyle body(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return TextStyle(
      fontSize: size.width * 0.028,
      color: text,
    );
  }

  // ===== 버튼 스타일 =====
  static ButtonStyle backButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IconButton.styleFrom(
      backgroundColor: accent,
      iconSize: size.width * 0.05,
    );
  }

  // ===== IntroTopicPage =====
  static double introImageHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.55; // 시계 크기 (조금 크게)
  }

  static double introSpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.03; // 시계와 텍스트 간격
  }

  static TextStyle introTitle(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return TextStyle(
      fontSize: w * 0.065, // 텍스트 크기 (너무 꽉 차지 않게)
      fontWeight: FontWeight.bold,
      color: strongText,
    );
  }

  // ===== MainTopicPage =====
  static double mainTopicImageHeight(BuildContext context) {
    // 이미지 크기 키움 (0.25 → 0.35)
    return MediaQuery.of(context).size.height * 0.55;
  }

  static double mainTopicSpacing(BuildContext context) {
    // 이미지와 텍스트 사이 간격 늘림
    return MediaQuery.of(context).size.height * 0.01;
  }

  static TextStyle mainTopicTitle(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return title(context).copyWith(
      fontSize: w * 0.09, // 텍스트 조금 더 키움
      color: strongText,
      height: 1.0, // 줄 간격 여유
    );
  }

  // ===== MainKeywordPage =====
  static double keywordImageHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.58; // 키워드 이미지 크기
  }

  static double keywordSpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.04; // 이미지-텍스트 간격
  }

  static TextStyle keywordTitle(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return TextStyle(
      fontSize: w * 0.08, // 텍스트 크게
      fontWeight: FontWeight.bold,
      color: strongText,
    );
  }

  // ===== StoryPage =====
  static double storyImageHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.6; // 스토리 이미지 크기
  }

  static double storySpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.04; // 이미지-텍스트 간격
  }

  static TextStyle storyTitle(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return TextStyle(
      fontSize: w * 0.06, // 화면 폭 기준 반응형 크기
      fontWeight: FontWeight.bold,
      color: strongText,
    );
  }
}
