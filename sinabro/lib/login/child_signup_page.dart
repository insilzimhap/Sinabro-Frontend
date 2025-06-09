import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChildSignUpPage extends StatefulWidget {
  final String parentUserId; // 부모의 userId (로그인 상태에서 받아와야 함)
  const ChildSignUpPage({super.key, required this.parentUserId});

  @override
  State<ChildSignUpPage> createState() => _ChildSignUpPageState();
}

class _ChildSignUpPageState extends State<ChildSignUpPage> {
  final _childIdController = TextEditingController();
  final _childPwController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childNickNameController = TextEditingController();
  final _childBirthController = TextEditingController();
  final _childAgeController = TextEditingController();
  final _childLevelController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  Future<void> _registerChild() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    const url = 'http://10.0.2.2:8090/api/child/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'childId': _childIdController.text.trim(),
          'childPw': _childPwController.text.trim(),
          'childName': _childNameController.text.trim(),
          'childNickName': _childNickNameController.text.trim(),
          'childBirth': _childBirthController.text.trim(),
          'childAge': int.tryParse(_childAgeController.text.trim()),
          'childLevel': _childLevelController.text.trim(),
          'role': 'child',
          'userId': widget.parentUserId, // 부모 ID(FK)
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('회원가입 성공'),
            content: const Text('아이 계정이 성공적으로 생성되었습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pushReplacementNamed(context, '/lobby-child');
                  // 또는 Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LobbyChildScreen()));
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 409) {
        setState(() {
          _message = '이미 존재하는 아이디입니다.';
        });
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
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text('아이 회원가입'),
        backgroundColor: Colors.orange[200],
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_childIdController, '아이디'),
              const SizedBox(height: 14),
              _buildTextField(_childPwController, '비밀번호', obscure: true),
              const SizedBox(height: 14),
              _buildTextField(_childNameController, '이름'),
              const SizedBox(height: 14),
              _buildTextField(_childNickNameController, '닉네임'),
              const SizedBox(height: 14),
              _buildTextField(_childBirthController, '생년월일 (예: 2015-08-01)'),
              const SizedBox(height: 14),
              _buildTextField(_childAgeController, '나이', keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _buildTextField(_childLevelController, '레벨 (예: 1, 2, 3 등)'),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerChild,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        child: const Text('아이 회원가입'),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
