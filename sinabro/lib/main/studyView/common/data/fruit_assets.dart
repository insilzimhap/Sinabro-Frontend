// lib/main/studyView/common/data/fruit_assets.dart

/*
 * ----------------------------------------------------------------
 * [Fruit ID <-> 이미지 에셋 경로 매핑]
 *
 * 백엔드에서 사용하는 Fruit ID를 프론트엔드의 이미지 에셋 경로와
 * 연결하는 맵(Map)입니다. 이 맵은 studyView 및 gameView 전체에서
 * 사과 이미지를 표시하는 데 사용됩니다.
 *
 * - 학습 모드: 스테이지 마지막 사과(황금 사과)만 다른 이미지를 사용합니다.
 * - 게임 모드: 각 Fruit ID별로 고유 이미지를 가질 수 있습니다.
 * (현재는 임시 경로이며, 실제 게임 디자인에 맞춰 수정 필요)
 * ----------------------------------------------------------------
 */

// 🍎 열매(Fruit) ID와 기본 이미지 에셋 경로를 매핑하는 상수
const Map<String, String> fruitImageMap = {
  // --------------------
  // 🎧 듣기 학습 (Listening Study)
  // --------------------
  // ST001 (Level 1)
  "FR_LS_001": "assets/img/contents/studyListen/apple.png", // 색상 A
  "FR_LS_002": "assets/img/contents/studyListen/apple.png", // 색상 B
  "FR_LS_003": "assets/img/contents/studyListen/apple.png", // 동물 A
  "FR_LS_004": "assets/img/contents/studyListen/apple.png", // 동물 B
  "FR_LS_005": "assets/img/contents/studyListen/gold_apple.png", // 동물 C (Gold)
  // ST002 (Level 2)
  "FR_LS_006": "assets/img/contents/studyListen/apple.png", // 가족
  "FR_LS_007": "assets/img/contents/studyListen/apple.png", // 기본 감정
  "FR_LS_008": "assets/img/contents/studyListen/apple.png", // 복잡 감정
  "FR_LS_009": "assets/img/contents/studyListen/apple.png", // 숫자 1~5
  "FR_LS_010":
      "assets/img/contents/studyListen/gold_apple.png", // 숫자 6~10 (Gold)
  // ST003 (Level 3)
  "FR_LS_011": "assets/img/contents/studyListen/apple.png", // 일상 (아침)
  "FR_LS_012": "assets/img/contents/studyListen/apple.png", // 일상 (점심)
  "FR_LS_013": "assets/img/contents/studyListen/apple.png", // 일상 (놀이)
  "FR_LS_014":
      "assets/img/contents/studyListen/gold_apple.png", // 일상 (저녁) (Gold)

  // --------------------
  // ✍️ 쓰기 학습 (Writing Study)
  // --------------------
  // ST004 (Level 1)
  "FR_WR_001": "assets/img/contents/studyListen/apple.png", // 직선
  "FR_WR_002": "assets/img/contents/studyListen/apple.png", // 곡선1
  "FR_WR_003": "assets/img/contents/studyListen/apple.png", // 곡선2
  "FR_WR_004": "assets/img/contents/studyListen/gold_apple.png", // 도형 (Gold)
  // ST005 (Level 2)
  "FR_WR_005": "assets/img/contents/studyListen/apple.png", // 자음1
  "FR_WR_006": "assets/img/contents/studyListen/apple.png", // 자음2
  "FR_WR_007": "assets/img/contents/studyListen/apple.png", // 모음1
  "FR_WR_008": "assets/img/contents/studyListen/gold_apple.png", // 모음2 (Gold)
  // ST006 (Level 3)
  "FR_WR_009": "assets/img/contents/studyListen/apple.png", // 동물
  "FR_WR_010": "assets/img/contents/studyListen/apple.png", // 과일
  "FR_WR_011": "assets/img/contents/studyListen/apple.png", // 야채
  "FR_WR_012": "assets/img/contents/studyListen/gold_apple.png", // 우리 몸 (Gold)

  // --------------------
  // 🎮 듣기 게임 (Listening Game) - 게임 디자인에 맞춰 경로 수정 필요
  // --------------------
  // ST007 (Level 1)
  "FR_LG_001":
      "assets/img/contents/gameListen/level1/apple_1.png", // 색상1 (게임용 개별 이미지)
  "FR_LG_002": "assets/img/contents/gameListen/level1/apple_2.png", // 색상2
  "FR_LG_003": "assets/img/contents/gameListen/level1/apple_3.png", // 집 동물
  "FR_LG_004": "assets/img/contents/gameListen/level1/apple_4.png", // 동물원 동물
  "FR_LG_005":
      "assets/img/contents/gameListen/gold_apple.png", // 연못/강가 동물 (Gold) - 예시 경로
  // ST008 (Level 2)
  "FR_LG_006": "assets/img/contents/gameListen/level2/apple_1.png", // 가족
  "FR_LG_007": "assets/img/contents/gameListen/level2/apple_2.png", // 단순 감정
  "FR_LG_008":
      "assets/img/contents/gameListen/gold_apple.png", // 복잡 감정 (Gold) - 예시 경로
  // ST009 (Level 3)
  "FR_LG_009": "assets/img/contents/gameListen/level3/apple_1.png", // 숫자 1~5
  "FR_LG_010":
      "assets/img/contents/gameListen/gold_apple.png", // 숫자 6~10 (Gold) - 예시 경로

  // --------------------
  // 🪶 쓰기 게임 (Writing Game) - 게임 디자인에 맞춰 경로 수정 필요
  // --------------------
  // ST010 (Level 1)
  "FR_WG_001": "assets/img/contents/gameWrite/level1/apple_1.png", // 직선 긋기
  "FR_WG_002": "assets/img/contents/gameWrite/level1/apple_2.png", // 곡선 긋기1
  "FR_WG_003": "assets/img/contents/gameWrite/level1/apple_3.png", // 곡선 긋기2
  "FR_WG_004":
      "assets/img/contents/gameWrite/gold_apple.png", // 도형 그리기 (Gold) - 예시 경로
  // ST011 (Level 2)
  "FR_WG_005": "assets/img/contents/gameWrite/level2/apple_1.png", // 자음 (쿠키1)
  "FR_WG_006": "assets/img/contents/gameWrite/level2/apple_2.png", // 모음 (쿠키2)
  "FR_WG_007":
      "assets/img/contents/gameWrite/gold_apple.png", // 자모음 (쿠키3) (Gold) - 예시 경로
  // ST012 (Level 3)
  "FR_WG_008": "assets/img/contents/gameWrite/level3/apple_1.png", // 동물 (주머니1)
  "FR_WG_009": "assets/img/contents/gameWrite/level3/apple_2.png", // 과일 (주머니2)
  "FR_WG_010": "assets/img/contents/gameWrite/level3/apple_3.png", // 야채 (주머니3)
  "FR_WG_011":
      "assets/img/contents/gameWrite/gold_apple.png", // 우리 몸 (주머니4) (Gold) - 예시 경로
};

