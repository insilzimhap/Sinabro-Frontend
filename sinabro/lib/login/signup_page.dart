import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'kakao_login_api.dart'; // 카카오 로그인 로직 분리된 파일
import 'package:google_sign_in/google_sign_in.dart';
import '/main/parentView/page/lobby_parent.dart';
import '/main/childView/page/lobby_child.dart';
import 'social_info_page.dart';

class SignUpPage extends StatefulWidget {
  final String role;
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();   // 아이디
  final _passwordController = TextEditingController();   // 비밀번호
  final _emailController = TextEditingController();      // 이메일
  final _nameController = TextEditingController();       // 이름
  final _phoneController = TextEditingController();      // 휴대폰 번호

  String _message = '';
  bool _isLoading = false;

  // ✅ 일반 회원가입 요청
  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    const url = 'http://10.0.2.2:8090/api/users/register';

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
          'role': widget.role, // 추가!
          // 서버에서 기본값 처리: userLanguage, role, socialType, socialId
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        final resBody = json.decode(response.body);
        final childId = resBody['childId'] ?? _usernameController.text.trim();

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
              builder: (context) => LobbyParentScreen(parentUserId: _usernameController.text.trim()),
            ),
          );
        }
      }
 else if (response.statusCode == 409) {
        // 중복 아이디
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ 카카오 로그인 + 서버 전송 (이전 코드 그대로)
  Future<void> _loginWithKakao() async {
    final result = await KakaoLoginApi.kakaoLogin();

    if (result == null) {
      setState(() {
        _message = '카카오 로그인 실패';
      });
      return;
    }

    const url = 'http://10.0.2.2:8090/api/users/social-register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': result['id'] ?? '',
          'userEmail': result['email'] ?? '',
          'userPw': result['accessToken'] ?? '',
          'userName': result['nickname'] ?? '',
          'socialType': 'kakao',
          'socialId': result['id'] ?? '',
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
          _message = '서버 응답 오류: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '요청 실패: $e';
      });
    }
  }

  // ✅ 구글 로그인 + 서버 전송 (이전 코드 그대로)
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
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '휴대폰 번호'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _registerUser,
                        child: const Text('회원가입'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loginWithKakao,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                        child: const Text(
                          '카카오로 시작하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _loginWithGoogle,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        child: const Text(
                          '구글 계정으로 시작하기', 
                          style: TextStyle(color: Colors.black),
                        ),
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
