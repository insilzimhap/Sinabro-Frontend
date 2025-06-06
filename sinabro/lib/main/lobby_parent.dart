import 'package:flutter/material.dart';
import '/login/signup_page.dart';

class LobbyParentScreen extends StatelessWidget {
  const LobbyParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6), // 아이 스타일과 동일한 배경색
      appBar: AppBar(
        title: const Text('부모 메인 로비'),
        backgroundColor: Colors.orange[200],
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.family_restroom, size: 80, color: Colors.brown),
              const SizedBox(height: 24),
              const Text(
                '환영합니다, 부모님!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(role: 'child'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Text('우리 아이 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
