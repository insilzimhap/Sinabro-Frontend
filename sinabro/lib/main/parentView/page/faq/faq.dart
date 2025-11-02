/*
 * 파일: lib/main/parentView/page/faq.dart (FaqPage)
 * 개요: 부모용 문의사항 목록 화면.
 * @ 채영: JWT+api 연결 완료
 * @연수: 언어팩 지원을 위해 수정중 // ✨
 */
import 'package:flutter/material.dart';
// ⭐️ [수정] sub 브랜치의 import 사용 (API 연동)
import 'dart:convert';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/faq/faq_write.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart'; // ✨

/* ---------------- 모델 ---------------- */
// ⭐️ [수정] sub 브랜치의 API 연동 모델 사용

/// 목록 행 데이터 (답변 여부만 상태로 표시)
class InquiryRow {
  final String id;
  final String title;
  final String author;
  final DateTime createdAt;
  final String status; // "답변 전", "답변 완료"

  InquiryRow({
    required this.id,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.status,
  });

  factory InquiryRow.fromJson(Map<String, dynamic> j) {
    final createdStr = (j['createdAt'] ?? '').toString();
    DateTime created;
    try {
      created = DateTime.parse(createdStr.replaceFirst(' ', 'T'));
    } catch (_) {
      created = DateTime.now();
    }
    return InquiryRow(
      id: j['id'].toString(),
      title: j['title']?.toString() ?? '',
      author: j['authorName']?.toString() ?? '부모',
      createdAt: created,
      status: j['status']?.toString() ?? '답변 전',
    );
  }
}

/// 상세 + 답변 1건 포함
class InquiryDetail {
  final String id;
  final String content;
  final ReplyDto? reply;
  const InquiryDetail({required this.id, required this.content, this.reply});

  factory InquiryDetail.fromJson(Map<String, dynamic> j) => InquiryDetail(
        id: j['id'].toString(),
        content: j['content']?.toString() ?? '',
        reply: j['reply'] != null ? ReplyDto.fromJson(j['reply']) : null,
      );
}

/// 답변 DTO
class ReplyDto {
  final String author;
  final String content;
  final DateTime createdAt;
  ReplyDto({
    required this.author,
    required this.content,
    required this.createdAt,
  });
  factory ReplyDto.fromJson(Map<String, dynamic> j) {
    DateTime date;
    try {
      date = DateTime.parse(
          (j['createdAt'] ?? '').toString().replaceFirst(' ', 'T'));
    } catch (_) {
      date = DateTime.now();
    }
    return ReplyDto(
      author: (j['author'] ?? '팀 시나브로').toString(),
      content: (j['content'] ?? '').toString(),
      createdAt: date, //changed
    );
  }
}

// ---------------- 위젯 ----------------
class FaqPage extends StatefulWidget {
  final String? parentUserId; // 사이드바 동적 표시가 필요하면 전달
  const FaqPage({super.key, this.parentUserId});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  // ⭐️ [수정] sub 브랜치의 API 연동 상태 변수 사용
  final List<InquiryRow> _rows = [];
  final Map<String, InquiryDetail> _detailCache = {};
  int _page = 0;
  final int _size = 20;
  bool _hasNext = true;
  bool _isLoadingList = false;
  String? _loadingDetailId;
  int _openIndex = -1; // ⭐️ ExpansionPanelList.radio는 이게 필요 없음 (나중에 정리)

