import 'package:flutter/material.dart';
import 'data/routine_data.dart';
import 'model/routine_content.dart';
import 'intro_topic_page.dart';
import 'main_topic_page.dart';
import 'main_keyword_page.dart';
import 'story_page.dart';

/// 🍎 루틴 시작 (사과 선택 후 호출됨)
void startLevel3Routine(BuildContext context, int routineIndex) {
  final routine = routineContents
      .where((r) => r.id.startsWith("${routineIndex + 1}-"))
      .toList();

  if (routine.isEmpty) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => IntroTopicPage(
        title: "째깍째깍... 지금 뭐하는 시간이지?",
        imagePath: "assets/img/contents/studyListen/level3/clock.png",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainTopicPage(
                topicImagePath: routine.first.topicImagePath,
                title: routine.first.topic,
                onTap: () {
                  // ✅ 루틴 본격 실행
                  startLevel3RoutineFlow(context, routine, 0);
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// 루틴 전체 실행 (스토리 자동 진행 포함)
void startLevel3RoutineFlow(
    BuildContext context, List<RoutineContent> routine, int keywordIndex) {
  if (keywordIndex >= routine.length) return;

  final keyword = routine[keywordIndex];

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MainKeywordPage(
        imagePath: keyword.imagePath,
        title: keyword.title,
        onTap: () {
          startStoryFlow(context, routine, keywordIndex, 0);
        },
      ),
    ),
  );
}

/// 스토리 자동 진행 (20초마다)
void startStoryFlow(BuildContext context, List<RoutineContent> routine,
    int keywordIndex, int storyIndex) {
  final keyword = routine[keywordIndex];
  if (storyIndex >= keyword.stories.length) {
    startLevel3RoutineFlow(context, routine, keywordIndex + 1);
    return;
  }

  final story = keyword.stories[storyIndex];

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StoryPage(
        imagePath: story.imagePath,
        text: story.text,
        onFinished: () {
          Future.delayed(const Duration(seconds: 20), () {
            startStoryFlow(context, routine, keywordIndex, storyIndex + 1);
          });
        },
      ),
    ),
  );
}
