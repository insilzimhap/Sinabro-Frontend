import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 앱 내부 페이지 경로들
import '/main/parentView/page/notice_page.dart'; // 공지사항 페이지
import 'package:sinabro/login/kakao_login_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sinabro/login/signup_page.dart';
import 'package:sinabro/config.dart';

class LoginParentScreen extends StatefulWidget {
  const LoginParentScreen({super.key});

  @override
  State<LoginParentScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginParentScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  /// 일반 로그인
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final url = '$baseUrl/api/users/login';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': _userIdController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': 'parent', // 부모 로그인 고정
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const NoticePage(),
          ), // ✅ 부모는 무조건 공지사항
        );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 카카오 로그인
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

      final url = '$baseUrl/api/users/social-register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userEmail': email,
          'userName': nickname,
          'socialType': 'kakao',
          'socialId': kakaoId,
          'role': 'parent', // ✅ 부모 고정
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoticePage()),
        );
      } else {
        setState(() => _message = '서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _message = '카카오 로그인 에러: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 구글 로그인
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

      final url = '$baseUrl/api/users/social-register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userEmail': email,
          'userName': name,
          'socialType': 'google',
          'socialId': id,
          'role': 'parent', // ✅ 부모 고정
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoticePage()),
        );
      } else {
        setState(() => _message = '구글 로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _message = '구글 로그인 에러: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goNotice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoticePage()),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFEEFEF);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: 0, // 상단바 숨김
      ),
      body: Stack(
        children: [
          // -------- 본문(세로 정중앙) --------
          LayoutBuilder(
            builder: (context, viewport) {
              return SingleChildScrollView(
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
                          _twoCardsRow(), // 카드 2개 (폼/SNS)
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
              );
            },
          ),

          // -------- 왼쪽 하단 공지사항 이동 버튼 --------
          Positioned(
            left: 12,
            bottom: 12,
            child: TextButton.icon(
              onPressed: _goNotice,
              icon: const Icon(Icons.campaign, size: 16),
              label: const Text('공지사항으로', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5A4032),
                backgroundColor: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 두 개 카드(아이디 로그인 / SNS 로그인)
  Widget _twoCardsRow() {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;
        double cardW = isNarrow ? (c.maxWidth - 32) : (c.maxWidth * 0.42);
        cardW = cardW.clamp(420.0, 620.0); // 카드 최대/최소 폭

        return Flex(
          direction: isNarrow ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이디 로그인 카드
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(role: 'parent'),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            SizedBox(width: isNarrow ? 0 : 40, height: isNarrow ? 20 : 0),

            // SNS 로그인 카드 (버튼 가득)
            _LoginCard(
              width: cardW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('SNS 로그인'),
                  const SizedBox(height: 16),

                  // 카카오 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loginWithKakao,
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                      ),
                      label: const Text(
                        '카카오로 로그인',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEB00),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 구글 버튼
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
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: const BorderSide(color: Color(0xFFE1DDE0)),
                      ),
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

  // 공통 인풋 스타일
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

// ---- 작은 UI 위젯들 ----
class _LoginCard extends StatelessWidget {
  final Widget child;
  final double? width;
  const _LoginCard({required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _CardTitle extends StatelessWidget {
  final String text;
  final bool underline;
  const _CardTitle(this.text, {this.underline = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF5A4032),
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF5A4032)),
    );
  }
}
