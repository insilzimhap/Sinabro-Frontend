/**
 * 파일: lib/main/parentView/page/child/child_report_page.dart
 * 기능: 부모용 자녀 리포트 (진행 요약 + 학습/게임 카드 4분할)
 * 작성자: 정화 + 채영 + Gemini
 * 최종 수정: 2025-11-05
 */

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/child/child_profile_edit.dart';
import 'package:sinabro/main/parentView/page/child/child_AIreport_page.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart';

/// ----------------------
/// 🧩 모델: ProgressSummary
/// ----------------------
class ProgressSummary {
  final double progressToNextLevel;
  final String? listeningStudyRecent;
  final String? listeningStudyBest;
  final String? writingStudyRecent;
  final String? writingStudyBest;
  final String? listeningGameRecent;
  final String? listeningGameBest;
  final String? writingGameRecent;
  final String? writingGameBest;

  ProgressSummary({
    required this.progressToNextLevel,
    this.listeningStudyRecent,
    this.listeningStudyBest,
    this.writingStudyRecent,
    this.writingStudyBest,
    this.listeningGameRecent,
    this.listeningGameBest,
    this.writingGameRecent,
    this.writingGameBest,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      progressToNextLevel:
          (json['progressToNextLevel'] as num?)?.toDouble() ?? 0.0,
      listeningStudyRecent: json['listeningStudyRecent'] as String?,
      listeningStudyBest: json['listeningStudyBest'] as String?,
      writingStudyRecent: json['writingStudyRecent'] as String?,
      writingStudyBest: json['writingStudyBest'] as String?,
      listeningGameRecent: json['listeningGameRecent'] as String?,
      listeningGameBest: json['listeningGameBest'] as String?,
      writingGameRecent: json['writingGameRecent'] as String?,
      writingGameBest: json['writingGameBest'] as String?,
    );
  }
}

/// ----------------------
/// 🧩 StatefulWidget 본체
/// ----------------------
class ChildReportPage extends StatefulWidget {
  final String childId;
  final String childName;
  final int childAge;
  final int level;
  final String? parentUserId;

  const ChildReportPage({
    super.key,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.level,
    this.parentUserId,
  });

  @override
  State<ChildReportPage> createState() => _ChildReportPageState();
}

class _ChildReportPageState extends State<ChildReportPage> {
  String? _childName;
  int? _childAge;
  dynamic _childLevel;
  ProgressSummary? _progressSummary;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _childName = widget.childName;
    _childAge = widget.childAge;
    _childLevel = widget.level == 0 ? '?' : widget.level;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSummary());
  }

  /// ----------------------
  /// 🎯 진행 요약 API 호출
  /// ----------------------
  Future<void> _fetchSummary() async {
    setState(() => _isLoading = true);
    try {
      final uri =
          Uri.parse('$baseUrl/api/app/child/${widget.childId}/progress-summary');
      final res = await AuthClient().get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        log('[리포트] 응답 = $data');
        setState(() {
          _progressSummary = ProgressSummary.fromJson(data);
          _errorMsg = null;
        });
      } else {
        setState(() => _errorMsg = '학습/게임 요약 데이터를 불러올 수 없습니다.');
      }
    } catch (e) {
      log('[리포트] 오류: $e');
      setState(() => _errorMsg = '네트워크 오류가 발생했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ----------------------
  /// 🧱 UI
  /// ----------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ParentLayout(
        activeMenu: '자녀페이지',
        content: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = _progressSummary;
    final progressPercent =
        ((summary?.progressToNextLevel ?? 0.0) * 100).clamp(0, 100).toStringAsFixed(0);

    return ParentLayout(
      activeMenu: '자녀페이지',
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 16),
                  _profileSection(progressPercent),
                  const SizedBox(height: 24),
                  if (_errorMsg != null)
                    Center(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red))),
                  if (summary != null && _errorMsg == null)
                    _buildCards(summary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ----------------------
  /// 🟩 상단 타이틀 바
  /// ----------------------
  Widget _header() => Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF6DBF73),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const TranslatedText(
          '자녀 페이지',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      );

  /// ----------------------
  /// 👶 프로필 / 진행도
  /// ----------------------
  Widget _profileSection(String percent) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('${_childAge ?? '?'}세 · lv.${_childLevel ?? '?'}',
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              const Spacer(),
              OutlinedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildProfileEditPage(
                        childId: widget.childId,
                        parentUserId: widget.parentUserId,
                        childName: _childName ?? widget.childName,
                      ),
                    ),
                  );
                  _fetchSummary();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6DBF73)),
                  foregroundColor: const Color(0xFF2E7D32),
                ),
                child: const TranslatedText('프로필 수정'),
              ),
            ]),
            const SizedBox(height: 12),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '${_childName ?? widget.childName} ',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const TextSpan(
                  text: '님의 학습 리포트',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ])),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_progressSummary?.progressToNextLevel ?? 0.0).clamp(0, 1),
                    color: const Color(0xFF6DBF73),
                    backgroundColor: const Color(0xFFECECEC),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('다음 레벨까지 $percent%'),
            ]),
          ],
        ),
      ),
    );
  }

  /// ----------------------
  /// 📊 카드 영역 (4개 고정)
  /// ----------------------
  Widget _buildCards(ProgressSummary summary) {
    final cards = [
      _buildCard('쓰기 학습', summary.writingStudyRecent, summary.writingStudyBest),
      _buildCard('듣기 학습', summary.listeningStudyRecent, summary.listeningStudyBest),
      _buildCard('쓰기 게임', summary.writingGameRecent, summary.writingGameBest),
      _buildCard('듣기 게임', summary.listeningGameRecent, summary.listeningGameBest),
    ];

    return LayoutBuilder(builder: (context, c) {
      final double cardWidth = (c.maxWidth - 16) / 2;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: cards
            .map((w) => SizedBox(width: cardWidth, child: w))
            .toList(),
      );
    });
  }

  /// ----------------------
  /// 🪣 개별 카드
  /// ----------------------
  Widget _buildCard(String title, String? recent, String? best) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6EDE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
            ),
            const SizedBox(height: 18),
            const Text('최근 기록', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              recent ?? '기록 없음',
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF43A047)),
            ),
            const SizedBox(height: 14),
            const Text('최고 기록', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              best ?? '기록 없음',
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF43A047)),
            ),
          ],
        ),
      ),
    );
  }
}