  String? _err;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _rows.clear();
      _detailCache.clear();
      _page = 0;
      _hasNext = true;
      _openIndex = -1;
      _ready = false;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingList || !_hasNext) return;
    if (widget.parentUserId == null || widget.parentUserId!.isEmpty) {
      setState(() => _err = 'parentUserId가 없습니다.');
      return;
    }

    setState(() => _isLoadingList = true);

    final uri =
        Uri.parse('$baseUrl/api/app/inquiries/parent/${widget.parentUserId}')
            .replace(queryParameters: {'page': '$_page', 'size': '$_size'});

    try {
      debugPrint('[faq] 목록 요청: $uri');
      final resp =
          await AuthClient().get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) throw '상태코드 ${resp.statusCode}';

      final map = json.decode(resp.body) as Map<String, dynamic>;
      final List list = (map['content'] as List?) ?? const [];
      final rows = list
          .whereType<Map<String, dynamic>>()
          .map(InquiryRow.fromJson)
          .toList();

      setState(() {
        _rows.addAll(rows);
        _hasNext = map['hasNext'] == true;
        _page = (map['page'] as int) + 1;
        _ready = true;
      });
      debugPrint(
          '[faq] 목록 로드: add=${rows.length} total=${_rows.length} hasNext=$_hasNext');
    } catch (e) {
      debugPrint('[faq][오류] 목록 로드 실패: $e');
      if (mounted) {
        setState(() {
          _err = '문의 목록 로드 실패: $e'; // TODO: 번역
          _ready = false;
        });
      }
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  Future<InquiryDetail?> _loadDetail(String id) async {
    if (_detailCache.containsKey(id)) return _detailCache[id];
    try {
      final uri = Uri.parse(
          '$baseUrl/api/app/inquiries/parent/${widget.parentUserId}/$id');
      debugPrint('[faq] 상세 요청: $uri');
      setState(() => _loadingDetailId = id);
      final resp =
          await AuthClient().get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final detail = InquiryDetail.fromJson(json.decode(resp.body));
      _detailCache[id] = detail;
      debugPrint('[faq] 상세 로드 완료: id=$id reply=${detail.reply != null}');
      return detail;
    } catch (e) {
      debugPrint('[faq][오류] 상세 로드 실패: $e');
      return null;
    } finally {
      if (mounted) setState(() => _loadingDetailId = null);
    }
  }

  // --------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    // ⭐️ [수정] sub 브랜치의 build 로직 (에러/로딩 처리) 사용
    
    // ⭐️ 키보드 올라왔을 때 하단 여백 계산 (HEAD 코드에서 가져옴)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    if (_err != null) {
      return ParentLayout(
        activeMenu: '문의사항',
        parentUserId: widget.parentUserId,
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                  onPressed: _loadFirstPage,
                  child: const TranslatedText('다시 시도')), // ✨
            ],
          ),
        ),
      );
    }

    if (!_ready) {
      // ⭐️ [수정] Scaffold로 감싸서 ParentLayout 없이 로딩 표시 (sub 코드)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // ⭐️ [수정] HEAD 브랜치의 ParentLayout + Column 구조와
    //           sub 브랜치의 '문의하기' 버튼 로직 결합
    return ParentLayout(
      activeMenu: '문의사항',
      parentUserId: widget.parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              // 하단 여백에 키보드/안전영역 반영
              padding: EdgeInsets.fromLTRB(16, 20, 16, bottomInset + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ 상단 고정 헤더
                  _headerBar(),
                  const SizedBox(height: 12),
                  
                  // ✨ Expanded로 감싸서 남은 공간 모두 차지 (sub 코드)
                  Expanded(child: _listCard()),
                  const SizedBox(height: 12),
                  
                  // '문의하기' 버튼 (sub 코드)
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: () async {
                          final created = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FaqWritePage(
                                parentUserId: widget.parentUserId,
                              ),
                            ),
                          );
                          // ⭐️ [수정] sub 코드: 문의 등록 후 목록 새로고침
                          if (created == true && mounted) {
                            await _loadFirstPage(); 
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6DBF73),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: TranslatedText(
                            // ✨
                            '문의하기',
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

  // 상단 녹색 헤더(고정)
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
        '문의하기',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _listCard() {
    // ⭐️ [수정] sub 브랜치: 목록 비었을 때 처리
    if (_rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: const TranslatedText(
          // ✨
          '문의 내역이 없습니다 😅',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    // ⭐️ [수정] sub 브랜치: API 데이터(_rows)로 ExpansionPanelList 생성
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ExpansionPanelList.radio(
        elevation: 0,
        expandIconColor: Colors.grey[700],
        animationDuration: const Duration(milliseconds: 200),
        children: _rows.map((row) { // ⭐️ items -> _rows
          return ExpansionPanelRadio(
            value: row.id, // ⭐️ item.id -> row.id
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => _rowHeader(row), // ⭐️ item -> row
            // ⭐️ [수정] sub 브랜치: 상세 내용 비동기 로드
            body: FutureBuilder<InquiryDetail?>(
              future: _loadDetail(row.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: TranslatedText('상세를 불러올 수 없습니다.'), // ✨
                  );
                }
                return _rowBody(row, snap.data!); // ⭐️ item -> row, detail
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ⭐️ [수정] sub 브랜치: _InquiryItem 대신 InquiryRow 사용
  Widget _rowHeader(InquiryRow item) { // ⭐️ _InquiryItem -> InquiryRow
    final isAnswered = item.status == '답변 완료'; // ⭐️ enum -> String
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  // ⭐️ item.date -> item.createdAt
                  '${item.author}   ${_dateLabel(item.createdAt)}', 
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isAnswered
                  ? const Color(0xFFCFEFD3)
                  : const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: TranslatedText(
              // ✨ 조건부 텍스트 번역
              isAnswered ? '답변 완료' : '답변 전',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isAnswered ? const Color(0xFF2E7D32) : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️ [수정] sub 브랜치: _InquiryItem 대신 InquiryRow, InquiryDetail 사용
  Widget _rowBody(InquiryRow row, InquiryDetail detail) {
    final isAnswered = row.status == '답변 완료';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFFF7F7F7),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Text(
            detail.content, // ⭐️ item.question -> detail.content
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        if (isAnswered && detail.reply != null) ...[ // ⭐️ null 체크 추가
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // ✨ 동적 텍스트 번역 (sub 코드)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          '${detail.reply!.author} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF495057),
                          ),
                        ),
                        const TranslatedText(
                          '님의 답변',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF495057),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      // ⭐️ item.answerDate -> detail.reply!.createdAt
                      '·  ${_dateLabel(detail.reply!.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  detail.reply!.content, // ⭐️ item.answer -> detail.reply!.content
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _dateLabel(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ⭐️ [수정] HEAD 브랜치의 더미 데이터용 모델(_InquiryItem, InquiryStatus) 삭제