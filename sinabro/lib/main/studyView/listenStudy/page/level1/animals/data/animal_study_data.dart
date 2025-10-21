// lib/main/studyView/listenStudy/page/level1/animals/data/animal_study_data.dart

import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/data/animal_study_models.dart';

// =============================================================================
// 🍎 열매 1: 집 주변 동물 (FR_LS_003)
// =============================================================================
final animalGroup1 = AnimalGroupData(
  groupName: '집 주변 동물',
  introCharacter: 'assets/img/character/mungji_explorer.png',
  introText: '이번에는 집 주변으로 가볼까요?',
  introAudio: 'assets/audio/tts/studyListen/level1/animals/animals_step1.mp3',
  introBgImage: 'assets/img/contents/studyListen/level1/animals/animal1.png',
  finalOutroText: '집 주변에서 만날 수 있는\n동물 친구들을 모두 만났어요!',
  finalOutroAudio:
      'assets/audio/tts/studyListen/level1/animals/animals_next1.mp3',
  animals: const [
    dogData,
    catData,
    duckData,
    birdData,
    flogData, // 'frog'의 오타로 보이나, 기존 애셋 경로를 따름
  ],
);

const dogData = AnimalContentData(
  name: 'dog',
  silhouetteImage: 'assets/img/contents/studyListen/level1/animals/dog_00.png',
  silhouetteRect: Rect.fromLTWH(601, 0, 799, 828),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/dog_01.png',
    'assets/img/contents/studyListen/level1/animals/dog_02.png',
    'assets/img/contents/studyListen/level1/animals/dog_03.png',
    'assets/img/contents/studyListen/level1/animals/dog_04.png',
    'assets/img/contents/studyListen/level1/animals/dog_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/dog01.mp3',
    'assets/audio/tts/studyListen/level1/animals/dog02.mp3',
    'assets/audio/tts/studyListen/level1/animals/dog03.mp3',
    'assets/audio/tts/studyListen/level1/animals/dog04.mp3',
    'assets/audio/tts/studyListen/level1/animals/dog05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/dog_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/dog06.mp3',
  outroText: '강아지는 신나게 뛰어놀러 갔어요!',
);

const catData = AnimalContentData(
  name: 'cat',
  silhouetteImage: 'assets/img/contents/studyListen/level1/animals/cat_00.png',
  silhouetteRect: Rect.fromLTWH(641, 6, 805.59, 828),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/cat_01.png',
    'assets/img/contents/studyListen/level1/animals/cat_02.png',
    'assets/img/contents/studyListen/level1/animals/cat_03.png',
    'assets/img/contents/studyListen/level1/animals/cat_04.png',
    'assets/img/contents/studyListen/level1/animals/cat_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/cat01.mp3',
    'assets/audio/tts/studyListen/level1/animals/cat02.mp3',
    'assets/audio/tts/studyListen/level1/animals/cat03.mp3',
    'assets/audio/tts/studyListen/level1/animals/cat04.mp3',
    'assets/audio/tts/studyListen/level1/animals/cat05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/cat_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/cat06.mp3',
  outroText: '고양이는 조심조심 걸어 집으로갔어요',
);

const duckData = AnimalContentData(
  name: 'duck',
  silhouetteImage: 'assets/img/contents/studyListen/level1/animals/duck_00.png',
  silhouetteRect: Rect.fromLTWH(637, 6, 805, 805),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/duck_01.png',
    'assets/img/contents/studyListen/level1/animals/duck_02.png',
    'assets/img/contents/studyListen/level1/animals/duck_03.png',
    'assets/img/contents/studyListen/level1/animals/duck_04.png',
    'assets/img/contents/studyListen/level1/animals/duck_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/duck01.mp3',
    'assets/audio/tts/studyListen/level1/animals/duck02.mp3',
    'assets/audio/tts/studyListen/level1/animals/duck03.mp3',
    'assets/audio/tts/studyListen/level1/animals/duck04.mp3',
    'assets/audio/tts/studyListen/level1/animals/duck05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/duck_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/duck06.mp3',
  outroText: '오리가 어푸어푸 헤엄쳐 갔어요',
);

