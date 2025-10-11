// lib/main/studyView/listenStudy/level2/routine_flow.dart
import 'package:flutter/material.dart';
import '../../../common/widget/apple_popup.dart';

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
void startLevel2Routine(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Level2IntroPage(
        onFinished: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenderSelectPage(
                onSelected: (gender) {
                  _startStory1Flow(context, gender, 1);
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

void _startStory1Flow(BuildContext context, Gender gender, int index) {
  if (index > 6) {
    Navigator.popUntil(context, (route) => route.isFirst);
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
                  _startStory1Flow(context, gender, index + 1);
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
Future<void> startLevel2Routine2(BuildContext context, int routineIndex) async {
  // 6번째=Data1 / 7번째=Data2
  final dataSource = (routineIndex == 0)
      ? story2Data1.keywordRoutine
      : story2Data2.keywordRoutine;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Story2IntroPage(
        onNext: () {
          _startEmotionTopicFlow(context, 0, dataSource);
        },
      ),
    ),
  );
}

/// 내부: 토픽 → 키워드 → 스토리 순서 진행
void _startEmotionTopicFlow(
  BuildContext context,
  int index,
  List<Map<String, dynamic>> dataSource,
) {
  if (index >= dataSource.length) {
    Navigator.popUntil(context, (route) => route.isFirst);
    return;
  }

  final item = dataSource[index];
  final topic = item["topic"] as RoutineContent;
  final keyword = item["keyword"] as RoutineContent;
  final stories = item["stories"] as List<RoutineContent>;

  // ① 토픽 페이지
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicPage(
        topic: topic,
        onNext: () {
          // ② 키워드 페이지
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KeywordPage(
                keyword: keyword,
                onNext: () {
                  // ③ 스토리 페이지 (3장 순차)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => story2.StoryPage(
                        data: stories,
                        onFinished: () {
                          _startEmotionTopicFlow(context, index + 1, dataSource);
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

Future<void> startLevel2Routine3(BuildContext context, int routineIndex) async {
  // 🍎 4번째=Data1(1~5) / 5번째=Data2(6~10)
  final dataSource = (routineIndex == 2)
      ? story3Data1.numberRoutine
      : story3Data2.numberRoutine;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => story3Intro.Story3IntroPage( // ✅ 클래스 이름 일치 수정
        routineIndex: (routineIndex == 2) ? 0 : 1, // 데이터 구분용
        onNext: () {
          _startNumberFlow(context, 0, routineIndex);
        },
      ),
    ),
  );
}

/// 내부: 숫자 → 손 → 과일 → 정리 페이지 순서대로 진행
void _startNumberFlow(
  BuildContext context,
  int index,
  int routineIndex,
) {
  final dataSource = (routineIndex == 2)
      ? story3Data1.numberRoutine
      : story3Data2.numberRoutine;

  // ✅ 모든 숫자 학습 완료 시 (루틴 종료 시점)
  if (index >= dataSource.length) {
    // 🍏 나무2 열매5(=routineIndex 2), 나무3 열매4(=routineIndex 3)에서만 팝업 표시
    final bool isGoldPopup =
        (routineIndex == 2) || (routineIndex == 3);

    showApplePopup(context, isGold: isGoldPopup);
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
                  _startNumberFlow(context, index + 1, routineIndex);
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}
