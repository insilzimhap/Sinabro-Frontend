import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main/main_lobby.dart';
import '../main/parentView/page/parent_main.dart'; // 부모 메인 화면
import '../main/parentView/page/no_child_parent.dart'; // 자녀 없는 화면
import '../main/parentView/page/parent_main.dart';

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
                ),
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
          backgroundColor: const Color.fromARGB(255, 255, 239, 168),
          shadowColor: const Color.fromARGB(255, 159, 142, 98),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        child: const Text(
          '시작하기',
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 100, 84, 63),
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

    if (userType == '부모') {
      final hasChild = await _checkIfParentHasChild();

      if (hasChild) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ParentMainScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectParentsPage()),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainLobbyScreen(userType: userType),
        ),
      );
    }
  }

  Future<bool> _checkIfParentHasChild() async {
    // TODO: 실제 DB 조회로 대체
    await Future.delayed(Duration(milliseconds: 300));
    return false; // ← 테스트용. 자녀가 있으면 true로 바꾸기!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 선택'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ 테스트용 진입 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentMainScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
              child: const Text('📂 부모 화면 바로가기'),
            ),
            const SizedBox(height: 30),

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
