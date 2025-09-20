/**
 * @file lib/login/social_info_page.dart
 * 역할: 소셜 추가정보 제출. 응답에 토큰이 있으면 저장.
 *  * 흐름:
 *   1) 사용자가 추가정보(전화, 비밀번호 등) 입력 → 제출
 *   2) 서버 응답 200이면 토큰/세션 저장:
 *        - AuthClient.instance.setAuthToken(...) : 전역 헤더 자동부착
 *        - ChildrenState.instance.setToken(...)  : UI 스토어/SharedPreferences
 *   3) 공지 페이지로 이동
 */
///

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/page/notice_page.dart';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/main/parentView/page/children_state.dart';
import 'package:flutter/services.dart';


class SocialExtraInfoPage extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userName;
  final String socialType; // 'kakao' | 'google'
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
  // ---------------- 상태 ----------------
  final TextEditingController _phoneController = TextEditingController();


  // [UI-ONLY] 피그마용 상태 (서버 전송 안 함)
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  bool _agreePrivacy = false; // 필수 동의(제출 시 검증)
  bool _agreeEmail = false;   
  bool _agreePush  = false;   
  String _lang = '한국어';
  String _message = '';
  bool _isLoading = false;

  // ───────────────── helpers ─────────────────
  bool _isPhoneValid(String v) => RegExp(r'^010-\d{4}-\d{4}$').hasMatch(v);
  bool _isPasswordValid(String pw) => pw.length >= 8 && pw.length <= 16;

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _mapLang(String v) {
    switch (v) {
      case '한국어': return 'Korea';
      case 'English': return 'English';
      case '日本語': return 'Japanese';
      case 'Tiếng Việt': return 'Vietnamese';
      case '中文': return 'Chinese';
      case 'ไทย': return 'Thai';
      default: return 'Korea';
    }
  }

  Map<String, dynamic> _safeJson(String s) {
    try {
      final v = json.decode(s);
      return (v is Map<String, dynamic>) ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }


  // ───────────────── 제출 ─────────────────
  Future<void> _submit() async {

    // 0) 클라이언트 검증
    final phone = _phoneController.text.trim();
    final hasPw = _pwController.text.isNotEmpty || _pwConfirmController.text.isNotEmpty;

    if (!_agreePrivacy) {
      return _showSnack('개인정보 수집 동의가 필요합니다.');
    }
    if (phone.isNotEmpty && !_isPhoneValid(phone)) {
      return _showSnack('전화번호는 010-0000-0000 형식으로 입력해 주세요.');
    }
    if (hasPw) {
      if (!_isPasswordValid(_pwController.text)) {
        return _showSnack('비밀번호는 8~16자로 설정해 주세요.');
      }
      if (_pwController.text != _pwConfirmController.text) {
        return _showSnack('비밀번호와 재입력이 일치하지 않습니다.');
      }
    }


    setState(() => _isLoading = true);


    try {
      // 1) 페이로드 구성
      final payload = <String, dynamic>{
        'userId': widget.userId,
        'userEmail': widget.userEmail,
        'userName': widget.userName,
        'userPhoneNum': phone.isEmpty ? null : phone,
        'role': 'parent',  // 부모 고정
        'socialType': widget.socialType, // kakao / google
        'socialId': widget.socialId,
        'userLanguage': _mapLang(_lang),
        'settings': {
          'privacyConsent': _agreePrivacy,  //필수동의
          'allowNotifications': _agreePush,
          'emailSubscription': _agreeEmail,
        },
      };
      if (hasPw) {
        payload['newPassword'] = _pwController.text;
        payload['confirmPw'] = _pwConfirmController.text;
      }

      print('[소셜추가] 요청 보냄: /api/users/social-register '
          '(socialType=${widget.socialType}, userId=${widget.userId})');

      // 2) 전송 (permitAll API라 Authorization 자동 미부착)
      final client = AuthClient();
      final res = await client.post(
        Uri.parse('$baseUrl/api/users/social-register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (!mounted) return;
      print('[소셜추가] 응답 수신: ${res.statusCode}');

      // 3) 처리
      if (res.statusCode == 200) {
        // 응답 파싱 (LoginResponseDto: { user: {...}, token: "..." })
        final body = json.decode(res.body) as Map<String, dynamic>;
        final token = (body['token'] ?? body['accessToken']) as String?;
        final refresh = body['refreshToken'] as String?;
        final userMap = body['user'] as Map<String, dynamic>?;

        final parentUserId   = (userMap?['userId']   ?? widget.userId).toString();
        final parentUserName = (userMap?['userName'] ?? widget.userName).toString();

        // 🔐 토큰/세션 저장
        if (token != null && token.isNotEmpty) {
          // 전역: 이후 보호 API에 자동 부착
          await AuthClient.instance.setAuthToken(token, refreshToken: refresh);
          // UI 스토어/SharedPreferences
          await ChildrenState.instance.setToken(
            accessToken: token,
            refreshToken: (refresh != null && refresh.isNotEmpty) ? refresh : null,
          );
          print('[소셜추가] 토큰 저장 완료 (AT=${token.length}자, RT=${refresh != null ? '있음' : '없음'})');
        } else {
          print('[소셜추가][경고] 응답에 토큰이 없음');
        }


        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );
        print('[소셜추가] 세션 저장 완료 (userId=$parentUserId, userName=$parentUserName)');


        // 추가 정보 등록 완료 → 공지사항으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoticePage()),
        );
      } else {
        setState(() {
          _message = '요청 실패: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '에러 발생: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // ---------------- UI ----------------
  @override
  void dispose() {
    _phoneController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    super.dispose();
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
      appBar: AppBar(backgroundColor: bg, elevation: 0, toolbarHeight: 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 900;
            final content = Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('가입하기', style: headerStyle),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: isWide
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
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _leftFormCard(cardColor),
                                const SizedBox(height: 16),
                                _rightConsentCard(cardColor),
                                const SizedBox(height: 16),
                                _animationBox(cardColor),
                              ],
                            ),
                          ),
                  ),
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_message,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            );
            return content;
          },
        ),
      ),
    );
  }

  // 좌측: 소셜 추가 정보 카드 (회원가입 화면 톤과 동일)
  Widget _leftFormCard(Color cardColor) {
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
                '소셜 회원 추가 정보 입력',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.brown[700],
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 이름 (읽기전용)
            TextField(
              controller: TextEditingController(text: widget.userName),
              enabled: false,
              decoration: _input('이름'),
            ),
            const SizedBox(height: 16),

            // 이메일 (읽기전용)
            TextField(
              controller: TextEditingController(text: widget.userEmail),
              readOnly: true,
              decoration: _input('이메일'),
            ),
            const SizedBox(height: 16),

            // 전화번호
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              ],
              maxLength: 13, // 010-0000-0000
              decoration: _input('전화번호').copyWith(
                hintText: '010-0000-0000',
                counterText: '',
              ),
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
            const SizedBox(height: 16),

            // 비밀번호 (UI-only)
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
                    color: _isPasswordValid(_pwController.text)
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 재입력 (UI-only)
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
                      color: _pwConfirmController.text == _pwController.text
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // 개인정보 수집 동의 (UI-only, 기본 false)
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
                  onPressed: () {}, // 모달 연결 예정
                  child: const Text('전문 읽기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 우측: 수신동의/언어 카드 (UI-only, 기본 미체크)
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '한국어', child: Text('한국어')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: '日本語', child: Text('日本語')),
                  DropdownMenuItem(value: 'Tiếng Việt', child: Text('Tiếng Việt')),
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

  // 하단: 가입하기 버튼 카드 (동작은 기존 _submit)
  Widget _animationBox(Color cardColor) {
    return Card(
      color: const Color(0xFFBDBDBD),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC5C5),
                    foregroundColor: Colors.brown[800],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '가입하기 애니메이션(자리)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),
    );
  }
}