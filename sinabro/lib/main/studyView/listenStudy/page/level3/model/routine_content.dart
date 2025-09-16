class StoryItem {
  final String id;       
  final String imagePath;
  final String text;

  StoryItem({
    required this.id,
    required this.imagePath,
    required this.text,
  });
}


class RoutineContent {
  final String id;               // 고유 ID
  final String topic;            // 주제 (예: 아침시간, 점심시간)
  final String title;            // 키워드 제목 (예: 세수를 해요)
  final String imagePath;        // 키워드 대표 이미지
  final List<StoryItem> stories; // 스토리 3개 // Changed

  RoutineContent({
    required this.id,
    required this.topic,
    required this.title,
    required this.imagePath,
    required this.stories,
  });
}
