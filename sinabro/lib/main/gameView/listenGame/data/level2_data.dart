/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2 게임의 데이터값 ]
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

final level2GameData = [
  // 📍 테마 1 (FR_LG_006) -------------------------------------------------- // 
  ListenGameContent(
    questionId: 'LG_Q6_01',

    characterName: '꼬마요정',
    dialogueText: '우선 가족에 대해서 제게 알려주세요!',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t1_q1.mp3',
    
    optionIds: ['LG_Q6_1A', 'LG_Q6_1B', 'LG_Q6_1C'], // 옵션 매핑 (백엔드)

    optionImages: ['brother.png', 'sister.png', 'mother.png'],

    correctIndex: 0, //(형/오빠)
  ),
  ListenGameContent(
    questionId: 'LG_Q6_02',

    characterName: '꼬마요정',
    dialogueText: '좋아요! 계속 알려주면 기억할게요~',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t1_q2.mp3',

    optionIds: ['LG_Q6_2A', 'LG_Q6_2B', 'LG_Q6_2C'],

    optionImages: ['sister.png', 'brother.png', 'father.png'],
    correctIndex:0, //(언니/누나)
  ),
  ListenGameContent(
    questionId: 'LG_Q6_03',

    characterName: '꼬마요정',
    dialogueText: '정말 도움이 많이 되고 있어요! 힘내요',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t1_q3.mp3',

    optionIds: ['LG_Q6_3A', 'LG_Q6_3B', 'LG_Q6_3C'],

    optionImages: ['mother.png', 'sister.png', 'younger.png'],
    correctIndex: 2, //(동생)
  ),
  ListenGameContent(
    questionId: 'LG_Q6_04',

    characterName: '꼬마요정',
    dialogueText: '가족에 대해서 더 제게 알려주세요!',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t1_q4.mp3',

    optionIds: ['LG_Q6_4A', 'LG_Q6_4B', 'LG_Q6_4C'],

    optionImages: ['father.png', 'sister.png', 'brother.png'],
    correctIndex: 0, //(아빠)
  ),
  ListenGameContent(
    questionId: 'LG_Q6_05',

    characterName: '꼬마요정',
    dialogueText: '같은 관계여도 호칭이 여러개라니!',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t1_q5.mp3',

    optionIds: ['LG_Q6_5A', 'LG_Q6_5B', 'LG_Q6_5C'],


    optionImages: ['father.png', 'mother.png', 'sister.png'],
    correctIndex: 1, //(엄마)
  ),

  // 📍 테마 2 (FR_LG_007) --------------------------------------------------------- // 
  ListenGameContent(
    questionId: 'LG_Q7_01',

    characterName: '꼬마요정',
    dialogueText: '사람들의 표정을 익혀보려고 해요',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t2_q1.mp3',

    optionIds: ['LG_Q7_1A', 'LG_Q7_1B', 'LG_Q7_1C'],

    optionImages: ['happy.png', 'funny.png', 'bored.png'],
    correctIndex: 0, //(행복)
  ),
  ListenGameContent(
    questionId: 'LG_Q7_02',

    characterName: '꼬마요정',
    dialogueText: '이건 무슨 표정인걸까요?',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t2_q2.mp3',

    optionIds: ['LG_Q7_2A', 'LG_Q7_2B', 'LG_Q7_2C'],

    optionImages: ['funny.png', 'surprised.png', 'bored.png'],
    correctIndex: 0, //(웃겨)
  ),
  ListenGameContent(
    questionId: 'LG_Q7_03',

    characterName: '꼬마요정',
    dialogueText: '새로운 표정들도 많아요 신기해요!',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t2_q3.mp3',

    optionIds: ['LG_Q7_3A', 'LG_Q7_3B', 'LG_Q7_3C'],

    optionImages: ['surprised.png', 'nervous.png', 'funny.png'],
    correctIndex: 0, //놀람
  ),
  ListenGameContent(
    questionId: 'LG_Q7_04',

    characterName: '꼬마요정',
    dialogueText: '행복이라는 감정이 더 멀리멀리 퍼지길~',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t2_q4.mp3',

    optionIds: ['LG_Q7_4A', 'LG_Q7_4B', 'LG_Q7_4C'],

    optionImages: ['happy.png', 'nervous.png', 'bored.png'],
    correctIndex: 2, //(지루)
  ),
  ListenGameContent(
    questionId: 'LG_Q7_05',

    characterName: '꼬마요정',
    dialogueText: '마지막이에요! 무슨 표정인가요?',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t2_q5.mp3',

    optionIds: ['LG_Q7_5A', 'LG_Q7_5B', 'LG_Q7_5C'],

    optionImages: ['nervous.png', 'happy.png', 'surprised.png'],
    correctIndex: 0, //(긴장)
  ),

  // 📍 테마 3 (FR_LG_008) ----------------------------------------------------- // 
  ListenGameContent(
    questionId: 'LG_Q8_01',

    characterName: '꼬마요정',
    dialogueText: '사람의 표정은 참 다양하네요!',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t3_q1.mp3',

    optionIds: ['LG_Q8_1A', 'LG_Q8_1B', 'LG_Q8_1C'],

    optionImages: ['disappointed.png', 'shy.png', 'simsim.png'],
    correctIndex: 0, //(실망)
  ),
  ListenGameContent(
    questionId: 'LG_Q8_02',

    characterName: '꼬마요정',
    dialogueText: '표정을 따라하다 보면 더 알기 쉬워요',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t3_q2.mp3',

    optionIds: ['LG_Q8_2A', 'LG_Q8_2B', 'LG_Q8_2C'],

    optionImages: ['hungry.png', 'comfortable.png', 'disappointed.png'],
    correctIndex: 0, //(배고픔)
  ),
  ListenGameContent(
    questionId: 'LG_Q8_03',

    characterName: '꼬마요정',
    dialogueText: '이건 조금 어려운 것 같아요',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t3_q3.mp3',

    optionIds: ['LG_Q8_3A', 'LG_Q8_3B', 'LG_Q8_3C'],

    optionImages: ['simsim.png', 'disappointed.png', 'shy.png'],
    correctIndex: 2, //(부끄러워요)
  ),
  ListenGameContent(
    questionId: 'LG_Q8_04',

    characterName: '꼬마요정',
    dialogueText: '거의 다 끝나가요! 정말 대단해요',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t3_q4.mp3',

    optionIds: ['LG_Q8_4A', 'LG_Q8_4B', 'LG_Q5_4C'],

    optionImages: ['hungry.png', 'comfortable.png', 'shy.png'],
    correctIndex: 1, //(평온해요)
  ),
  ListenGameContent(
    questionId: 'LG_Q8_05',

    characterName: '꼬마요정',
    dialogueText: '마지막 표정이에요 도와줘서 고마워요!',
    characterImagePath: 'assets/img/contents/gameListen/level2/fairy_chat.png',
    audioPath: 'assets/audio/gameListen/level2/t3_q5.mp3',

    optionIds: ['LG_Q8_5A', 'LG_Q8_5B', 'LG_Q8_5C'],

    optionImages: ['simsim.png', 'hungry.png', 'comfortable.png'],
    correctIndex: 0, //(심심해)
  )
];