// lib/main/parentView/page/child_report_page.dart
/*
 * 파일: lib/main/parentView/page/child_report_page.dart
 * 개요: 자녀의 학습 리포트를 보여주는 화면(뷰 전용, 서버 미연동).
 * @ 채영: 자녀 이름, 나이, 레벨 등 띄울 수 있는 부분은 수정 해놓음.
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';

// ✅ 프로필 수정 페이지 import
import 'package:sinabro/main/parentView/page/child/child_profile_edit.dart';

/// 자녀 학습 리포트 페이지 (뷰 전용 / 서버 미연동)
class ChildReportPage extends StatefulWidget {
  final String? parentUserId;

  // 화면에 표시할 정보들
  final String childId; //자녀 아이디
  final String childName; // 예: 박쑥일
  final int childAge; // 예: 7
  final int level; // 예: 2
  final double progressToNext; // 0.0 ~ 1.0 (예: 0.57 -> 57%)

  // 카드에 보여줄 텍스트(데모)
  final String studyRecent; // 최근 학습 기록
  final String studyBest; // 최고 학습 기록
  final String gameRecent; // 최근 게임 기록
  final String gameBest; // 최고 게임 기록

  const ChildReportPage({
    super.key,
    this.parentUserId,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.level,
    required this.progressToNext,
    this.studyRecent = '1나무 5열매',
    this.studyBest = '1나무 3열매',
    this.gameRecent = '1나무 5열매',
    this.gameBest = '1나무 3열매',
  });

  @override
  State<ChildReportPage> createState() => _ChildReportPageState();
}

class _ChildReportPageState extends State<ChildReportPage> {
  String? _childName;
  int? _childAge;
  dynamic _childLevel; // null → "?" 표시

  bool loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _childName = widget.childName;
    _childAge = widget.childAge;
    _childLevel = widget.level;
    // ✅ 수정: 프레임 끝난 뒤 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  Future<void> _fetchProfile() async {
    try {
      final uri =
          Uri.parse("$baseUrl/api/app/mypage/children/${widget.childId}");
      final res = await AuthClient().get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _childName = data["childName"] ?? widget.childName;
          // 나이는 DB에는 없으니 기존 값 사용
          _childAge = (data["childAge"] as int?) ?? widget.childAge;
          _childLevel = data["childLevel"] ?? "?"; // 없으면 "?"
          loading = false;
        });
        log("[리포트] 성공 childId=${widget.childId}");
      } else {
        log("[리포트] 실패 code=${res.statusCode}");
        setState(() => loading = false);
      }
    } catch (e) {
      log("[리포트] 예외 $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final childName = _childName ?? widget.childName;
    final childAge = _childAge ?? widget.childAge;
    final level = _childLevel ?? "?";
    final prog = widget.progressToNext;

    // ★ 추가: 뒤로 갈 때 updated 여부를 부모(ChildrenPage)로 넘김
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dirty);
        return false;
      },
      child: ParentLayout(
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
                    _childHeadline(context, childName, childAge, level, prog),
                    const SizedBox(height: 18),
                    _cardsArea(context, level, prog),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 상단 큰 녹색 바
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

  /// 이름/나이/레벨/프로필수정 버튼 / 진행도
  Widget _childHeadline(BuildContext context, String childName, int childAge,
      dynamic level, double progressToNext) {
    final percent = (progressToNext * 100).clamp(0, 100).toStringAsFixed(0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 7세 · lv.2  |  프로필 수정
            Row(
              children: [
                Text(
                  '$childAge세  ·  lv.$level',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () async {
                      // ✅ 프로필 편집으로 이동 (데모 값 사용)
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChildProfileEditPage(
                            parentUserId: widget.parentUserId,
                            childId: widget.childId,
                            childName: childName,
                          ),
                        ),
                      );
                      // ✅ 수정 완료 후 돌아오면 다시 프로필 불러오기
                      if (updated == true && mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _dirty = true;
                          _fetchProfile();
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6DBF73)),
                      foregroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('프로필 수정'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$childName 님의 학습 리포트',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            // 진행도
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressToNext.clamp(0.0, 1.0).toDouble(),
                      minHeight: 10,
                      backgroundColor: const Color(0xFFECECEC),
                      color: const Color(0xFF6DBF73),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('다음 레벨까지 $percent%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 좌측: 학습 / 우측: 게임 카드
  Widget _cardsArea(
      BuildContext context, dynamic level, double progressToNext) {
    return LayoutBuilder(
      builder: (_, c) {
        final isNarrow = c.maxWidth < 860;
        final cards = [
          _statCard(
            title: '학습',
            progressLabel:
                '$level 레벨의 ${(progressToNext * 100).toStringAsFixed(0)}% 완료!',
            recent: widget.studyRecent,
            best: widget.studyBest,
          ),
          _statCard(
            title: '게임',
            progressLabel:
                '$level 레벨의 ${(progressToNext * 100).toStringAsFixed(0)}% 완료!',
            recent: widget.gameRecent,
            best: widget.gameBest,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map(
                (w) => SizedBox(
                  width: isNarrow ? c.maxWidth : (c.maxWidth - 16) / 2,
                  child: w,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String progressLabel,
    required String recent,
    required String best,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 탭처럼 보이는 머릿글 + 우측 진행도 텍스트
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EDE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  progressLabel,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 최근 기록
            const Text('최근 학습 기록', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              recent,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(height: 14),

            // 최고 기록
            const Text('최고 학습 기록', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              best,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
