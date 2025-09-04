// lib/login/login_parent.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinabro/login/kakao_login_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sinabro/login/signup_page.dart';
import 'package:sinabro/config.dart';

// ✅ 세션
import 'package:sinabro/main/parentView/page/children_state.dart';
// ✅ 로그인 성공 시 바로 자녀 페이지로 이동
import 'package:sinabro/main/parentView/page/children_page.dart';

// (선택) 여전히 공지로 가는 버튼은 남겨두고 싶으면 유지
import 'package:sinabro/main/parentView/page/notice_page.dart' show NoticePage;

class LoginParentScreen extends StatefulWidget {
  const LoginParentScreen({super.key});
  @override
  State<LoginParentScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginParentScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  // ---------------- 일반 로그인 ----------------
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': _userIdController.text.trim(),
          'userPw': _passwordController.text.trim(),
          'role': 'parent',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = _safeJson(response.body);
        final parentUserId =
            (body['userId'] ?? _userIdController.text.trim()).toString();
        final parentUserName =
            (body['userName'] ?? body['name'] ?? '').toString();

        // 세션 저장
        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );

        // ✅ 공지 대신 자녀 페이지로 직행 (명시적으로 uid/name 전달)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => NoticePage(
                  parentUserId: parentUserId,
                  parentDisplayName: parentUserName,
                ),
          ),
        );
      } else {
        final body = _safeJson(response.body);
        setState(() {
          _message =
              (body['message'] as String?) ??
              '로그인 실패: 아이디 또는 비밀번호를 확인하세요. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _message = '에러 발생: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- 카카오 로그인 ----------------
  Future<void> _loginWithKakao() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final user = await KakaoLoginApi.kakaoLogin();
      if (user == null) {
        setState(() => _message = '카카오 로그인 실패');
        return;
      }

      final email = (user['kakao_account']?['email'] ?? '').toString();
      final nickname = (user['properties']?['nickname'] ?? '').toString();
      final kakaoId = (user['id'] ?? '').toString();

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/social-register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userEmail': email,
          'userName': nickname,
          'socialType': 'kakao',
          'socialId': kakaoId,
          'role': 'parent',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = _safeJson(response.body);
        final parentUserId = (body['userId'] ?? email).toString();
        final parentUserName = (body['userName'] ?? nickname).toString();

        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );

        // ✅ 자녀 페이지로 직행
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChildrenPage(
                  parentUserId: parentUserId,
                  parentDisplayName: parentUserName,
                ),
          ),
        );
      } else {
        setState(
          () => _message = '서버 오류: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      setState(() => _message = '카카오 로그인 에러: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- 구글 로그인 ----------------
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _message = '구글 로그인 취소됨');
        return;
      }

      final email = googleUser.email;
      final name = googleUser.displayName;
      final id = googleUser.id;

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/social-register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userEmail': email,
          'userName': name,
          'socialType': 'google',
          'socialId': id,
          'role': 'parent',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = _safeJson(response.body);
        final parentUserId = (body['userId'] ?? email).toString();
        final parentUserName = (body['userName'] ?? name ?? '').toString();

        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );

        // ✅ 자녀 페이지로 직행
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChildrenPage(
                  parentUserId: parentUserId,
                  parentDisplayName: parentUserName,
                ),
          ),
        );
      } else {
        setState(
          () => _message = '구글 로그인 실패: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      setState(() => _message = '구글 로그인 에러: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _safeJson(String s) {
    try {
      final v = json.decode(s);
      return (v is Map<String, dynamic>) ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  // (선택) 하단 공지 버튼 유지
  void _goNotice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoticePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFEEFEF);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: bg, elevation: 0, toolbarHeight: 0),
      body: Stack(
        children: [
          LayoutBuilder(
            builder:
                (context, viewport) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewport.maxHeight - 60,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5A4032),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _twoCardsRow(),
                            const SizedBox(height: 16),
                            if (_message.isNotEmpty)
                              Text(
                                _message,
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: TextButton.icon(
              onPressed: _goNotice,
              icon: const Icon(Icons.campaign, size: 16),
              label: const Text('공지사항으로', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoCardsRow() {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;
        double cardW = isNarrow ? (c.maxWidth - 32) : (c.maxWidth * 0.42);
        cardW = cardW.clamp(420.0, 620.0);

        return Flex(
          direction: isNarrow ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LoginCard(
              width: cardW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('아이디로 로그인', underline: true),
                  const SizedBox(height: 16),
                  const _FieldLabel('아이디'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _userIdController,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('비밀번호'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const SignUpPage(role: 'parent'),
                                ),
                              ),
                          child: const Text(
                            '계정이 없으신가요?',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF5A4032),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB9B9),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(width: isNarrow ? 0 : 40, height: isNarrow ? 20 : 0),
            _LoginCard(
              width: cardW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('SNS 로그인'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loginWithKakao,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        '카카오로 로그인',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                        'assets/img/auth/google_logo.jpg',
                        width: 18,
                        height: 18,
                      ),
                      label: const Text('구글로 로그인'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static InputDecoration _inputDecoration() => const InputDecoration(
    filled: true,
    fillColor: Color(0xFFF8F7F6),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE5E2E0)),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

class _LoginCard extends StatelessWidget {
  final Widget child;
  final double? width;
  const _LoginCard({required this.child, this.width});
  @override
  Widget build(BuildContext context) => Container(
    width: width ?? 360,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class _CardTitle extends StatelessWidget {
  final String text;
  final bool underline;
  const _CardTitle(this.text, {this.underline = false});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF5A4032),
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 14, color: Color(0xFF5A4032)),
  );
}
