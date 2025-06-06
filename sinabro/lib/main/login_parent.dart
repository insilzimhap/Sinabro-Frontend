import 'package:flutter/material.dart';
import 'lobby_parent.dart';

class LoginParentScreen extends StatelessWidget {
  const LoginParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('부모 로그인')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LobbyParentScreen(),
              ),
            );
          },
          child: const Text('부모로 로그인'),
        ),
      ),
    );
  }
}
