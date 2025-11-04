/*
 * 파일: lib/main/parentView/page/child/child_report_page.dart
 * 개요: 자녀의 학습 리포트 개요 화면. API 연동 및 언어팩 지원.
 * @ 채영: 자녀 이름, 나이, 레벨 등 띄울 수 있는 부분은 수정 해놓음.
 * @ 정화: AI 리포트 버튼 추가 및 진행 상황 요약 API 연동 (모델 수정 완료).
 * @ 연수 (Gemini 병합): 언어팩 지원 (TranslatedText 위젯 적용)
 * @ Gemini: 2개 카드 -> 4개 카드(학습/게임, 쓰기/듣기 분리)로 UI 수정
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/page/child/child_profile_edit.dart';
import 'package:sinabro/main/parentView/page/child/child_AIreport_page.dart'; // ⭐️ AI 리포트 페이지 import
import 'package:sinabro/main/parentView/widget/translated_text.dart'; // ✨

// API 응답 데이터를 담을 모델 클래스 (V1)
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

class ChildReportPage extends StatefulWidget {
  final String? parentUserId;
  final String childId;
  final String childName; // 초기값
  final int childAge; // 초기값
  final int level; // 초기값

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

  // 자녀 프로필 정보 가져오기 (V1)
  Future<void> _fetchProfile() async {
    if (!_isLoadingProfile) setState(() => _isLoadingProfile = true);
    try {
      final uri =
          Uri.parse("$baseUrl/api/app/mypage/children/${widget.childId}");
      final res = await AuthClient().get(uri);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(() {
          _childName = data["childName"] ?? widget.childName;
          _childAge = (data["childAge"] as int?) ?? widget.childAge;
          _childLevel = (data["childLevel"] == null || data["childLevel"] == 0)
              ? "?"
              : data["childLevel"];
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

  // 진행 상황 요약 API 호출 함수 (V1)
  Future<void> _fetchProgressSummary() async {
    if (!_isLoadingSummary) setState(() => _isLoadingSummary = true);
    _summaryErrorMessage = null;
    try {
      final uri = Uri.parse(
          "$baseUrl/api/app/child/${widget.childId}/progress-summary");
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
        setState(() {
          _summaryErrorMessage = "학습/게임 기록 요약을 불러오는데 실패했습니다.";
        });
      }
    } catch (e) {
      log("[리포트-요약] 예외 $e");
      if (mounted) {
        setState(() {
          _summaryErrorMessage = "오류가 발생했습니다: $e";
        });
      }
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
              // ⭐️ [수정] 4개 카드 스크롤되도록 SingleChildScrollView 추가
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _headerBar(), // ✨
                      const SizedBox(height: 16),
                      _childHeadline(context, widget.childId, childName, childAge,
                          level, progressToNext), // ✨
                      const SizedBox(height: 18),
                      // ⭐️ [수정] _cardsArea가 4개 카드를 반환함
                      _cardsArea(context, _progressSummary, _summaryErrorMessage),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 상단 큰 녹색 바 (V2 적용)
  Widget _headerBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF6DBF73),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const TranslatedText(
        // ✨
        '자녀 페이지',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // 이름/나이/레벨/프로필수정/AI리포트 버튼/진행도 (V1 + V2 병합)
  Widget _childHeadline(BuildContext context, String childId, String childName,
      int childAge, dynamic level, double progressToNext) {
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
            Row(
              // 나이/레벨 | 프로필 수정 버튼
              children: [
                // ✨ V2 구조 적용
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$childAge',
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                    const TranslatedText(
                      '세',
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '  ·  lv.$level',
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () async {
                      // V1 로직 유지
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
                    child: const TranslatedText('프로필 수정'), // ✨
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              // AI 리포트 버튼 (V1 기능 유지)
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
              // ✨ V2 구조 적용 (Wrap)
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                // V1의 스타일을 하위 텍스트에 적용
                textDirection: TextDirection.ltr, // Wrap 내부 Text 정렬을 위해
                children: [
                  Text(
                    '$childName ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  // ⭐️ [수정] '학습 리포트' -> '게임 리포트' (네가 저번에 요청한 거)
                  const TranslatedText(
                    '님의 게임 리포트',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              // 진행도 바
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
                // ✨ V2 구조 적용
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TranslatedText('다음 레벨까지'),
                    Text(' $percent%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ⭐️ [수정] 좌우 2개 -> 총 4개 카드로 변경
  Widget _cardsArea(
      BuildContext context, ProgressSummary? summary, String? errorMessage) {
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(errorMessage, style: TextStyle(color: Colors.red[700])),
        ),
      );
    }
    
    // ⭐️ [추가] 4개의 카드를 리스트로 정의
    final cards = [
      // Card 1: 쓰기 학습
      _statCard(
        titleWidget: const TranslatedText('쓰기 학습'), // ✨
        recent: summary?.writingStudyRecent ?? '기록 없음', // ⭐️ '쓰기 학습' 전용 데이터
        best: summary?.writingStudyBest ?? '기록 없음', // ⭐️ '쓰기 학습' 전용 데이터
      ),
      // Card 2: 듣기 학습
      _statCard(
        titleWidget: const TranslatedText('듣기 학습'), // ✨
        recent: summary?.listeningStudyRecent ?? '기록 없음', // ⭐️ '듣기 학습' 전용 데이터
        best: summary?.listeningStudyBest ?? '기록 없음', // ⭐️ '듣기 학습' 전용 데이터
      ),
      // Card 3: 쓰기 게임
      _statCard(
        titleWidget: const TranslatedText('쓰기 게임'), // ✨
        recent: summary?.writingGameRecent ?? '기록 없음', // ⭐️ '쓰기 게임' 전용 데이터
        best: summary?.writingGameBest ?? '기록 없음', // ⭐️ '쓰기 게임' 전용 데이터
      ),
      // Card 4: 듣기 게임
      _statCard(
        titleWidget: const TranslatedText('듣기 게임'), // ✨
        recent: summary?.listeningGameRecent ?? '기록 없음', // ⭐️ '듣기 게임' 전용 데이터
        best: summary?.listeningGameBest ?? '기록 없음', // ⭐️ '듣기 게임' 전용 데이터
      ),
    ];

    return LayoutBuilder(
      builder: (_, c) {
        final isNarrow = c.maxWidth < 860;
        // ⭐️ Wrap 위젯이 4개의 카드를 알아서 2x2 또는 1x4로 배치
        return Wrap(
          spacing: 16, // 좌우 간격
          runSpacing: 16, // 상하 간격
          children: cards
              .map((w) => SizedBox(
                    // 좁으면 1줄에 1개, 넓으면 1줄에 2개
                    width: isNarrow ? c.maxWidth : (c.maxWidth - 16) / 2,
                    child: w,
                  ))
              .toList(),
        );
      },
    );
  }

  // ⭐️ [수정] 학습/게임 기록 카드 위젯 (progressLabel 파라미터 삭제)
  Widget _statCard({
    required Widget titleWidget, // ✨ V2 방식 (String title -> Widget titleWidget)
    // required String progressLabel, // 👈 ⭐️ [삭제] 겹치는 정보라 삭제
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
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EDE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // ✨ V2 방식 적용
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                    child: titleWidget,
                  ),
                ),
                const Spacer(),
                // ⭐️ [삭제] 겹치는 진행도 텍스트 삭제
              ],
            ),
            const SizedBox(height: 18),
            // ⭐️ [수정] '학습' -> '최근' (공통 용어)
            const TranslatedText('최근 기록',
                style: TextStyle(color: Colors.black54)), // ✨
            const SizedBox(height: 6),
            Text(
              recent,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
              // ⭐️ 글자 수 길어지면 ... 처리
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 14),
            // ⭐️ [수정] '학습' -> '최고' (공통 용어)
            const TranslatedText('최고 기록',
                style: TextStyle(color: Colors.black54)), // ✨
            const SizedBox(height: 6),
            Text(
              best,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
              // ⭐️ 글자 수 길어지면 ... 처리
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
} // End of _ChildReportPageState