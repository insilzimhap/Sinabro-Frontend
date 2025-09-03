import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/children_state.dart';
import 'package:sinabro/main/parentView/page/add_child_form.dart'; // 네가 준 파일명 기준
import 'package:sinabro/main/parentView/page/child_report_page.dart';

class ChildrenPage extends StatefulWidget {
  final String parentUserId; // 부모 식별자(추가 폼에 전달)
  final String parentDisplayName; // 상단 타이틀에 표시할 이름

  const ChildrenPage({
    super.key,
    required this.parentUserId,
    required this.parentDisplayName,
  });

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  final _store = ChildrenState.instance;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.loadOnce(); // 최초 1회 더미/서버 로딩
  }

  // 자녀 추가 폼으로 이동
  Future<void> _goAdd() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildFormPage(parentUserId: widget.parentUserId),
      ),
    );

    if (ok == true) {
      // 성공 후 끝쪽으로 부드럽게 스크롤(피드백 느낌)
      await Future.delayed(const Duration(milliseconds: 120));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _scrollLeft() {
    if (!_scroll.hasClients) return;
    final target = (_scroll.offset - 240)
        .clamp(0, _scroll.position.maxScrollExtent)
        .toDouble();
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    if (!_scroll.hasClients) return;
    final target = (_scroll.offset + 240)
        .clamp(0, _scroll.position.maxScrollExtent)
        .toDouble();
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '자녀페이지',
      parentUserId: widget.parentUserId,
      content: AnimatedBuilder(
        animation: _store,
        builder: (_, __) {
          final items = _store.items;

          return Container(
            color: const Color(0xFFF9F2F5),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 상단 타이틀 + 추가 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.parentDisplayName} 님의 자녀 리스트',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _goAdd,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7BC27D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('추가하기'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 내용 카드
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: items.isEmpty
                            ? _EmptyChildren(onAdd: _goAdd)
                            : Row(
                                children: [
                                  // 왼쪽 화살표
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _scrollLeft,
                                  ),
                                  const SizedBox(width: 6),

                                  // 가로 스크롤 카드 목록
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _scroll,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 4),
                                          ...items.map((c) {
                                            final name = c.nickname.isNotEmpty
                                                ? c.nickname
                                                : c.name;
                                            return GestureDetector(
                                              onTap: () {
                                                // 자녀 카드 탭 → 리포트 화면
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ChildReportPage(
                                                      parentUserId:
                                                          widget.parentUserId,
                                                      childName: name,
                                                      childAge: c.age,
                                                      level: 2, // 데모 값
                                                      progressToNext:
                                                          0.57, // 데모 값
                                                      studyRecent: '1나무 5열매',
                                                      studyBest: '1나무 3열매',
                                                      gameRecent: '1나무 5열매',
                                                      gameBest: '1나무 3열매',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: _ChildCard(
                                                ageLabel: '${c.age}세',
                                                name: name,
                                              ),
                                            );
                                          }).toList(),
                                          const SizedBox(width: 4),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),
                                  // 오른쪽 화살표
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _scrollRight,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ------------------------------- 위젯들 ------------------------------- */

class _EmptyChildren extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyChildren({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: Color(0xFF6EB16F),
            ),
            const SizedBox(height: 12),
            const Text(
              '현재 자녀가 없습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text('오른쪽 위 [추가하기] 버튼으로 등록해 주세요.'),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAdd, child: const Text('지금 추가하기')),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final String ageLabel;
  final String name;
  const _ChildCard({required this.ageLabel, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 54, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(ageLabel, style: const TextStyle(color: Colors.grey)),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
