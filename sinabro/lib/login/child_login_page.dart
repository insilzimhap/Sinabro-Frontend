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
  final url = 'http://10.0.2.2:8090/api/character/selection/check?childId=$childId';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
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

    const url = 'http://10.0.2.2:8090/api/child/login'; // 아이 로그인용 엔드포인트

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
            builder: (context) => const LobbyChildScreen(),
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
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text('아이 로그인'),
        backgroundColor: Colors.orange[200],
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: '아이 아이디',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        child: const Text('로그인'),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
