// lib/main/studyView/listenStudy/level2/story/data/routine_data.dart
import '../model/routine_content.dart';

/// 인트로
final RoutineContent introData = const RoutineContent(
  text: "숫자 친구들이 찾아왔어요!",
  imagePath: "assets/img/contents/studyListen/level2/num_hi_1.png",
);

/// 숫자 루틴 (1~10)
final List<Map<String, dynamic>> numberRoutine = [
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 1이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-1-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-1-2.png",
      ),
      RoutineContent(
        text: "시원한 수박이 1개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-1-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 2에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-2-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-2-2.png",
      ),
      RoutineContent(
        text: "달콤한 복숭아가 2개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-2-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 3이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-3-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-3-2.png",
      ),
      RoutineContent(
        text: "아삭아삭 배가 3개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-3-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 4에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-4-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-4-2.png",
      ),
      RoutineContent(
        text: "새콤달콤 감이 4개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-4-3.png",
      ),
    ]
  },
  {
    "keyword": const RoutineContent(
      text: "이건 숫자 5에요",
      imagePath: "assets/img/contents/studyListen/level2/story/4-5-1.png",
    ),
    "stories": const [
      RoutineContent(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-5-2.png",
      ),
      RoutineContent(
        text: "달콤한 딸기가 5개!",
        imagePath: "assets/img/contents/studyListen/level2/story/4-5-3.png",
      ),
    ]
  }
];
