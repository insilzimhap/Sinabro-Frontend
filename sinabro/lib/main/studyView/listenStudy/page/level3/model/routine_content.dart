// lib/main/studyView/listenStudy/page/level3/model/routine_content.dart
import 'package:sinabro/main/studyView/listenStudy/page/level3/model/story_item.dart'; // 절대 경로 사용

class RoutineContent {
  final String id; // 고유 ID
  final String topic; // 주제 (예: 아침시간, 점심시간)
  final String topicImagePath; // 주제 대표 이미지 (메인 토픽 페이지용)
  final String title; // 키워드 제목 (예: 세수를 해요)
  final String imagePath; // 키워드 대표 이미지 (메인 키워드 페이지용)
  final List<StoryItem> stories; // 스토리 3개
  final String? topicAudioPath; // 주제 오디오 경로
  final String? titleAudioPath;

  RoutineContent({
    required this.id,
    required this.topic,
    required this.topicImagePath,
    required this.title,
    required this.imagePath,
    required this.stories,
    this.topicAudioPath,
    this.titleAudioPath,
  });
}
