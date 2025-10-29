// lib/main/studyView/listenStudy/page/level3/routine_flow.dart

/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 3 학습 흐름 관리]
 *
 * 이 파일은 듣기 학습 레벨 3의 각 주제(아침, 점심, 놀이, 저녁 /
 * FR_LS_011 ~ FR_LS_014)별 학습 콘텐츠 페이지 전환 로직을 관리합니다.
 *
 * - `startLevel3Routine` 함수는 `listen_study_router`에서 호출되어
 * 해당 주제 학습의 진입점 역할을 합니다.
 * - 진행 순서: Intro(시계) -> Topic(주제) -> Keyword(핵심 단어) ->
 * (Story 자동재생 * N) -> 다음 Keyword -> ... -> 완료 Popup
 * - 스토리 페이지(`StoryPage`)는 오디오 재생 완료 시 자동으로 다음 단계로 진행됩니다.
 * - `childId`를 모든 단계에 걸쳐 전달합니다.
 * ----------------------------------------------------------------
 */
import 'package:flutter/material.dart';

// 공통 위젯 import (절대 경로)
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';
// 레벨 3 관련 페이지, 모델, 데이터 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level3/data/routine_data.dart'; // routineContents
import 'package:sinabro/main/studyView/listenStudy/page/level3/model/routine_content.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/model/story_item.dart'; // StoryItem (StoryPage 용)
import 'package:sinabro/main/studyView/listenStudy/page/level3/intro_topic_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/main_topic_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/main_keyword_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/story_page.dart';
// ListenAppleSelect import (팝업 완료 후 돌아갈 경로 이름 사용 위해)
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart';

// 라우트 이름 상수 (임시 정의, AppConstants로 옮기는 것 권장)
const routeNameLevel3IntroTopic = '/level3-intro-topic';
const routeNameLevel3MainTopic = '/level3-main-topic';
const routeNameLevel3MainKeyword = '/level3-main-keyword';

