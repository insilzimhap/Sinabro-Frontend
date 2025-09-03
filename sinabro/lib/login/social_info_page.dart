import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/page/notice_page.dart';

class SocialExtraInfoPage extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userName;
  final String socialType; // 'kakao' | 'google'
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
  final TextEditingController _phoneController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final payload = {
        'userId': widget.userId,
        'userEmail': widget.userEmail,
        'userName': widget.userName,
        // 비밀번호는 소셜에서 사용하지 않음
        'userPhoneNum': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'role': 'parent', // ✅ 부모 고정
        'socialType': widget.socialType, // kakao / google
        'socialId': widget.socialId,
      };

      final url = '$baseUrl/api/users/social-register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        // ✅ 추가 정보 등록 완료 → 공지사항으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoticePage()),
        );
      } else {
        setState(() {
          _message = '요청 실패: ${response.statusCode}';
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추가 정보 입력')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: widget.userEmail),
              decoration: const InputDecoration(labelText: '이메일'),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.userName),
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '휴대폰 번호',
                hintText: '예) 010-1234-5678',
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
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
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('회원가입 완료'),
                    ),
                  ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
