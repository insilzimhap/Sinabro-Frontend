// lib/main/studyView/listenStudy/page/level2/story2/routine_flow.dart

/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2, Story 2 (감정) 학습 흐름 관리]
 *
 * 이 파일은 레벨 2의 '감정' 주제(FR_LS_007, FR_LS_008) 학습 흐름을 제어합니다.
 * 'listen_study_router'에서 `startLevel2Routine2` 함수를 호출하여 시작됩니다.
 *
 * - 진행 순서: Intro -> (Topic -> Keyword -> Story) * N -> 완료 팝업
 * - 페이지 전환은 사용자의 탭(onNext 콜백)에 의해 트리거됩니다.
 * - `childId`를 모든 단계에 걸쳐 전달합니다.
 * ----------------------------------------------------------------
 */
import 'package:flutter/material.dart';
// 공통 위젯 import (절대 경로)
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

// 레벨 2 Story 2 (감정) 관련 페이지 및 데이터 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/intro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/topic_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/keyword_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/story_page.dart'
    as story2; // 이름 충돌 방지 alias
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/model/routine_content.dart'; // 데이터 모델
// 감정 데이터 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/data/routine_data_1.dart'
    as story2Data1; // 기본 감정
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/data/routine_data_2.dart'
    as story2Data2; // 복잡 감정

/// 🍊 레벨 2 Story 2 (감정) 학습 시작 함수
/// - `listen_study_router`에서 호출됩니다.
/// - 감정 학습의 전체 흐름(Intro -> Topic -> Keyword -> Story -> ...)을 시작합니다.
///
/// @param context BuildContext for navigation.
/// @param routineIndex 감정 데이터 세트를 구분 (0: 기본 감정 FR_LS_007, 1: 복잡 감정 FR_LS_008).
/// @param isGold 현재 학습이 황금 사과(스테이지 마지막)인지 여부.
/// @param childId 현재 학습을 진행하는 자녀의 고유 ID.
Future<void> startLevel2Routine2(
  BuildContext context,
  int routineIndex, {
  required bool isGold,
  required String childId, // ✅ 자녀 ID 추가됨
}) async {
  // routineIndex에 따라 '기본 감정' 또는 '복잡 감정' 데이터 소스 선택
  final dataSource = (routineIndex == 0)
      ? story2Data1.keywordRoutine // 기본 감정 데이터 (e.g., 좋아요, 슬퍼요)
      : story2Data2.keywordRoutine; // 복잡 감정 데이터 (e.g., 부끄러워요, 심심해요)

  debugPrint(
      '[Level2 Story2 Flow] Starting Routine $routineIndex for child $childId. Gold: $isGold');

  // 1. 감정 학습 인트로 페이지 표시 (await Navigator.push)
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Story2IntroPage(
        // TODO: Story2IntroPage 생성자에 childId 추가 필요
        childId: childId, // ✅ childId 전달
        onNext: () {
          debugPrint('[Level2 Story2 Flow] Intro finished. Starting topics.');
          // 2. 인트로 페이지 완료 후 (onNext 콜백)
          //    _startTopicFlow 함수를 호출하여 첫 번째 감정(index 0)부터 학습 시작
          _startTopicFlow(
              context, 0, dataSource, isGold, childId); // ✅ childId 전달
        },
      ),
    ),
  );
}

/// 🧩 감정 학습 내부 플로우 함수 (재귀 호출)
/// - 토픽 표시 -> 키워드 표시 -> 스토리 자동 재생 -> 다음 토픽으로...
///
/// @param context 현재 페이지의 BuildContext (페이지 전환용).
/// @param index 현재 학습할 감정의 순서 (dataSource 내 인덱스, 0부터 시작).
/// @param dataSource 현재 사용 중인 감정 데이터 목록 (기본 또는 복잡).
/// @param isGold 현재 학습이 황금 사과인지 여부.
/// @param childId 현재 학습 중인 자녀 ID.
Future<void> _startTopicFlow(
  BuildContext context,
  int index, // 현재 진행할 감정의 인덱스 (0, 1, 2...)
  List<Map<String, dynamic>> dataSource, // 감정 데이터 목록
  bool isGold,
  String childId, // ✅ 자녀 ID 추가됨
) async {
  // 3. 종료 조건: dataSource의 모든 감정을 학습했으면 (index가 목록 크기 이상)
  if (index >= dataSource.length) {
    debugPrint('[Level2 Story2 Flow] All topics finished. Showing popup.');
    // 완료 팝업 표시 후 함수 종료
    await showApplePopup(context,
        isGold: isGold, childId: childId); // ✅ childId 전달
    return;
  }

  // 현재 인덱스(index)에 해당하는 감정 데이터(topic, keyword, stories) 추출
  final item = dataSource[index];
  final topic = item["topic"] as RoutineContent; // 예: "좋아요" 주제 정보
  final keyword = item["keyword"] as RoutineContent; // 예: "신나요" 키워드 정보
  final stories = item["stories"] as List<RoutineContent>; // 예: 관련된 스토리 3개 목록

  debugPrint('[Level2 Story2 Flow] Starting Topic ${index + 1}: ${topic.text}');

  // 4. 토픽 페이지(TopicPage) 표시 (Navigator.push)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicPage(
        // TODO: TopicPage 생성자에 childId 추가 필요
        topic: topic, // 현재 감정 주제 데이터 전달
        childId: childId, // ✅ childId 전달
        onNext: () {
          debugPrint(
              '[Level2 Story2 Flow] Topic finished. Showing Keyword: ${keyword.text}');
          // 5. 토픽 페이지 완료 후 (onNext 콜백 - 사용자가 탭하면)
          //    키워드 페이지(KeywordPage) 표시 (Navigator.push)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KeywordPage(
                // TODO: KeywordPage 생성자에 childId 추가 필요
                keyword: keyword, // 현재 감정 키워드 데이터 전달
                childId: childId, // ✅ childId 전달
                onNext: () {
                  debugPrint(
                      '[Level2 Story2 Flow] Keyword finished. Showing Stories.');
                  // 6. 키워드 페이지 완료 후 (onNext 콜백 - 사용자가 탭하면)
                  //    스토리 페이지(story2.StoryPage) 표시 (Navigator.push)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => story2.StoryPage(
                        // TODO: story2.StoryPage 생성자에 childId 추가 필요
                        data: stories, // 현재 감정 관련 스토리 목록 전달 (자동 재생됨)
                        childId: childId, // ✅ childId 전달
                        onFinished: () {
                          debugPrint(
                              '[Level2 Story2 Flow] Stories finished. Moving to next topic.');
                          // 7. 스토리 페이지의 모든 스토리 재생 완료 후 (onFinished 콜백)
                          //    _startTopicFlow 함수를 다음 인덱스(index + 1)로 재귀 호출
                          //    -> 다음 감정 학습 시작
                          _startTopicFlow(context, index + 1, dataSource,
                              isGold, childId); // ✅ childId 전달
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
