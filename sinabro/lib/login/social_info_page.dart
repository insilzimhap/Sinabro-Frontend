import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main/parentView/page/lobby_parent.dart';

class _Palette {
  // 화면 톤 (연한 핑크 배경 + 포커스 보라)
  static const bg = Color(0xFFFFF1F1);         // 전체 배경
  static const card = Color(0xFFF8EAEA);       // 섹션 카드
  static const focus = Color(0xFF7C4DFF);      // 포커스/아웃라인
  static const ok = Color(0xFF2E7D32);         // 초록 안내
  static const err = Colors.red;               // 에러
  static const label = Color(0xFF6B6B6B);      // 라벨톤
}

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
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  final _phoneController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();

  // 동의/설정
  bool _agreePrivacy = false; // (필수)
  bool _agreeEmail = false;   // (선택)
  bool _agreePush = false;    // (선택)
  String _lang = 'ko';        // 기본 한국어

  // 상태
  String _message = '';
  bool _isLoading = false;

  // 유효성 도우미
  bool get _passwordValid {
    final pw = _pwController.text.trim();
    return pw.length >= 8 && pw.length <= 16;
  }

  bool get _passwordsMatch =>
      _pwController.text.trim().isNotEmpty &&
      _pwController.text.trim() == _pwConfirmController.text.trim();

  bool get _canSubmit =>
      !_isLoading && _formKey.currentState?.validate() == true && _agreePrivacy;

  Future<void> _submit() async {
    if (!_canSubmit) {
      _formKey.currentState?.validate();
      setState(() {}); // 버튼 상태 갱신
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    const url = 'http://10.0.2.2:8090/api/users/social-register';
    // const url = 'http://172.30.1.64:8090/api/users/social-register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'userEmail': widget.userEmail,
          'userPw': widget.socialId, // 기존 로직 유지(임시 PW)
          'userName': widget.userName,
          'userPhoneNum': _phoneController.text.trim(),
          'role': 'parent',
          'socialType': widget.socialType,
          'socialId': widget.socialId,

          // 화면 추가 항목: 현재는 전송 안 함 (스펙 확정 시 주석 해제)
          // 'appPassword': _pwController.text.trim(),
          // 'agreePrivacy': _agreePrivacy,
          // 'agreeEmail': _agreeEmail,
          // 'agreePush': _agreePush,
          // 'lang': _lang,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        final parentUserId = userInfo['userId'] ?? widget.userId;

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
  void dispose() {
    _phoneController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final divider = const SizedBox(height: 16);

    // 입력 필드 공통 스타일 (보라 포커스, 둥근 모서리)
    final inputDecorationTheme = InputDecorationTheme(
      labelStyle: const TextStyle(color: _Palette.label),
      helperStyle: const TextStyle(color: _Palette.ok, fontSize: 12),
      errorStyle: const TextStyle(color: _Palette.err, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _Palette.focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _Palette.err, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _Palette.err, width: 2),
      ),
      isDense: true,
    );

    return Scaffold(
      backgroundColor: _Palette.bg,
      appBar: AppBar(
        title: const Text('추가 정보 입력'),
        backgroundColor: Colors.white.withOpacity(0.7),
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: inputDecorationTheme,
          checkboxTheme: CheckboxThemeData(
            fillColor:
                MaterialStateProperty.resolveWith((_) => _Palette.focus),
            side: const BorderSide(color: Colors.black38),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all(const Size(160, 44)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey.shade300;
                }
                return const Color(0xFFFF8E8E); // 연한 코랄
              }),
              foregroundColor:
                  MaterialStateProperty.all(Colors.white),
              elevation: MaterialStateProperty.all(0),
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이메일 / 이름 (비활성)
                  TextFormField(
                    enabled: false,
                    initialValue: widget.userEmail,
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    enabled: false,
                    initialValue: widget.userName,
                    decoration: const InputDecoration(labelText: '이름'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: '휴대폰 번호'),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) {
                        return '휴대폰 번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),

                  divider,

                  // 역할: 부모
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

                  // === 비밀번호 / 재입력 ===
                  Text(
                    '비밀번호 (소셜 로그인 비밀번호가 아닌, 회원 정보 수정/탈퇴 등에 사용하는 비밀번호입니다)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: _Palette.label),
                  ),
                  const SizedBox(height: 8),

                  // 비밀번호
                  TextFormField(
                    controller: _pwController,
                    obscureText: true, // 항상 숨김
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      helperText: '8자 이상 16자 이하',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final pw = (v ?? '').trim();
                      if (pw.isEmpty) return '비밀번호를 입력해주세요.';
                      if (pw.length < 8 || pw.length > 16) {
                        return '비밀번호는 8자 이상 16자 이하로 입력해주세요.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // 재입력
                  TextFormField(
                    controller: _pwConfirmController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(labelText: '재입력'),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final text = (v ?? '').trim();
                      if (text.isEmpty) return '비밀번호를 한 번 더 입력해주세요.';
                      if (_pwController.text.trim() != text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 6),

                  // 일치/불일치 안내
                  Builder(builder: (_) {
                    final pw = _pwController.text.trim();
                    final confirm = _pwConfirmController.text.trim();
                    if (pw.isEmpty && confirm.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final match = pw.isNotEmpty && pw == confirm;
                    return Text(
                      match ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: match ? _Palette.ok : _Palette.err,
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // === 수신동의(선택) & 언어 설정 ===
                  Container(
                    decoration: BoxDecoration(
                      color: _Palette.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('수신동의 (선택)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: _agreeEmail,
                          onChanged: (v) =>
                              setState(() => _agreeEmail = v ?? false),
                          title: const Text('이메일 수신 동의'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: _agreePush,
                          onChanged: (v) =>
                              setState(() => _agreePush = v ?? false),
                          title: const Text('알림 수신 동의'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 8),
                        const Text('언어설정',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _lang,
                          items: const [
                            DropdownMenuItem(value: 'ko', child: Text('한국어')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'ja', child: Text('日本語')),
                          ],
                          onChanged: (v) => setState(() => _lang = v ?? 'ko'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 개인정보 수집 동의(필수) + 전문 읽기
                  Row(
                    children: [
                      Checkbox(
                        value: _agreePrivacy,
                        onChanged: (v) =>
                            setState(() => _agreePrivacy = v ?? false),
                      ),
                      const Expanded(child: Text('개인정보 수집 동의 (필수)')),
                      TextButton(
                        onPressed: () {
                          // TODO: 약관 전문 보기 화면 연결
                        },
                        child: const Text('전문 읽기'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 제출 버튼
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _canSubmit ? _submit : null,
                            child: const Text('회원가입 완료'),
                          ),
                  ),

                  const SizedBox(height: 12),

                  if (_message.isNotEmpty)
                    Text(_message, style: const TextStyle(color: _Palette.err)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}