/**
 * @file lib/main/auth/authChild/login_child.dart
 * 역할: 자녀 로그인 (permitAll).
 *      ✅ 개발 편의: AppBar에 "미리보기"를 추가해 로그인 없이 캐릭터 선택 화면으로 이동 가능
 *      ✅ 로그인 성공 → /api/child/info 로 캐릭터 선택 여부 확인
 *          - characterId 존재 → 자녀 로비로
 *          - characterId 없음(null/빈문자) → 레벨테스트로
 *      ❌ 로그인 실패(401) 또는 정보조회 실패 → 이동하지 않고 에러 표시
 */

import 'package:flutter/foundation.dart' show kReleaseMode; // ← 배포시 미리보기 숨김
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinabro/main/childView/page/lobby_child.dart';
import 'package:sinabro/main/childView/page/level_test_page.dart';
import 'package:sinabro/main/childView/page/select_character.dart'; // ← 캐릭터 선택 화면
import 'package:sinabro/config.dart';
import 'package:sinabro/main/gameView/common/api/child_state.dart';

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

  // ---------------- Helpers ----------------

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

  // 자녀 정보 조회 (permitAll). 성공 시 Map 반환, 실패 시 null
  Future<Map<String, dynamic>?> _fetchChildInfo(String childId) async {
    final uri = Uri.parse('$baseUrl/api/child/info')
        .replace(queryParameters: {'childId': childId});
    try {
      // ignore: avoid_print
      print('[login_child] 자녀정보 조회 시작 childId=$childId');

      final resp = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        // ignore: avoid_print
        print('[login_child] 자녀정보 조회 실패: 상태코드=${resp.statusCode}');
        return null;
      }

      final ct = resp.headers['content-type'] ?? '';
      if (!ct.contains('application/json')) {
        // ignore: avoid_print
        print('[login_child] 자녀정보 응답이 JSON이 아님: $ct');
        return null;
      }

      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) {
        // ignore: avoid_print
        print('[login_child] 자녀정보 조회 성공: $data');
        return data;
      }
      // ignore: avoid_print
      print('[login_child] 자녀정보 파싱 실패(형식 불일치)');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[login_child] 자녀정보 조회 예외: $e');
      return null;
    }
  }

  //---------- 로그인 (permitAll) --------------
  // → 성공 시 캐릭터 선택 여부 확인 → 라우팅 결정
  Future<void> _login() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = '$baseUrl/api/child/login';
    final inputChildId = _idController.text.trim();
    final inputPw = _pwController.text.trim();

    // ignore: avoid_print
    print('[login_child] 로그인 시도 childId=$inputChildId');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'childId': inputChildId, 'childPw': inputPw}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // 성공: childId 결정 (응답이 문자열이거나 JSON일 수 있음)
        String childId = inputChildId;

        try {
          final ct = response.headers['content-type'] ?? '';
          if (ct.contains('application/json')) {
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

        // 공백 제거
        childId = childId.trim();

        // ✅ 로그인 성공 로그
        // ignore: avoid_print
        print('[login_child] 로그인 성공 childId=$childId');

        // ✅ 전역 상태에 childId 저장
        ChildState.instance.setChild(childId);

        // (중요) 여기서만 캐릭터 여부 확인/분기. 실패시 이동하지 않음.
        final info = await _fetchChildInfo(childId);
        if (!mounted) return;

        if (info == null) {
          setState(() {
            _message = '캐릭터 선택 여부 확인에 실패했습니다. 잠시 후 다시 시도해 주세요.';
          });
          // ignore: avoid_print
          print('[login_child] 캐릭터 확인 실패 → 이동하지 않음');
          return;
        }

        final characterId = (info['characterId'] ?? '').toString().trim();
        // ignore: avoid_print
        print(
            '[login_child] characterId=${characterId.isEmpty ? '(없음)' : characterId}');

        if (characterId.isNotEmpty) {
          // 자녀 로비로
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LobbyChildScreen(childId: childId),
            ),
          );
        } else {
          // 레벨테스트로
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LevelTestPage(childId: childId)),
          );
        }
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        setState(() {
          _message = '로그인 실패: 아이디 또는 비밀번호를 확인해 주세요. (401)';
        });
        // ignore: avoid_print
        print('[login_child] 로그인 실패(401)');
      } else {
        if (!mounted) return;
        setState(() {
          _message = '로그인 실패: 서버 오류(${response.statusCode})';
        });
        // ignore: avoid_print
        print('[login_child] 로그인 실패: 상태코드=${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '에러 발생: $e';
      });
      // ignore: avoid_print
      print('[login_child] 로그인 예외: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8E7),
        elevation: 0,
        actions: [
          // 🔧 개발용 "미리보기" 버튼 (릴리스에서 자동 숨김)
          if (!kReleaseMode)
            TextButton(
              onPressed: () {
                // DEV_PREVIEW로 진입 → select_character.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectCharacterPage(
                      childId: 'DEV_PREVIEW',
                    ),
                  ),
                );
              },
              child: const Text(
                '미리보기',
                style: TextStyle(
                  color: Color(0xFF5A4032),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
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
                    const SizedBox(height: 8),
                    // 🔧 로그인 폼 하단에도 미리보기 버튼(선택): AppBar 버튼이 불편하면 사용
                    if (!kReleaseMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SelectCharacterPage(
                                  childId: 'DEV_PREVIEW',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            '캐릭터 선택(미리보기)',
                            style: TextStyle(
                              color: Color(0xFF5A4032),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
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
