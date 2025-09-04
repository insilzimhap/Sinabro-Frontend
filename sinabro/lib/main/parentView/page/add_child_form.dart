// lib/main/parentView/page/add_child_form.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

// ▼ 서버 호출용
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart'; // baseUrl

class AddChildFormPage extends StatefulWidget {
  final String parentUserId; // 서버 연동에 사용
  const AddChildFormPage({super.key, required this.parentUserId});

  @override
  State<AddChildFormPage> createState() => _AddChildFormPageState();
}

class _AddChildFormPageState extends State<AddChildFormPage> {
  // --- Controllers ---
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  // --- UI state ---
  bool _agree = false; // 개인정보 동의
  bool _idChecked = false; // 아이디 중복 확인 완료 여부
  bool _showPwMismatch = false; // 비밀번호 불일치 경고
  bool _isSaving = false; // 저장 로딩

  // 비밀번호 유효성
  bool get _pwValidLength => _pw.text.length >= 8 && _pw.text.length <= 16;
  bool get _pwMatch => _pw.text == _pw2.text && _pw2.text.isNotEmpty;

  // 버튼 활성화 조건
  bool get _canSubmit =>
      _idChecked &&
      _pwValidLength &&
      _pwMatch &&
      _name.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _agree &&
      !_isSaving;

  @override
  void initState() {
    super.initState();
    _pw.addListener(_onPwChange);
    _pw2.addListener(_onPwChange);
  }

  void _onPwChange() {
    final mismatch = _pw2.text.isNotEmpty && _pw.text != _pw2.text;
    if (mismatch != _showPwMismatch) {
      setState(() => _showPwMismatch = mismatch);
    } else {
      setState(() {}); // 길이 상태 반영
    }
  }

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    _pw2.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  // ---------------- 서버 Actions ----------------

  /// (서버) 아이디 중복확인
  Future<void> _checkDuplicate() async {
    final id = _id.text.trim();
    if (id.length < 4) {
      _idChecked = false;
      _toast('아이디는 4자 이상 입력해주세요.');
      setState(() {});
      return;
    }

    try {
      // TODO: 실제 API 경로/파라미터 확인
      // 예시: GET /api/children/check-id?childId={id}
      final uri = Uri.parse(
        '$baseUrl/api/children/check-id',
      ).replace(queryParameters: {'childId': id});
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        // 서버가 {"available": true} 형태로 응답한다고 가정
        final body = json.decode(res.body) as Map<String, dynamic>;
        final ok = (body['available'] == true);
        _idChecked = ok;
        _toast(ok ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.');
      } else {
        _idChecked = false;
        _toast('중복 확인 실패: ${res.statusCode}');
      }
    } catch (e) {
      _idChecked = false;
      _toast('중복 확인 에러: $e');
    }

    setState(() {});
  }

  /// (서버) 자녀 생성
  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSaving = true);

    try {
      // TODO: 실제 API 경로/Body 스펙 확인
      // 예시: POST /api/parents/{parentUserId}/children
      final uri = Uri.parse(
        '$baseUrl/api/parents/${widget.parentUserId}/children',
      );

      final payload = {
        'childId': _id.text.trim(),
        'password': _pw.text.trim(),
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        await _showSuccessDialog(childName: _name.text.trim());
        if (!mounted) return;
        // 이전 화면(자녀 리스트)로 성공 신호 전달 → FutureBuilder/새로고침 트리거
        Navigator.pop(context, true);
      } else {
        // 서버가 에러 메시지를 내려주는 경우 파싱
        String msg = '등록 실패: ${res.statusCode}';
        try {
          final body = json.decode(res.body);
          if (body is Map && body['message'] is String) {
            msg = body['message'] as String;
          }
        } catch (_) {}
        _toast(msg);
      }
    } catch (e) {
      _toast('등록 에러: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------- 기타 Actions ----------------

  // 개인정보 전문
  void _showTerms() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('개인정보 수집·이용 동의(예시)'),
            content: const SingleChildScrollView(
              child: Text('여기에 동의 전문/이미지가 들어갑니다. 실제 문구는 추후 교체하세요.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  Future<void> _showSuccessDialog({required String childName}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32,
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF2E7D32)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      Container(
                        width: 240,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE6D6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '추가 성공',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B5A51),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '자녀 $childName 님이 추가되었습니다!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B5A51),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '자녀페이지', // 사이드바 하이라이트
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFFAFAF8),
        child: ListView(
          children: [
            _titleBar(),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 980,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('자녀 추가하기'),
                    const SizedBox(height: 16),

                    // 아이디 + 중복확인
                    _rowField(
                      label: '아이디',
                      trailing: ElevatedButton(
                        onPressed: _checkDuplicate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF59B35A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('중복 확인'),
                      ),
                      child: _input(_id, hint: '아이 아이디를 입력하세요'),
                    ),

                    // 비밀번호
                    _rowField(
                      label: '비밀번호',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _input(
                            _pw,
                            obscure: true,
                            hint: '8자 이상 16자 이하',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '8자 이상 16자 이하',
                            style: TextStyle(
                              fontSize: 12,
                              color: _pwValidLength ? Colors.grey : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 재입력
                    _rowField(
                      label: '재입력',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _input(_pw2, obscure: true, hint: '비밀번호를 다시 입력하세요'),
                          if (_showPwMismatch) ...[
                            const SizedBox(height: 6),
                            const Text(
                              '비밀번호가 달라요',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 이름
                    _rowField(label: '이름', child: _input(_name, hint: '아이 이름')),

                    // 전화번호
                    _rowField(
                      label: '전화번호',
                      child: _input(_phone, hint: '010-0000-0000'),
                    ),

                    const SizedBox(height: 14),
                    _agreeRow(),

                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 140,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59B35A),
                            disabledBackgroundColor: const Color(0xFFBFDDBF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('등록하기'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _titleBar() {
    return Container(
      color: const Color(0xFF64A86A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: const Text(
        '자녀 페이지',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _rowField({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B564C),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController c, {
    String? hint,
    bool obscure = false,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB7CDB8)),
        ),
      ),
      keyboardType:
          (hint == '010-0000-0000') ? TextInputType.phone : TextInputType.text,
    );
  }

  Widget _agreeRow() {
    return Row(
      children: [
        Checkbox(
          value: _agree,
          onChanged: (v) => setState(() => _agree = v ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const Text('개인정보 수집 동의', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        TextButton(
          onPressed: _showTerms,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFE6E6E6),
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('전문 읽기'),
        ),
      ],
    );
  }
}

// 섹션 타이틀
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6B564C),
      ),
    );
  }
}
