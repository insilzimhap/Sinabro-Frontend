/*
 * 파일: lib/main/parentView/page/faq_page.dart (FaqPage)
 * 개요: 부모용 문의사항 목록 화면.
 * @ 채영: JWT+api 연결 완료
 */
import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/config.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/fap/faq_write.dart';




/* ---------------- 모델 ---------------- */

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
  ReplyDto({required this.author, required this.content, required this.createdAt,});
  factory ReplyDto.fromJson(Map<String, dynamic> j) {
    DateTime date;
    try {
      date = DateTime.parse((j['createdAt'] ?? '').toString().replaceFirst(' ', 'T'));
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
  // 리스트 상태
  final List<InquiryRow> _rows = [];
  final Map<String, InquiryDetail> _detailCache = {};
  int _page = 0;
  final int _size = 20;
  bool _hasNext = true;
  bool _isLoadingList = false;
  String? _loadingDetailId;  // 상세 로딩 표시용
  int _openIndex = -1;   // 펼친 인덱스(없으면 -1)

  //------ 뷰 상태 -------
  String? _err;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  /// 첫 페이지부터 로드
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

  /// 페이지네이션 추가 로드
  Future<void> _loadMore() async {
    if (_isLoadingList || !_hasNext) return;
    if (widget.parentUserId == null || widget.parentUserId!.isEmpty) {
      setState(() => _err = 'parentUserId가 없습니다.');
      return;
    }


    setState(() => _isLoadingList = true);


    final uri = Uri.parse(
        '$baseUrl/api/app/inquiries/parent/${widget.parentUserId}')
      .replace(queryParameters: {'page': '$_page', 'size': '$_size'});


    try {
      debugPrint('[faq] 목록 요청: $uri');
      final resp = await AuthClient().get(uri).timeout(const Duration(seconds: 8)); 
      if (resp.statusCode != 200) throw '상태코드 ${resp.statusCode}';

      final map = json.decode(resp.body) as Map<String, dynamic>;
      final List list = (map['content'] as List?) ?? const [];
      final rows = list.whereType<Map<String, dynamic>>().map(InquiryRow.fromJson).toList();

      setState(() {
        _rows.addAll(rows);
        _hasNext = map['hasNext'] == true;
        _page = (map['page'] as int) + 1;
        _ready = true;
      });
      debugPrint('[faq] 목록 로드: add=${rows.length} total=${_rows.length} hasNext=$_hasNext');

    } catch (e) {
      debugPrint('[faq][오류] 목록 로드 실패: $e');
      if (mounted) {
        setState(() {
          _err = '문의 목록 로드 실패: $e';
          _ready = false;
        });
      }
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  /// 상세 API
  Future<InquiryDetail?> _loadDetail(String id) async {
    if (_detailCache.containsKey(id)) return _detailCache[id];
    try {
      final uri = Uri.parse('$baseUrl/api/app/inquiries/parent/${widget.parentUserId}/$id');
      debugPrint('[faq] 상세 요청: $uri');
      setState(() => _loadingDetailId = id);
      final resp = await AuthClient().get(uri).timeout(const Duration(seconds: 8)); //changed (JWT)
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
    if (_err != null) {
      return ParentLayout(
        activeMenu: '문의사항',
        parentUserId: widget.parentUserId,
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: _loadFirstPage, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ParentLayout(
      activeMenu: '문의사항',
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
                  _headerBar(),
                  const SizedBox(height: 12),
                  _listCard(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: () async {
                          final created = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => FaqWritePage(
                                    parentUserId: widget.parentUserId,
                                  ),
                            ),
                          );
                          if (created == true && mounted) {
                            await _loadFirstPage(); // 작성 후 목록 갱신
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
                          child: Text(
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

  // 상단 녹색 헤더
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
        '문의하기',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // 리스트 카드 (아코디언)
  Widget _listCard() {
    if (_rows.isEmpty) {
      // ✅ 목록이 아예 없을 때
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: const Text(
          '문의 내역이 없습니다 😅',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
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
        children: _rows.map((row) {
          return ExpansionPanelRadio(
            value: row.id,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => _rowHeader(row),
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
                    child: Text('상세를 불러올 수 없습니다.'),
                  );
                }
                return _rowBody(row, snap.data!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // 행 헤더 (제목/작성자/날짜/상태칩)
  Widget _rowHeader(InquiryRow row) {
    final isAnswered = row.status == '답변 완료';
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
                  row.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${row.author}   ${_dateLabel(row.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  isAnswered
                      ? const Color(0xFFCFEFD3)
                      : const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
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

  // 펼쳐진 본문
  Widget _rowBody(InquiryRow row, InquiryDetail detail) {
    final isAnswered = row.status == '답변 완료';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFFF7F7F7),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Text(
            detail.content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        if (isAnswered && detail.reply != null) ...[
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${detail.reply!.author} 님의 답변',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·  ${_dateLabel(detail.reply!.createdAt)}', //changed ✅ 날짜 복원
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  detail.reply!.content,
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


