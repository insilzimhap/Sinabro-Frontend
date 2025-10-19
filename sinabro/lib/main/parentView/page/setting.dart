/*
 * 파일: lib/main/parentView/page/setting.dart (SettingsPage)
 * 개요: 부모용 ‘설정’ 화면. ParentLayout 하위에서 수신동의/언어 등 앱 환경설정을
 * 구성하고 로그아웃·회원탈퇴 플로우(커스텀 다이얼로그)까지 제공한다.
 * 로그아웃 → UserSelectScreen, 탈퇴 → HomeScreen
 * @ 채영: JWT+api 연결 완료
 * @ 연수: 언어팩 지원을 위한 코드 수정 완료
 * @연수: 설정 -> 언어 변경 후 저장하기 눌렀을 때, 언어 새로고침 수정중
 */
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart';
import 'package:sinabro/main/mainView/page/user_select_screen.dart';
import 'package:sinabro/main/parentView/services/translation_service.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/parent/settings';
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
    'English',
    '日本語',
    'Tiếng Việt',
    '中文',
    'ไทย',
  ];
  String selectedLang = '한국어';

  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings(); //서버 프리필
  }

  // 부모 설정 불러오기: GET /api/app/mypage/parent/{userId}/settings
  Future<void> _loadSettings() async {
    if ((widget.parentUserId ?? '').isEmpty) return;
    setState(() => _loading = true);
    try {
      final s = await ParentApi.fetchSettings(widget.parentUserId!);
      if (!mounted) return;
      setState(() {
        agreeEmail = s.emailSubscription;
        agreePush = s.allowNotifications;
        selectedLang = _reverseMapLang(s.userLanguage); //언어 매핑 적용
      });
      print(
        '[설정 불러오기 성공] allow=$agreePush, email=$agreeEmail, lang=$selectedLang',
      );
    } catch (e) {
      if (mounted) {
        print('[설정 불러오기 실패] $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('설정 불러오기 실패: $e'))); // TODO: 번역
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 부모 설정 저장: PATCH /api/app/mypage/parent/{userId}/settings
  Future<void> _save() async {
    if ((widget.parentUserId ?? '').isEmpty) return;
    setState(() => _saving = true);
    try {
      // 1. 서버에 변경된 설정을 저장합니다.
      await ParentApi.updateSettings(
        userId: widget.parentUserId!,
        allowNotifications: agreePush,
        emailSubscription: agreeEmail,
        userLanguage: _mapLang(selectedLang), // 언어 매핑
      );

      // 2. 성공 시, TranslationService를 다시 초기화하여 변경된 언어를 즉시 앱에 적용합니다.
      await TranslationService.instance.initialize(widget.parentUserId!);

      if (!mounted) return;
      print('[설정 저장 성공]');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('설정이 저장되었습니다.'))); // TODO: 번역
    } catch (e) {
      if (mounted) {
        print('[설정 저장 실패] $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('설정 저장 실패: $e'))); // TODO: 번역
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // 언어 매핑 (프론트 → 서버)
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

  // 언어 매핑 (서버 → 프론트)
  String _reverseMapLang(String v) {
    switch (v) {
      case 'Korea':
        return '한국어';
      case 'English':
        return 'English';
      case 'Japanese':
        return '日本語';
      case 'Vietnamese':
        return 'Tiếng Việt';
      case 'Chinese':
        return '中文';
      case 'Thai':
        return 'ไทย';
      default:
        return '한국어';
    }
  }

  // ================= Actions =================

  // 로그아웃: POST /api/users/logout
  Future<void> _logout() async {
    try {
      await ParentApi.logout();
      print('[로그아웃 성공]');
    } catch (e) {
      print('[로그아웃 실패] $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserSelectScreen()),
      (route) => false,
    );
  }

  // 회원 탈퇴 플로우
  Future<void> _withdrawFlow() async {
    final pw = await _askCurrentPassword();
    if (pw == null || pw.isEmpty) return;

    // 1단계: 비밀번호 검증
    try {
      await ParentApi.verifyDelete(widget.parentUserId!, pw);
    } catch (e) {
      await _showFailureDialog(
        title: '실패',
        message: '현재 비밀번호가 올바르지 않습니다!',
      );
      return;
    }

    // 2단계: 정말 탈퇴하시겠습니까?
    final ok = await _showConfirmDialog(
      title: '주의',
      message: '정말 탈퇴하시겠습니까?',
      yesText: '예',
      noText: '아니요',
    );
    if (ok != true) return;

    // 3단계: 탈퇴 API 호출
    try {
      await ParentApi.deleteParent(widget.parentUserId!, pw);
      await _showSuccessGoHome(message: '탈퇴되었습니다!\n메인 화면으로 돌아갑니다');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => CloudAnimationScreen()),
        (route) => false,
      );
    } catch (e) {
      await _showFailureDialog(
        title: '실패',
        message: '탈퇴 실패: $e',
      );
    }
  }

  // -------- 공통 다이얼로그들 --------
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
                  const TranslatedText(
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
                      child: const TranslatedText('확인'),
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

  Future<void> _showFailureDialog(
      {required String title, required String message}) async {
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
                    child: TranslatedText(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B5A51),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TranslatedText(
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

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
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
                    child: TranslatedText(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B5A51),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TranslatedText(
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
                          child: TranslatedText(yesText),
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
                          child: TranslatedText(noText),
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
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => CloudAnimationScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  TranslatedText(
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

  // ================= UI =================
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
                    child: const TranslatedText(
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
                          _sectionTitle(const TranslatedText('수신동의')),
                          const SizedBox(height: 8),
                          _checkRow(
                            label: const TranslatedText('이메일 수신 동의'),
                            value: agreeEmail,
                            onChanged: (v) =>
                                setState(() => agreeEmail = v ?? false),
                          ),
                          _checkRow(
                            label: const TranslatedText('알림 수신 동의'),
                            value: agreePush,
                            onChanged: (v) =>
                                setState(() => agreePush = v ?? false),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle(const TranslatedText('언어설정')),
                          const SizedBox(height: 8),
                          _langDropdown(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 하단 버튼들: 좌측 로그아웃 / 우측 탈퇴·저장
                  Row(
                    children: [
                      // 좌측 로그아웃
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _logout,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFBDBDBD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: TranslatedText(
                              '로그아웃',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 우측 탈퇴
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
                            child: TranslatedText(
                              '회원 탈퇴',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 저장하기
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
                            child: TranslatedText(
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
  Widget _sectionTitle(Widget child) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6A5C53),
        fontFamily: 'DefaultFont', // 폰트 깨짐 방지
      ),
      child: child,
    );
  }

  Widget _checkRow({
    required Widget label,
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
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontFamily: 'DefaultFont', // 폰트 깨짐 방지
            ),
            child: label,
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
              .map((e) => DropdownMenuItem(value: e, child: TranslatedText(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedLang = v ?? selectedLang),
        ),
      ),
    );
  }
}
