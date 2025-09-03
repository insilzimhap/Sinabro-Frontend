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
  final _phoneController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = '$baseUrl/api/users/social-register';

    try {
      final payload = {
        'userId': widget.userId,
        'userEmail': widget.userEmail,
        // 'userPw': null,  // ⬅️ 절대 보내지 않음
        'userName': widget.userName,
        'userPhoneNum': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'role': 'parent',
        'socialType': widget.socialType, // kakao / google
        'socialId': widget.socialId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
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
            Row(
              children: const [
                Text('역할: ', style: TextStyle(fontSize: 16)),
                Text('부모',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown)),
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
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
