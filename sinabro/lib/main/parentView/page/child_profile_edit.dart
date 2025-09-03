// lib/main/parentView/page/child_profile_edit.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/mypage.dart';

/// 자녀 프로필 수정 (뷰 전용 / 서버 미연동)
class ChildProfileEditPage extends StatefulWidget {
  final String? parentUserId;

  /// 데모용 기본값들
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
  late final TextEditingController _phoneCtl;
  final TextEditingController _pwCtl = TextEditingController();
  final TextEditingController _pw2Ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.childName);
    _idCtl = TextEditingController(text: widget.childId);
    _phoneCtl = TextEditingController(text: widget.childPhone);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _idCtl.dispose();
    _phoneCtl.dispose();
    _pwCtl.dispose();
    _pw2Ctl.dispose();
    super.dispose();
  }

  // ---------------- Actions ----------------

  // 수정 완료
  Future<void> _save() async {
    // 서버 연동 전: 간단 유효성만 체크
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

    // 저장 성공 팝업 -> 이전화면으로 복귀
    await _showNiceDialog(
      title: '수정 성공',
      message: '정보가 성공적으로 수정되었습니다!',
      icon: Icons.check_circle_outline,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // 자녀 삭제 플로우
  Future<void> _deleteFlow() async {
    // 1) 부모 비밀번호 입력
    final parentPw = await _askParentPassword();
    if (parentPw == null) return;

    // 데모 검증: "1234"면 성공, 아니면 실패
    if (parentPw != '1234') {
      await _showNiceDialog(
        title: '실패',
        message: '현재 비밀번호가 올바르지 않습니다!',
        icon: Icons.error_outline,
      );
      return;
    }

    // 2) 정말 삭제하시겠습니까?
    final ok = await _confirmDialog(
      title: '주의',
      message: '정말 삭제하시겠습니까?',
      yesText: '예',
      noText: '아니요',
    );
    if (ok != true) return;

    // 3) 삭제 완료 안내 → 부모 페이지(마이페이지)로 이동
    await _showNiceDialog(
      title: '',
      message: '탈퇴되었습니다!\\n부모 페이지로 돌아갑니다',
      icon: Icons.info_outline,
    );
    if (!mounted) return;

    // 부모 페이지(마이페이지)로 완전 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyPage()),
      (_) => false,
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- Dialog Helpers ----------------

  Future<void> _showNiceDialog({
    required String title,
    required String message,
    required IconData icon,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  // ---------------- UI ----------------

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerBar(),
                  const SizedBox(height: 16),
                  _formCard(),
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
            // 아바타
            Column(
              children: const [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text('자녀 회원', style: TextStyle(color: Colors.black45)),
              ],
            ),
            const SizedBox(width: 26),

            // 폼
            Expanded(
              child: Column(
                children: [
                  _row('이름', _input(_nameCtl)),
                  _row('아이디', _input(_idCtl, readOnly: true)),
                  _row('전화번호', _input(_phoneCtl, hint: '010-0000-0000')),
                  _row(
                    '비밀번호',
                    _input(_pwCtl, hint: '8자 이상 16자 이상', obscure: true),
                  ),
                  _row('재입력', _input(_pw2Ctl, obscure: true)),
                  const SizedBox(height: 10),

                  // 하단 버튼
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
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
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
      ),
      keyboardType:
          (hint == '010-0000-0000') ? TextInputType.phone : TextInputType.text,
    );
  }
}
