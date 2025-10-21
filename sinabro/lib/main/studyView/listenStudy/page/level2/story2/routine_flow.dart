import 'package:flutter/material.dart';
import 'intro_page.dart';
import 'topic_page.dart';
import 'keyword_page.dart';
import 'story_page.dart' as story2;
import 'data/routine_data_1.dart' as story2Data;
import 'model/routine_content.dart';

/// 🍊 레벨2 Story2 (감정)
/// 인트로 → 토픽 → 키워드 → 스토리 순서로 진행
void startLevel2Routine2(BuildContext context, int routineIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Story2IntroPage(
        onNext: () {
          _startTopicFlow(context, 0); // ✅ 인트로 후 첫 토픽부터 시작
        },
      ),
    ),
  );
}

/// 🧩 내부 플로우: 토픽 → 키워드 → 스토리 순서대로 실행
void _startTopicFlow(BuildContext context, int index) {
  if (index >= story2Data.keywordRoutine.length) {
    // ✅ 모든 감정 학습 완료 → 처음으로 복귀
    Navigator.popUntil(context, (route) => route.isFirst);
    return;
  }

  // 현재 감정 데이터 묶음
  final item = story2Data.keywordRoutine[index];
  final topic = item["topic"] as RoutineContent;
  final keyword = item["keyword"] as RoutineContent;
  final stories = item["stories"] as List<RoutineContent>;

  // ✅ 1️⃣ 토픽 페이지
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicPage(
        topic: topic,
        onNext: () {
          // ✅ 2️⃣ 키워드 페이지
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KeywordPage(
                keyword: keyword,
                onNext: () {
                  // ✅ 3️⃣ 스토리 페이지 (3개 순차로 보여줌)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => story2.StoryPage(
                        data: stories,
                        onFinished: () {
                          // 다음 감정 루틴으로
                          _startTopicFlow(context, index + 1);
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
