import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main/parentView/page/lobby_parent.dart';

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
  final _phoneController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    const url = 'http://10.0.2.2:8090/api/users/social-register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'userEmail': widget.userEmail,
          'userPw': widget.socialId, // 소셜 ID를 임시 비밀번호로 저장
          'userName': widget.userName,
          'userPhoneNum': _phoneController.text.trim(),
          'role': 'parent', // 자동으로 부모로 고정!
          'socialType': widget.socialType,
          'socialId': widget.socialId,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LobbyParentScreen(parentUserId: "")), // parentUserId 전달 필요시 수정
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
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.userEmail),
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.userName),
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '휴대폰 번호'),
            ),
            const SizedBox(height: 16),
            // 역할 선택 대신 "부모"로 고정 표시
            Row(
              children: const [
                Text(
                  '역할: ',
                  style: TextStyle(fontSize: 16),
                ),
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
                    onPressed: _phoneController.text.trim().isNotEmpty ? _submit : null,
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
