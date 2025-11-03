/// 쓰기 게임 문제 매핑 (Stage 2~3)
/// key: 화면에 제시된 문자/단어
/// value: wg_question_id
/// 프론트는 이 값을 WriteGameApi.sendChoice() 호출 시 전달한다.

/// ────────────── Stage 2 자음 (FR_WG_005) ──────────────
const Map<String, String> consonantQuestionMap = {
  'ㄱ': 'WG_Q5_01',
  'ㄲ': 'WG_Q5_02',
  'ㄷ': 'WG_Q5_03',
  'ㄸ': 'WG_Q5_04',
  'ㅅ': 'WG_Q5_05',
  'ㅆ': 'WG_Q5_06',
  'ㅈ': 'WG_Q5_07',
  'ㅉ': 'WG_Q5_08',
  'ㅂ': 'WG_Q5_09',
  'ㅃ': 'WG_Q5_10',
  'ㄴ': 'WG_Q5_11',
  'ㄹ': 'WG_Q5_12',
  'ㅁ': 'WG_Q5_13',
  'ㅇ': 'WG_Q5_14',
  'ㅊ': 'WG_Q5_15',
  'ㅋ': 'WG_Q5_16',
  'ㅌ': 'WG_Q5_17',
  'ㅍ': 'WG_Q5_18',
  'ㅎ': 'WG_Q5_19',
};

/// ────────────── Stage 2 모음 (FR_WG_006 가정) ──────────────
const Map<String, String> vowelQuestionMap = {
  'ㅏ': 'WG_Q6_01',
  'ㅑ': 'WG_Q6_02',
  'ㅓ': 'WG_Q6_03',
  'ㅕ': 'WG_Q6_04',
  'ㅗ': 'WG_Q6_05',
  'ㅛ': 'WG_Q6_06',
  'ㅜ': 'WG_Q6_07',
  'ㅠ': 'WG_Q6_08',
  'ㅡ': 'WG_Q6_09',
  'ㅣ': 'WG_Q6_10',
  'ㅟ': 'WG_Q6_11', 
  'ㅘ': 'WG_Q6_12', 
  'ㅢ': 'WG_Q6_13', 
  'ㅙ': 'WG_Q6_14', 
  'ㅚ': 'WG_Q6_15', 
  'ㅝ': 'WG_Q6_16', 
  'ㅞ': 'WG_Q6_17', 
};

/// ────────────── Stage 2 자모음 (FR_WG_007) ──────────────
const Map<String, String> consonantVowelQuestionMap = {
  'ㄱ': 'WG_Q7_01',
  'ㄲ': 'WG_Q7_02',
  'ㄷ': 'WG_Q7_03',
  'ㄸ': 'WG_Q7_04',
  'ㅅ': 'WG_Q7_05',
  'ㅆ': 'WG_Q7_06',
  'ㅈ': 'WG_Q7_07',
  'ㅉ': 'WG_Q7_08',
  'ㅂ': 'WG_Q7_09',
  'ㅃ': 'WG_Q7_10',
  'ㄴ': 'WG_Q7_11',
  'ㄹ': 'WG_Q7_12',
  'ㅁ': 'WG_Q7_13',
  'ㅇ': 'WG_Q7_14',
  'ㅊ': 'WG_Q7_15',
  'ㅋ': 'WG_Q7_16',
  'ㅌ': 'WG_Q7_17',
  'ㅍ': 'WG_Q7_18',
  'ㅎ': 'WG_Q7_19',
  'ㅏ': 'WG_Q7_20',
  'ㅑ': 'WG_Q7_21',
  'ㅓ': 'WG_Q7_22',
  'ㅕ': 'WG_Q7_23',
  'ㅗ': 'WG_Q7_24',
  'ㅛ': 'WG_Q7_25',
  'ㅜ': 'WG_Q7_26',
  'ㅠ': 'WG_Q7_27',
  'ㅡ': 'WG_Q7_28',
  'ㅣ': 'WG_Q7_29',
  'ㅟ': 'WG_Q7_30',
  'ㅘ': 'WG_Q7_31',
  'ㅢ': 'WG_Q7_32',
};

/// ────────────── Stage 3 동물 (FR_WG_008) ──────────────
const Map<String, String> animalQuestionMap = {
  '강아지': 'WG_Q8_01',
  '고양이': 'WG_Q8_02',
  '오리': 'WG_Q8_11',
  '개구리': 'WG_Q8_13',
  '거북이': 'WG_Q8_14',
  '토끼': 'WG_Q8_15',
};

/// ────────────── Stage 3 과일 (FR_WG_009) ──────────────
const Map<String, String> fruitQuestionMap = {
  '사과': 'WG_Q9_01',
  '바나나': 'WG_Q9_02',
  '딸기': 'WG_Q9_03',
  '포도': 'WG_Q9_04',
  '수박': 'WG_Q9_05',
  '복숭아': 'WG_Q9_06',
};

/// ────────────── Stage 3 야채 (FR_WG_010) ──────────────
const Map<String, String> vegetableQuestionMap = {
  '감자': 'WG_Q10_01',
  '고구마': 'WG_Q10_02',
  '오이': 'WG_Q10_03',
  '배추': 'WG_Q10_04',
  '옥수수': 'WG_Q10_05',
  '버섯': 'WG_Q10_06',
};

/// ────────────── Stage 3 몸 (FR_WG_011 가정) ──────────────
const Map<String, String> bodyQuestionMap = {
  '눈': 'WG_Q11_01',
  '코': 'WG_Q11_02',
  '입': 'WG_Q11_03',
  '귀': 'WG_Q11_04',
  '손': 'WG_Q11_05',
  '발': 'WG_Q11_06',
};

/// ────────────── 공통 유틸 ──────────────
String requireWgQuestionId(Map<String, String> map, String key, {String? ctx}) {
  final qid = map[key];
  if (qid == null) {
    throw StateError(
      'wg_question_id not found for "$key"${ctx != null ? ' [$ctx]' : ''}',
    );
  }
  return qid;
}
