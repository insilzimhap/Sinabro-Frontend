import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main/lobby_child.dart';
import '/main/lobby_parent.dart';
import 'signup_page.dart';
import 'kakao_login_api.dart';
import 'social_info_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userIdController = TextEditingController();   // 아이디
  final _passwordController = TextEditingController(); // 비밀번호

  String _message = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    const url = 'http://10.0.2.2:8090/api/users/login';

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
        if (!mounted) return;
        if (widget.role == 'child') {
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
              builder: (context) => const LobbyParentScreen(),
            ),
          );
        }
      }
      else {
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

  // ✅ 카카오 로그인 (이전 코드 그대로)
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

      const url = 'http://10.0.2.2:8090/api/users/social-register';

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
          'role': widget.role, // 추가!
        }),
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SocialExtraInfoPage(
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

  // ✅ 구글 로그인 (이전 코드 그대로)
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

      const url = 'http://10.0.2.2:8090/api/users/social-register';

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
          'role': widget.role, // 추가!
        }),
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SocialExtraInfoPage(
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
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('로그인'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(role: widget.role),
                            ),
                          );
                        },
                        child: const Text('회원가입'),
                      ),
                      ElevatedButton(
                        onPressed: _loginWithKakao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                        ),
                        child: const Text(
                          '카카오로 시작하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _loginWithGoogle,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        child: const Text('구글 계정으로 시작하기', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
