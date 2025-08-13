import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main/parentView/page/lobby_parent.dart';
import 'package:sinabro/config.dart';

class SocialExtraInfoPage extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userName;
  final String socialType;
  final String socialId;

  const SocialExtraInfoPage({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.socialType,
    required this.socialId,
  });

  @override
  State<SocialExtraInfoPage> createState() => _SocialExtraInfoPageState();
}

class _SocialExtraInfoPageState extends State<SocialExtraInfoPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  final TextEditingController _phoneController = TextEditingController();

  // 값이 이미 있으면 읽기 전용, 없으면 입력 가능
  bool get _emailLocked => _emailController.text.trim().isNotEmpty;
  bool get _nameLocked => _nameController.text.trim().isNotEmpty;

  String _message = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail);
    _nameController  = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = '$baseUrl/api/users/social-register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'userEmail': _emailController.text.trim(),   // ← 컨트롤러 값 사용
          'userPw': widget.socialId,                   // 소셜 ID를 임시 비밀번호로 저장
          'userName': _nameController.text.trim(),     // ← 컨트롤러 값 사용
          'userPhoneNum': _phoneController.text.trim(),
          'role': 'parent',
          'socialType': widget.socialType,
          'socialId': widget.socialId,
        }),
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        final parentUserId = userInfo['userId'] ?? widget.userId;

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectParentsPage(parentUserId: parentUserId),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추가 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 이메일: 값 있으면 잠금, 없으면 입력 가능
            TextField(
              controller: _emailController,
              enabled: !_emailLocked,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            // 이름: 값 있으면 잠금, 없으면 입력 가능
            TextField(
              controller: _nameController,
              enabled: !_nameLocked,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '휴대폰 번호'),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Text('역할: ', style: TextStyle(fontSize: 16)),
                Text(
                  '부모',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('회원가입 완료'),
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
