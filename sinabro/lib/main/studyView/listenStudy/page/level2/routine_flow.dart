// lib/main/studyView/listenStudy/level2/routine_flow.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

// ⭐️ [추가] API 연동을 위한 3개 import
import 'dart:convert';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';

/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2 학습 흐름 관리]
 *
 * 이 파일은 듣기 학습 레벨 2의 각 주제(가족, 감정, 숫자)별
 * 학습 콘텐츠 페이지 전환 로직을 관리합니다.
 *
 * - 각 `startLevel2RoutineX` 함수는 해당 주제 학습의 진입점 역할을 하며,
 * `listen_study_router`에서 호출됩니다.
 * - 내부 헬퍼 함수(`_start...Flow`)들이 재귀적으로 호출되며
 * 페이지(Intro -> Topic/Keyword -> Story -> ...)를 순차적으로 표시합니다.
 * - 사용자의 탭(onTap/onNext) 또는 특정 조건 완료 시 다음 단계로 진행됩니다.
 * - 모든 학습 단계 완료 시 `showApplePopup`을 호출하여 종료합니다.
 * - `childId`를 모든 단계에 걸쳐 전달하여 학습 결과 추적 기반을 마련합니다.
 * ----------------------------------------------------------------
 */

// ────────────────────────────────
// 🍎 Story 1 (가족)
// ────────────────────────────────
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/intro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/gender_select_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/main_keyword.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/story_page.dart'
    as story1;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/models.dart';

// ────────────────────────────────
// 🍊 Story 2 (감정)
// ────────────────────────────────
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/intro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/topic_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/keyword_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/story_page.dart'
    as story2;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/model/routine_content.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/data/routine_data_1.dart'
    as story2Data1;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/data/routine_data_2.dart'
    as story2Data2;

// ────────────────────────────────
// 🍇 Story 3 (숫자)
// ────────────────────────────────
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/intro_page.dart'
    as story3Intro;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/model/number_story_item.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/story_page.dart'
    as story3;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/sort_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/data/routine_data_1.dart'
    as story3Data1;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/data/routine_data_2.dart'
    as story3Data2;

// ======================================================
// 🍎 레벨2 Story1 (가족)
// ======================================================
// ========================================================================
// 🍎 레벨 2 - Story 1: 가족 (FR_LS_006)
// ========================================================================

// ⭐️ [추가] API 호출용 클라이언트 (파일 최상단에 하나만)
final AuthClient _authClient = AuthClient();

// ⭐️ [추가] 공용 완료 API 호출 함수
Future<void> _completeStudy(String childId, String fruitId, DateTime startTime) async {
  // 1. 학습 시간 계산
  final int timeSpentSecs = DateTime.now().difference(startTime).inSeconds;
  // 2. DTO (JSON Body) 구성
  final body = jsonEncode({
    'childId': childId,
    'fruitId': fruitId, // ⭐️ "FR_LS_007", "FR_LS_008" 등...
    'isCompleted': true,
    'timeSpentSecs': timeSpentSecs,
  });

  // 3. API 엔드포인트
  final uri = Uri.parse('$baseUrl/api/study/listening/complete');

  // 4. API 호출 (중복 호출 방지는 각 '두목' 위젯/함수에서 알아서)
  try {
    debugPrint('[Level2 Flow] 듣기 학습 완료 API 호출: $body');
    final response = await _authClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200) {
      debugPrint('[Level2 Flow] 듣기 학습 완료 처리 성공 (fruitId: $fruitId)');
    } else {
      debugPrint('[Level2 Flow] 학습 완료 처리 실패: (${response.statusCode}) ${response.body}');
    }
  } catch (e) {
    debugPrint('[Level2 Flow] 학습 완료 API 호출 중 예외 발생: $e');
  }
}