const birdData = AnimalContentData(
  name: 'bird',
  silhouetteImage: 'assets/img/contents/studyListen/level1/animals/bird_00.png',
  silhouetteRect: Rect.fromLTWH(353.45, 45, 1206.8, 804.12),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/bird_01.png',
    'assets/img/contents/studyListen/level1/animals/bird_02.png',
    'assets/img/contents/studyListen/level1/animals/bird_03.png',
    'assets/img/contents/studyListen/level1/animals/bird_04.png',
    'assets/img/contents/studyListen/level1/animals/bird_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/bird01.mp3',
    'assets/audio/tts/studyListen/level1/animals/bird02.mp3',
    'assets/audio/tts/studyListen/level1/animals/bird03.mp3',
    'assets/audio/tts/studyListen/level1/animals/bird04.mp3',
    'assets/audio/tts/studyListen/level1/animals/bird05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/bird_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/bird06.mp3',
  outroText: '새가 훨훨 하늘로 날아갔어요!',
);

const flogData = AnimalContentData(
  name: 'flog',
  silhouetteImage: 'assets/img/contents/studyListen/level1/animals/flog_00.png',
  silhouetteRect: Rect.fromLTWH(598, 6, 805, 805),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/flog_01.png',
    'assets/img/contents/studyListen/level1/animals/flog_02.png',
    'assets/img/contents/studyListen/level1/animals/flog_03.png',
    'assets/img/contents/studyListen/level1/animals/flog_04.png',
    'assets/img/contents/studyListen/level1/animals/flog_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/flog01.mp3',
    'assets/audio/tts/studyListen/level1/animals/flog02.mp3',
    'assets/audio/tts/studyListen/level1/animals/flog03.mp3',
    'assets/audio/tts/studyListen/level1/animals/flog04.mp3',
    'assets/audio/tts/studyListen/level1/animals/flog05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/flog_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/flog06.mp3',
  outroText: '개구리는 수영하러 폴짝폴짝 뛰어갔어요!',
);

// =============================================================================
// 🍎 열매 2: 동물원 동물 (FR_LS_004)
// =============================================================================
final animalGroup2 = AnimalGroupData(
  groupName: '동물원 동물',
  introCharacter: 'assets/img/character/gonyam_explorer.png',
  introText: '이번에는 동물원으로 가볼까요?',
  introAudio: 'assets/audio/tts/studyListen/level1/animals/animals_step2.mp3',
  introBgImage: 'assets/img/contents/studyListen/level1/animals/animal2.png',
  finalOutroText: '동물원에서 만날 수 있는\n동물 친구들을 모두 만났어요!',
  finalOutroAudio:
      'assets/audio/tts/studyListen/level1/animals/animals_next2.mp3',
  animals: const [
    sheepData,
    tigerData,
    monkeyData,
    rabbitData,
    elephantData,
  ],
);

const sheepData = AnimalContentData(
  name: 'sheep',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/sheep_00.png',
  silhouetteRect: Rect.fromLTWH(410, 45, 1180, 787),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/sheep_01.png',
    'assets/img/contents/studyListen/level1/animals/sheep_02.png',
    'assets/img/contents/studyListen/level1/animals/sheep_03.png',
    'assets/img/contents/studyListen/level1/animals/sheep_04.png',
    'assets/img/contents/studyListen/level1/animals/sheep_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/sheep01.mp3',
    'assets/audio/tts/studyListen/level1/animals/sheep02.mp3',
    'assets/audio/tts/studyListen/level1/animals/sheep03.mp3',
    'assets/audio/tts/studyListen/level1/animals/sheep04.mp3',
    'assets/audio/tts/studyListen/level1/animals/sheep05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/sheep_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/sheep06.mp3',
  outroText: '양은 조심조심 목장으로 갔어요',
);

const tigerData = AnimalContentData(
  name: 'tiger',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/tiger_00.png',
  silhouetteRect: Rect.fromLTWH(360, 25, 1280, 853),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/tiger_01.png',
    'assets/img/contents/studyListen/level1/animals/tiger_02.png',
    'assets/img/contents/studyListen/level1/animals/tiger_03.png',
    'assets/img/contents/studyListen/level1/animals/tiger_04.png',
    'assets/img/contents/studyListen/level1/animals/tiger_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/tiger01.mp3',
    'assets/audio/tts/studyListen/level1/animals/tiger02.mp3',
    'assets/audio/tts/studyListen/level1/animals/tiger03.mp3',
    'assets/audio/tts/studyListen/level1/animals/tiger04.mp3',
    'assets/audio/tts/studyListen/level1/animals/tiger05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/tiger_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/tiger06.mp3',
  outroText: '호랑이는 씩씩하게 산으로 올라갔어요',
);

