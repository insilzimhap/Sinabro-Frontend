// lib/main/parentView/page/child_profile_edit.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/mypage.dart';

class ChildProfileEditPage extends StatefulWidget {
  final String? parentUserId;

  // 데모용 기본값
  final String childId;
  final String childName;
  final String childPhone;

  const ChildProfileEditPage({
    super.key,
    this.parentUserId,
    required this.childId,
    required this.childName,
    required this.childPhone,
  });

  @override
  State<ChildProfileEditPage> createState() => _ChildProfileEditPageState();
}

class _ChildProfileEditPageState extends State<ChildProfileEditPage> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _idCtl;
  final TextEditingController _nickCtl = TextEditingController();
  final TextEditingController _pwCtl = TextEditingController();
  final TextEditingController _pw2Ctl = TextEditingController();

  int _year = DateTime.now().year;
  int _month = 1;
  int _day = 1;
  int _limitMinutes = 30;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.childName);
    _idCtl = TextEditingController(text: widget.childId);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _idCtl.dispose();
    _nickCtl.dispose();
    _pwCtl.dispose();
    _pw2Ctl.dispose();
    super.dispose();
  }

  // ───────── Actions ─────────
  Future<void> _save() async {
    if (_nameCtl.text.trim().isEmpty) {
      _toast('이름을 입력해 주세요.');
      return;
    }
    if (_pwCtl.text.isNotEmpty || _pw2Ctl.text.isNotEmpty) {
      if (_pwCtl.text.length < 8 || _pwCtl.text.length > 16) {
        _toast('비밀번호는 8자 이상 16자 이하로 입력해 주세요.');
        return;
      }
      if (_pwCtl.text != _pw2Ctl.text) {
        _toast('비밀번호가 서로 다릅니다.');
        return;
      }
    }

    await _showNiceDialog(
      title: '수정 성공',
      message: '정보가 성공적으로 수정되었습니다!',
      icon: Icons.check_circle_outline,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteFlow() async {
    final parentPw = await _askParentPassword();
    if (parentPw == null) return;

    if (parentPw != '1234') {
      await _showNiceDialog(
        title: '실패',
        message: '현재 비밀번호가 올바르지 않습니다!',
        icon: Icons.error_outline,
      );
      return;
    }

    final ok = await _confirmDialog(
      title: '주의',
      message: '정말 삭제하시겠습니까?',
      yesText: '예',
      noText: '아니요',
    );
    if (ok != true) return;

    await _showNiceDialog(
      title: '',
      message: '탈퇴되었습니다!\n부모 페이지로 돌아갑니다',
      icon: Icons.info_outline,
    );
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyPage()),
      (_) => false,
    );
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ───────── Dialog Helpers ─────────
  Future<void> _showNiceDialog({
    required String title,
    required String message,
    required IconData icon,
  }) async {
    await showDialog<void>(
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
                      Icon(icon, size: 48, color: const Color(0xFF2E7D32)),
                      const SizedBox(height: 14),
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B5A51),
                          ),
                        ),
                      if (title.isNotEmpty) const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B5A51),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<String?> _askParentPassword() async {
    final ctl = TextEditingController();
    return showDialog<String?>(
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
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        '부모의 비밀번호를 입력해주십시오',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B5A51),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 360,
                        child: TextField(
                          controller: ctl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 160,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, ctl.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6DBF73),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('확인'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    String yesText = '예',
    String noText = '아니요',
  }) async {
    return showDialog<bool>(
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
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B5A51),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B5A51),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6DBF73),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Text(yesText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 120,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6DBF73),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Text(noText),
                            ),
                          ),
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

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '자녀페이지',
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              // ✅ 스크롤 가능하도록 Column → ListView 변경
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _headerBar(),
                  const SizedBox(height: 16),
                  _formCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF6DBF73),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Text(
        '자녀 페이지',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _formCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 프로필
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 56,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text('자녀 회원', style: TextStyle(color: Colors.black45)),
                const SizedBox(height: 6),
                Text(
                  '${widget.childName} 님',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B564C),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 26),

            // 오른쪽 폼
            Expanded(
              child: Column(
                children: [
                  _row('이름', _input(_nameCtl)),
                  _row('아이디', _input(_idCtl, readOnly: true)),
                  _row('닉네임', _input(_nickCtl, hint: '표시할 닉네임')),
                  _row('생일', _birthDropdowns()),
                  _row(
                    '비밀번호',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _input(_pwCtl, hint: '변경 시에만 입력해주십시오.', obscure: true),
                        const SizedBox(height: 6),
                        const Text(
                          '8자 이상 16자 이하',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  _row('재입력', _input(_pw2Ctl, obscure: true)),
                  _row('제한시간', _limitDropdown()),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _deleteFlow,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE85C58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '자녀 삭제',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6DBF73),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '수정 완료',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B564C),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: field),
        ],
      ),
    );
  }

  InputDecoration get _decoration => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF7F7F7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  Widget _input(
    TextEditingController c, {
    bool obscure = false,
    bool readOnly = false,
    String? hint,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      readOnly: readOnly,
      decoration: _decoration.copyWith(hintText: hint),
    );
  }

  Widget _birthDropdowns() {
    return Row(
      children: [
        Expanded(child: _yearDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _monthDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _dayDropdown()),
      ],
    );
  }

  Widget _yearDropdown() {
    final years = List<int>.generate(40, (i) => DateTime.now().year - i);
    final value = years.contains(_year) ? _year : years.first;
    return DropdownButtonFormField<int>(
      value: value,
      items:
          years
              .map((y) => DropdownMenuItem(value: y, child: Text('$y년')))
              .toList(),
      onChanged: (v) {
        if (v == null) return;
        final maxDay = _daysInMonth(v, _month);
        setState(() {
          _year = v;
          if (_day > maxDay) _day = maxDay;
        });
      },
      decoration: _decoration,
    );
  }

  Widget _monthDropdown() {
    return DropdownButtonFormField<int>(
      value: _month,
      items:
          List<int>.generate(12, (i) => i + 1)
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text('${m.toString().padLeft(2, '0')}월'),
                ),
              )
              .toList(),
      onChanged: (v) {
        if (v == null) return;
        final maxDay = _daysInMonth(_year, v);
        setState(() {
          _month = v;
          if (_day > maxDay) _day = maxDay;
        });
      },
      decoration: _decoration,
    );
  }

  Widget _dayDropdown() {
    final maxDay = _daysInMonth(_year, _month);
    final days = List<int>.generate(maxDay, (i) => i + 1);
    if (_day > maxDay) _day = maxDay;

    return DropdownButtonFormField<int>(
      value: _day,
      items:
          days
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text('${d.toString().padLeft(2, '0')}일'),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => _day = v ?? _day),
      decoration: _decoration,
    );
  }

  Widget _limitDropdown() {
    const options = [30, 60, 90, 120];
    return DropdownButtonFormField<int>(
      value: _limitMinutes,
      items:
          options
              .map((m) => DropdownMenuItem(value: m, child: Text('$m분')))
              .toList(),
      onChanged: (v) => setState(() => _limitMinutes = v ?? _limitMinutes),
      decoration: _decoration,
    );
  }

  int _daysInMonth(int y, int m) {
    if (m == 2) {
      final leap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
      return leap ? 29 : 28;
    }
    const monthDays = [31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return monthDays[m - 1];
  }
}
