import 'package:flutter/material.dart';

/// 색깔 학습 하나에 대한 모든 정보를 담는 데이터 클래스(설계도)입니다.
class ColorLessonData {
  /// 학습할 색깔의 이름 (예: "빨강")
  final String name;

  /// 대표 색상 값 (예: Color(0xFFE25151))
  final Color primaryColor;

  /// 캐릭터 이미지 경로
  final String characterImagePath;

  /// 마법봉 이미지 경로
  final String magicWandImagePath;

  /// 변신 단계별 정보 리스트
  final List<TransformStep> transformSteps;

  /// 요약 단계별 정보 리스트
  final List<SummaryStep> summarySteps;

  /// TTS 오디오 경로 모음
  final TtsAudioPaths ttsPaths;

  /// 효과음(SFX) 오디오 경로 모음
  final SfxAudioPaths sfxPaths;

  const ColorLessonData({
    required this.name,
    required this.primaryColor,
    required this.characterImagePath,
    required this.magicWandImagePath,
    required this.transformSteps,
    required this.summarySteps,
    required this.ttsPaths,
    required this.sfxPaths,
  });
}

/// TransformPage의 정보를 담는 클래스
class TransformStep {
  final String imagePath;
  final String line; // 대사
  final String audioAsset; // TTS 오디오
  final int minDurationMs;
  final Rect figmaRect;

  const TransformStep({
    required this.imagePath,
    required this.line,
    required this.audioAsset,
    required this.minDurationMs,
    required this.figmaRect,
  });
}

/// Summary Page 아이템 정보를 담는 클래스
class SummaryStep {
  final String imagePath;
  final String name; // 아이템 이름 (예: "사과")
  final String audioAsset; // TTS 오디오
  final int minDurationMs;
  final Rect figmaRect; // 👈 이미지의 위치와 크기
  final Offset labelPosition; // 👈 [추가] 라벨의 위치 (x, y 좌표)

  const SummaryStep({
    required this.imagePath,
    required this.name,
    required this.audioAsset,
    required this.minDurationMs,
    required this.figmaRect,
    required this.labelPosition,
  });
}

/// TTS(대사) 오디오 파일 경로를 담는 클래스
class TtsAudioPaths {
  final String intro; // 예: red00
  final String introLine;
  final String transformIntro; // 예: color_common2
  final String summaryTitle; // 예: red07
  final String outro; // 예: red08

  const TtsAudioPaths({
    required this.intro,
    required this.introLine, // [추가]
    required this.transformIntro,
    required this.summaryTitle,
    required this.outro,
  });
}

/// 효과음(SFX) 오디오 파일 경로를 담는 클래스
class SfxAudioPaths {
  final String reveal; // 예: color_effect2
  final String intro; // 예: color_effect3
  final String transform; // 예: color_effect4
  final String outro; // 예: color_effect5

  const SfxAudioPaths({
    required this.reveal,
    required this.intro,
    required this.transform,
    required this.outro,
  });
}