const monkeyData = AnimalContentData(
  name: 'monkey',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/monkey_00.png',
  silhouetteRect: Rect.fromLTWH(360, 25, 1280, 853),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/monkey_01.png',
    'assets/img/contents/studyListen/level1/animals/monkey_02.png',
    'assets/img/contents/studyListen/level1/animals/monkey_03.png',
    'assets/img/contents/studyListen/level1/animals/monkey_04.png',
    'assets/img/contents/studyListen/level1/animals/monkey_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/monkey01.mp3',
    'assets/audio/tts/studyListen/level1/animals/monkey02.mp3',
    'assets/audio/tts/studyListen/level1/animals/monkey03.mp3',
    'assets/audio/tts/studyListen/level1/animals/monkey04.mp3',
    'assets/audio/tts/studyListen/level1/animals/monkey05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/monkey_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/monkey06.mp3',
  outroText: '원숭이는 바나나를 찾으러 갔어요',
);

const rabbitData = AnimalContentData(
  name: 'rabbit',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/rabbit_00.png',
  silhouetteRect: Rect.fromLTWH(265, 34, 1375, 916),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/rabbit_01.png',
    'assets/img/contents/studyListen/level1/animals/rabbit_02.png',
    'assets/img/contents/studyListen/level1/animals/rabbit_03.png',
    'assets/img/contents/studyListen/level1/animals/rabbit_04.png',
    'assets/img/contents/studyListen/level1/animals/rabbit_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/rabbit01.mp3',
    'assets/audio/tts/studyListen/level1/animals/rabbit02.mp3',
    'assets/audio/tts/studyListen/level1/animals/rabbit03.mp3',
    'assets/audio/tts/studyListen/level1/animals/rabbit04.mp3',
    'assets/audio/tts/studyListen/level1/animals/rabbit05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/rabbit_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/rabbit06.mp3',
  outroText: '토끼는 깡총깡총 당근을 먹으러 갔어요',
);

const elephantData = AnimalContentData(
  name: 'elephant',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/elephant_00.png',
  silhouetteRect: Rect.fromLTWH(230, -35, 1369, 913),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/elephant_01.png',
    'assets/img/contents/studyListen/level1/animals/elephant_02.png',
    'assets/img/contents/studyListen/level1/animals/elephant_03.png',
    'assets/img/contents/studyListen/level1/animals/elephant_04.png',
    'assets/img/contents/studyListen/level1/animals/elephant_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/elephant01.mp3',
    'assets/audio/tts/studyListen/level1/animals/elephant02.mp3',
    'assets/audio/tts/studyListen/level1/animals/elephant03.mp3',
    'assets/audio/tts/studyListen/level1/animals/elephant04.mp3',
    'assets/audio/tts/studyListen/level1/animals/elephant05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/elephant_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/elephant06.mp3',
  outroText: '코끼리는 긴 코로 물을 마시러 갔어요',
);

// =============================================================================
// 🍎 열매 3: 저 멀리 동물 (FR_LS_005)
// =============================================================================
final animalGroup3 = AnimalGroupData(
  groupName: '저 멀리 동물',
  introCharacter: 'assets/img/character/tosoom_explorer.png',
  introText: '이번에는 더 멀리 가볼까요?',
  introAudio: 'assets/audio/tts/studyListen/level1/animals/animals_step3.mp3',
  introBgImage: 'assets/img/contents/studyListen/level1/animals/animal3.png',
  finalOutroText: '저 멀리에서 만날 수 있는\n동물 친구들을 모두 만났어요!',
  finalOutroAudio:
      'assets/audio/tts/studyListen/level1/animals/animals_next3.mp3',
  animals: const [
    chickenData,
    penguinData,
    turtleData,
    mouseData,
    pigData,
  ],
);

const chickenData = AnimalContentData(
  name: 'chicken',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/chicken_00.png',
  silhouetteRect: Rect.fromLTWH(400, 0, 1280, 853),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/chicken_01.png',
    'assets/img/contents/studyListen/level1/animals/chicken_02.png',
    'assets/img/contents/studyListen/level1/animals/chicken_03.png',
    'assets/img/contents/studyListen/level1/animals/chicken_04.png',
    'assets/img/contents/studyListen/level1/animals/chicken_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/chicken01.mp3',
    'assets/audio/tts/studyListen/level1/animals/chicken02.mp3',
    'assets/audio/tts/studyListen/level1/animals/chicken03.mp3',
    'assets/audio/tts/studyListen/level1/animals/chicken04.mp3',
    'assets/audio/tts/studyListen/level1/animals/chicken05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/chicken_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/chicken06.mp3',
  outroText: '닭은 꼬꼬댁~ 친구들을 불러 모으러 갔어요',
);

