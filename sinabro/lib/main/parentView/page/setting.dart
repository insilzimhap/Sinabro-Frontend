import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';

class SettingsPage extends StatefulWidget {
  /// 라우팅용 이름 (MaterialApp.routes에 등록해서 사용)
  static const String routeName = '/parent/settings';

  /// 사이드바 동적 표시용 (없어도 동작)
  final String? parentUserId;

  const SettingsPage({super.key, this.parentUserId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 수신동의
  bool agreeEmail = false;
  bool agreePush = false;

  // 언어설정
  final List<String> languages = const [
    '한국어',
    '中文',
    'ไทย',
    'English',
    'Tiếng Việt',
  ];
  String selectedLang = '한국어';

  // ================= 저장 =================
  Future<void> _save() async {
    // TODO: 서버 저장 API 연동
    // final payload = {...}; await http.post(...);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('설정이 저장되었습니다.')));
  }

  // ============== 회원 탈퇴 플로우 ==============
  // 1) 현재 비밀번호 입력 -> 실패 시 실패 팝업
  // 2) 성공 시 확인 팝업 -> 예 누르면 탈퇴 처리 -> 성공 팝업 후 홈으로
  Future<void> _withdrawFlow() async {
    final pw = await _askCurrentPassword();
    if (pw == null) return;

    // TODO: 실제 비밀번호 검증 API
    final verified = pw.isNotEmpty;
    if (!verified) {
      await _showFailureDialog(
        titleImage: 'assets/img/dialog/fail.png',
        message: '현재 비밀번호가 올바르지 않습니다!',
      );
      return;
    }

    final ok = await _showConfirmDialog(
      titleImage: 'assets/img/dialog/warn.png',
      message: '정말 탈퇴하시겠습니까?',
      yesText: '예',
      noText: '아니요',
    );
    if (ok != true) return;

    // TODO: 실제 탈퇴 API 호출
    await Future.delayed(const Duration(milliseconds: 350));

    await _showSuccessGoHome(message: '탈퇴되었습니다!\n메인 화면으로 돌아갑니다');
    if (!mounted) return;

    // ✅ 탈퇴 후 home_screen.dart로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => CloudAnimationScreen()),
      (route) => false,
    );
  }

  // -------- 팝업 1: 현재 비밀번호 입력 --------
  Future<String?> _askCurrentPassword() async {
    final controller = TextEditingController();
    return showDialog<String?>(
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
                  onPressed: () => Navigator.pop(context, null),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    '현재 비밀번호를 입력해주십시오',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B5A51),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 420,
                    child: TextField(
                      controller: controller,
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
                      onPressed: () => Navigator.pop(context, controller.text),
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

  // -------- 팝업 2: 실패 --------
  Future<void> _showFailureDialog({
    required String message,
    String? titleImage,
  }) async {
    await showDialog<void>(
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
                    child: (titleImage == null)
                        ? const Text(
                            '실패',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B5A51),
                            ),
                          )
                        : Image.asset(titleImage, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
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

  // -------- 팝업 3: 확인(예/아니요) --------
  Future<bool?> _showConfirmDialog({
    required String message,
    String? titleImage,
    String yesText = '예',
    String noText = '아니요',
  }) async {
    return showDialog<bool>(
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
                  onPressed: () => Navigator.pop(context, false),
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
                    child: (titleImage == null)
                        ? const Text(
                            '주의',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B5A51),
                            ),
                          )
                        : Image.asset(titleImage, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B5A51),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
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
                        width: 140,
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

  // -------- 팝업 4: 성공 후 홈으로 --------
  Future<void> _showSuccessGoHome({required String message}) async {
    await showDialog<void>(
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
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B5A51),
                    ),
                  ),
                  const SizedBox(height: 6),
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
      activeMenu: '설정',
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                children: [
                  // 상단 녹색 헤더
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DBF73),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      '설정',
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
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('수신동의'),
                          const SizedBox(height: 8),
                          _checkRow(
                            label: '이메일 수신 동의',
                            value: agreeEmail,
                            onChanged: (v) =>
                                setState(() => agreeEmail = v ?? false),
                          ),
                          _checkRow(
                            label: '알림 수신 동의',
                            value: agreePush,
                            onChanged: (v) =>
                                setState(() => agreePush = v ?? false),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle('언어설정'),
                          const SizedBox(height: 8),
                          _langDropdown(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 하단 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _withdrawFlow,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE85C58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '회원 탈퇴',
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
                            padding: EdgeInsets.symmetric(horizontal: 22),
                            child: Text(
                              '저장하기',
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
          ),
        ),
      ),
    );
  }

  // ============= 공용 위젯 =============
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6A5C53),
      ),
    );
  }

  Widget _checkRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            shape: const CircleBorder(),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLang,
          items: languages
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedLang = v ?? selectedLang),
        ),
      ),
    );
  }
}
