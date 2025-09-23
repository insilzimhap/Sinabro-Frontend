import 'package:flutter/material.dart';
import 'listen_game_mock.dart';

/// 스토리 컷 데이터
class StoryData {
  final String imagePath;
  final String dialogue;
  final bool showButton;

  const StoryData({
    required this.imagePath,
    required this.dialogue,
    this.showButton = false,
  });
}

/// 엔딩/실패 대사 데이터
class ResultData {
  final String imagePath;
  final String dialogue;

  const ResultData({
    required this.imagePath,
    required this.dialogue,
  });
}

/// 레벨별 전체 Flow 데이터
class LevelFlowConfig {
  final int themeCount; // 테마 개수
  final Color color; // 색상톤
  final ListenGameMockData Function() characterData; // 캐릭터 데이터
  final List<StoryData> story; // 스토리 컷
  final List<ResultData> ending; // 클리어 결과
  final List<ResultData> fail; // 실패 결과

  const LevelFlowConfig({
    required this.themeCount,
    required this.color,
    required this.characterData,
    required this.story,
    required this.ending,
    required this.fail,
  });
}

/// 레벨별 설정 모음
final levelConfigs = {
  1: LevelFlowConfig(
    themeCount: 5,
    color: Colors.orange,
    characterData: ListenGameMock.yangji,
    story: [
      StoryData(
        imagePath: "assets/img/contents/gameListen/level1/story_1.png",
        dialogue: "안녕하세요! 저는 양지라고 해요",
      ),
      StoryData(
        imagePath: "assets/img/contents/gameListen/level1/story_2.png",
        dialogue: "내일 마법 시험이 있는데 성공을 못했어요",
      ),
      StoryData(
        imagePath: "assets/img/contents/gameListen/level1/story_2.png",
        dialogue: "저를 좀 도와주세요!",
        showButton: true,
      ),
    ],
    ending: [
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/ending_theme1.png",
        dialogue: "레벨1-테마1 클리어! 잘했어!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/ending_theme2.png",
        dialogue: "레벨1-테마2 클리어! 최고야!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/ending_theme3.png",
        dialogue: "레벨1-테마3 클리어! 멋져!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/ending_theme4.png",
        dialogue: "레벨1-테마4 클리어! 완벽해!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/ending_theme5.png",
        dialogue: "레벨1-테마5 클리어! 굿!",
      ),
    ],
    fail: [
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/fail_theme1.png",
        dialogue: "레벨1-테마1 실패... 다시 도전?",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/fail_theme2.png",
        dialogue: "레벨1-테마2 실패... 아쉽네!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/fail_theme3.png",
        dialogue: "레벨1-테마3 실패... 화이팅!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/fail_theme4.png",
        dialogue: "레벨1-테마4 실패... 다시 해볼까?",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level1/fail_theme5.png",
        dialogue: "레벨1-테마5 실패... 아깝다!",
      ),
    ],
  ),
  2: LevelFlowConfig(
    themeCount: 3,
    color: Colors.blue,
    characterData: ListenGameMock.littleFairy,
    story: [
      StoryData(
        imagePath: "assets/img/contents/gameListen/level2/story_1.png",
        dialogue: "레벨2 스토리의 첫 장면이에요!",
      ),
      StoryData(
        imagePath: "assets/img/contents/gameListen/level2/story_2.png",
        dialogue: "새로운 도전을 앞두고 있어요.",
      ),
      StoryData(
        imagePath: "assets/img/contents/gameListen/level2/story_3.png",
        dialogue: "함께 힘을 모아 도전해볼까요?",
        showButton: true,
      ),
    ],
    ending: [
      ResultData(
        imagePath: "assets/img/contents/gameListen/level2/ending_theme1.png",
        dialogue: "레벨2-테마1 클리어!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level2/ending_theme2.png",
        dialogue: "레벨2-테마2 클리어!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level2/ending_theme3.png",
        dialogue: "레벨2-테마3 클리어!",
      ),
    ],
    fail: [
      ResultData(
        imagePath: "assets/img/contents/gameListen/level2/fail_theme1.png",
        dialogue: "레벨2-테마1 실패...",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level2/fail_theme2.png",
        dialogue: "레벨2-테마2 실패...",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level2/fail_theme3.png",
        dialogue: "레벨2-테마3 실패...",
      ),
    ],
  ),
  3: LevelFlowConfig(
    themeCount: 2,
    color: Colors.purple,
    characterData: ListenGameMock.kuku,
    story: [
      StoryData(
        imagePath: "assets/img/contents/gameListen/level3/story_1.png",
        dialogue: "레벨3 스토리의 첫 장면이에요!",
      ),
      StoryData(
        imagePath: "assets/img/contents/gameListen/level3/story_2.png",
        dialogue: "드디어 마지막 시험을 준비하고 있어요.",
      ),
      StoryData(
        imagePath: "assets/img/contents/gameListen/level3/story_3.png",
        dialogue: "끝까지 가볼까요?",
        showButton: true,
      ),
    ],
    ending: [
      ResultData(
        imagePath: "assets/img/contents/gameListen/level3/ending_theme1.png",
        dialogue: "레벨3-테마1 클리어!",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level3/ending_theme2.png",
        dialogue: "레벨3-테마2 클리어!",
      ),
    ],
    fail: [
      ResultData(
        imagePath: "assets/img/contents/gameListen/level3/fail_theme1.png",
        dialogue: "레벨3-테마1 실패...",
      ),
      ResultData(
        imagePath: "assets/img/contents/gameListen/level3/fail_theme2.png",
        dialogue: "레벨3-테마2 실패...",
      ),
    ],
  ),
};
