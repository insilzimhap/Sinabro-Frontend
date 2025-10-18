/**
 * @file lib/login/signup_page.dart
 * 역할: 부모 회원가입. 응답에 토큰이 있으면 저장.
 * @채영: JWT+api 연결 완료
 * @연수: 디버깅 로그 추가
 */
///

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinabro/config.dart';
import 'package:sinabro/main/auth/authParent/login_parent.dart'; //가입 후 로그인 화면 이동
import 'package:sinabro/main/parentView/page/child/children_state.dart';
import 'package:flutter/services.dart'; // TextInputFormatter 전화번호 양식 유지

class SignUpPage extends StatefulWidget {
  final String role; // 'parent' 등
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers
  final _userIdController = TextEditingController(); // 아이디
  final _emailController = TextEditingController(); // 이메일
  final _pwController = TextEditingController(); // 비밀번호
  final _pwConfirmController = TextEditingController(); // 비밀번호 재입력
  final _nameController = TextEditingController(); // 이름
  final _phoneController = TextEditingController(); // 전화번호

  // State
  bool _isLoading = false;
  String _message = '';

  // ID 중복 체크 상태
  bool _idChecking = false;
  bool? _idAvailable; // null=미확인, true=사용가능, false=중복
  String _idCheckMsg = '';

  // 동의/설정
  bool _agreePrivacy = false; // 개인정보 수집 동의
  bool _agreeEmail = false; // 이메일 수신
  bool _agreePush = false; // 알림 수신
  String _lang = '한국어';

  // ───────────────── helpers ─────────────────
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isPasswordValid(String pw) => pw.length >= 8 && pw.length <= 16;

  Map<String, dynamic> _safeJson(String s) {
    try {
      final v = json.decode(s);
      return (v is Map<String, dynamic>) ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _mapLang(String v) {
    switch (v) {
      case '한국어':
        return 'Korea';
      case 'English':
        return 'English';
      case '日本語':
        return 'Japanese';
      case 'Tiếng Việt':
        return 'Vietnamese';
      case '中文':
        return 'Chinese';
      case 'ไทย':
        return 'Thai';
      default:
        return 'Korea';
    }
  }

  bool _isPhoneValid(String v) => RegExp(r'^010-\d{4}-\d{4}$').hasMatch(v);

  // ───────────────── 아이디 중복 확인 ─────────────────
  Future<void> _checkUserId() async {
    final id = _userIdController.text.trim();
    if (id.isEmpty) {
      setState(() {
        _idAvailable = null;
        _idCheckMsg = '아이디를 입력하세요.';
      });
      return;
    }

    setState(() {
      _idChecking = true;
      _idCheckMsg = '';
    });

    final uri = Uri.parse(
      '$baseUrl/api/users/check-id',
    ).replace(queryParameters: {'userId': id});

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = _safeJson(res.body);
        final available = (data['available'] == true);
        setState(() {
          _idAvailable = available;
          _idCheckMsg = available ? '사용 가능한 아이디예요.' : '이미 사용 중인 아이디예요.';
        });
      } else {
        setState(() {
          _idAvailable = null;
          _idCheckMsg = '중복 확인 실패(${res.statusCode})';
        });
      }
    } catch (e) {
      // ✅ 디버깅용 print 추가
      print('🛑 아이디 중복 확인 중 오류: $e');
      setState(() {
        _idAvailable = null;
        _idCheckMsg = '중복 확인 중 오류: $e';
      });
    } finally {
      setState(() => _idChecking = false);
    }
  }

