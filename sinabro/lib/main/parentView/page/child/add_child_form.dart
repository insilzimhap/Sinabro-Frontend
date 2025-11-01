/**
 * @file lib/main/parentView/page/child/add_child_form.dart
 * 역할: 자녀 추가 화면. 
 * - 아이디 중복 확인(permitAll).
 * - 자녀 등록 요청 (JWT 필요, 부모 userId 포함).
 * - 성공 시 다이얼로그 → "첫 로그인 안내 팝업" → 자녀 로그인 페이지로 이동.
 * @ 채영: JWT+api 연결 완료
 * @ 연수: 언어팩 지원을 위한 코드 수정 완료
 */
///

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/main/auth/authChild/login_child.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart'; // ✨

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
  final _name = TextEditingController();
  final _nick = TextEditingController();

  // --- UI state ---
  bool _idChecked = false; // 아이디 중복 확인 완료 여부
  bool _isSaving = false; // 저장 로딩

  String _dupMessage = '';
  Color _dupColor = Colors.grey;

  // 생년월일 / 제한시간
  int _year = DateTime.now().year; // ← 기본값 즉시 설정
  int _month = 1;
  int _day = 1;
  int _limitMinutes = 0; // 기본은 "제한 없음"

  // 비밀번호 유효성
  bool get _pwValidLength => _pw.text.length >= 8 && _pw.text.length <= 16;

  // 버튼 활성화 조건
  bool get _canSubmit =>
      _idChecked &&
      _pwValidLength &&
      _name.text.trim().isNotEmpty &&
      _nick.text.trim().isNotEmpty &&
      !_isSaving;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year; // 기본값: 올해
    _pw.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    _name.dispose();
    _nick.dispose();
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
      // rest api
      final uri = Uri.parse('$baseUrl/api/child/check-id')
          .replace(queryParameters: {'childId': id});
      final res = await AuthClient().get(uri); // permitAll → 토큰 스킵

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final ok = (body['available'] == true);
        _idChecked = ok;
        setState(() {
          _dupMessage = ok ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.';
          _dupColor = ok ? Colors.green : Colors.red;
        });
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

  // (서버) 자녀 생성
  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSaving = true);

    try {
      final uri = Uri.parse('$baseUrl/api/child/register');

      final birth =
          '${_year.toString().padLeft(4, '0')}-${_month.toString().padLeft(2, '0')}-${_day.toString().padLeft(2, '0')}';

      // ✅ 현재 연도 기준 나이 계산
      final now = DateTime.now();
      int age = now.year - _year;
      if (now.month < _month || (now.month == _month && now.day < _day)) {
        age -= 1;
      }

      final payload = {
        'childId': _id.text.trim(),
        'childPw': _pw.text.trim(),
        'childName': _name.text.trim(),
        'childNickname': _nick.text.trim(),
        'childBirth': birth, // "YYYY-MM-DD"
        'childAge': age,
        'timeLimitMinutes': _limitMinutes, // 30, 60, 90, 120
        'userId': widget.parentUserId, // 부모 ID 필수
      };

      final res = await AuthClient().post(
        // ✅ http.post → AuthClient().post
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        await _showSuccessDialog(childName: _name.text.trim());
        if (!mounted) return;
        // ① 첫 로그인 안내 팝업
        await _showFirstLoginNotice();
        // ② 자녀 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginChildScreen()),
        );
      } else {
        String msg = '등록 실패: ${res.statusCode}';
        try {
          final body = json.decode(res.body);
          if (body is Map && body['message'] is String) msg = body['message'];
        } catch (_) {}
        _toast(msg);
      }
    } catch (e) {
      _toast('등록 에러: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------- Helpers ----------------

  int _daysInMonth(int y, int m) {
    if (m == 2) {
      final leap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
      return leap ? 29 : 28;
    }
    const monthDays = [31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return monthDays[m - 1];
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /// "아이 첫 로그인 안내" 팝업 -> css 제대로 적용 필요
  Future<void> _showFirstLoginNotice() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const TranslatedText('안내',
            style: TextStyle(fontWeight: FontWeight.bold)), // ✨
        content: const TranslatedText(
          // ✨
          '아이 첫 로그인은 부모가 옆에서 도와줘야 해요!\n레벨테스트가 있습니다!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TranslatedText('확인'), // ✨
          ),
        ],
      ),
    );
  }

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
                    const _SectionTitle(child: TranslatedText('자녀 추가하기')), // ✨
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
                        child: const TranslatedText('중복 확인'), // ✨
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _input(_id,
                              hint: '아이 아이디를 입력하세요'), // TODO: Hint text 번역
                          const SizedBox(height: 6),
                          if (_dupMessage.isNotEmpty)
                            Text(
                              // TODO: 동적 메시지 번역
                              _dupMessage,
                              style: TextStyle(fontSize: 12, color: _dupColor),
                            ),
                        ],
                      ),
                    ),

                    // 비밀번호
                    _rowField(
                      label: '비밀번호',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _input(_pw,
                              obscure: true,
                              hint: '8자 이상 16자 이하'), // TODO: Hint text 번역
                          const SizedBox(height: 6),
                          const TranslatedText(
                            // ✨
                            '8자 이상 16자 이하',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // 이름
                    _rowField(
                        label: '이름',
                        child:
                            _input(_name, hint: '아이 이름')), // TODO: Hint text 번역

                    // 닉네임
                    _rowField(
                      label: '닉네임',
                      child:
                          _input(_nick, hint: '표시할 닉네임'), // TODO: Hint text 번역
                    ),

                    // 생년월일 (년/월/일 드롭다운)
                    _rowField(
                      label: '생년월일',
                      child: Row(
                        children: [
                          Expanded(child: _yearDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _monthDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _dayDropdown()),
                        ],
                      ),
                    ),

                    // 제한시간
                    _rowField(label: '제한시간', child: _limitDropdown()),

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
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const TranslatedText('저장하기'), // ✨
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

  // ----- Widgets -----

  Widget _titleBar() {
    return Container(
      color: const Color(0xFF64A86A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: const TranslatedText(
        // ✨
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
            child: TranslatedText(
              // ✨
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

  InputDecoration get _fieldDecoration => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      );

  Widget _input(TextEditingController c, {String? hint, bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: _fieldDecoration.copyWith(hintText: hint),
    );
  }

  Widget _yearDropdown() {
    final years = List<int>.generate(40, (i) => DateTime.now().year - i);
    final value = years.contains(_year) ? _year : years.first;

    return DropdownButtonFormField<int>(
      value: value,
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text('$y년')))
          .toList(),
      decoration: _fieldDecoration,
      onChanged: (v) {
        if (v == null) return;
        final maxDay = _daysInMonth(v, _month);
        setState(() {
          _year = v;
          if (_day > maxDay) _day = maxDay;
        });
      },
    );
  }

  Widget _monthDropdown() {
    return DropdownButtonFormField<int>(
      value: _month,
      items: List<int>.generate(12, (i) => i + 1)
          .map(
            (m) => DropdownMenuItem(
              value: m,
              child: Text('${m.toString().padLeft(2, '0')}월'),
            ),
          )
          .toList(),
      decoration: _fieldDecoration,
      onChanged: (v) {
        if (v == null) return;
        final maxDay = _daysInMonth(_year, v);
        setState(() {
          _month = v;
          if (_day > maxDay) _day = maxDay;
        });
      },
    );
  }

  Widget _dayDropdown() {
    final maxDay = _daysInMonth(_year, _month);
    final days = List<int>.generate(maxDay, (i) => i + 1);
    if (_day > maxDay) _day = maxDay;

    return DropdownButtonFormField<int>(
      value: _day,
      items: days
          .map(
            (d) => DropdownMenuItem(
              value: d,
              child: Text('${d.toString().padLeft(2, '0')}일'),
            ),
          )
          .toList(),
      decoration: _fieldDecoration,
      onChanged: (v) => setState(() => _day = v ?? _day),
    );
  }

  Widget _limitDropdown() {
    final options = const [
      {'label': '제한 없음', 'value': 0},
      {'label': '30분', 'value': 30},
      {'label': '1시간', 'value': 60},
      {'label': '1시간 30분', 'value': 90},
    ];

    return DropdownButtonFormField<int>(
      value: _limitMinutes,
      items: options
          .map(
            (opt) => DropdownMenuItem<int>(
              value: opt['value'] as int,
              child: TranslatedText(opt['label'] as String), // ✨
            ),
          )
          .toList(),
      decoration: _fieldDecoration,
      onChanged: (v) => setState(() => _limitMinutes = v ?? _limitMinutes),
    );
  }

  Future<void> _showSuccessDialog({required String childName}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
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
                    child: const TranslatedText(
                      // ✨
                      '추가 성공',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B5A51),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ✨ 동적 텍스트 번역 적용
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TranslatedText('자녀'),
                      Text(' $childName '),
                      const TranslatedText('님이 추가되었습니다!'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 섹션 타이틀
// ✨ String 대신 Widget을 받도록 수정
class _SectionTitle extends StatelessWidget {
  final Widget child;
  const _SectionTitle({required this.child});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6B564C),
      ),
      child: child,
    );
  }
}
