import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

// ✅ 모든 색깔 학습 데이터는 이 리스트에 추가됩니다.
// [신규] 첫 번째 나무- 첫 번째 사과에 해당하는 색상 그룹
final List<ColorLessonData> apple1Lessons = [
  redLesson,
  yellowLesson,
  blueLesson,
  whiteLesson,
  blackLesson,
];

// [신규] 두 번째 나무- 두 번째 사과에 해당하는 색상 그룹
final List<ColorLessonData> apple2Lessons = [
  orangeLesson,
  greenLesson,
  brownLesson,
  purpleLesson,
  pinkLesson,
];

// -----------------------------------------------------------------------------
// ❤️ 빨강(RED) 학습 데이터
// -----------------------------------------------------------------------------
final redLesson = ColorLessonData(
  name: '빨강',
  primaryColor: const Color(0xFFE25151),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/red_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/red00.mp3', // 빨강 친구가 왔어요~
    introLine: '빨강 친구가 왔어요~ 뜨겁고 활발한 빨강!',
    transformIntro:
        'audio/tts/studyListen/level1/colors/color_common2.mp3', // 자, 이제! 내가 변신해볼게!
    summaryTitle: 'audio/tts/studyListen/level1/colors/red07.mp3', // 우리는 빨강
    outro: 'audio/tts/studyListen/level1/colors/red08.mp3', // 앞으로 나를 기억해줘!
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/red_01.png',
      line: '맛있는~ 빨간 사과로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/red01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(550, 30, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/red_02.png',
      line: '눈부시게 아름다운 빨간 장미로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/red02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(551, 30, 899, 899),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/red_03.png',
      line: '삐용삐용! 안전안전! 빨간 소방차로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/red03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(550, 30, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/red_01.png',
      name: '사과',
      audioAsset: 'audio/tts/studyListen/level1/colors/red04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(162, 386, 550, 550),
      labelPosition: Offset(326, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/red_02.png',
      name: '장미',
      audioAsset: 'audio/tts/studyListen/level1/colors/red05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(712, 386, 550, 550),
      labelPosition: Offset(876, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/red_03.png',
      name: '소방차',
      audioAsset: 'audio/tts/studyListen/level1/colors/red06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1287, 386, 550, 550),
      labelPosition: Offset(1396, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 💛 노랑(YELLOW) 학습 데이터
// -----------------------------------------------------------------------------
final yellowLesson = ColorLessonData(
  name: '노랑',
  primaryColor: const Color(0xFFFFDA6D),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/yellow_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/yellow00.mp3', // 노랑 친구가 왔어요~
    introLine: '노랑 친구가 왔어요~ 밝고 환한 노랑!',
    transformIntro:
        'audio/tts/studyListen/level1/colors/color_common2.mp3', // 자, 이제! 내가 변신해볼게!
    summaryTitle: 'audio/tts/studyListen/level1/colors/yellow07.mp3', // 우리는 노랑
    outro: 'audio/tts/studyListen/level1/colors/yellow08.mp3', // 앞으로 나를 기억해줘!
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/yellow_01.png',
      line: '달콤한~ 노란 바나나로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/yellow01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(550, 30, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/yellow_02.png',
      line: '삐약삐약! 귀여운 노란 병아리로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/yellow02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(551, 30, 899, 899),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/yellow_03.png',
      line: '활짝~ 예쁜 해바라기로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/yellow03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(550, 30, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/yellow_01.png',
      name: '바나나',
      audioAsset: 'audio/tts/studyListen/level1/colors/yellow04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(146, 386, 550, 550),
      labelPosition: Offset(255, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/yellow_02.png',
      name: '병아리',
      audioAsset: 'audio/tts/studyListen/level1/colors/yellow05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(725, 423, 550, 504),
      labelPosition: Offset(818, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/yellow_03.png',
      name: '해바라기',
      audioAsset: 'audio/tts/studyListen/level1/colors/yellow06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1286, 439, 550, 497),
      labelPosition: Offset(1340, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 💙 파랑(BLUE) 학습 데이터
// -----------------------------------------------------------------------------
final blueLesson = ColorLessonData(
  name: '파랑',
  primaryColor: const Color(0xFF50B8FF),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/blue_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/blue00.mp3',
    introLine: '파랑 친구가 왔어요~ 시원하고 상쾌한 파랑!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/blue07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/blue08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/blue_01.png',
      line: '어푸어푸~! 파란 고래로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/blue01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 254, 899.92, 747),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/blue_02.png',
      line: '훨훨~ 자유로운 파란 나비로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/blue02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(488, 0, 1024, 1024),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/blue_03.png',
      line: '부웅~ 빵빵~! 파란 버스로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/blue03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 254, 899.92, 747),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/blue_01.png',
      name: '고래',
      audioAsset: 'audio/tts/studyListen/level1/colors/blue04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(209, 552, 550, 457),
      labelPosition: Offset(341, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/blue_02.png',
      name: '나비',
      audioAsset: 'audio/tts/studyListen/level1/colors/blue05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(726, 437, 550, 550),
      labelPosition: Offset(890, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/blue_03.png',
      name: '버스',
      audioAsset: 'audio/tts/studyListen/level1/colors/blue06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1242, 552, 550, 457),
      labelPosition: Offset(1438, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 🤍 하양(WHITE) 학습 데이터
// -----------------------------------------------------------------------------
final whiteLesson = ColorLessonData(
  name: '하양',
  primaryColor: const Color(0xFFFFFFFF),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/white_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/white00.mp3',
    introLine: '하양 친구가 왔어요~ 깨끗하고 포근한 하양!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/white07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/white08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/white_01.png',
      line: '포근포근 하얀 구름으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/white01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 201, 899.68, 825),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/white_02.png',
      line: '꽁꽁 오들오들... 하얀 눈사람으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/white02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 169, 899.52, 831),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/white_03.png',
      line: '깡총깡총! 귀여운 하얀 토끼로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/white03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 80, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/white_01.png',
      name: '구름',
      audioAsset: 'audio/tts/studyListen/level1/colors/white04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(146, 398, 646, 597),
      labelPosition: Offset(358, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/white_02.png',
      name: '눈사람',
      audioAsset: 'audio/tts/studyListen/level1/colors/white05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(682, 397, 636, 583),
      labelPosition: Offset(834, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/white_03.png',
      name: '토끼',
      audioAsset: 'audio/tts/studyListen/level1/colors/white06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1208, 368, 620, 620),
      labelPosition: Offset(1421, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 🖤 검정(BLACK) 학습 데이터
// -----------------------------------------------------------------------------
final blackLesson = ColorLessonData(
  name: '검정',
  primaryColor: const Color(0xFF000000),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/black_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/black00.mp3',
    introLine: '검정 친구가 왔어요~ 또렷하고 깊은 검정!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/black07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/black08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/black_01.png',
      line: '영차영차 엉금엉금~ 검정 개미로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/black01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 226, 900.29, 735),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/black_02.png',
      line: '야옹야옹! 귀여운 검정 고양이로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/black02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 46, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/black_03.png',
      line: '딴~ 따단~ 듣기좋은 검정 피아노로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/black03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(560, 80, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/black_01.png',
      name: '개미',
      audioAsset: 'audio/tts/studyListen/level1/colors/black04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(168, 519, 550, 449),
      labelPosition: Offset(332, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/black_02.png',
      name: '고양이',
      audioAsset: 'audio/tts/studyListen/level1/colors/black05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(725, 418, 550, 550),
      labelPosition: Offset(834, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/black_03.png',
      name: '피아노',
      audioAsset: 'audio/tts/studyListen/level1/colors/black06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1275, 418, 550, 550),
      labelPosition: Offset(1384, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 🧡 주황(ORANGE) 학습 데이터
// -----------------------------------------------------------------------------
final orangeLesson = ColorLessonData(
  name: '주황',
  primaryColor: const Color(0xFFFF8A4B),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/orange_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/orange00.mp3',
    introLine: '주황 친구가 왔어요~ 통통 튀는 주황!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/orange07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/orange08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/orange_01.png',
      line: '새콤달콤! 상큼한 주황 귤로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/orange01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 118, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/orange_02.png',
      line: '풍성풍성~ 든든한 주황 호박으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/orange02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 118, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/orange_03.png',
      line: '통통! 에너지 가득 주황 농구공으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/orange03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 118, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/orange_01.png',
      name: '귤',
      audioAsset: 'audio/tts/studyListen/level1/colors/orange04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(177, 418, 550, 550),
      labelPosition: Offset(396, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/orange_02.png',
      name: '호박',
      audioAsset: 'audio/tts/studyListen/level1/colors/orange05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(725, 418, 550, 550),
      labelPosition: Offset(876, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/orange_03.png',
      name: '농구공',
      audioAsset: 'audio/tts/studyListen/level1/colors/orange06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1277, 418, 550, 550),
      labelPosition: Offset(1386, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 💚 초록(GREEN) 학습 데이터
// -----------------------------------------------------------------------------
final greenLesson = ColorLessonData(
  name: '초록',
  primaryColor: const Color(0xFF53DA69),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/green_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/green00.mp3',
    introLine: '초록 친구가 왔어요~ 싱그럽고 시원한 초록!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/green07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/green08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/green_01.png',
      line: '쑥쑥! 튼튼한 초록 나무로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/green01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/green_02.png',
      line: '시원아삭! 달콤한 초록 수박으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/green02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/green_03.png',
      line: '폴짝폴짝! 발랄한 초록 개구리로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/green03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/green_01.png',
      name: '나무',
      audioAsset: 'audio/tts/studyListen/level1/colors/green04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(171, 418, 550, 550),
      labelPosition: Offset(335, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/green_02.png',
      name: '수박',
      audioAsset: 'audio/tts/studyListen/level1/colors/green05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(725, 418, 550, 550),
      labelPosition: Offset(890, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/green_03.png',
      name: '개구리',
      audioAsset: 'audio/tts/studyListen/level1/colors/green06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1273, 418, 550, 550),
      labelPosition: Offset(1382, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 🤎 갈색(BROWN) 학습 데이터
// -----------------------------------------------------------------------------
final brownLesson = ColorLessonData(
  name: '갈색',
  primaryColor: const Color(0xFFA27E57),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/brown_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/brown00.mp3',
    introLine: '갈색 친구가 왔어요~ 든든하고 포근한 갈색!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/brown07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/brown08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/brown_01.png',
      line: '포근포근~ 든든한 갈색 곰으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/brown01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/brown_02.png',
      line: '사르르~ 녹아내리는 갈색 초콜릿으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/brown02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(550, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/brown_03.png',
      line: '데굴데굴~ 귀여운 갈색 도토리로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/brown03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/brown_01.png',
      name: '곰',
      audioAsset: 'audio/tts/studyListen/level1/colors/brown04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(162, 418, 550, 550),
      labelPosition: Offset(381, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/brown_02.png',
      name: '초콜릿',
      audioAsset: 'audio/tts/studyListen/level1/colors/brown05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(712, 418, 550, 550),
      labelPosition: Offset(834, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/brown_03.png',
      name: '도토리',
      audioAsset: 'audio/tts/studyListen/level1/colors/brown06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1262, 418, 550, 550),
      labelPosition: Offset(1371, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 💜 보라(PURPLE) 학습 데이터
// -----------------------------------------------------------------------------
final purpleLesson = ColorLessonData(
  name: '보라',
  primaryColor: const Color(0xFFDB61F7),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/purple_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/purple00.mp3',
    introLine: '보라 친구가 왔어요~ 향기롭고 부드러운 보라!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/purple07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/purple08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/purple_01.png',
      line: '탱글탱글~ 달콤한 보라 포도로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/purple01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/purple_02.png',
      line: '살랑살랑~ 향기로운 보라 라일락으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/purple02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/purple_03.png',
      line: '통통~ 신선한 보라 가지로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/purple03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/purple_01.png',
      name: '포도',
      audioAsset: 'audio/tts/studyListen/level1/colors/purple04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(175, 418, 550, 550),
      labelPosition: Offset(339, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/purple_02.png',
      name: '라일락',
      audioAsset: 'audio/tts/studyListen/level1/colors/purple05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(725, 418, 550, 550),
      labelPosition: Offset(834, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/purple_03.png',
      name: '가지',
      audioAsset: 'audio/tts/studyListen/level1/colors/purple06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1275, 418, 550, 550),
      labelPosition: Offset(1439, 936),
    ),
  ],
);

// -----------------------------------------------------------------------------
// 💖 분홍(PINK) 학습 데이터
// -----------------------------------------------------------------------------
final pinkLesson = ColorLessonData(
  name: '분홍',
  primaryColor: const Color(0xFFFFC0CB),
  characterImagePath:
      'assets/img/contents/studyListen/level1/colors/pink_character.png',
  magicWandImagePath:
      'assets/img/contents/studyListen/level1/colors/magic_wand.png',
  ttsPaths: const TtsAudioPaths(
    intro: 'audio/tts/studyListen/level1/colors/pink00.mp3',
    introLine: '분홍 친구가 왔어요~ 사랑스럽고 귀여운 분홍!',
    transformIntro: 'audio/tts/studyListen/level1/colors/color_common2.mp3',
    summaryTitle: 'audio/tts/studyListen/level1/colors/pink07.mp3',
    outro: 'audio/tts/studyListen/level1/colors/pink08.mp3',
  ),
  sfxPaths: const SfxAudioPaths(
    reveal: 'audio/effect/color_effect2.mp3',
    intro: 'audio/effect/color_effect3.mp3',
    transform: 'audio/effect/color_effect4.mp3',
    outro: 'audio/effect/color_effect5.mp3',
  ),
  transformSteps: [
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/pink_01.png',
      line: '꿀꿀~ 귀여운 분홍 돼지로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/pink01.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/pink_02.png',
      line: '말랑말랑~ 달콤한 분홍 복숭아로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/pink02.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 93, 900, 900),
    ),
    const TransformStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/pink_03.png',
      line: '몽글몽글~ 달콤한 분홍 솜사탕으로 변신 완료!',
      audioAsset: 'audio/tts/studyListen/level1/colors/pink03.mp3',
      minDurationMs: 4800,
      figmaRect: Rect.fromLTWH(553, 57, 900, 900),
    ),
  ],
  summarySteps: [
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/pink_01.png',
      name: '돼지',
      audioAsset: 'audio/tts/studyListen/level1/colors/pink04.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(150, 388, 600, 600),
      labelPosition: Offset(339, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/pink_02.png',
      name: '복숭아',
      audioAsset: 'audio/tts/studyListen/level1/colors/pink05.mp3',
      minDurationMs: 1200,
      figmaRect: Rect.fromLTWH(725, 418, 550, 550),
      labelPosition: Offset(834, 936),
    ),
    const SummaryStep(
      imagePath: 'assets/img/contents/studyListen/level1/colors/pink_03.png',
      name: '솜사탕',
      audioAsset: 'audio/tts/studyListen/level1/colors/pink06.mp3',
      minDurationMs: 1400,
      figmaRect: Rect.fromLTWH(1275, 418, 550, 550),
      labelPosition: Offset(1384, 936),
    ),
  ],
);
