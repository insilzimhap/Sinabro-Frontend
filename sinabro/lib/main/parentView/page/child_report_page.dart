// lib/main/parentView/page/child_report_page.dart
/*
 * 파일: lib/main/parentView/page/child_report_page.dart
 * 개요: 자녀의 학습 리포트 개요 화면. AI 리포트 페이지로 이동하는 버튼 포함.
 * @ 채영: 자녀 이름, 나이, 레벨 등 띄울 수 있는 부분은 수정 해놓음.
 * @ Gemini: AI 리포트 버튼 추가 및 진행 상황 요약 API 연동 (모델 수정 완료).
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/page/child/child_profile_edit.dart';
import 'package:sinabro/main/parentView/page/child_AIreport_page.dart';

// API 응답 데이터를 담을 모델 클래스
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

  // JSON 데이터를 ProgressSummary 객체로 변환
  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      progressToNextLevel: (json['progressToNextLevel'] as num?)?.toDouble() ?? 0.0,
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


class ChildReportPage extends StatefulWidget {
  final String? parentUserId;
  final String childId;
  final String childName; // 초기값
  final int childAge;    // 초기값
  final int level;       // 초기값

  const ChildReportPage({
    super.key,
    this.parentUserId,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.level,
  });

  @override
  State<ChildReportPage> createState() => _ChildReportPageState();
}

class _ChildReportPageState extends State<ChildReportPage> {
  // 프로필 정보 상태
  String? _childName;
  int? _childAge;
  dynamic _childLevel;

  // 진행 상황 요약 데이터 상태 변수
  ProgressSummary? _progressSummary;
  String? _summaryErrorMessage;

  // 로딩 상태
  bool _isLoadingProfile = true;
  bool _isLoadingSummary = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _childName = widget.childName;
    _childAge = widget.childAge;
    _childLevel = widget.level == 0 ? "?" : widget.level;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
      _fetchProgressSummary();
    });
  }

  // 자녀 프로필 정보 가져오기
  Future<void> _fetchProfile() async {
    if (!_isLoadingProfile) setState(() => _isLoadingProfile = true);
    try {
      final uri = Uri.parse("$baseUrl/api/app/mypage/children/${widget.childId}");
      final res = await AuthClient().get(uri);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          _childName = data["childName"] ?? widget.childName;
          _childAge = (data["childAge"] as int?) ?? widget.childAge;
          _childLevel = (data["childLevel"] == null || data["childLevel"] == 0) ? "?" : data["childLevel"];
        });
        log("[리포트-프로필] 성공 childId=${widget.childId}");
      } else {
        log("[리포트-프로필] 실패 code=${res.statusCode}, body=${res.body}");
      }
    } catch (e) {
      log("[리포트-프로필] 예외 $e");
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // 진행 상황 요약 API 호출 함수
  Future<void> _fetchProgressSummary() async {
    if (!_isLoadingSummary) setState(() => _isLoadingSummary = true);
    _summaryErrorMessage = null;
    try {
      final uri = Uri.parse("$baseUrl/api/app/child/${widget.childId}/progress-summary");
      final res = await AuthClient().get(uri);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          _progressSummary = ProgressSummary.fromJson(data);
        });
        log("[리포트-요약] 성공 childId=${widget.childId}");
      } else {
        log("[리포트-요약] 실패 code=${res.statusCode}, body=${res.body}");
        setState(() { _summaryErrorMessage = "학습/게임 기록 요약을 불러오는데 실패했습니다."; });
      }
    } catch (e) {
      log("[리포트-요약] 예외 $e");
      if (mounted) { setState(() { _summaryErrorMessage = "오류가 발생했습니다: $e"; }); }
    } finally {
      if (mounted) setState(() => _isLoadingSummary = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool stillLoading = _isLoadingProfile || _isLoadingSummary;

    if (stillLoading) {
      return const ParentLayout(
        activeMenu: '자녀페이지',
        content: Center(child: CircularProgressIndicator()),
      );
    }

    final childName = _childName ?? widget.childName;
    final childAge = _childAge ?? widget.childAge;
    final level = _childLevel ?? "?";
    final progressToNext = _progressSummary?.progressToNextLevel ?? 0.0;

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
                    _childHeadline(context, widget.childId, childName, childAge, level, progressToNext),
                    const SizedBox(height: 18),
                    _cardsArea(context, widget.childId, level, _progressSummary, _summaryErrorMessage),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 상단 큰 녹색 바
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

  // 이름/나이/레벨/프로필수정/AI리포트 버튼/진행도
  Widget _childHeadline(BuildContext context, String childId, String childName, int childAge,
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
            Row( // 나이/레벨 | 프로필 수정 버튼
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
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChildProfileEditPage(
                                parentUserId: widget.parentUserId,
                                childId: childId,
                                childName: childName,
                              ),
                        ),
                      );
                      if (updated == true && mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _dirty = true;
                          _fetchProfile(); // 프로필 정보 새로고침
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
            const SizedBox(height: 10),
            ElevatedButton( // AI 리포트 버튼
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildAIReportPage(
                      childId: childId,
                      childName: childName,
                    ),
                  ),
                );
              },
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                 minimumSize: const Size(0, 30), // 버튼 높이 최소값
              ).copyWith(
                 overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Text(
                '$childName 님의 학습 리포트',
                 style: const TextStyle(
                   fontSize: 24,
                   fontWeight: FontWeight.w900,
                   color: Colors.black,
                 ),
              ),
            ),
            const SizedBox(height: 12),
            Row( // 진행도 바
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressToNext.clamp(0.0, 1.0),
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

  // 좌측: 학습 / 우측: 게임 카드 (실제 데이터 또는 에러 메시지 표시)
  Widget _cardsArea(BuildContext context, String childId, dynamic level,
                                      ProgressSummary? summary, String? errorMessage) {
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(errorMessage, style: TextStyle(color: Colors.red[700])),
        ),
      );
    }

    // API 응답 또는 기본값("기록 없음") 사용
    final progressLabelText = (summary == null)
        ? "$level 레벨의 ?% 완료!"
        : "$level 레벨의 ${(summary.progressToNextLevel * 100).toStringAsFixed(0)}% 완료!";
    // 모델 필드명 변경 적용 (쓰기 기록 우선 표시)
    final studyRecentText = summary?.writingStudyRecent ?? summary?.listeningStudyRecent ?? '기록 없음';
    final studyBestText = summary?.writingStudyBest ?? summary?.listeningStudyBest ?? '기록 없음';
    final gameRecentText = summary?.writingGameRecent ?? summary?.listeningGameRecent ?? '기록 없음';
    final gameBestText = summary?.writingGameBest ?? summary?.listeningGameBest ?? '기록 없음';


    return LayoutBuilder(
      builder: (_, c) {
        final isNarrow = c.maxWidth < 860;
        final cards = [
          _statCard(
            title: '학습',
            progressLabel: progressLabelText,
            recent: studyRecentText, // 실제 데이터 반영
            best: studyBestText,     // 실제 데이터 반영
          ),
          _statCard(
            title: '게임',
            progressLabel: progressLabelText, // 학습과 동일 진행률 사용 가정
            recent: gameRecentText, // 실제 데이터 반영
            best: gameBestText,     // 실제 데이터 반영
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((w) => SizedBox(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 16) / 2,
                child: w,
              )).toList(),
        );
      },
    );
  }

  // 학습/게임 기록 카드 위젯 (UI 수정 없음)
  Widget _statCard({
    required String title,
    required String progressLabel,
    required String recent,
    required String best,
  }) {
    // UI 코드는 수정 없음
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
} // End of _ChildReportPageState