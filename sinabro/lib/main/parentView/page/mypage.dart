/*
 * 파일: lib/main/parentView/page/mypage.dart (MyPage)
 * 개요: 부모용 "마이페이지" 진입 게이트 화면. ParentLayout 하위에서
 * 비밀번호 재확인을 받아 프로필/계정 수정 화면(MyInfoEditPage)로 이동시킨다.
 * @ 채영: JWT+api 연결 완료
 * @연수: 언어팩 지원을 위해 수정중 // ✨
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/myinfo_edit_page.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart'; // ✨

class MyPage extends StatefulWidget {
  /// 사이드바를 동적으로 채우고, 상단 이름을 불러오려면 parentUserId를 넘겨주세요.
  final String? parentUserId;
  const MyPage({super.key, this.parentUserId});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _pwController = TextEditingController();
  bool _verifying = false;

  Future<String> _loadParentName() async {
    if (widget.parentUserId == null || widget.parentUserId!.isEmpty) {
      return '';
    }
    try {
      final name = await ParentApi.fetchParentName(widget.parentUserId!);
      return name;
    } catch (_) {
      return '';
    }
  }

  Future<void> _onVerify() async {
    final uid = widget.parentUserId?.trim() ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
          content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'))); // TODO: 번역
      return;
    }
    if (_pwController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TranslatedText('비밀번호를 입력해주세요.')));
      return;
    }

    setState(() => _verifying = true);

    // TODO: 서버 비밀번호 검증 API 연동 (예: /api/users/verify-password)
    // 지금은 데모로 바로 통과 처리
    try {
      await ParentApi.verifyParentPassword(
          uid, _pwController.text.trim()); // ✅ 서버 검증 호출
    } catch (e) {
      setState(() => _verifying = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }

    if (!mounted) return;
    setState(() => _verifying = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyInfoEditPage(parentUserId: uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ParentLayout을 사용: 사이드바/헤더는 레이아웃이 담당
    return ParentLayout(
      activeMenu: '마이페이지',
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        // ⬇⬇⬇ 오버플로우 방지: 스크롤 가능 + 키보드 높이만큼 하단 패딩
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                (bottomInset > 0) ? bottomInset + 16 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      children: [
                        // 상단 녹색 헤더바
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6DBF73),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(width: 16),
                              TranslatedText(
                                '마이 페이지',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 중앙 카드 (비밀번호 확인)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 36,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const TranslatedText(
                                  '부모 회원',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // 이름 로딩
                                FutureBuilder<String>(
                                  future: _loadParentName(),
                                  builder: (context, snap) {
                                    final name = (snap.data ?? '').trim();
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          name.isEmpty ? '' : '$name ',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        TranslatedText(
                                          name.isEmpty ? '회원님' : '님',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 28),
                                const TranslatedText(
                                  '비밀번호를 입력해주세요',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 360,
                                  child: TextField(
                                    controller: _pwController,
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
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: 160,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: _verifying ? null : _onVerify,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6DBF73),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _verifying
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
                                        : const TranslatedText('확인'),
                                  ), // ⬅️ ElevatedButton 닫기
                                ), // ⬅️ SizedBox (버튼) 닫기
                              ],
                            ), // ⬅️ Column (카드 안) 닫기
                          ), // ⬅️ Padding (카드 안) 닫기
                        ), // ⬅️ Card 닫기
                      ],
                    ), // ⬅️ Column (메인) 닫기
                  ), // ⬅️ Padding (메인) 닫기
                ), // ⬅️ ConstrainedBox 닫기
              ), // ⬅️ Center 닫기
            ); // ⬅️ SingleChildScrollView 닫기
          }, // ⬅️ LayoutBuilder builder 닫기
        ), // ⬅️ LayoutBuilder 닫기
      ), // ⬅️ Container (content) 닫기
    ); // ⬅️ ParentLayout 닫기
  }
}