/// 🍎 레벨 3 듣기 학습 시작 함수
/// - `listen_study_router`에서 호출됩니다.
/// - 해당 일상 주제(아침/점심/놀이/저녁)의 학습 흐름을 시작합니다.
///
/// @param context BuildContext from the calling widget (likely ListenAppleSelect).
/// @param routineIndex 현재 학습할 일상 주제 (0: 아침, 1: 점심, 2: 놀이, 3: 저녁).
/// @param isGold 현재 학습이 황금 사과(스테이지 마지막)인지 여부.
/// @param childId 현재 학습 중인 자녀 ID.
Future<void> startLevel3Routine(
  BuildContext context, // 라우터에서 넘어온 context (ListenAppleSelect의 context)
  int routineIndex, {
  required bool isGold,
  required String childId, // ✅ 자녀 ID 추가됨
}) async {
  // routineIndex에 해당하는 데이터 필터링 (e.g., "1-"로 시작하는 ID들)
  final routineData = routineContents
      .where((r) => r.id.startsWith("${routineIndex + 1}-"))
      .toList();

  // 데이터 없으면 오류 로그 출력 후 종료
  if (routineData.isEmpty) {
    debugPrint(
        "[Level3 Flow] Error: No routine data found for index $routineIndex");
    return;
  }

  debugPrint(
      '[Level3 Flow] Starting Routine $routineIndex for child $childId. Gold: $isGold');

  // 1. 인트로 페이지 (시계) 표시 (Navigator.push)
  await Navigator.push(
    context, // ListenAppleSelect의 context 사용
    MaterialPageRoute(
      settings: const RouteSettings(name: routeNameLevel3IntroTopic),
      builder: (introContext) => IntroTopicPage(
        // ✅ childId 생성자 추가됨 (가정)
        childId: childId, // ✅ childId 전달
        title: "째깍째깍... 지금 뭐하는 시간이지?",
        imagePath:
            "assets/img/contents/studyListen/level3/clock.png", // TODO: AppConstants 사용
        onTap: () {
          debugPrint('[Level3 Flow] Intro finished. Showing Main Topic.');
          // 2. 인트로 완료 후 메인 토픽 페이지 표시 (Navigator.push)
          Navigator.push(
            introContext, // IntroTopicPage의 context 사용
            MaterialPageRoute(
              settings: const RouteSettings(name: routeNameLevel3MainTopic),
              builder: (topicContext) => MainTopicPage(
                // TODO: MainTopicPage 생성자에 childId 추가 필요
                childId: childId, // ✅ childId 전달
                topicImagePath: routineData.first.topicImagePath,
                title: routineData.first.topic,
                audioPath: routineData.first.topicAudioPath,
                onTap: () {
                  debugPrint(
                      '[Level3 Flow] Main Topic finished. Starting keyword flow.');
                  // 3. 메인 토픽 완료 후, 첫 번째 키워드부터 실제 학습 흐름 시작
                  startLevel3RoutineFlow(topicContext, routineData, 0,
                      routineIndex, isGold, childId); // ✅ childId 전달
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// 레벨 3 학습 루틴 내부 플로우 함수 (키워드 단위 진행, 재귀 호출)
/// - MainKeywordPage 표시 -> (탭) -> startStoryFlow 호출
///
/// @param flowContext 현재 네비게이션 스택 상의 context (MainTopicPage 또는 MainKeywordPage).
/// @param routineData 현재 주제의 전체 데이터 리스트.
/// @param keywordIndex 현재 진행할 키워드의 순서 (0부터 시작).
/// @param routineIndex 현재 학습 중인 전체 루틴 인덱스 (0~3).
/// @param isGold 현재 학습이 황금 사과인지 여부.
/// @param childId 현재 학습 중인 자녀 ID.
Future<void> startLevel3RoutineFlow(
  BuildContext flowContext, // MainTopicPage 또는 MainKeywordPage의 context
  List<RoutineContent> routineData,
  int keywordIndex,
  int routineIndex,
  bool isGold,
  String childId, // ✅ 자녀 ID 추가됨
) async {
  // 4. 종료 조건: 모든 키워드 학습 완료 시
  if (keywordIndex >= routineData.length) {
    debugPrint('[Level3 Flow] All keywords finished. Showing popup.');
    // 완료 팝업 표시 후 종료
    await showApplePopup(flowContext,
        isGold: isGold, childId: childId); // ✅ childId 전달
    return;
  }

  // 현재 키워드 데이터 추출
  final currentKeyword = routineData[keywordIndex];
  // title이 null일 수 없다고 가정 (VS Code 경고 반영)
  // 만약 title이 null일 수 있다면 currentKeyword.title ?? currentKeyword.text 사용
  final displayTitle = currentKeyword.title!; // ✅ [수정] title이 null 아님을 명시
  // final displayTitle = currentKeyword.title ?? currentKeyword.text; // 이전 코드 (더 안전할 수 있음)

  debugPrint(
      '[Level3 Flow] Starting Keyword ${keywordIndex + 1}: $displayTitle');

  // 5. 메인 키워드 페이지 표시 (Navigator.pushReplacement)
  await Navigator.pushReplacement(
    flowContext, // 전달받은 context 사용
    MaterialPageRoute(
      settings: const RouteSettings(name: routeNameLevel3MainKeyword),
      builder: (keywordContext) => MainKeywordPage(
        // ✅ childId 생성자 추가됨
        childId: childId, // ✅ childId 전달
        imagePath:
            currentKeyword.imagePath ?? '', // imagePath가 null일 경우 빈 문자열 전달
        title: displayTitle, // ✅ 수정된 title 사용
        audioPath: currentKeyword.titleAudioPath,
        onTap: () {
          debugPrint('[Level3 Flow] Keyword tapped. Starting story flow.');
          // 6. 키워드 페이지 탭 시, 해당 키워드의 첫 번째 스토리부터 자동 재생 시작
          startStoryFlow(
              keywordContext, // 현재 페이지(MainKeywordPage)의 context 전달
              routineData,
              keywordIndex,
              0, // 첫 번째 스토리부터 시작
              routineIndex,
              isGold,
              childId); // ✅ childId 전달
        },
      ),
    ),
  );
}

/// 레벨 3 스토리 자동 진행 플로우 함수 (재귀 호출)
/// - StoryPage 표시 (push 또는 pushReplacement) -> (오디오 완료) -> 다음 스토리 또는 다음 키워드 진행
///
/// @param currentStoryContext 현재 페이지(MainKeywordPage 또는 이전 StoryPage)의 context.
/// @param routineData 현재 주제의 전체 데이터 리스트.
/// @param keywordIndex 현재 진행 중인 키워드의 인덱스.
/// @param storyIndex 현재 키워드 내에서 진행할 스토리의 순서 (0부터 시작).
/// @param routineIndex 현재 학습 중인 전체 루틴 인덱스 (0~3).
/// @param isGold 현재 학습이 황금 사과인지 여부.
/// @param childId 현재 학습 중인 자녀 ID.
void startStoryFlow(
  BuildContext currentStoryContext, // MainKeywordPage 또는 이전 StoryPage의 context
  List<RoutineContent> routineData,
  int keywordIndex,
  int storyIndex,
  int routineIndex,
  bool isGold,
  String childId, // ✅ 자녀 ID 추가됨
) {
  final currentKeyword = routineData[keywordIndex];

  // 7. 종료 조건: 현재 키워드의 모든 스토리 재생 완료 시
  if (storyIndex >= currentKeyword.stories.length) {
    debugPrint(
        '[Level3 Flow] All stories for keyword ${keywordIndex + 1} finished. Moving to next keyword.');
    // 마지막 StoryPage 닫기(pop)
    Navigator.pop(currentStoryContext);

    // pop 후 활성화된 이전 페이지(MainKeywordPage)의 context를 사용해야 하지만,
    // 직접 접근이 어려우므로 pop 전의 context(currentStoryContext)를 그대로 사용.
    // pushReplacement는 스택 최상단을 교체하므로 이 방식도 동작함.
    startLevel3RoutineFlow(currentStoryContext, routineData, keywordIndex + 1,
        routineIndex, isGold, childId); // ✅ childId 전달
    return;
  }

  // 현재 스토리 데이터(StoryItem) 추출
  final currentStory = currentKeyword.stories[storyIndex];
  debugPrint(
      '[Level3 Flow] Showing Story ${storyIndex + 1} for keyword ${keywordIndex + 1}');

  // 8. 스토리 페이지(StoryPage) 표시를 위한 MaterialPageRoute 생성
  final pageRoute = MaterialPageRoute(
    settings:
        RouteSettings(name: '/level3-story-${currentStory.id}'), // 디버깅용 이름
    builder: (storyPageContext) => StoryPage(
      // TODO: StoryPage 생성자에 childId 추가 필요
      childId: childId, // ✅ childId 전달
      story: currentStory, // 현재 스토리 아이템 전달
      onFinished: () {
        debugPrint(
            '[Level3 Flow] Story finished automatically. Moving to next story.');
        // 9. 오디오 완료 시 (onFinished 콜백), 다음 스토리 페이지로 교체 (재귀 호출)
        if (storyPageContext.mounted) {
          // 페이지 유효성 확인
          startStoryFlow(
            storyPageContext, // ✅ 현재 페이지 context 전달
            routineData,
            keywordIndex,
            storyIndex + 1, // 다음 스토리 인덱스
            routineIndex,
            isGold,
            childId, // ✅ childId 전달
          );
        }
      },
    ),
  );

  // 10. 페이지 전환: 첫 스토리 ? push : pushReplacement
  if (storyIndex == 0) {
    // 첫 스토리: MainKeywordPage 위에 PUSH
    Navigator.push(currentStoryContext, pageRoute);
  } else {
    // 이후 스토리: 이전 StoryPage를 교체 (REPLACE)
    Navigator.pushReplacement(currentStoryContext, pageRoute);
  }
}
