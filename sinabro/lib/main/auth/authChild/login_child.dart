import 'package:flutter/material.dart';

import 'package:sinabro/main/childView/page/select_character.dart';

class LoginChildScreen extends StatelessWidget {
  const LoginChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이 로그인')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectCharacterPage(),
              ),
            );
          },
          child: const Text('로그인하고 시작하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.orange[200],
            foregroundColor: Colors.brown,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