const penguinData = AnimalContentData(
  name: 'penguin',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/penguin_00.png',
  silhouetteRect: Rect.fromLTWH(233, -74, 1536, 1024),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/penguin_01.png',
    'assets/img/contents/studyListen/level1/animals/penguin_02.png',
    'assets/img/contents/studyListen/level1/animals/penguin_03.png',
    'assets/img/contents/studyListen/level1/animals/penguin_04.png',
    'assets/img/contents/studyListen/level1/animals/penguin_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/penguin01.mp3',
    'assets/audio/tts/studyListen/level1/animals/penguin02.mp3',
    'assets/audio/tts/studyListen/level1/animals/penguin03.mp3',
    'assets/audio/tts/studyListen/level1/animals/penguin04.mp3',
    'assets/audio/tts/studyListen/level1/animals/penguin05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/penguin_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/penguin06.mp3',
  outroText: '펭귄은 뒤뚱뒤뚱 걸어 집으로갔어요',
);

const turtleData = AnimalContentData(
  name: 'turtle',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/turtle_00.png',
  silhouetteRect: Rect.fromLTWH(400, 80, 1155, 798),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/turtle_01.png',
    'assets/img/contents/studyListen/level1/animals/turtle_02.png',
    'assets/img/contents/studyListen/level1/animals/turtle_03.png',
    'assets/img/contents/studyListen/level1/animals/turtle_04.png',
    'assets/img/contents/studyListen/level1/animals/turtle_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/turtle01.mp3',
    'assets/audio/tts/studyListen/level1/animals/turtle02.mp3',
    'assets/audio/tts/studyListen/level1/animals/turtle03.mp3',
    'assets/audio/tts/studyListen/level1/animals/turtle04.mp3',
    'assets/audio/tts/studyListen/level1/animals/turtle05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/turtle_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/turtle06.mp3',
  outroText: '거북이가 엉금엉금 기어갔어요',
);

const mouseData = AnimalContentData(
  name: 'mouse',
  silhouetteImage:
      'assets/img/contents/studyListen/level1/animals/mouse_00.png',
  silhouetteRect: Rect.fromLTWH(176, -117, 1493, 995),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/mouse_01.png',
    'assets/img/contents/studyListen/level1/animals/mouse_02.png',
    'assets/img/contents/studyListen/level1/animals/mouse_03.png',
    'assets/img/contents/studyListen/level1/animals/mouse_04.png',
    'assets/img/contents/studyListen/level1/animals/mouse_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/mouse01.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse02.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse03.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse04.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/mouse_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/mouse06.mp3',
  outroText: '찍찍 쥐는 치즈를 찾으러 갔어요',
);

const pigData = AnimalContentData(
  name: 'pig',
  silhouetteImage: 'assets/img/contents/studyListen/level1/animals/pig_00.png',
  silhouetteRect: Rect.fromLTWH(313, 0, 1286, 857),
  storyImages: [
    'assets/img/contents/studyListen/level1/animals/pig_01.png',
    'assets/img/contents/studyListen/level1/animals/pig_02.png',
    'assets/img/contents/studyListen/level1/animals/pig_03.png',
    'assets/img/contents/studyListen/level1/animals/pig_04.png',
    'assets/img/contents/studyListen/level1/animals/pig_05.png',
  ],
  storyAudios: [
    'assets/audio/tts/studyListen/level1/animals/pig01.mp3',
    'assets/audio/tts/studyListen/level1/animals/pig02.mp3',
    'assets/audio/tts/studyListen/level1/animals/pig03.mp3',
    'assets/audio/tts/studyListen/level1/animals/pig04.mp3',
    'assets/audio/tts/studyListen/level1/animals/pig05.mp3',
  ],
  outroImage: 'assets/img/contents/studyListen/level1/animals/pig_06.png',
  outroAudio: 'assets/audio/tts/studyListen/level1/animals/pig06.mp3',
  outroText: '돼지는 꿀꿀 맛있는 걸 먹으러 갔어요',
);
