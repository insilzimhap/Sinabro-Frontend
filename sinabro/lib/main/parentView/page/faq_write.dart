/*
 * 파일: lib/main/parentView/page/faq_write.dart (FaqWritePage)
 * 개요: 부모용 문의/FAQ 작성 화면. 사이드바(ParentLayout) 내 '문의사항' 메뉴에 대응하며
 *      제목·내용 입력 후 서버 전송(추후 연동) 및 성공 토스트를 띄운 뒤 이전 화면으로 복귀한다.
 */
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

class FaqWritePage extends StatefulWidget {
  final String? parentUserId;
  const FaqWritePage({super.key, this.parentUserId});

  @override
  State<FaqWritePage> createState() => _FaqWritePageState();
}

class _FaqWritePageState extends State<FaqWritePage> {
  final _titleCtl = TextEditingController();
  final _bodyCtl = TextEditingController();

  Future<void> _submit() async {
    final title = _titleCtl.text.trim();
    final body = _bodyCtl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해 주세요.')));
      return;
    }

    // TODO: 서버로 전송 API 연동
    // await http.post(...)

    if (!mounted) return;
    await _showSuccessToast(); // ✅ 커스텀 성공 팝업 (짧은 높이)
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  /// ✅ 시안(2번) 형태의 커스텀 팝업 (배경 흐림 없음, 짧은 세로)
  Future<void> _showSuccessToast() async {
    const bg = Color(0xFFE7F6E9); // 연두 배경
    const bd = Color(0xFF53A866); // 초록 보더
    const txt = Color(0xFF6B5A51); // 본문 텍스트

    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'success',
      barrierDismissible: true,
      barrierColor: Colors.transparent, // 배경 어둡게 하지 않음
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, a1, a2) {
        final size = MediaQuery.of(ctx).size;
        final width = math.min(size.width - 48, 520.0); // 좁은 화면 대응

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              // ⬇️ 세로 길이 제한(원하는 사이즈로 조절 가능)
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 160),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: bd, width: 3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 닫기(X)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6DBF73),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // 본문 텍스트
                  const Center(
                    child: Text(
                      '문의가 등록되었습니다!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: txt,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '문의사항',
      parentUserId: widget.parentUserId,
      content: Scaffold(
        backgroundColor: const Color(0xFFF9F2F5),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 헤더
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DBF73),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      '문의하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 입력 폼
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleCtl,
                            decoration: const InputDecoration(
                              labelText: '제목',
                              filled: true,
                              fillColor: Color(0xFFF8F9FA),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _bodyCtl,
                            minLines: 8,
                            maxLines: 12,
                            decoration: const InputDecoration(
                              labelText: '내용',
                              filled: true,
                              fillColor: Color(0xFFF8F9FA),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 작성완료 버튼
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6DBF73),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            '작성완료',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