// 기본 이미지 경로 (fruitImageMap에 해당 ID가 없거나 null일 경우 사용될 백업 이미지)
const String defaultAppleAsset =
    "assets/img/contents/studyListen/apple.png"; // 가장 기본적인 빨간 사과

/*
// (선택 사항) 상태별 이미지 경로를 가져오는 함수
// - 게임 모드 등에서 잠금(_locked) 또는 클리어(_cleared) 상태 이미지를 표시할 때 사용 가능
// - 사용하려면 아래 enum 정의와 함께 주석 해제 후, 상태별 이미지 파일(_locked.png, _cleared.png) 필요

// 열매 상태를 나타내는 enum (별도 파일 추천: e.g., fruit_state.dart)
// enum FruitStateType { normal, locked, cleared }

String getFruitImage(String fruitId, {FruitStateType state = FruitStateType.normal}) {
  // fruitImageMap에서 기본 경로를 찾거나, 없으면 defaultAppleAsset 사용
  // null safety를 위해 ?? 연산자 사용
  final base = fruitImageMap[fruitId] ?? defaultAppleAsset;

  // 상태(state)에 따라 파일 이름에 접미사(_locked, _cleared) 추가
  switch (state) {
    case FruitStateType.locked:
      // 게임 모드용 잠금 이미지 경로 반환 (예: apple.png -> apple_locked.png)
      // 실제 _locked.png 파일이 해당 경로에 존재해야 함
      // 경로에 gold_apple.png가 있을 경우 gold_apple_locked.png 가 되도록 처리
      if (!base.endsWith('.png')) return base; // .png가 아니면 원본 반환 (오류 방지)
      return base.replaceFirst('.png', '_locked.png');

    case FruitStateType.cleared:
      // 클리어 상태 이미지 경로 반환 (예: apple.png -> apple_cleared.png)
      // 실제 _cleared.png 파일이 해당 경로에 존재해야 함
      if (!base.endsWith('.png')) return base;
      return base.replaceFirst('.png', '_cleared.png');

    default: // normal
      // 일반 상태(활성화)는 기본 경로 반환
      return base;
  }
}
*/
