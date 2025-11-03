/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1 게임의 데이터값 ]
 * 
 *  - characterName: 상단 말풍선의 캐릭터명
 *  - dialogueText : 상단 말풍선의 텍스트
 *  - characterImagePath : 상단 말풍선의 캐릭터이미지
 *  - audioPath : 음성 파일 경로
 *  - optionImages : 보기 이미지
 *  - correctIndex : 정답 인덱스
 * ----------------------------------------------------------------
 */

// UI import
import 'package:sinabro/main/gameView/listenGame/model/listen_game_content.dart';

final level1GameData = [
  // 📍 테마 1 (FR_LG_001) -------------------------------------------------------//
  ListenGameContent(
    questionId: 'LG_Q1_01', // 새로 추가된 부분 (백앤드)

    characterName: '양지',
    dialogueText: '무지개 만들기 마법서를 골라주셨네요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'intro_t1',

    optionIds: ['LG_Q1_1A', 'LG_Q1_1B', 'LG_Q1_1C'], // 옵션 매핑 (백엔드)

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/black.png',
      'assets/img/contents/gameListen/level1/answer/blue.png',
      'assets/img/contents/gameListen/level1/answer/yellow.png',
    ],
    correctIndex: 0, //(검정)
  ),
  ListenGameContent(
    questionId: 'LG_Q1_02',

    characterName: '양지',
    dialogueText: '이렇게 정답을 선택하면 무지개가 채워져요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t1_1',

    optionIds: ['LG_Q1_2A', 'LG_Q1_2B', 'LG_Q1_2C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/white.png',
      'assets/img/contents/gameListen/level1/answer/red.png',
      'assets/img/contents/gameListen/level1/answer/blue.png',
    ],
    correctIndex: 0, //(흰색)
  ),
  ListenGameContent(
    questionId: 'LG_Q1_03',

    characterName: '양지',
    dialogueText: '채워지고 있어요 벌써 아름다워요!!!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t1_2',

    optionIds: ['LG_Q1_3A', 'LG_Q1_3B', 'LG_Q1_3C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/yellow.png',
      'assets/img/contents/gameListen/level1/answer/white.png',
      'assets/img/contents/gameListen/level1/answer/red.png',
    ],
    correctIndex: 2, //(빨)
  ),
  ListenGameContent(
    questionId: 'LG_Q1_04',

    characterName: '양지',
    dialogueText: '거의 다왔어요! 예쁜 무지개가 될 것 같아요',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t1_3',

    optionIds: ['LG_Q1_4A', 'LG_Q1_4B', 'LG_Q1_4C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/blue.png',
      'assets/img/contents/gameListen/level1/answer/yellow.png',
      'assets/img/contents/gameListen/level1/answer/black.png',
    ],
    correctIndex: 0, //(파랑)
  ),
  ListenGameContent(
    questionId: 'LG_Q1_05',

    characterName: '양지',
    dialogueText: '마지막이에요! 무지개를 완성해요',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t1_4',

    optionIds: ['LG_Q1_5A', 'LG_Q1_5B', 'LG_Q1_5C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/red.png',
      'assets/img/contents/gameListen/level1/answer/black.png',
      'assets/img/contents/gameListen/level1/answer/yellow.png',
    ],
    correctIndex: 2, //(노랑색)
  ),

  // 📍 테마 2 (FR_LG_002) ------------------------------------------------------ //
  ListenGameContent(
    questionId: 'LG_Q2_01',

    characterName: '양지',
    dialogueText: '사탕 만들기 마법서를 골라주셨네요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'intro_t2',

    optionIds: ['LG_Q2_1A', 'LG_Q2_1B', 'LG_Q2_1C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/brown.png',
      'assets/img/contents/gameListen/level1/answer/white.png',
      'assets/img/contents/gameListen/level1/answer/green.png',
    ],
    correctIndex: 0, //(갈색)
  ),
  ListenGameContent(
    questionId: 'LG_Q2_02',

    characterName: '양지',
    dialogueText: '달콤한 사탕을 잔뜩 만들어봐요~',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t2_1',

    optionIds: ['LG_Q2_2A', 'LG_Q2_2B', 'LG_Q2_2C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/orange.png',
      'assets/img/contents/gameListen/level1/answer/purple.png',
      'assets/img/contents/gameListen/level1/answer/pink.png',
    ],
    correctIndex: 2, //(핑크)
  ),
  ListenGameContent(
    questionId: 'LG_Q2_03',

    characterName: '양지',
    dialogueText: '사탕을 많이 만들어서 어디에 쓰냐고요?',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t2_2',

    optionIds: ['LG_Q2_3A', 'LG_Q2_3B', 'LG_Q2_3C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/white.png',
      'assets/img/contents/gameListen/level1/answer/black.png',
      'assets/img/contents/gameListen/level1/answer/purple.png',
    ],
    correctIndex: 2, //(보라)
  ),
  ListenGameContent(
    questionId: 'LG_Q2_04',

    characterName: '양지',
    dialogueText: '많은 어린이에게 행복을 줄 거예요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t2_3',

    optionIds: ['LG_Q2_4A', 'LG_Q2_4B', 'LG_Q2_4C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/green.png',
      'assets/img/contents/gameListen/level1/answer/pink.png',
      'assets/img/contents/gameListen/level1/answer/yellow.png',
    ],
    correctIndex: 0, //(초록)
  ),
  ListenGameContent(
    questionId: 'LG_Q2_05',

    characterName: '양지',
    dialogueText: '마지막이에요! 달콤한 사탕아 생겨라~',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t2_4',

    optionIds: ['LG_Q2_5A', 'LG_Q2_5B', 'LG_Q2_5C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/red.png',
      'assets/img/contents/gameListen/level1/answer/orange.png',
      'assets/img/contents/gameListen/level1/answer/brown.png',
    ],
    correctIndex: 1, //(주황)
  ),

  // 📍 테마 3 (FR_LG_003) ------------------------------------------------------ //
  ListenGameContent(
    questionId: 'LG_Q3_01',

    characterName: '양지',
    dialogueText: '동물의 하급 마법서를 골라주셨네요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'intro_t3',

    optionIds: ['LG_Q3_1A', 'LG_Q3_1B', 'LG_Q3_1C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/dog.png',
      'assets/img/contents/gameListen/level1/answer/cat.png',
      'assets/img/contents/gameListen/level1/answer/chicken.png',
    ],
    correctIndex: 0, //(강아지)
  ),
  ListenGameContent(
    questionId: 'LG_Q3_02',

    characterName: '양지',
    dialogueText: '이 동물을 대체 무엇일까요...?',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t3_1',

    optionIds: ['LG_Q3_2A', 'LG_Q3_2B', 'LG_Q3_2C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/cat.png',
      'assets/img/contents/gameListen/level1/answer/chicken.png',
      'assets/img/contents/gameListen/level1/answer/pig.png',
    ],
    correctIndex: 0, //(고양이)
  ),
  ListenGameContent(
    questionId: 'LG_Q3_03',

    characterName: '양지',
    dialogueText: '동물 친구들은 많이 알 수록 좋아요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t3_2',

    optionIds: ['LG_Q3_3A', 'LG_Q3_3B', 'LG_Q3_3C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/pig.png',
      'assets/img/contents/gameListen/level1/answer/chicken.png',
      'assets/img/contents/gameListen/level1/answer/mouse.png',
    ],
    correctIndex: 1, //(닭)
  ),
  ListenGameContent(
    questionId: 'LG_Q3_04',

    characterName: '양지',
    dialogueText: '제가 자주 보는 친구들도 많이 있네요~',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t3_3',

    optionIds: ['LG_Q3_4A', 'LG_Q3_4B', 'LG_Q3_4C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/pig.png',
      'assets/img/contents/gameListen/level1/answer/mouse.png',
      'assets/img/contents/gameListen/level1/answer/dog.png',
    ],
    correctIndex: 0, //(돼지)
  ),
  ListenGameContent(
    questionId: 'LG_Q3_05',

    characterName: '양지',
    dialogueText: '마지막으로 이 동물의 이름만 알면 돼요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t3_4',

    optionIds: ['LG_Q3_5A', 'LG_Q3_5B', 'LG_Q3_5C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/mouse.png',
      'assets/img/contents/gameListen/level1/answer/dog.png',
      'assets/img/contents/gameListen/level1/answer/cat.png',
    ],
    correctIndex: 0, //(쥐)
  ),

  // 📍 테마 4 (FR_LG_004) ------------------------------------------------------- //
  ListenGameContent(
    questionId: 'LG_Q4_01',

    characterName: '양지',
    dialogueText: '동물의 중급 마법서를 골라주셨네요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'intro_t4',

    optionIds: ['LG_Q4_1A', 'LG_Q4_1B', 'LG_Q4_1C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/elephant.png',
      'assets/img/contents/gameListen/level1/answer/tiger.png',
      'assets/img/contents/gameListen/level1/answer/monkey.png',
    ],
    correctIndex: 0, //(코끼리)
  ),
  ListenGameContent(
    questionId: 'LG_Q4_02',

    characterName: '양지',
    dialogueText: '동물들을 많이 알아둬야 좋아요',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t4_1',

    optionIds: ['LG_Q4_2A', 'LG_Q4_2B', 'LG_Q4_2C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/sheep.png',
      'assets/img/contents/gameListen/level1/answer/tiger.png',
      'assets/img/contents/gameListen/level1/answer/penguin.png',
    ],
    correctIndex: 0, //(양)
  ),
  ListenGameContent(
    questionId: 'LG_Q4_03',

    characterName: '양지',
    dialogueText: '세상엔 수많은 동물 친구들이 있답니다~',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t4_2',

    optionIds: ['LG_Q4_3A', 'LG_Q4_3B', 'LG_Q4_3C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/penguin.png',
      'assets/img/contents/gameListen/level1/answer/elephant.png',
      'assets/img/contents/gameListen/level1/answer/monkey.png',
    ],
    correctIndex: 2, //(원숭이)
  ),
  ListenGameContent(
    questionId: 'LG_Q4_04',

    characterName: '양지',
    dialogueText: '그치만 그중에서 제가 마법을 가장 잘 써요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t4_3',

    optionIds: ['LG_Q4_4A', 'LG_Q4_4B', 'LG_Q4_4C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/monkey.png',
      'assets/img/contents/gameListen/level1/answer/sheep.png',
      'assets/img/contents/gameListen/level1/answer/tiger.png',
    ],
    correctIndex: 2, //(호랑이)
  ),
  ListenGameContent(
    questionId: 'LG_Q4_05',

    characterName: '양지',
    dialogueText: '연습을 도와주신 덕분일 거예요 감사해요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t4_4',

    optionIds: ['LG_Q4_5A', 'LG_Q4_5B', 'LG_Q4_5C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/elephant.png',
      'assets/img/contents/gameListen/level1/answer/sheep.png',
      'assets/img/contents/gameListen/level1/answer/penguin.png',
    ],
    correctIndex: 2, //(펭귄)
  ),

  // 📍 테마 5 (FR_LG_005) ------------------------------------------------------ //
  ListenGameContent(
    questionId: 'LG_Q5_01',

    characterName: '양지',
    dialogueText: '동물의 상급 마법서를 골라주셨네요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'intro_t5',

    optionIds: ['LG_Q5_1A', 'LG_Q5_1B', 'LG_Q5_1C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/bird.png',
      'assets/img/contents/gameListen/level1/answer/rabbit.png',
      'assets/img/contents/gameListen/level1/answer/frog.png',
    ],
    correctIndex: 0, //(병아리)
  ),
  ListenGameContent(
    questionId: 'LG_Q5_02',

    characterName: '양지',
    dialogueText: '이 동물을 대체 무엇일까요...?',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t5_1',

    optionIds: ['LG_Q5_2A', 'LG_Q5_2B', 'LG_Q5_2C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/turtle.png',
      'assets/img/contents/gameListen/level1/answer/duck.png',
      'assets/img/contents/gameListen/level1/answer/rabbit.png',
    ],
    correctIndex: 0, //(거북이)
  ),
  ListenGameContent(
    questionId: 'LG_Q5_03',

    characterName: '양지',
    dialogueText: '동물 친구들은 많이 알 수록 좋아요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t5_2',

    optionIds: ['LG_Q5_3A', 'LG_Q5_3B', 'LG_Q5_3C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/rabbit.png',
      'assets/img/contents/gameListen/level1/answer/duck.png',
      'assets/img/contents/gameListen/level1/answer/bird.png',
    ],
    correctIndex: 0, //(토끼)
  ),
  ListenGameContent(
    questionId: 'LG_Q5_04',

    characterName: '양지',
    dialogueText: '제가 자주 보는 친구들도 많이 있네요~',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t5_3',

    optionIds: ['LG_Q5_4A', 'LG_Q5_4B', 'LG_Q5_4C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/bird.png',
      'assets/img/contents/gameListen/level1/answer/frog.png',
      'assets/img/contents/gameListen/level1/answer/turtle.png',
    ],
    correctIndex: 1, //(개구리)
  ),
  ListenGameContent(
    questionId: 'LG_Q5_05',

    characterName: '양지',
    dialogueText: '마지막으로 이 동물의 이름만 알면 돼요!',
    characterImagePath: 'assets/img/contents/gameListen/level1/yangji_chat.png',
    audioPath: 'progress_t5_4',

    optionIds: ['LG_Q5_5A', 'LG_Q5_5B', 'LG_Q5_5C'],

    optionImages: [
      'assets/img/contents/gameListen/level1/answer/turtle.png',
      'assets/img/contents/gameListen/level1/answer/duck.png',
      'assets/img/contents/gameListen/level1/answer/frog.png',
    ],
    correctIndex: 1, //(오리)
  ),
];
