// lib/main/studyView/listenStudy/level2/story/data/routine_data.dart
import '../model/routine_content.dart';

/// 인트로
final RoutineContent introData = const RoutineContent(
  text: "숫자 친구들이 찾아왔어요!",
  imagePath: "assets/img/contents/studyListen/level2/num_hi_2.png",
);

/// 숫자 루틴 (6~10)
final List<Map<String, dynamic>> numberRoutine = [
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 6이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-1-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-1-2.png",
      ),
      RoutineContent(
        text: "주룩주룩 우산 6개!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-1-2.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 7이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-2-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-2-2.png",
      ),
      RoutineContent(
        text: "팔랑팔랑 물고기 7마리!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-2-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 8이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-3-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-3-2.png",
      ),
      RoutineContent(
        text: "따끈따끈 밤톨이 8개!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-3-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 9에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-4-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-4-2.png",
      ),
      RoutineContent(
        text: "통통한 사과가 9개!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-4-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 10이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-5-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-5-2.png",
      ),
      RoutineContent(
        text: "톡톡 튀는 포도가 10알!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-5-3.png",
      ),
    ]
  },
];
