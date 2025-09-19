/*
 * 파일: lib/main/parentView/page/notice_page.dart (NoticePage)
 * 개요: 부모용 공지사항 목록 화면. ParentLayout 하위에서 공지 리스트를
 *      펼침/접힘 UI로 보여준다. 세션/부모정보를 복구해 사이드바/헤더에 반영.
 */
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart' as parent_api;
import 'package:sinabro/main/parentView/page/children_state.dart';

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

class NoticePage extends StatefulWidget {
  final String? parentUserId; // 선택
  final String? parentDisplayName; // 선택
  const NoticePage({super.key, this.parentUserId, this.parentDisplayName});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final _store = ChildrenState.instance;

  bool _ready = false;
  String? _err;
  String _uid = '';
  String _parentName = '';
  int _openIndex = 0;

  @override
  void initState() {
    super.initState();
    _ensureParentContext();
  }

  Future<void> _ensureParentContext() async {
    setState(() {
      _ready = false;
      _err = null;
    });

    try {
      // 1) userId 결정 (prop → active → session → prefs)
      await _store.setParent(widget.parentUserId);
      var uid = (_store.activeUserId ?? '').trim();
      if (uid.isEmpty) {
        throw 'parentUserId가 없습니다. 로그인/세션을 확인해주세요.';
      }

      // 2) 이름 결정 (prop → session → 서버)
      var name = (widget.parentDisplayName ?? '').trim();
      if (name.isEmpty) name = (_store.sessionUserName ?? '').trim();
      if (name.isEmpty) {
        name = await parent_api.ParentApi.fetchParentName(uid);
        await _store.setSession(userId: uid, userName: name);
      }

      if (!mounted) return;
      setState(() {
        _uid = uid;
        _parentName = name.isEmpty ? '부모' : name;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = '서버 연결 실패: $e';
        _ready = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_err != null) {
      return ParentLayout(
        activeMenu: '공지사항',
        parentUserId: _uid,
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _ensureParentContext,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ParentLayout(
      activeMenu: '공지사항',
      parentUserId: _uid,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  const _NoticeHeader(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _NoticeList(
                      notices: _demoNotices,
                      openIndex: _openIndex,
                      onToggle:
                          (i) => setState(() {
                            _openIndex = (_openIndex == i) ? -1 : i;
                          }),
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

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF6DBF73),
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
        '${item.date.year.toString().padLeft(4, '0')}-'
        '${item.date.month.toString().padLeft(2, '0')}-'
        '${item.date.day.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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
