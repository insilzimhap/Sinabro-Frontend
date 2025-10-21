// lib/main/studyView/listenStudy/level2/routine_flow.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

// ────────────────────────────────
// 🍎 Story 1 (가족)
// ────────────────────────────────
import 'story1/intro_page.dart';
import 'story1/gender_select_page.dart';
import 'story1/main_keyword.dart';
import 'story1/story_page.dart' as story1;
import 'story1/models.dart';

// ────────────────────────────────
// 🍊 Story 2 (감정)
// ────────────────────────────────
import 'story2/intro_page.dart';
import 'story2/topic_page.dart';
import 'story2/keyword_page.dart';
import 'story2/story_page.dart' as story2;
import 'story2/model/routine_content.dart';
import 'story2/data/routine_data_1.dart' as story2Data1;
import 'story2/data/routine_data_2.dart' as story2Data2;

// ────────────────────────────────
// 🍇 Story 3 (숫자)
// ────────────────────────────────
import 'story3/intro_page.dart' as story3Intro;
import 'story3/story_page.dart' as story3;
import 'story3/sort_page.dart';
import 'story3/data/routine_data_1.dart' as story3Data1;
import 'story3/data/routine_data_2.dart' as story3Data2;

// ======================================================
// 🍎 레벨2 Story1 (가족)
// ======================================================
Future<void> startLevel2Routine(BuildContext context,
    {required bool isGold}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Level2IntroPage(
        onFinished: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenderSelectPage(
                onSelected: (gender) {
                  _startStory1Flow(context, gender, 1, isGold);
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _startStory1Flow(
  BuildContext context,
  Gender gender,
  int index,
  bool isGold,
) async {
  if (index > 6) {
    // ✅ 루틴 종료 시
    await showApplePopup(context, isGold: isGold);
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MainKeywordPage(
        index: index,
        gender: gender,
        onNext: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => story1.StoryPage(
                index: index,
                gender: gender,
                onFinished: () {
                  _startStory1Flow(context, gender, index + 1, isGold);
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

// ======================================================
// 🍊 레벨2 Story2 (감정)
// ======================================================
Future<void> startLevel2Routine2(
  BuildContext context,
  int routineIndex, {
  required bool isGold,
}) async {
  final dataSource = (routineIndex == 0)
      ? story2Data1.keywordRoutine
      : story2Data2.keywordRoutine;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Story2IntroPage(
        onNext: () {
          _startEmotionTopicFlow(context, 0, dataSource, isGold);
        },
      ),
    ),
  );
}

Future<void> _startEmotionTopicFlow(
  BuildContext context,
  int index,
  List<Map<String, dynamic>> dataSource,
  bool isGold,
) async {
  if (index >= dataSource.length) {
    // ✅ 루틴 종료 시
    await showApplePopup(context, isGold: isGold);
    return;
  }

  final item = dataSource[index];
  final topic = item["topic"] as RoutineContent;
  final keyword = item["keyword"] as RoutineContent;
  final stories = item["stories"] as List<RoutineContent>;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicPage(
        topic: topic,
        onNext: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KeywordPage(
                keyword: keyword,
                onNext: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => story2.StoryPage(
                        data: stories,
                        onFinished: () {
                          _startEmotionTopicFlow(
                              context, index + 1, dataSource, isGold);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

// ======================================================
// 🍇 레벨2 Story3 (숫자)
// ======================================================
Future<void> startLevel2Routine3(
  BuildContext context,
  int routineIndex, {
  required bool isGold,
}) async {
  final dataSource = (routineIndex == 2)
      ? story3Data1.numberRoutine
      : story3Data2.numberRoutine;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => story3Intro.Story3IntroPage(
        routineIndex: (routineIndex == 2) ? 0 : 1,
        onNext: () {
          _startNumberFlow(context, 0, routineIndex, isGold);
        },
      ),
    ),
  );
}

void _startNumberFlow(
  BuildContext context,
  int index,
  int routineIndex,
  bool isGold,
) {
  final dataSource = (routineIndex == 2)
      ? story3Data1.numberRoutine
      : story3Data2.numberRoutine;

  if (index >= dataSource.length) {
    showApplePopup(context, isGold: isGold);
    return;
  }

  final item = dataSource[index];
  final keyword = item["keyword"];
  final stories = item["stories"] as List;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => story3.StoryPage(
        stories: [keyword, ...stories],
        onFinished: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SortPage(
                stories: [keyword, ...stories],
                number: index + 1 + ((routineIndex == 2) ? 0 : 5),
                onNext: () {
                  _startNumberFlow(context, index + 1, routineIndex, isGold);
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}
