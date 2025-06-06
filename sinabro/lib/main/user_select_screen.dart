import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_child.dart';
import '../main/parentView/page/login_parent.dart'; // ✅ 상대 경로로 수정
import '../main/parentView/page/no_child_parent.dart'; // 경로 확인 OK!

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  Future<void> _saveUserSelection(BuildContext context, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);

    if (userType == '아이') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginChildScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginParentScreen()),
      );
    }
  }

  void _goToNoChildParent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectParentsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 선택'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8F4FD), // AppBar 배경도 통일
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE8F4FD), // ✅ 연파랑 배경 적용
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
                Column(
                  children: [
                    _buildUserButton(context, '부모'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _goToNoChildParent(context),
                      child: const Text(
                        '부모 아이X',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
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
