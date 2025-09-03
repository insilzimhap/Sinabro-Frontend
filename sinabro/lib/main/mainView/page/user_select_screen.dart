import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sinabro/main/auth/authChild/login_child.dart';
import 'package:sinabro/main/auth/authParent/login_parent.dart';


class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  Future<void> _saveUserSelection(BuildContext context, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);

    // 선택 후 뒤로가기로 다시 이 화면 안 돌아오도록 pushReplacement 사용
    if (userType == '아이') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginChildScreen()),
      );
    } else {
      // ✅ 부모 전용 Login 화면은 role 인자를 받지 않음
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginParentScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFE8F4FD);

    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 선택'),
        centerTitle: true,
        backgroundColor: bg,
        elevation: 0,
      ),
      backgroundColor: bg,
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
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(40),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
