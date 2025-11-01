// lib/main/studyView/listenStudy/navigation/listen_study_router.dart

/*
 * ----------------------------------------------------------------
 * [듣기 학습 네비게이션 라우터]
 *
 * 'listen_study_apple.dart'에서 fruitId를 받아
 * 적절한 학습 콘텐츠 페이지로 이동시키는 역할을 합니다.
 *
 * - fruitId를 기반으로 어떤 페이지(ColorEntryPage, AnimalStudyEntry 등) 또는
 * 어떤 함수(startLevel2Routine 등)를 호출할지 결정합니다.
 * - 페이지 이동 시 필요한 arguments(isGold, childId 등)를 전달합니다.
 * ----------------------------------------------------------------
 */
import 'package:flutter/material.dart';

// 레벨 1 페이지 및 데이터 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_entry_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/data/color_lessons.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_study_entry.dart';
// 레벨 2 흐름 시작 함수 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level2/routine_flow.dart';
// 레벨 3 흐름 시작 함수 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level3/routine_flow.dart';

// 라우트 이름 상수 (임시 정의, AppConstants로 옮기는 것 권장)
const routeNameColorEntry = '/study/listen/color-entry';
const routeNameAnimalEntry = '/study/listen/animal-entry';

/// 🍎 듣기 학습 전용 네비게이션 함수
///   - `ListenAppleSelect` 위젯에서 사과 탭 시 호출됩니다.
///   - `fruitId`를 기준으로 적절한 학습 콘텐츠를 시작시킵니다.
///
/// @param context BuildContext for navigation.
/// @param fruitId 사용자가 탭한 사과의 고유 ID (e.g., "FR_LS_001").
/// @param isGold 해당 사과가 황금 사과(스테이지 마지막)인지 여부.
/// @param childId 현재 학습 중인 자녀의 ID.
Future<void> navigateToListenStudy(
    BuildContext context, String fruitId, bool isGold, String childId) {
  debugPrint(
      '[ListenRouter] Navigating -> Fruit: $fruitId, Child: $childId, Gold: $isGold');

  // fruitId에 따라 분기 처리
  switch (fruitId) {
    // --- 레벨 1 (ST001) ---
    case 'FR_LS_001': // 색상 A
      return Navigator.pushNamed(context, routeNameColorEntry, arguments: {
        'lessonsToShow': apple1Lessons,
        'isGold': isGold,
        'childId': childId,
        'fruitId': fruitId
      });
      break;
    case 'FR_LS_002': // 색상 B
      return Navigator.pushNamed(context, routeNameColorEntry, arguments: {
        'lessonsToShow': apple2Lessons,
        'isGold': isGold,
        'childId': childId,
        'fruitId': fruitId
      });
      break;
    case 'FR_LS_003': // 동물 A
      return Navigator.pushNamed(context, routeNameAnimalEntry, arguments: {
        'fruitId': 'FR_LS_003',
        'isGold': isGold,
        'childId': childId,
        'fruitId': fruitId
      });
      break;
    case 'FR_LS_004': // 동물 B
      return Navigator.pushNamed(context, routeNameAnimalEntry, arguments: {
        'fruitId': 'FR_LS_004',
        'isGold': isGold,
        'childId': childId,
        'fruitId': fruitId
      });
      break;
    case 'FR_LS_005': // 동물 C
      return Navigator.pushNamed(context, routeNameAnimalEntry, arguments: {
        'fruitId': 'FR_LS_005',
        'isGold': isGold,
        'childId': childId,
        'fruitId': fruitId
      });
      break;

    // --- 레벨 2 (ST002) ---
    case 'FR_LS_006': // 가족
      return startLevel2Routine(context, isGold: isGold, childId: childId, fruitId: fruitId,);
      break;
    case 'FR_LS_007': // 기본 감정
      return startLevel2Routine2(context, 0,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 0
      break;
    case 'FR_LS_008': // 복잡 감정
      return startLevel2Routine2(context, 1,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 1
      break;
    case 'FR_LS_009': // 숫자 1~5
      return startLevel2Routine3(context, 2,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 2
      break;
    case 'FR_LS_010': // 숫자 6~10
      return startLevel2Routine3(context, 3,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 3
      break;

    // --- 레벨 3 (ST003) ---
    case 'FR_LS_011': // 일상 (아침)
      return startLevel3Routine(context, 0,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 0
      break;
    case 'FR_LS_012': // 일상 (점심)
      return startLevel3Routine(context, 1,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 1
      break;
    case 'FR_LS_013': // 일상 (놀이)
      return startLevel3Routine(context, 2,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 2
      break;
    case 'FR_LS_014': // 일상 (저녁)
      return startLevel3Routine(context, 3,
          isGold: isGold, childId: childId, fruitId: fruitId); // routineIndex 3
      break;

    default:
      // 정의되지 않은 fruitId 처리
      debugPrint("[ListenRouter] Error: Unknown fruitId '$fruitId'");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'$fruitId' 학습을 열 수 없습니다.")),
      );
      // ⭐️ [수정] 오류가 나도 Future를 반환해야 함
      return Future.value();
  }
}