/// 레벨 2 가족 학습 시작 함수
/// - `listen_study_router`에서 호출됩니다.
/// - 가족 학습의 전체 흐름(Intro -> 성별 선택 -> (키워드 -> 스토리) * 6 -> 완료 팝업)을 시작합니다.
///
/// @param context BuildContext for navigation.
/// @param isGold 현재 학습이 황금 사과(스테이지 마지막)인지 여부.
/// @param childId 현재 학습을 진행하는 자녀의 고유 ID.
Future<void> startLevel2Routine(
  BuildContext context, {
  required bool isGold,
  required String childId, // ✅ 자녀 ID 추가됨
  required String fruitId,
}) async {

  // ⭐️ [추가] 학습 시작 시간 기록
  final DateTime startTime = DateTime.now();
  // ⭐️ [추가] 완료 플래그 (중복 호출 방지)
  bool isCompleted = false;
  
  debugPrint(
      '[Level2 Story1 Flow] Starting Routine for child $childId. Gold: $isGold');
  // 1. 인트로 페이지 표시
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Level2IntroPage(
        childId: childId, // ✅ childId 전달
        onFinished: () {
          debugPrint(
              '[Level2 Story1 Flow] Intro finished. Showing gender select.');
          // 2. 인트로 완료 후 성별 선택 페이지 표시
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenderSelectPage(
                childId: childId, // ✅ childId 전달
                onSelected: (gender) {
                  debugPrint(
                      '[Level2 Story1 Flow] Gender selected: $gender. Starting keywords.');
                  // 3. 성별 선택 완료 후 첫 번째 가족 구성원(index 1)부터 흐름 시작
                  _startStory1Flow(
                      context,
                      gender,
                      1,
                      isGold,
                      childId,
                      fruitId,
                      startTime,
                      () { // ⭐️ [추가] 완료 콜백 함수 전달
                      if (isCompleted) return;
                      isCompleted = true;
                      _completeStudy(childId, fruitId, startTime);
                      }
                    ); // ✅ childId 전달
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// 가족 학습 내부 플로우 함수 (재귀 호출)
/// - 키워드 표시 -> 스토리 표시 -> 다음 키워드로...
///
/// @param context 현재 페이지의 BuildContext (페이지 전환용).
/// @param gender 사용자가 선택한 성별 (호칭 결정용).
/// @param index 현재 학습할 가족 구성원의 순서 (1부터 6까지).
/// @param isGold 현재 학습이 황금 사과인지 여부.
/// @param childId 현재 학습 중인 자녀 ID.
Future<void> _startStory1Flow(
  BuildContext context,
  Gender gender,
  int index, // 현재 가족 구성원 인덱스 (1 ~ 6)
  bool isGold,
  String childId, // ✅ 자녀 ID 추가됨
  String fruitId,   // ⭐️ [추가]
  DateTime startTime,
  VoidCallback onCompleteApiCall, // ⭐️ [추가] 완료 시 호출할 함수
) async {
  // 4. 종료 조건: 모든 가족 구성원(6명) 학습 완료 시
  if (index > 6) {
    debugPrint('[Level2 Story1 Flow] All keywords finished. Showing popup.');
    
    // ⭐️ [수정] 1. API 호출
    onCompleteApiCall();
    // 완료 팝업 표시 후 함수 종료
    await showApplePopup(context,
        isGold: isGold, childId: childId); // ✅ childId 전달
    return;
  }
  debugPrint('[Level2 Story1 Flow] Starting Keyword $index.');
  // 5. 현재 순서(index)에 맞는 키워드 페이지(MainKeywordPage) 표시 (Navigator.push)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MainKeywordPage(
        index: index, // 현재 가족 구성원 번호 전달
        gender: gender, // 선택된 성별 전달
        childId: childId, // ✅ childId 전달
        onNext: () {
          debugPrint(
              '[Level2 Story1 Flow] Keyword finished. Showing Story $index.');
          // 6. 키워드 페이지 완료 후 (onNext 콜백 - 사용자가 탭하면)
          //    스토리 페이지(story1.StoryPage)로 교체 (Navigator.pushReplacement)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => story1.StoryPage(
                index: index, // 현재 가족 구성원 번호 전달
                gender: gender, // 선택된 성별 전달
                childId: childId, // ✅ childId 전달
                onFinished: () {
                  debugPrint(
                      '[Level2 Story1 Flow] Story finished. Moving to next keyword.');
                  // 7. 스토리 페이지 완료 후 (onFinished 콜백)
                  //    _startStory1Flow 함수를 다음 인덱스(index + 1)로 재귀 호출
                  //    -> 다음 가족 구성원 학습 시작
                  _startStory1Flow(
                    context,
                     gender,
                      index + 1,
                       isGold,
                      childId,
                      fruitId,   // ⭐️ [추가]
                      startTime, // ⭐️ [추가]
                      onCompleteApiCall ); // ✅ childId 전달
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
// ========================================================================
// 🍊 레벨 2 - Story 2: 감정 (FR_LS_007, FR_LS_008)
// ========================================================================

/// 레벨 2 감정 학습 시작 함수
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
  required String childId, // 자녀 ID
  required String fruitId, // ⭐️ 받음
}) async {
  final DateTime startTime = DateTime.now();
  bool isCompleted = false;

  // routineIndex에 따라 '기본 감정' 또는 '복잡 감정' 데이터 소스 선택
  final dataSource = (routineIndex == 0)
      ? story2Data1.keywordRoutine // 기본 감정 데이터 (e.g., 좋아요, 슬퍼요)
      : story2Data2.keywordRoutine; // 복잡 감정 데이터 (e.g., 부끄러워요, 심심해요)

  // 1. 감정 학습 인트로 페이지 표시 (await Navigator.push)
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Story2IntroPage(
        childId: childId, // 자녀 ID 전달
        onNext: () {
          // 2. 인트로 페이지 완료 후 (onNext 콜백)
          //    _startTopicFlow 함수를 호출하여 첫 번째 감정(index 0)부터 학습 시작
          _startTopicFlow(
              context,
              0,
              dataSource,
              isGold,
              childId,
              fruitId,
              startTime,() { // ⭐️ 넘김
                if (isCompleted) return;
                isCompleted = true;
                _completeStudy(childId, fruitId, startTime);
              },
            ); // 자녀 ID 전달
        },
      ),
    ),
  );
}

/// 감정 학습 내부 플로우 함수 (재귀 호출)
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
  String childId, // 자녀 ID
  String fruitId,   // ⭐️ [추가]
  DateTime startTime,
  VoidCallback onCompleteApiCall,
) async {
  // 3. 종료 조건: dataSource의 모든 감정을 학습했으면 (index가 목록 크기 이상)
  if (index >= dataSource.length) {
    onCompleteApiCall(); // ⭐️ API 호출
    // 완료 팝업 표시 후 함수 종료
    await showApplePopup(context, isGold: isGold, childId: childId); // 자녀 ID 전달
    return;
  }

  // 현재 인덱스(index)에 해당하는 감정 데이터(topic, keyword, stories) 추출
  final item = dataSource[index];
  final topic = item["topic"] as RoutineContent; // 예: "좋아요" 주제 정보
  final keyword = item["keyword"] as RoutineContent; // 예: "신나요" 키워드 정보
  final stories = item["stories"] as List<RoutineContent>; // 예: 관련된 스토리 3개 목록

  // 4. 토픽 페이지(TopicPage) 표시 (Navigator.push)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicPage(
        // TODO: TopicPage 생성자에 childId 추가 필요
        topic: topic, // 현재 감정 주제 데이터 전달
        childId: childId, // 자녀 ID 전달
        onNext: () {
          // 5. 토픽 페이지 완료 후 (onNext 콜백 - 사용자가 탭하면)
          //    키워드 페이지(KeywordPage) 표시 (Navigator.push)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KeywordPage(
                // TODO: KeywordPage 생성자에 childId 추가 필요
                keyword: keyword, // 현재 감정 키워드 데이터 전달
                childId: childId, // 자녀 ID 전달
                onNext: () {
                  // 6. 키워드 페이지 완료 후 (onNext 콜백 - 사용자가 탭하면)
                  //    스토리 페이지(story2.StoryPage) 표시 (Navigator.push)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => story2.StoryPage(
                        // TODO: story2.StoryPage 생성자에 childId 추가 필요
                        data: stories, // 현재 감정 관련 스토리 목록 전달 (자동 재생됨)
                        childId: childId, // 자녀 ID 전달
                        onFinished: () {
                          // 7. 스토리 페이지의 모든 스토리 재생 완료 후 (onFinished 콜백)
                          //    _startTopicFlow 함수를 다음 인덱스(index + 1)로 재귀 호출
                          //    -> 다음 감정 학습 시작
                          _startTopicFlow(
                            context, index + 1, dataSource,
                            isGold, 
                            childId,
                            fruitId,   // ⭐️ 넘김
                            startTime, // ⭐️ 넘김
                            onCompleteApiCall // ⭐️ 넘김
                          );
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
/// 레벨 2 숫자 학습 시작 함수
/// - `listen_study_router`에서 호출됩니다.
/// - 숫자 학습의 전체 흐름(Intro -> (스토리 * 3 -> 정리) * 5 -> 완료 팝업)을 시작합니다.
///
/// @param context BuildContext for navigation.
/// @param routineIndex 숫자 데이터 세트를 구분 (2: 숫자 1~5 FR_LS_009, 3: 숫자 6~10 FR_LS_010).
/// @param isGold 현재 학습이 황금 사과(스테이지 마지막)인지 여부.
/// @param childId 현재 학습을 진행하는 자녀의 고유 ID.
Future<void> startLevel2Routine3(
  BuildContext context,
  int routineIndex, {
  // 2 또는 3
  required bool isGold,
  required String childId, // ✅ 자녀 ID 추가됨
  required String fruitId,

}) async {
  final DateTime startTime = DateTime.now();
  bool isCompleted = false;

  // routineIndex에 따라 '숫자 1~5' 또는 '숫자 6~10' 데이터 소스 선택
  final dataSource = (routineIndex == 2)
      ? story3Data1.numberRoutine // 숫자 1~5 데이터
      : story3Data2.numberRoutine; // 숫자 6~10 데이터
  debugPrint(
      '[Level2 Story3 Flow] Starting Routine $routineIndex for child $childId. Gold: $isGold');
  // 1. 숫자 학습 인트로 페이지 표시
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => story3Intro.Story3IntroPage(
        // TODO: Story3IntroPage 생성자에 childId 추가 필요
        // 인트로 페이지 내부 분기를 위해 routineIndex 전달 (0 또는 1)
        routineIndex: (routineIndex == 2) ? 0 : 1,
        childId: childId, // ✅ childId 전달
        onNext: () {
          debugPrint('[Level2 Story3 Flow] Intro finished. Starting numbers.');
          // 2. 인트로 완료 후 첫 번째 숫자(index 0)부터 흐름 시작
          _startNumberFlow(
              context, 0, routineIndex, isGold, childId,
              fruitId,   // ⭐️ 넘김
              startTime, // ⭐️ 넘김
              () { // ⭐️ 넘김
                if (isCompleted) return;
                isCompleted = true;
                _completeStudy(childId, fruitId, startTime);
              });
        },
      ),
    ),
  );
}

/// 숫자 학습 내부 플로우 함수 (재귀 호출)
/// - (숫자 + 손 + 과일) 스토리 표시 -> 정리 페이지 표시 -> 다음 숫자로...
///
/// @param context 현재 페이지의 BuildContext (페이지 전환용).
/// @param index 현재 학습할 숫자의 순서 (dataSource 내 인덱스, 0부터 4까지).
/// @param routineIndex 현재 진행 중인 루틴 (2: 1~5, 3: 6~10).
/// @param isGold 현재 학습이 황금 사과인지 여부.
/// @param childId 현재 학습 중인 자녀 ID.
void _startNumberFlow(
  BuildContext context,
  int index, // 현재 진행할 숫자의 인덱스 (0 ~ 4)
  int routineIndex, // 2 또는 3
  bool isGold,
  String childId, // ✅ 자녀 ID 추가됨
  String fruitId,   // ⭐️ [추가]
  DateTime startTime,
  VoidCallback onCompleteApiCall,
) {
  // routineIndex에 따라 데이터 소스 재확인
  final dataSource = (routineIndex == 2)
      ? story3Data1.numberRoutine // 숫자 1~5
      : story3Data2.numberRoutine; // 숫자 6~10

  // 3. 종료 조건: dataSource의 모든 숫자(5개)를 학습했으면
  if (index >= dataSource.length) {
    onCompleteApiCall(); // ⭐️ API 호출
    debugPrint('[Level2 Story3 Flow] All numbers finished. Showing popup.');
    // 완료 팝업 표시 후 함수 종료
    showApplePopup(context, isGold: isGold, childId: childId); // ✅ childId 전달
    return;
  }

  // 현재 인덱스(index)에 해당하는 숫자 데이터 추출
  final item = dataSource[index];
  final keywordStory =
      item["keyword"] as NumberStoryItem; // 숫자 자체 스토리 (e.g., 숫자 '1')
  final relatedStories = item["stories"]
      as List<NumberStoryItem>; // 연관 스토리 (e.g., 손가락 '1', 과일 '1개')

  final currentNumber = index + 1 + ((routineIndex == 2) ? 0 : 5);
  debugPrint(
      '[Level2 Story3 Flow] Starting Number $currentNumber (Index $index)');

  // 4. 숫자 스토리 페이지(story3.StoryPage) 표시 (Navigator.push)
  //    - 키워드 스토리와 연관 스토리를 합쳐서 전달 (총 3개)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => story3.StoryPage(
        // TODO: story3.StoryPage 생성자에 childId 추가 필요
        stories: [keywordStory, ...relatedStories], // 3개의 스토리를 리스트로 전달
        childId: childId, // ✅ childId 전달
        onFinished: () {
          debugPrint(
              '[Level2 Story3 Flow] Stories finished. Showing Sort page.');
          // 5. 모든 스토리(3개) 완료 후 (onFinished 콜백)
          //    정리 페이지(SortPage) 표시 (Navigator.push)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SortPage(
                stories: [keywordStory, ...relatedStories], // 동일한 스토리 데이터 전달
                number: currentNumber, // 현재 숫자 값 전달 (e.g., 1, 2, ..., 10)
                childId: childId, // ✅ childId 전달
                onNext: () {
                  debugPrint(
                      '[Level2 Story3 Flow] Sort page finished. Moving to next number.');
                  // 6. 정리 페이지 완료 후 (onNext 콜백 - 사용자가 탭하면)
                  //    _startNumberFlow 함수를 다음 인덱스(index + 1)로 재귀 호출
                  //    -> 다음 숫자 학습 시작
                  _startNumberFlow(
                    context, index + 1, routineIndex, 
                    isGold, 
                    childId,
                    fruitId,   // ⭐️ 넘김
                    startTime, // ⭐️ 넘김
                    onCompleteApiCall // ⭐️ 넘김
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
