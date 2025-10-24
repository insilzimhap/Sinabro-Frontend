// lib/main/studyView/listenStudy/level2/story2/data/routine_data.dart
import 'package:sinabro/main/studyView/listenStudy/page/level2/story2/model/routine_content.dart';

/// 인트로
final List<RoutineContent> introData = [
  RoutineContent(
    text: "짠! 오늘은 감정에 대해서 알아볼까요?",
    imagePath: "assets/img/contents/studyListen/level2/face.png",
    audioPath: "assets/audio/tts/studyListen/level2/emotions/emo_intro1.mp3",
  ),
];

/// 키워드 + 나는@@ + 스토리
final List<Map<String, dynamic>> keywordRoutine = [
  {
    "topic": RoutineContent(
      text: "좋아요",
      imagePath: "assets/img/contents/studyListen/level2/main_topic/1.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_happy.mp3",
    ),
    "keyword": RoutineContent(
      text: "나는 좋아요!",
      imagePath: "assets/img/contents/studyListen/level2/main_keyword/2-1.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_happy2.mp3",
    ),
    "stories": [
      RoutineContent(
        text: "친구랑 놀아서 좋아요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-1-1.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_happy3.mp3",
      ),
      RoutineContent(
        text: "놀이터에 와서 좋아요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-1-2.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_happy4.mp3",
      ),
      RoutineContent(
        text: "선물 받아서 좋아요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-1-3.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_happy5.mp3",
      ),
    ]
  },
  {
    "topic": RoutineContent(
      text: "배고파요",
      imagePath: "assets/img/contents/studyListen/level2/main_topic/2.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_hungry.mp3",
    ),
    "keyword": RoutineContent(
      text: "나는 배고파요!",
      imagePath: "assets/img/contents/studyListen/level2/main_keyword/2-2.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_hungry2.mp3",
    ),
    "stories": [
      RoutineContent(
          text: "아침 안 먹어서 배고파요!",
          imagePath: "assets/img/contents/studyListen/level2/story/2-2-1.png",
          audioPath: "audio/tts/studyListen/level2/emotions/emo_hungry3.mp3"),
      RoutineContent(
          text: "밥 시간 기다려서 배고파요!",
          imagePath: "assets/img/contents/studyListen/level2/story/2-2-2.png",
          audioPath: "audio/tts/studyListen/level2/emotions/emo_hungry4.mp3"),
      RoutineContent(
          text: "맛있는 냄새가 나서 배고파요!",
          imagePath: "assets/img/contents/studyListen/level2/story/2-2-3.png",
          audioPath: "audio/tts/studyListen/level2/emotions/emo_hungry5.mp3"),
    ]
  },
  {
    "topic": RoutineContent(
      text: "재밌어요",
      imagePath: "assets/img/contents/studyListen/level2/main_topic/3.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_fun.mp3",
    ),
    "keyword": RoutineContent(
      text: "나는 재밌어요!",
      imagePath: "assets/img/contents/studyListen/level2/main_keyword/2-3.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_fun2.mp3",
    ),
    "stories": [
      RoutineContent(
        text: "미끄럼틀 타서 재밌어요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-3-1.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_fun3.mp3",
      ),
      RoutineContent(
        text: "강아지랑 놀아서 재밌어요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-3-2.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_fun4.mp3",
      ),
      RoutineContent(
        text: "비눗방울 해서 재밌어요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-3-3.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_fun5.mp3",
      ),
    ]
  },
  {
    "topic": RoutineContent(
      text: "무서워요",
      imagePath: "assets/img/contents/studyListen/level2/main_topic/4.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_scared.mp3",
    ),
    "keyword": RoutineContent(
      text: "나는 무서워요!",
      imagePath: "assets/img/contents/studyListen/level2/main_keyword/2-4.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_scared2.mp3",
    ),
    "stories": [
      RoutineContent(
        text: "밤이 어두워서 무서워요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-4-1.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_scared3.mp3",
      ),
      RoutineContent(
        text: "번개가 쳐서 무서워요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-4-2.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_scared4.mp3",
      ),
      RoutineContent(
        text: "그림자 보여서 무서워요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-4-3.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_scared5.mp3",
      ),
    ]
  },
  {
    "topic": RoutineContent(
      text: "놀랐어요",
      imagePath: "assets/img/contents/studyListen/level2/main_topic/5.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_surprised.mp3",
    ),
    "keyword": RoutineContent(
      text: "나는 놀랐어요!",
      imagePath: "assets/img/contents/studyListen/level2/main_keyword/2-5.png",
      audioPath: "audio/tts/studyListen/level2/emotions/emo_surprised2.mp3",
    ),
    "stories": [
      RoutineContent(
        text: "상자가 열려서 놀랐어요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-5-1.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_surprised3.mp3",
      ),
      RoutineContent(
        text: "풍선이 터져서 놀랐어요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-5-2.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_surprised4.mp3",
      ),
      RoutineContent(
        text: "강아지가 짖어서 놀랐어요!",
        imagePath: "assets/img/contents/studyListen/level2/story/2-5-3.png",
        audioPath: "audio/tts/studyListen/level2/emotions/emo_surprised5.mp3",
      ),
    ]
  },
];
