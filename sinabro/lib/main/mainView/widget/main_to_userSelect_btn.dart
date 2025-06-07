import 'package:flutter/material.dart';

import 'package:sinabro/main/mainView/page/user_select_screen.dart';

class MainToUserSelectBtn extends StatelessWidget {
  const MainToUserSelectBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 20,
      child: ElevatedButton(
        key: const Key('main_to_userSelect_btn'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserSelectScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 239, 168), // 배경색
          shadowColor: const Color.fromARGB(255, 159, 142, 98), // 그림자 색
          elevation: 8, // 그림자 깊이
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        child: const Text(
          '시작하기',
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 100, 84, 63), // 글자색
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
