// lib/main/studyView/listenStudy/level3/routine_flow.dart
import 'package:flutter/material.dart';
import 'model/routine_content.dart';
import 'main_keyword_page.dart';
import 'story_page.dart';

// 루틴 전체 실행 (스토리 자동 진행 포함)
void startRoutineFlow(
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

// 스토리 자동 진행 (20초마다)
void startStoryFlow(BuildContext context, List<RoutineContent> routine,
    int keywordIndex, int storyIndex) {
  final keyword = routine[keywordIndex];
  if (storyIndex >= keyword.stories.length) {
    startRoutineFlow(context, routine, keywordIndex + 1);
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
