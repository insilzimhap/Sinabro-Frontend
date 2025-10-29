// lib/main/studyView/listenStudy/page/level1/animals/data/animal_study_models.dart

import 'package:flutter/material.dart';

/// 동물 하나에 대한 모든 콘텐츠 정보를 담는 데이터 클래스
@immutable
class AnimalContentData {
  /// 동물 영문 이름 (예: 'dog', 'cat')
  final String name;

  /// 실루엣 이미지 경로
  final String silhouetteImage;

  /// 실루엣 이미지의 위치와 크기 (Figma 좌표 기준)
  final Rect silhouetteRect;

  /// 스토리 이미지 5개 목록
  final List<String> storyImages;

  /// 스토리 오디오 5개 목록
  final List<String> storyAudios;

  /// 아웃트로 배경 이미지 경로
  final String outroImage;

  /// 아웃트로 고유 오디오 경로
  final String outroAudio;

  /// 아웃트로 고유 대사
  final String outroText;

  const AnimalContentData({
    required this.name,
    required this.silhouetteImage,
    required this.silhouetteRect,
    required this.storyImages,
    required this.storyAudios,
    required this.outroImage,
    required this.outroAudio,
    required this.outroText,
  });
}

/// 동물 그룹(열매 하나)에 대한 정보를 담는 데이터 클래스
@immutable
class AnimalGroupData {
  /// 그룹 이름 (예: '집 주변 동물')
  final String groupName;

  /// 인트로 화면 캐릭터
  final String introCharacter;

  /// 인트로 화면 대사
  final String introText;

  /// 인트로 화면 오디오 경로
  final String introAudio;

  /// 인트로 배경 이미지 경로 (집, 동물원, 바다 등)
  final String introBgImage;

  /// 학습 완료 시 최종 대사
  final String finalOutroText;

  /// 학습 완료 시 최종 오디오
  final String finalOutroAudio;

  /// 이 그룹에 속한 동물 목록
  final List<AnimalContentData> animals;

  const AnimalGroupData({
    required this.groupName,
    required this.introCharacter,
    required this.introText,
    required this.introAudio,
    required this.introBgImage,
    required this.finalOutroText,
    required this.finalOutroAudio,
    required this.animals,
  });
}
