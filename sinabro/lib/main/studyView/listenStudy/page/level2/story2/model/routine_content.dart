// lib/main/studyView/listenStudy/level2/story2/model/routine_content.dart

class RoutineContent {
  final String? title;
  final String text;
  final String? imagePath;
  final List<RoutineContent> stories;
  final String? audioPath;

  const RoutineContent({
    this.title,
    required this.text,
    this.imagePath,
    this.stories = const [],
    this.audioPath,
  });
}
