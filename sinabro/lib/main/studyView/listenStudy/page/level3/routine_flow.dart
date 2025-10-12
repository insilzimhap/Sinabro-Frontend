// lib/main/studyView/listenStudy/level3/routine_flow.dart
import 'package:flutter/material.dart';
import '../../../common/widget/apple_popup.dart';
import 'data/routine_data.dart';
import 'model/routine_content.dart';
import 'intro_topic_page.dart';
import 'main_topic_page.dart';
import 'main_keyword_page.dart';
import 'story_page.dart';

/// 🍎 레벨3 루틴 시작 (사과 선택 후 호출됨)
Future<void> startLevel3Routine(
  BuildContext context,
  int routineIndex, {
  required bool isGold,
}) async {
  final routine = routineContents
      .where((r) => r.id.startsWith("${routineIndex + 1}-"))
      .toList();

  if (routine.isEmpty) return;

  await Navigator.push(
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
                  startLevel3RoutineFlow(context, routine, 0, routineIndex, isGold);
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
Future<void> startLevel3RoutineFlow(
  BuildContext context,
  List<RoutineContent> routine,
  int keywordIndex,
  int routineIndex,
  bool isGold,
) async {
  // ✅ 모든 키워드 끝났을 때 (루틴 완료)
  if (keywordIndex >= routine.length) {
    await showApplePopup(context, isGold: isGold);
    return;
  }

  final keyword = routine[keywordIndex];

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MainKeywordPage(
        imagePath: keyword.imagePath,
        title: keyword.title,
        onTap: () {
          startStoryFlow(context, routine, keywordIndex, 0, routineIndex, isGold);
        },
      ),
    ),
  );
}

/// 스토리 자동 진행 (20초마다 다음으로)
void startStoryFlow(
  BuildContext context,
  List<RoutineContent> routine,
  int keywordIndex,
  int storyIndex,
  int routineIndex,
  bool isGold,
) {
  final keyword = routine[keywordIndex];

  // ✅ 현재 키워드의 스토리 끝 → 다음 키워드로
  if (storyIndex >= keyword.stories.length) {
    startLevel3RoutineFlow(context, routine, keywordIndex + 1, routineIndex, isGold);
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
          // ✅ 스토리 종료 후 20초 뒤 다음 스토리로 이동
          Future.delayed(const Duration(seconds: 20), () {
            startStoryFlow(
              context,
              routine,
              keywordIndex,
              storyIndex + 1,
              routineIndex,
              isGold,
            );
          });
        },
      ),
    ),
  );
}
