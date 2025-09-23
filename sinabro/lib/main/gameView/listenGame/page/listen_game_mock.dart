import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_layout.dart';

/// 듣기 게임용 목업 데이터 모음
class ListenGameMock {
  /// 양지
  static ListenGameLayout yangji() {
    return ListenGameLayout(
      characterName: "양지",
      dialogueText: "안녕! 나는 양지야.\n오늘도 함께 공부해볼까?",
      characterImagePath: "assets/img/contents/gameListen/yangji_chat.png",
      optionImagePaths: [
        "assets/images/option1.png",
        "assets/images/option2.png",
        "assets/images/option3.png",
      ],
      onPlayAudio: () => debugPrint("양지 오디오 재생 (목업)"),
      dialogueColor: const Color(0xFFFFEED7),
      nameTagColor: const Color(0xFFEEC186),
    );
  }

  /// 꼬마요정
  static ListenGameLayout littleFairy() {
    return ListenGameLayout(
      characterName: "꼬마요정",
      dialogueText: "반가워! 나는 꼬마요정이야.\n무엇을 들어볼까?",
      characterImagePath: "assets/img/contents/gameListen/littleFairy_chat.png",
      optionImagePaths: [
        "assets/images/option1.png",
        "assets/images/option2.png",
        "assets/images/option3.png",
      ],
      onPlayAudio: () => debugPrint("꼬마요정 오디오 재생 (목업)"),
      dialogueColor: const Color(0xFFFFFFFF),
      nameTagColor: const Color(0xFF98D78B),
    );
  }

  /// 크크
  static ListenGameLayout kuku() {
    return ListenGameLayout(
      characterName: "크크",
      dialogueText: "헤헤! 나는 크크야.\n같이 들어볼래?",
      characterImagePath: "assets/img/contents/gameListen/kuku_chat.png",
      optionImagePaths: [
        "assets/images/option1.png",
        "assets/images/option2.png",
        "assets/images/option3.png",
      ],
      onPlayAudio: () => debugPrint("크크 오디오 재생 (목업)"),
      dialogueColor: const Color(0xFFFFEDED),
      nameTagColor: const Color(0xFFFFCDCD),
    );
  }
}
