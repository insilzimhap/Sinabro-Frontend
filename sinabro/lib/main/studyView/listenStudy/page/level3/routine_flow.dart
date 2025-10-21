// lib/main/studyView/listenStudy/page/level3/routine_flow.dart
import 'package:flutter/material.dart';

// ✨ 절대 경로로 수정
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/data/routine_data.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/model/routine_content.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/intro_topic_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/main_topic_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/main_keyword_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level3/story_page.dart';

/// 🍎 레벨3 루틴 시작 (사과 선택 후 호출됨)
/// - context: 빌드 컨텍스트
/// - routineIndex: 현재 루틴의 인덱스 (0: 아침, 1: 점심, 2: 놀이, 3: 저녁)
/// - isGold: 황금 사과 여부
Future<void> startLevel3Routine(
  BuildContext context,
  int routineIndex, {
  required bool isGold,
}) async {
  final routine = routineContents
      .where((r) => r.id.startsWith("${routineIndex + 1}-"))
      .toList();

  if (routine.isEmpty) return;

  // ✨ [수정] 네비게이션을 위한 최상위 context를 미리 저장
  // (이 context는 ListenAppleSelect의 context입니다)
  final rootContext = context;

  await Navigator.push(
    context,
    MaterialPageRoute(
      // 페이지에 routeName을 설정해줍니다.
      settings: const RouteSettings(name: '/level3-intro-topic'),
      builder: (context) => IntroTopicPage(
        // 이 context는 IntroTopicPage의 context
        title: "째깍째깍... 지금 뭐하는 시간이지?",
        imagePath: "assets/img/contents/studyListen/level3/clock.png",
        onTap: () {
          // 2. 메인 토픽 페이지 표시
          Navigator.push(
            context, // IntroTopicPage의 context를 사용
            MaterialPageRoute(
              // 페이지에 routeName을 설정해줍니다.
              settings: const RouteSettings(name: '/level3-main-topic'),
              builder: (context) => MainTopicPage(
                // 이 context는 MainTopicPage의 context
                topicImagePath: routine.first.topicImagePath,
                title: routine.first.topic,
                audioPath: routine.first.topicAudioPath, // 오디오 경로 전달
                onTap: () {
                  // ✅ 루틴 본격 실행 (ListenAppleSelect의 context 전달)
                  startLevel3RoutineFlow(
                      rootContext, routine, 0, routineIndex, isGold);
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
/// - keywordIndex: 현재 진행 중인 키워드의 인덱스
Future<void> startLevel3RoutineFlow(
  BuildContext context, // ✨ 이 context는 ListenAppleSelect의 context입니다.
  List<RoutineContent> routine,
  int keywordIndex,
  int routineIndex,
  bool isGold,
) async {
  // ✅ 모든 키워드 끝났을 때 (루틴 완료)
  if (keywordIndex >= routine.length) {
    // 1. 팝업을 띄우고 닫힐 때까지 기다립니다.
    //    팝업이 페이지 이동까지 모두 처리해 줄 것입니다.
    // ✨ [수정] ListenAppleSelect의 context를 팝업에 전달합니다.
    await showApplePopup(context, isGold: isGold);

    // 2. ❗️ [삭제] 팝업이 이미 'isFirst'로 이동시켰으므로,
    //    여기서 추가로 popUntil을 호출하면 충돌이 발생합니다.
    // if (context.mounted) {
    //   Navigator.popUntil(
    //       context, ModalRoute.withName(ListenAppleSelect.routeName));
    // }
    return; // 팝업을 띄운 후 이 함수의 역할은 끝입니다.
  }

  final keyword = routine[keywordIndex];

  // ✨ [수정] MainTopicPage를 MainKeywordPage로 교체
  // ListenAppleSelect의 context를 사용해 페이지를 교체합니다.
  await Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      // 페이지에 routeName을 설정해줍니다.
      settings: const RouteSettings(name: '/level3-main-keyword'),
      builder: (context) => MainKeywordPage(
        // 이 context는 MainKeywordPage의 context
        imagePath: keyword.imagePath,
        title: keyword.title,
        audioPath: keyword.titleAudioPath, // 오디오 경로 전달
        onTap: () {
          // ✅ 키워드 탭 -> 스토리 플로우 시작
          startStoryFlow(
              context, // MainKeywordPage의 context를 전달
              routine,
              keywordIndex,
              0, // 첫 번째 스토리부터
              routineIndex,
              isGold);
        },
      ),
    ),
  );
}

/// 스토리 자동 진행 (오디오 완료 시 다음으로)
/// - storyIndex: 현재 진행 중인 스토리의 인덱스
void startStoryFlow(
  BuildContext
      context, // ✨ 이 context는 현재 페이지(MainKeyword or StoryPage)의 context
  List<RoutineContent> routine,
  int keywordIndex,
  int storyIndex,
  int routineIndex,
  bool isGold,
) {
  final keyword = routine[keywordIndex];

  // ✅ 현재 키워드의 스토리 끝 → 다음 키워드로
  if (storyIndex >= keyword.stories.length) {
    // ✨ 모든 스토리가 끝났으므로, 현재 페이지(마지막 StoryPage)를 닫습니다.
    Navigator.pop(context);

    // ✨ [수정] MainKeywordPage의 context를 사용해 다음 키워드 플로우를 시작합니다.
    startLevel3RoutineFlow(
        context, routine, keywordIndex + 1, routineIndex, isGold);
    return;
  }

  final story = keyword.stories[storyIndex];

  final pageRoute = MaterialPageRoute(
    // 페이지에 routeName을 설정해줍니다.
    settings: RouteSettings(name: '/level3-story-${story.id}'),
    // ✨ context_new는 새로 생성될 StoryPage의 context
    builder: (context_new) => StoryPage(
      story: story, // StoryItem 객체 전체 전달
      onFinished: () {
        // ✨ onFinished가 호출되면, '현재 페이지(context_new)'의 context를 사용해
        // 다음 스토리를 띄웁니다.
        if (context_new.mounted) {
          startStoryFlow(
            context_new, // ❗️[핵심 수정] 다음 페이지를 교체할 수 있도록 현재 context를 전달
            routine,
            keywordIndex,
            storyIndex + 1, // 다음 스토리
            routineIndex,
            isGold,
          );
        }
      },
    ),
  );

  if (storyIndex == 0) {
    // 첫 번째 스토리는 MainKeywordPage(context) 위로 PUSH
    Navigator.push(context, pageRoute);
  } else {
    // 두 번째, 세 번째 스토리는 이전 StoryPage(context)를 REPLACE
    Navigator.pushReplacement(context, pageRoute);
  }
}
