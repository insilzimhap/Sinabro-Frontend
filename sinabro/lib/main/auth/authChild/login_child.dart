import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinabro/main/childView/page/lobby_child.dart';
import 'package:sinabro/main/childView/page/level_test_page.dart';
import 'package:sinabro/config.dart';

class LoginChildScreen extends StatefulWidget {
  const LoginChildScreen({super.key});

  @override
  State<LoginChildScreen> createState() => _LoginChildScreenState();
}

class _LoginChildScreenState extends State<LoginChildScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  // 다양한 타입을 bool로 변환(문자열 'true', '1' 등도 처리)
  bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'y' || s == 'yes';
    }
    return false;
  }

  // 캐릭터 선택 여부 체크 (예외 안전)
  Future<bool> isCharacterSelected(String childId) async {
    final url = '$baseUrl/api/character/selection/check?childId=$childId';
    try {
      final resp = await http.get(
        Uri.parse(url),
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) return false;

      final ct = resp.headers['content-type'] ?? '';
      if (ct.contains('application/json')) {
        final body = json.decode(resp.body);
        // { selected: true } 혹은 { isSelected: true }, 혹은 { characterId: 'C001' } 등 방어
        if (body is Map) {
          if (body.containsKey('selected')) return _toBool(body['selected']);
          if (body.containsKey('isSelected')) return _toBool(body['isSelected']);
          if (body.containsKey('characterId')) {
            final cid = (body['characterId'] ?? '').toString();
            return cid.trim().isNotEmpty;
          }
        }
        return _toBool(body);
      } else {
        // 평문 'true' / 'false' 대응
        return _toBool(resp.body);
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = '$baseUrl/api/child/login';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'childId': _idController.text.trim(),
              'childPw': _pwController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // childId는 응답에 있으면 우선 사용, 없으면 입력값 사용
        String childId = _idController.text.trim();
        try {
          if ((response.headers['content-type'] ?? '')
              .contains('application/json')) {
            final body = json.decode(response.body);
            if (body is Map && body['childId'] != null) {
              childId = body['childId'].toString().trim();
            } else if (body is String && body.trim().isNotEmpty) {
              childId = body.trim();
            }
          } else {
            final raw = response.body.trim();
            if (raw.isNotEmpty) childId = raw;
          }
        } catch (_) {
          final raw = response.body.trim();
          if (raw.isNotEmpty) childId = raw;
        }

        if (!mounted) return;
        final selected = await isCharacterSelected(childId);

        if (!mounted) return;
        if (selected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LobbyChildScreen(childId: childId)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LevelTestPage(childId: childId)),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _message = '로그인 실패: 아이디 또는 비밀번호를 확인하세요. '
              '(${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '에러 발생: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFFEF8E7), elevation: 0),
      backgroundColor: const Color(0xFFFEF8E7),
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
              // 아이디 로그인 박스
              Container(
                width: 340,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      controller: _idController,
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
                      controller: _pwController,
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_message,
                            style: const TextStyle(color: Colors.red)),
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
                                horizontal: 20, vertical: 10),
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
              // 오른쪽 이미지
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
