import 'package:flutter/material.dart';

class LobbyParentScreen extends StatelessWidget {
  const LobbyParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('부모 메인 로비')),
      body: const Center(
        child: Text(
          '환영합니다, 부모님!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
