// lib/main/parentView/page/child_AIreport_page.dart
/*
 * 파일: lib/main/parentView/page/child_AIreport_page.dart
 * 개요: 자녀의 AI 학습 리포트를 보여주는 화면. 서버에서 리포트 텍스트를 불러옴.
 * @ Gemini: 신규 생성 및 백엔드 연동 구현.
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart'; // 공통 레이아웃
import 'dart:convert';
import 'dart:developer';
import 'package:sinabro/common/auth_client.dart'; // ⭐️ 인증된 API 호출 클라이언트
import 'package:sinabro/config.dart';             // ⭐️ baseUrl

class ChildAIReportPage extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildAIReportPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildAIReportPage> createState() => _ChildAIReportPageState();
}

class _ChildAIReportPageState extends State<ChildAIReportPage> {
  bool _isLoading = true; // 로딩 상태
  String? _aiReportText; // 서버에서 받아올 AI 리포트 텍스트
  String? _errorMessage; // 오류 메시지

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 첫 프레임에서 API 호출 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAIReport();
    });
  }

  // 백엔드에서 AI 리포트 텍스트를 가져오는 함수
  Future<void> _fetchAIReport() async {
    // 이미 로딩 중이면 시작하지 않음 (선택적)
    // if (!_isLoading) setState(() => _isLoading = true);
    setState(() { // 로딩 시작
      _isLoading = true;
      _errorMessage = null; // 이전 오류 메시지 초기화
    });

    try {
      // ⭐️ API 엔드포인트: 백엔드 요약에 명시된 '/api/report/preview' (POST)
      final url = Uri.parse('$baseUrl/api/report/preview');

      // ⭐️⭐️⭐️ 1. 오늘 날짜를 "YYYY-MM-DD" 형식으로 만들기 ⭐️⭐️⭐️
      final now = DateTime.now();
      // (DateTime을 'YYYY-MM-DD'로 변환하는 가장 간단한 방법. intl 패키지 써도 됨)
      final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // ⭐️⭐️⭐️ 2. 요청 본문(Body)에 'date' 필드 추가! ⭐️⭐️⭐️
      final body = jsonEncode({
        'childId': widget.childId,
        'date': formattedDate, // ⬅️ 오늘 날짜 추가!
      });
      // ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️

      final response = await AuthClient().post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _aiReportText = data['reportText'] as String?;
          _isLoading = false;
          if (_aiReportText == null || _aiReportText!.isEmpty) {
            _errorMessage = '리포트 내용을 받아오지 못했습니다.';
          }
        });
        log("[AI리포트] 성공 childId=${widget.childId}");
      } else {
        log("[AI리포트] 실패 code=${response.statusCode}, body=${response.body}");
        setState(() {
          _errorMessage = '리포트를 불러오는데 실패했습니다. (코드: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      log("[AI리포트] 예외 $e");
      if (mounted) {
        setState(() {
          _errorMessage = '오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '자녀페이지', // 현재 메뉴 활성화 표시 (선택적)
      // parentUserId: widget.parentUserId, // 필요 시 부모 ID 전달
      content: Container(
        color: const Color(0xFFF9F2F5), // 배경색
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100), // 최대 너비
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerBar(), // 상단 녹색 바
                  const SizedBox(height: 16),
                  _buildReportContent(), // AI 리포트 내용 표시 영역
                ],
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
      child: Text(
        '${widget.childName} AI 학습 리포트', // 자녀 이름 표시
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  /// AI 리포트 내용을 표시하는 위젯 (로딩/오류/성공 처리)
  Widget _buildReportContent() {
    if (_isLoading) {
      // 로딩 중일 때
      return const Expanded( // 남은 공간 차지
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_errorMessage != null) {
      // 오류 발생 시
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (_aiReportText != null) {
      // 성공적으로 리포트 텍스트를 받아왔을 때
      return Expanded(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0), // 내부 여백
            child: SingleChildScrollView( // 내용이 길어지면 스크롤 가능
              child: Text(
                _aiReportText!,
                style: const TextStyle(fontSize: 16, height: 1.6), // 줄 간격 조절
              ),
            ),
          ),
        ),
      );
    } else {
      // 예상치 못한 상태 (데이터도 없고 오류도 없을 때)
      return const Expanded(
        child: Center(child: Text('리포트 데이터가 없습니다.')),
      );
    }
  }
} // End of _ChildAIReportPageState