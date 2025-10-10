import 'package:flutter/material.dart';

// story 1
import 'story1/intro_page.dart';
import 'story1/gender_select_page.dart';
import 'story1/main_keyword.dart';
import 'story1/story_page.dart';
import 'story1/models.dart';

// story 2
import 'story2/intro_page.dart';
import 'story2/keyword_page.dart';
import 'story2/story_page.dart';
import 'story2/model/routine_content.dart';
import 'story2/data/routine_data.dart' as story2Data;

// story 3
import 'story3/intro_page.dart' as story3Intro;
import 'story3/story_page.dart' as story3Story;
import 'story3/sort_page.dart';
import 'story3/data/routine_data.dart' as story3Data;

/// 🍎 레벨2 story1
/// 🍎 레벨2 Story1 (가족)
void startLevel2Routine(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => Level2IntroPage(
            onFinished: () {
              // → 성별 선택
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GenderSelectPage(
                        onSelected: (gender) {
                          _startStory1Flow(context, gender, 1); // index=1부터 시작
                        },
                      ),
                ),
              );
            },
          ),
    ),
  );
}

/// 내부: Story1의 메인 키워드 → 스토리 반복 (1~6)
void _startStory1Flow(BuildContext context, Gender gender, int index) {
  if (index > 6) {
    // 전체 끝나면 루틴 종료 (첫 화면으로 복귀)
    Navigator.popUntil(context, (route) => route.isFirst);
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => MainKeywordPage(
            index: index,
            gender: gender,
            onNext: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => StoryPage(
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

/// 🍎 레벨2 story2 (index 0~1)
void startLevel2Routine2(BuildContext context, int routineIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => Story2IntroPage(
            onNext: () {
              _startKeywordFlow(context, 0);
            },
          ),
    ),
  );
}

/// 내부: story2 키워드/스토리 반복
void _startKeywordFlow(BuildContext context, int index) {
  if (index >= story2Data.keywordRoutine.length) {
    Navigator.popUntil(context, (route) => route.isFirst);
    return;
  }

  final item = story2Data.keywordRoutine[index];
  final keyword = item["keyword"] as RoutineContent;
  final self = item["self"] as RoutineContent;
  final stories = item["stories"] as List<RoutineContent>;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => KeywordPage(
            keyword: keyword,
            self: self,
            onNext: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => Story2StoryPage(
                        data: stories,
                        onFinished: () {
                          _startKeywordFlow(context, index + 1);
                        },
                      ),
                ),
              );
            },
          ),
    ),
  );
}

/// 🍎 레벨2 story3 (index 2~3)
void startLevel2Routine3(BuildContext context, int routineIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => story3Intro.IntroPage(
            onNext: () {
              _startNumberFlow(context, 0);
            },
          ),
    ),
  );
}

/// 내부: 숫자별 진행 (1~10)
void _startNumberFlow(BuildContext context, int index) {
  if (index >= story3Data.numberRoutine.length) {
    // 10까지 끝났으면 정리 페이지
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SortPage()),
    );
    return;
  }

  final item = story3Data.numberRoutine[index];
  final keyword = item["keyword"];
  final stories = item["stories"];

  // keyword 먼저
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => story3Story.StoryPage(
            stories: [keyword, ...stories], // 숫자 카드 + 3개 스토리
            onFinished: () {
              _startNumberFlow(context, index + 1);
            },
          ),
    ),
  );
}
