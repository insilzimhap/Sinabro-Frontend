/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 3 게임의 데이터값 ]
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

final level3GameData = [
 // 📍 테마 1 (FR_LG_009) ------------------------------------------------------ // 
  ListenGameContent(
    questionId: 'LG_Q9_01',

    characterName: '크크',
    dialogueText: '과일이 맛있게 생긴것 같다크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t2_q1.mp3',

    optionIds: ['LG_Q9_1A', 'LG_Q9_1B', 'LG_Q9_1C'], // 옵션 매핑 (백엔드)

    optionImages: ['fruit_2.png', 'fruit_1.png', 'fruit_4.png'],
    correctIndex: 0, //(숫자 2)
  ),
  ListenGameContent(
    questionId: 'LG_Q9_02',

    characterName: '크크',
    dialogueText: '아까보다 어려운 것 같다크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t2_q2.mp3',

    optionIds: ['LG_Q9_2A', 'LG_Q9_2B', 'LG_Q9_2C'],

    optionImages: ['fruit_5.png', 'fruit_4.png', 'fruit_1.png'],
    correctIndex: 0, //(숫자 5)
  ),
  ListenGameContent(
    questionId: 'LG_Q9_03',

    characterName: '크크',
    dialogueText: '얼른 심부름을 하고 엄마를 보러가고싶크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t2_q3.mp3',

    optionIds: ['LG_Q9_3A', 'LG_Q9_3B', 'LG_Q9_3C'],

    optionImages: ['fruit_3.png', 'fruit_4.png', 'fruit_5.png'],
    correctIndex: 1, //(숫자 4)
  ),
  ListenGameContent(
    questionId: 'LG_Q9_04',

    characterName: '크크',
    dialogueText: '여기까지 하다니 대단하다크! 멋져크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t2_q4.mp3',

    optionIds: ['LG_Q9_4A', 'LG_Q9_4B', 'LG_Q9_4C'],

    optionImages: ['fruit_1.png', 'fruit_3.png', 'fruit_2.png'],
    correctIndex: 0, //(숫자 1)
  ),
  ListenGameContent(
    questionId: 'LG_Q9_05',

    characterName: '크크',
    dialogueText: '마지막이다크! 수고했다크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t2_q5.mp3',

    optionIds: ['LG_Q9_5A', 'LG_Q9_5B', 'LG_Q9_5C'],

    optionImages: ['fruit_3.png', 'fruit_5.png', 'fruit_2.png'],
    correctIndex: 0, //(숫자 3)
  ),

  // 📍 테마 2 (FR_LG_010) ----------------------------------------------------- // 
  ListenGameContent(
    questionId: 'LG_Q10_01',

    characterName: '크크',
    dialogueText: '이건 무슨 숫자냐크?',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t1_q1.mp3',

    optionIds: ['LG_Q10_1A', 'LG_Q10_1B', 'LG_Q10_1C'],

    optionImages: ['seafood_6.png', 'seafood_8.png', 'seafood_10.png'],
    correctIndex: 0, //(숫자 6)
  ),
  ListenGameContent(
    questionId: 'LG_Q10_02',

    characterName: '크크',
    dialogueText: '너무 숫자가 많크! 어렵크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t1_q2.mp3',

    optionIds: ['LG_Q10_2A', 'LG_Q10_2B', 'LG_Q10_2C'],

    optionImages: ['seafood_10.png', 'seafood_8.png', 'seafood_7.png'],
    correctIndex: 1, //(숫자 8)
  ),
  ListenGameContent(
    questionId: 'LG_Q10_03',

    characterName: '크크',
    dialogueText: '사장님은 나를 안 무서워한다크',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t1_q3.mp3',

    optionIds: ['LG_Q10_3A', 'LG_Q10_3B', 'LG_Q10_3C'],

    optionImages: ['seafood_6.png', 'seafood_10.png', 'seafood_9.png'],
    correctIndex: 1, //(숫자 10)
  ),
  ListenGameContent(
    questionId: 'LG_Q10_04',

    characterName: '크크',
    dialogueText: '얼추 이쪽 심부름이 끝나간다크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t1_q4.mp3',

    optionIds: ['LG_Q10_4A', 'LG_Q10_4B', 'LG_Q10_4C'],

    optionImages: ['seafood_6.png', 'seafood_9.png', 'seafood_7.png'],
    correctIndex: 1, //(숫자 9)
  ),
  ListenGameContent(
    questionId: 'LG_Q10_05',

    characterName: '크크',
    dialogueText: '이건 크크도 안다크!',
    characterImagePath: 'assets/img/contents/gameListen/level3/kuku_chat.png',
    audioPath: 'assets/audio/gameListen/level3/t1_q5.mp3',

    optionIds: ['LG_Q10_5A', 'LG_Q10_5B', 'LG_Q10_5C'],

    optionImages: ['seafood_7.png', 'seafood_8.png', 'seafood_9.png'],
    correctIndex: 0, //(숫자 7)
  ),
];