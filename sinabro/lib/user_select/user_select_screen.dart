import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main/main_lobby.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시나브로',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/start_image.png',
                  width: 300,
                  height: 300,
                ), // 이미지 파일 위치에 맞게 수정
                const SizedBox(height: 20),
                const Text(
                  '처음 만나는 한글놀이, 시나브로',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const MainToUserSelectBtn(),
        ],
      ),
    );
  }
}

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

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  Future<void> _saveUserSelection(BuildContext context, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);

    // main/main_lobby.dart로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainLobbyScreen(userType: userType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 선택'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '누구로 로그인하나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUserButton(context, '부모'),
                const SizedBox(width: 20),
                _buildUserButton(context, '아이'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserButton(BuildContext context, String label) {
    return ElevatedButton(
      onPressed: () => _saveUserSelection(context, label),
      child: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(40),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }
}

class MainLobbyScreen extends StatelessWidget {
  final String userType;

  const MainLobbyScreen({required this.userType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('메인 로비 - $userType')),
      body: Center(
        child: Text(
          '환영합니다, $userType님!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
