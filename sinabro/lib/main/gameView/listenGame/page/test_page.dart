import 'package:flutter/material.dart';
import 'listen_game_main.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("듣기 게임 테스트")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListenGameMainPage(level: 1),
                  ),
                );
              },
              child: const Text("레벨 1 시작"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListenGameMainPage(level: 2),
                  ),
                );
              },
              child: const Text("레벨 2 시작"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListenGameMainPage(level: 3),
                  ),
                );
              },
              child: const Text("레벨 3 시작"),
            ),
          ],
        ),
      ),
    );
  }
}
