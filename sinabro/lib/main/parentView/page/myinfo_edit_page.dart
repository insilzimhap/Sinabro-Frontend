/*
 * 파일: lib/main/parentView/page/mypage_edit_page.dart (MyInfoEditPage)
 * 개요: 부모 계정 정보 수정 화면. ParentLayout(사이드바/헤더) 하위에서
 *      프로필 요약(좌측)과 계정 정보 입력 폼(우측)을 카드 형태로 제공한다.
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

class MyInfoEditPage extends StatefulWidget {
  /// 동적 사이드바/헤더에 쓰일 parentUserId (없어도 동작)
  final String? parentUserId;

  /// 초기 표시용 값들 (서버 연동 전까지 더미/프리필)
  final String initialName;
  final String initialUserId;
  final String initialEmail;
  final String initialPhone;

  const MyInfoEditPage({
    super.key,
    this.parentUserId,
    this.initialName = '박성민',
    this.initialUserId = 'Sungminpark',
    this.initialEmail = 'Sungminpark@Gmail.Com',
    this.initialPhone = '010-0000-1111',
  });

  @override
  State<MyInfoEditPage> createState() => _MyInfoEditPageState();
}

class _MyInfoEditPageState extends State<MyInfoEditPage> {
  late final TextEditingController _name;
  late final TextEditingController _userId;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final TextEditingController _pw = TextEditingController();
  final TextEditingController _pw2 = TextEditingController();

  bool _saving = false;
  bool _pwMismatch = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _userId = TextEditingController(text: widget.initialUserId);
    _email = TextEditingController(text: widget.initialEmail);
    _phone = TextEditingController(text: widget.initialPhone);

    _pw.addListener(_validatePw);
    _pw2.addListener(_validatePw);
  }

  @override
  void dispose() {
    _name.dispose();
    _userId.dispose();
    _email.dispose();
    _phone.dispose();
    _pw.removeListener(_validatePw);
    _pw2.removeListener(_validatePw);
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  void _validatePw() {
    final mismatch =
        _pw.text.isNotEmpty && _pw2.text.isNotEmpty && _pw.text != _pw2.text;
    if (mismatch != _pwMismatch) {
      setState(() => _pwMismatch = mismatch);
    }
  }

  Future<void> _save() async {
    // 비번을 변경하려는 경우에만 유효성 검사
    if (_pw.text.isNotEmpty || _pw2.text.isNotEmpty) {
      if (_pwMismatch) return;
      if (_pw.text.length < 8 || _pw.text.length > 16) {
        _showSnack('비밀번호는 8자 이상 16자 이하로 입력해주세요.');
        return;
      }
    }

    setState(() => _saving = true);

    // TODO: 서버 연동 (/api/users/update 등) — payload 생성 후 요청
    await Future.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;
    setState(() => _saving = false);

    _showSuccessDialog(); // 시안과 유사한 녹색 성공 박스
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE7F6E9),
                border: Border.all(color: const Color(0xFF53A866), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Stack(
                children: [
                  // 닫기 버튼 (오른쪽 위)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF2E7D32)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // 본문
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(height: 12),
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(height: 14),
                      Text(
                        '수정 성공',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '정보가 성공적으로 수정되었습니다!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '마이페이지',
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  // 상단 녹색 헤더바
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DBF73),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      '마이 페이지',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 본문 카드
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽 프로필 블럭
                          Column(
                            children: const [
                              CircleAvatar(
                                radius: 64,
                                backgroundColor: Color(0xFFE0E0E0),
                                child: Icon(
                                  Icons.person,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '부모 회원',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '박성민 님',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 28),

                          // 오른쪽 입력 폼
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFDFDFDF),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 이름
                                  _row('이름', _name, readOnly: true),
                                  const SizedBox(height: 14),

                                  // 아이디
                                  _row('아이디', _userId, readOnly: true),

                                  const SizedBox(height: 14),
                                  _row(
                                    '이메일',
                                    _email,
                                    keyboard: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 14),
                                  _row(
                                    '전화번호',
                                    _phone,
                                    keyboard: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 14),
                                  _row(
                                    '비밀번호',
                                    _pw,
                                    obscure: true,
                                    hint: '변경 시에만 입력해주세요.',
                                    helper: '8자 이상 16자 이상',
                                  ),
                                  const SizedBox(height: 14),
                                  _row(
                                    '재입력',
                                    _pw2,
                                    obscure: true,
                                    errorText: _pwMismatch ? '비밀번호가 달라요' : null,
                                  ),
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 160,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed:
                                            (_saving || _pwMismatch)
                                                ? null
                                                : _save,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF6DBF73,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child:
                                            _saving
                                                ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                          Colors.white,
                                                        ),
                                                  ),
                                                )
                                                : const Text('수정 완료'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 공통 라벨+필드 행
Widget _row(
  String label,
  TextEditingController c, {
  bool readOnly = false,
  bool obscure = false,
  String? hint,
  String? helper,
  String? errorText,
  TextInputType? keyboard,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF7E6F64),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextField(
          controller: c,
          readOnly: readOnly,
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF5F7F9),
            hintText: hint,
            helperText: helper,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color(0xFFE2E2E2)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color(0xFFE2E2E2)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color(0xFF9ACB9F), width: 1.6),
            ),
          ),
        ),
      ),
    ],
  );
}