  // ───────────────── 회원가입 ─────────────────
  Future<void> _registerUser() async {
    final userId = _userIdController.text.trim();
    final userPw = _pwController.text;
    final confirmPw = _pwConfirmController.text;

    if (userId.isEmpty) return _showSnack('아이디를 입력하세요.');
    if (_idAvailable == false || _idAvailable == null) {
      return _showSnack('아이디 중복 확인을 완료해 주세요.');
    }
    if (!_isPasswordValid(userPw)) {
      return _showSnack('비밀번호는 8~16자로 설정해 주세요.');
    }
    if (userPw != confirmPw) {
      return _showSnack('비밀번호와 재입력이 일치하지 않습니다.');
    }
    if (_nameController.text.trim().isEmpty) {
      return _showSnack('이름을 입력하세요.');
    }
    if (_emailController.text.trim().isEmpty) {
      return _showSnack('이메일을 입력하세요.');
    }
    if (!_agreePrivacy) {
      return _showSnack('개인정보 수집 동의가 필요합니다.');
    }
    if (!_isPhoneValid(_phoneController.text.trim())) {
      return _showSnack('전화번호는 010-0000-0000 형식으로 입력해 주세요.');
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final payload = {
        'userId': userId,
        'userPw': userPw,
        'confirmPw': confirmPw,
        'userEmail': _emailController.text.trim(),
        'userName': _nameController.text.trim(),
        'userPhoneNum': _phoneController.text.trim(),
        'role': widget.role,
        'userLanguage': _mapLang(_lang),
        'settings': {
          'privacyConsent': true,
          'allowNotifications': _agreePush,
          'emailSubscription': _agreeEmail,
        },
      };

      final res = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = _safeJson(res.body);
        final parentUserId = (body['userId'] ?? userId).toString();
        final parentUserName =
            (body['userName'] ?? _nameController.text.trim()).toString();

        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginParentScreen()),
        );
      } else if (res.statusCode == 409) {
        _showSnack('이미 존재하는 아이디/이메일입니다.');
      } else if (res.statusCode == 400) {
        _showSnack(_safeJson(res.body).toString());
      } else {
        // ✅ 디버깅용 print 추가
        print('🚨 서버 응답 오류: ${res.statusCode}');
        print('📄 서버 응답 내용: ${res.body}');
        setState(() {
          _message = '회원가입 실패: ${res.statusCode}\n${res.body}';
        });
      }
    } catch (e) {
      // ✅ 디버깅용 print 추가
      print('🛑 회원가입 요청 중 심각한 오류 발생: $e');
      setState(() {
        _message = '요청 실패: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ───────────────── UI ─────────────────
  InputDecoration _input(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF1F1);
    final cardColor = Colors.white;
    final headerStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: const Color(0xFF7A4F3B),
      fontWeight: FontWeight.w800,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        // ✅ SingleChildScrollView 추가 (오버플로우 방지)
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 900;
              final page = Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text('회원가입', style: headerStyle),
                    ),
                    const SizedBox(height: 12),
                    isWide
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _leftFormCard(cardColor)),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _rightConsentCard(cardColor),
                                  const SizedBox(height: 20),
                                  _animationBox(cardColor),
                                ],
                              ),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            _leftFormCard(cardColor),
                            const SizedBox(height: 16),
                            _rightConsentCard(cardColor),
                            const SizedBox(height: 16),
                            _animationBox(cardColor),
                          ],
                        ),
                  ],
                ),
              );
              return page;
            },
          ),
        ),
      ),
    );
  }

  Widget _leftFormCard(Color cardColor) {
    final idHintColor =
        _idAvailable == null
            ? Colors.grey
            : _idAvailable == true
            ? Colors.green
            : Colors.red;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    onChanged: (_) {
                      setState(() {
                        _idAvailable = null;
                        _idCheckMsg = '';
                      });
                    },
                    decoration: _input('아이디'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _idChecking ? null : _checkUserId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC5C5),
                      foregroundColor: Colors.brown[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _idChecking
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('중복 확인'),
                  ),
                ),
              ],
            ),
            if (_idCheckMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _idCheckMsg,
                    style: TextStyle(color: idHintColor, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _input('이메일'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: _input('비밀번호'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '8자 이상 16자 이하',
                  style: TextStyle(
                    color:
                        _isPasswordValid(_pwController.text)
                            ? Colors.green
                            : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwConfirmController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: _input('재입력'),
            ),
            if (_pwConfirmController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _pwConfirmController.text == _pwController.text
                        ? '비밀번호가 일치합니다.'
                        : '비밀번호가 일치하지 않습니다.',
                    style: TextStyle(
                      color:
                          _pwConfirmController.text == _pwController.text
                              ? Colors.green
                              : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: _input('이름')),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              ],
              maxLength: 13,
              decoration: _input(
                '전화번호',
              ).copyWith(hintText: '010-0000-0000', counterText: ''),
            ),
            if (_phoneController.text.isNotEmpty &&
                !_isPhoneValid(_phoneController.text.trim()))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '전화번호 형식: 010-0000-0000',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _agreePrivacy,
                  onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text('개인정보 수집 동의'),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showSnack('개인정보 처리 방침 모달은 추후 연결 예정'),
                  child: const Text('전문 읽기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rightConsentCard(Color cardColor) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '수신동의 (선택)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.brown[700],
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agreeEmail,
              onChanged: (v) => setState(() => _agreeEmail = v ?? false),
              title: const Text('이메일 수신 동의'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agreePush,
              onChanged: (v) => setState(() => _agreePush = v ?? false),
              title: const Text('알림 수신 동의'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '언어설정',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.brown[700],
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: _lang,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '한국어', child: Text('한국어')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: '日本語', child: Text('日本語')),
                  DropdownMenuItem(
                    value: 'Tiếng Việt',
                    child: Text('Tiếng Việt'),
                  ),
                  DropdownMenuItem(value: '中文', child: Text('中文')),
                  DropdownMenuItem(value: 'ไทย', child: Text('ไทย')),
                ],
                onChanged: (v) => setState(() => _lang = v ?? '한국어'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animationBox(Color cardColor) {
    return Card(
      color: cardColor, // 배경색을 흰색으로 변경
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Center(
          // ✅ Column 추가 (오류 메시지 표시 위함)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                  child: Text(
                    _message,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC5C5),
                      foregroundColor: Colors.brown[800],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '가입하기',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
