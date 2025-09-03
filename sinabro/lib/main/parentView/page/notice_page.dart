import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

/// -------------------------------
/// 모델
/// -------------------------------
class NoticeItem {
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final int views;

  const NoticeItem({
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.views,
  });
}

/// 데모 데이터 (서버 붙이기 전까지 사용)
final List<NoticeItem> _demoNotices = [
  NoticeItem(
    title: '[긴급 공지] 현재 발생하고 있는 이슈에 대해 사과드립니다',
    content:
        '2025년 8월 16일 22시 57분경부터 접속이 불가능한 이슈가 파악되었습니다.\n'
        '신속하게 조치하여 2025년 8월 17일 00시 15분부터 접속이 가능합니다.\n\n'
        '기다려주셔서 감사합니다.\n앞으로 더욱 발전하는 시나브로 팀이 되겠습니다.\n\n'
        '아이들의 성장이 한 걸음씩! 시나브로~',
    author: '팀 시나브로',
    date: DateTime(2025, 8, 17),
    views: 1,
  ),
  NoticeItem(
    title: '[이벤트 안내] 1주년 기념 학습 전체 무료화 (~25.9.1)',
    content:
        '1주년을 기념하여 전 학습 콘텐츠를 무료로 제공합니다.\n기간: ~ 2025년 9월 1일\n대상: 모든 회원\n'
        '자세한 내용은 공지 본문 또는 고객센터를 확인해주세요.',
    author: '팀 시나브로',
    date: DateTime(2025, 8, 17),
    views: 8,
  ),
  NoticeItem(
    title: '[긴급 공지] 현재 발생하고 있는 이슈에 대해 사과드립니다',
    content: '추가 점검 내역을 안내드립니다.\n일부 기기에서 로그인이 지연되는 현상을 개선했습니다.',
    author: '팀 시나브로',
    date: DateTime(2025, 8, 17),
    views: 3,
  ),
];

/// -------------------------------
/// 페이지
/// -------------------------------
class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  // 현재 펼쳐진 인덱스 (없으면 -1)
  int _openIndex = 0; // 첫 번째 항목 펼쳐놓고 시작하려면 0, 모두 접힘은 -1

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '공지사항', // 👈 사이드바에 초록 불
      content: Container(
        color: const Color(0xFFF9F2F5), // 본문 연분홍 배경(시안 톤 맞춤)
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  _NoticeHeader(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _NoticeList(
                      notices: _demoNotices,
                      openIndex: _openIndex,
                      onToggle: (i) {
                        setState(() {
                          _openIndex = (_openIndex == i) ? -1 : i;
                        });
                      },
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

/// -------------------------------
/// 상단 헤더 바 (초록색)
/// -------------------------------
class _NoticeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF6DBF73), // 초록 헤더
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          SizedBox(width: 12),
          Icon(Icons.home, color: Colors.white),
          SizedBox(width: 12),
          Text(
            '공지사항',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------------------
/// 공지 리스트 (단일 펼침 아코디언)
/// -------------------------------
class _NoticeList extends StatelessWidget {
  final List<NoticeItem> notices;
  final int openIndex;
  final ValueChanged<int> onToggle;

  const _NoticeList({
    required this.notices,
    required this.openIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = notices[i];
        final opened = openIndex == i;
        return _NoticeTile(
          item: item,
          opened: opened,
          onTap: () => onToggle(i),
        );
      },
    );
  }
}

/// 개별 공지 아이템
class _NoticeTile extends StatelessWidget {
  final NoticeItem item;
  final bool opened;
  final VoidCallback onTap;

  const _NoticeTile({
    required this.item,
    required this.opened,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: const Color(0xFFE6E6E6));
    final dateStr =
        '${item.date.year.toString().padLeft(4, '0')}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: border,
            boxShadow:
                opened
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Column(
            children: [
              // 제목 줄
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const _RoundIcon(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      opened
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              // 메타 정보 라인
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      item.author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '조회: ${item.views}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              // 내용 (토글)
              ClipRect(
                child: AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(44, 10, 12, 16),
                    child: Text(
                      item.content,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  crossFadeState:
                      opened
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 시안처럼 왼쪽에 둥근 아이콘 자리
class _RoundIcon extends StatelessWidget {
  const _RoundIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.campaign_outlined,
        size: 14,
        color: Colors.black54,
      ),
    );
  }
}
