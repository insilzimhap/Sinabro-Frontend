import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main/childView/page/lobby_child.dart';
import '/main/childView/page/select_character.dart';

class LoginChildPage extends StatefulWidget {
  const LoginChildPage({super.key});

  @override
  State<LoginChildPage> createState() => _LoginChildPageState();
}

class _LoginChildPageState extends State<LoginChildPage> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<bool> isCharacterSelected(String childId) async {
    final url =
        'http://10.0.2.2:8090/api/character/selection/check?childId=$childId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('서버 응답: $data');
      return data['selected'] == true;
    } else {
      return false;
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    const url = 'http://10.0.2.2:8090/api/child/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'childId': _userIdController.text.trim(),
          'childPw': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        final childId = _userIdController.text.trim();
        final selected = await isCharacterSelected(childId);

        if (selected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LobbyChildScreen(childId: childId),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCharacterPage(childId: childId),
            ),
          );
        }
      } else {
        setState(() {
          _message = '로그인 실패: 아이디 또는 비밀번호를 확인하세요.';
        });
      }
    } catch (e) {
      setState(() {
        _message = '에러 발생: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8E7),
        elevation: 0,
        title: const Text('아이 로그인', style: TextStyle(color: Colors.brown)),
        foregroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            '로그인',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4032),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👤 로그인 입력 박스
              Container(
                width: 340,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '아이디로 로그인',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4032),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('아이디', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF8F7F6),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('비밀번호', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF8F7F6),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF0BB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C685F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),

              // 🖼 이미지 영역
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: AssetImage('assets/img/auth/loginRabit.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
