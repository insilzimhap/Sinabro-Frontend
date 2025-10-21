// lib/main/studyView/listenStudy/level2/story3/data/routine_data_1.dart
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/model/routine_content.dart';

/// 인트로
final RoutineContent introData = const RoutineContent(
  text: "숫자 친구들이 찾아왔어요!",
  imagePath: "assets/img/contents/studyListen/level2/num_hi_1.png",
  audioPath: "audio/tts/studyListen/level2/numbers/num_intro2.mp3",
);

/// 숫자 루틴 (1~5)
final List<Map<String, dynamic>> numberRoutine = [
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 1이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-1-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_01_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-1-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "시원한 수박이 1개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-1-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_01_example.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 2!",
      imagePath: "assets/img/contents/studyListen/level2/story/4-2-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_02_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-2-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "말랑한 복숭아가 2개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-2-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_02_example.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "숫자 3이네요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-3-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_03_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-3-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "아삭아삭 배가 3개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-3-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_03_example.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 4에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-4-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_04_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-4-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "서걱서걱 감이 4개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-4-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_04_example.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "숫자 5까지 전부 찾아냈어요!",
      imagePath: "assets/img/contents/studyListen/level2/story/4-5-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_05_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-5-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "달콤한 딸기가 5개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-5-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_05_example.mp3",
      ),
    ]
  }
];
