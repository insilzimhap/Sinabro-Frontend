// lib/main/studyView/listenStudy/level2/story2/model/routine_content.dart
class RoutineContent {
  final String? title;        // 제목 (nullable로 변경)
  final String text;          // 설명 문구
  final String? imagePath;    // 이미지 경로
  final List<RoutineContent> stories; // 스토리 리스트

  const RoutineContent({
    this.title,              // required 제거
    required this.text,
    this.imagePath,
    this.stories = const [],
  });
}
