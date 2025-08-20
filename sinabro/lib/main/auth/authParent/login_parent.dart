import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main/childView/page/lobby_child.dart';
import '/main/parentView/page/lobby_parent.dart';
import 'package:sinabro/login/kakao_login_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sinabro/login/social_info_page.dart';
import 'package:sinabro/login/signup_page.dart';
import 'package:sinabro/config.dart';

class LoginParentScreen extends StatefulWidget {
  final String role;
  const LoginParentScreen({super.key, required this.role});

  @override
  State<LoginParentScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginParentScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    final url = '$baseUrl/api/users/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userIdController.text.trim(),
          'userPw': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        final parentUserId = user['userId'];
        final childId = user['childId'];

        if (!mounted) return;
        if (widget.role == 'child') {
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
              builder:
                  (context) => SelectParentsPage(parentUserId: parentUserId),
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

  // 👇 아래 카카오 / 구글 로그인은 그대로 두시면 됩니다.

  Future<void> _loginWithKakao() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final user = await KakaoLoginApi.kakaoLogin();
      if (user == null) {
        setState(() {
          _message = '카카오 로그인 실패';
        });
        return;
      }

      final nickname = user['nickname'] ?? '카카오사용자';
      final email = user['email'] ?? '';
      final kakaoId = user['id'] ?? '';

      final url = '$baseUrl/api/users/social-register';
 

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': kakaoId,
          'userEmail': email,
          'userPw': kakaoId,
          'userName': nickname,
          'socialType': 'kakao',
          'socialId': kakaoId,
          'role': widget.role,
        }),
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => SocialExtraInfoPage(
                  userId: userInfo['userId'],
                  userEmail: userInfo['userEmail'],
                  userName: userInfo['userName'],
                  socialType: userInfo['socialType'],
                  socialId: userInfo['socialId'],
                ),
          ),
        );
      } else {
        setState(() {
          _message = '서버 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '카카오 로그인 에러: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          _message = '구글 로그인 취소됨';
        });
        return;
      }

      final name = googleUser.displayName ?? '구글사용자';
      final email = googleUser.email;
      final id = googleUser.id;

      final url = '$baseUrl/api/users/social-register';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': id,
          'userEmail': email,
          'userPw': id,
          'userName': name,
          'socialType': 'google',
          'socialId': id,
          'role': widget.role,
        }),
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => SocialExtraInfoPage(
                  userId: userInfo['userId'],
                  userEmail: userInfo['userEmail'],
                  userName: userInfo['userName'],
                  socialType: userInfo['socialType'],
                  socialId: userInfo['socialId'],
                ),
          ),
        );
      } else {
        setState(() {
          _message = '구글 로그인 실패: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '구글 로그인 에러: $e';
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
      appBar: AppBar(backgroundColor: const Color(0xFFFEEFEF), elevation: 0),
      backgroundColor: const Color(0xFFFEEFEF),
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
            // 👤 아이디 로그인 박스
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
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 👇 수정된 부분: GestureDetector로 감싸서 회원가입 페이지로 이동
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(role: 'parent'),
                              ),
                            );
                          },
                          child: const Text(
                            '계정이 없으신가요?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB9B9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 30),


              // 🌐 SNS 로그인 박스
              Container(
                width: 300,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SNS 로그인',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4032),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loginWithKakao,
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black,
                      ),
                      label: const Text(
                        '카카오톡으로 로그인',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEB00),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                        'assets/img/auth/google_logo.jpg',
                        width: 20,
                      ),
                      label: const Text('구글로 로그인'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_message, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
