/*
 * 파일: lib/main/parentView/page/faq.dart (FaqPage)
 * 개요: 상단 헤더는 고정, 그 아래 리스트+버튼만 스크롤.
 */
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/faq_write.dart';

class FaqPage extends StatefulWidget {
  final String? parentUserId; // 사이드바 동적 표시가 필요하면 전달
  const FaqPage({super.key, this.parentUserId});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  // 데모 데이터 (서버 연결 시 API 결과로 교체)
  final List<_InquiryItem> items = [
    _InquiryItem(
      id: '1',
      title: '애가 학습하기 싫어해요',
      author: '박성민 님',
      date: DateTime(2025, 8, 17),
      question:
          '애가 집중을 못하는 건 아닌데 그냥 학습에 흥미가 떨어지네요.\n다른 콘텐츠도 많이 추가됐으면 합니다...\n너무 콘텐츠들이 어린 애들 위주인 것 같아요!\n기대하겠습니다 ^^',
      status: InquiryStatus.answered,
      answer:
          '안녕하세요 팀 시나브로입니다.\n우선 저희 앱을 이용해주셔서 감사합니다.\n추후 콘텐츠 추가 예정에 있습니다 ^^ 감사합니다.',
      answerDate: DateTime(2025, 8, 17),
    ),
    _InquiryItem(
      id: '2',
      title: '기기 제한 시간 관련 문의',
      author: '박성민 님',
      date: DateTime(2025, 8, 18),
      question: '기기 제한 시간을 좀 더 유연하게 설정할 수 있나요?',
      status: InquiryStatus.pending,
    ),
    _InquiryItem(
      id: '3',
      title: '레벨 테스트 기준이 궁금합니다',
      author: '박성민 님',
      date: DateTime(2025, 8, 19),
      question: '레벨 테스트 결과가 반영되는 기준이 궁금합니다.',
      status: InquiryStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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

                  // ✅ 아래 영역만 스크롤
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _listCard(),
                          const SizedBox(height: 20),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('문의가 등록되었습니다.'),
                                      ),
                                    );
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
        children:
            items
                .map(
                  (item) => ExpansionPanelRadio(
                    value: item.id,
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) => _rowHeader(item),
                    body: _rowBody(item),
                  ),
                )
                .toList(),
      ),
    );
  }

  // 행 헤더 (제목/작성자/날짜/상태칩)
  Widget _rowHeader(_InquiryItem item) {
    final isAnswered = item.status == InquiryStatus.answered;
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
                  '${item.author}   ${_dateLabel(item.date)}',
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
  Widget _rowBody(_InquiryItem item) {
    final isAnswered = item.status == InquiryStatus.answered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFFF7F7F7),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Text(
            item.question,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        if (isAnswered) ...[
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '팀 시나브로 님의 답변',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·  ${_dateLabel(item.answerDate ?? item.date)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.answer ?? '',
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

/* =========================
   모델 & 상태
========================= */
enum InquiryStatus { pending, answered }

class _InquiryItem {
  final String id;
  final String title;
  final String author;
  final DateTime date;
  final String question;
  final InquiryStatus status;
  final String? answer;
  final DateTime? answerDate;

  _InquiryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.question,
    required this.status,
    this.answer,
    this.answerDate,
  });
}
