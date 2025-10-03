// lib/main/gameView/listenGame/page/test_page.dart
import 'package:flutter/material.dart';
import 'listen_game_main.dart';

/// 듣기 게임 테스트 페이지
/// - 레벨 1, 2, 3 버튼으로 각 게임 흐름 실행
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("듣기 게임 테스트")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final level = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListenGameMainPage(level: level),
                    ),
                  );
                },
                child: Text("레벨 $level 시작"),
              ),
            );
          }),
        ),
      ),
    );
  }
}
