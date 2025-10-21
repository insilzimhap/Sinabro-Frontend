// lib/main/studyView/listenStudy/page/level2/story3/data/routine_data.dart
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/model/routine_content.dart';

/// 인트로
final RoutineContent introData = const RoutineContent(
  text: "오늘은 숫자에 대해 알아볼까요?",
  imagePath: "assets/img/contents/studyListen/level2/story3/intro.png",
  // ✨ 오디오 경로 추가 (인트로는 별도 TTS가 없으므로 비워둠)
);

/// 숫자 루틴 (1~10)
final List<Map<String, dynamic>> numberRoutine = [
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 1이에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_01_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/1_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "시원한 수박이 1개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/1_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_01_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 1이에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/1_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_01_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 2에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/2.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_02_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/2_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "달콤한 복숭아가 2개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/2_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_02_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 2에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/2_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_02_check.mp3",
      ),
    ]
  },
  // ... (나머지 숫자 3부터 10까지도 위와 동일한 패턴으로 audioPath 추가)
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 3이에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/3.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_03_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/3_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "아삭아삭 배가 3개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/3_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_03_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 3이에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/3_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_03_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 4에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/4.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_04_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/4_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "새콤달콤 감이 4개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/4_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_04_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 4에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/4_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_04_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 5에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/5.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_05_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/5_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "달콤한 딸기가 5개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/5_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_05_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 5에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/5_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_05_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 6이에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/6.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_06_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/6_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "주룩주룩 우산 6개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/6_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_06_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 6이에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/6_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_06_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 7이에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/7.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_07_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/7_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "팔랑팔랑 물고기 7마리!",
        imagePath: "assets/img/contents/studyListen/level2/story3/7_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_07_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 7이에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/7_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_07_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 8이에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/8.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_08_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/8_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "따끈따끈 밤톨이 8개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/8_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_08_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 8이에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/8_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_08_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 9에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/9.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_09_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/9_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "통통한 사과가 9개!",
        imagePath: "assets/img/contents/studyListen/level2/story3/9_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_09_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 9에요\n다음 숫자를 알아볼까요?",
        imagePath: "assets/img/contents/studyListen/level2/story3/9_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_09_check.mp3",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 10이에요",
      imagePath: "assets/img/contents/studyListen/level2/story3/10.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_10_title.mp3",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story3/10_1.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      RoutineContent(
        text: "톡톡 튀는 포도가 10알!",
        imagePath: "assets/img/contents/studyListen/level2/story3/10_2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_10_example.mp3",
      ),
      RoutineContent(
        text: "이건 모두 10이에요",
        imagePath: "assets/img/contents/studyListen/level2/story3/10_3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_10_check.mp3",
      ),
    ]
  },
];
