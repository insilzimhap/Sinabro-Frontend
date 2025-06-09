import 'package:flutter/material.dart';
import '/login/child_login_page.dart'; // 아이 로그인 페이지로 이동


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
                builder: (context) => const LoginChildPage(),
              ),
            );
          },
          child: const Text('로그인하고 시작하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.orangeAccent, // 좀 더 진한 오렌지
            foregroundColor: Colors.brown,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
        ),
      ),
    );
  }
}
