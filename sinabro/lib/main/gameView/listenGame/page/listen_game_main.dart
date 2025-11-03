// lib/main/gameView/listenGame/page/listen_game_main.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_flow.dart';

/// 듣기 게임 진입 페이지
/// - level 값에 따라 Flow 실행
class ListenGameMainPage extends StatelessWidget {
  final int level;
  const ListenGameMainPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    switch (level) {
      case 1:
        return const Level1Flow();
      case 2:
        return const Level2Flow();
      case 3:
        return const Level3Flow();
      default:
        return const Scaffold(body: Center(child: Text("잘못된 레벨입니다.")));
    }
  }
}
