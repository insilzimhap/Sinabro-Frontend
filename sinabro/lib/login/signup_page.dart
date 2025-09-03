import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'kakao_login_api.dart'; // 카카오 로그인 로직
import 'package:google_sign_in/google_sign_in.dart';

// ✅ 부모용 공지사항 페이지로 이동
import 'package:sinabro/main/parentView/page/notice_page.dart';

import 'social_info_page.dart';
import 'package:sinabro/config.dart';

class SignUpPage extends StatefulWidget {
  // role은 지금 안 쓰이지만 기존 호출부 호환 위해 유지
  final String role;
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController(); // 아이디
  final _passwordController = TextEditingController(); // 비밀번호
  final _emailController = TextEditingController(); // 이메일
  final _nameController = TextEditingController(); // 이름
  final _phoneController = TextEditingController(); // 휴대폰 번호

  String _message = '';
  bool _isLoading = false;

  // ✅ 일반 회원가입 요청 (부모 전용)
  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = '$baseUrl/api/users/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': _usernameController.text.trim(),
          'userPw': _passwordController.text.trim(),
          'userEmail': _emailController.text.trim(),
          'userName': _nameController.text.trim(),
          'userPhoneNum': _phoneController.text.trim(),
          'role': 'parent', // 부모 전용
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        // 최종 이동: 공지사항 페이지
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoticePage()),
        );
      } else if (response.statusCode == 409) {
        // 중복 아이디
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('중복 오류'),
            content: const Text('이미 존재하는 아이디입니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _message = '회원가입 실패: ${response.statusCode}\n${response.body}';
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

  // ✅ 카카오 로그인 + 서버 전송
  Future<void> _loginWithKakao() async {
    try {
      final result = await KakaoLoginApi.kakaoLogin();

      if (result == null) {
        setState(() => _message = '카카오 로그인 실패');
        return;
      }

      final url = '$baseUrl/api/users/social-register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': result['id'] ?? '',
          'userEmail': result['email'] ?? '',
          'userPw': result['accessToken'] ?? '',
          'userName': result['nickname'] ?? '',
          'role': 'parent',
          'socialType': 'kakao',
          'socialId': result['id'] ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        if (!mounted) return;
        // 소셜은 추가 정보 입력 페이지로
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
          _message = '서버 응답 오류: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '요청 실패: $e';
      });
    }
  }

  // ✅ 구글 로그인 + 서버 전송
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
          'role': 'parent',
          'socialType': 'google',
          'socialId': id,
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7), // 배경색 통일
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.orange[100], // AppBar 색 통일
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: '아이디',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '휴대폰 번호',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[200],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginWithKakao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '카카오로 시작하기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '구글 계정으로 시작하기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
