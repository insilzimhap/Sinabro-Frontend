/*
 * 파일: lib/main/parentView/page/children_page.dart
 * 개요: 부모용 ‘자녀페이지’ 목록 화면. 사이드바(ParentLayout) 내 자녀 리스트를 보여주고,
 * 자녀 추가/상세(리포트)로 이동하는 허브 역할.
 * @ 채영: JWT+api 연결 완료
 * @연수: 언어팩 지원을 위해 수정중 // ✨
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/child/add_child_form.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart'; // ChildSummary
import 'package:sinabro/main/parentView/page/child/children_state.dart'; // 세션 + 상태 저장소
import 'package:sinabro/main/parentView/page/child/child_report_page.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart'; // ✨

class ChildrenPage extends StatefulWidget {
  final String? parentUserId; // (옵션) 외부에서 명시 전달 가능
  final String? parentDisplayName; // (옵션) 외부에서 명시 전달 가능

  const ChildrenPage({super.key, this.parentUserId, this.parentDisplayName});

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  final _store = ChildrenState.instance;
  Future<String>? _nameFuture; // 상단 타이틀용 이름 확보

  @override
  void initState() {
    super.initState();

    // ✅ 안전하게: 빌드 이후에 실행
    // ✅ 변경: 첫 프레임 끝난 뒤 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.loadOnce(widget.parentUserId);
      setState(() {
        _nameFuture = _ensureName(); //
      });
    });
  }

  /// 🔥 추가: 페이지 다시 들어올 때마다 최신 자녀목록을 불러오기
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.refresh();
    });
  }

  // 전달값 → 세션 순으로 uid 얻기
  String _resolvedUid() {
    final fromProp = (widget.parentUserId ?? '').trim();
    if (fromProp.isNotEmpty) return fromProp;
    return (_store.sessionUserId ?? '').trim();
  }

  Future<String> _ensureName() async {
    final propName = (widget.parentDisplayName ?? '').trim();
    if (propName.isNotEmpty) return propName;

    final sessName = (_store.sessionUserName ?? '').trim();
    if (sessName.isNotEmpty) return sessName;

    final uid = _resolvedUid();
    if (uid.isEmpty) return '부모';
    final name = await ParentApi.fetchParentName(uid);
    if (name.trim().isNotEmpty) {
      await _store.setSession(userId: uid, userName: name.trim());
    }
    return name.isEmpty ? '부모' : name.trim();
  }

  Future<void> _goAdd() async {
    final uid = _resolvedUid();
    if (uid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('로그인 정보를 확인해주세요.'))); // TODO: 번역
      return;
    }
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddChildFormPage(parentUserId: uid)),
    );
    if (ok == true && mounted) {
      await _store.refresh(); // 목록 새로고침
      setState(() => _nameFuture = _ensureName()); // 이름도 다시 보장
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidebarUid = _resolvedUid(); // ParentLayout/Sidebar로 전달

    return ParentLayout(
      activeMenu: '자녀페이지',
      parentUserId: sidebarUid,
      content: AnimatedBuilder(
        animation: _store,
        builder: (_, __) {
          final uid = _resolvedUid();

          if (uid.isEmpty && _store.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (uid.isEmpty) {
            return _ErrorView(
              message: '로그인 정보가 없습니다. (userId 비어 있음)', // ✨
              onRetry: () {
                _store.loadOnce(widget.parentUserId);
                setState(() => _nameFuture = _ensureName());
              },
            );
          }
          if (_store.loading && _store.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<String>(
            future: _nameFuture,
            builder: (context, snap) {
              final parentName = (snap.data ?? '').trim().isNotEmpty
                  ? snap.data!.trim()
                  : '부모';

              if (_store.items.isEmpty) {
                return _EmptyState(parentName: parentName, onAdd: _goAdd);
              }

              return _ChildList(
                parentName: parentName,
                parentUserId: sidebarUid,
                items: _store.items,
                onAdd: _goAdd,
              );
            },
          );
        },
      ),
    );
  }
}

/* ---------------- 리스트 / 카드 / 상태뷰 ---------------- */

class _ChildList extends StatelessWidget {
  final String parentName;
  final String parentUserId;
  final List<ChildSummary> items;
  final VoidCallback onAdd;

  const _ChildList({
    required this.parentName,
    required this.parentUserId,
    required this.items,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✨
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$parentName ',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const TranslatedText(
                    '님의 자녀 리스트',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9DAB7),
                  foregroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const TranslatedText('추가하기'), // ✨
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (_, i) {
                  final c = items[i];

                  final age = c.childAge; // ✨ int?로 직접 전달
                  const lvl = 1;
                  const prog = 0.0;

                  return _ChildCard(
                    name: c.childName,
                    age: age, // ✨
                    onTap: () async {
                      final updated =
                          await Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => ChildReportPage(
                            parentUserId: parentUserId,
                            childId: c.childId,
                            childName: c.childName,
                            childAge: age ?? 0,
                            level: lvl,
                            progressToNext: prog,
                          ),
                        ),
                      );
                      if (updated == true) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await ChildrenState.instance.refresh();
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final String name;
  final int? age; // ✨ String ageLabel -> int? age로 변경
  final VoidCallback onTap;

  const _ChildCard({
    required this.name,
    required this.age,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              // ✨ 나이 표시 로직 변경
              age == null
                  ? const TranslatedText(
                      '나이 정보 없음',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$age',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const TranslatedText(
                          '세',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String parentName;
  final VoidCallback onAdd;
  const _EmptyState({required this.parentName, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.brown,
          ),
          const SizedBox(height: 12),
          // ✨
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              const TranslatedText(
                '현재',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                parentName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const TranslatedText(
                '님의 자녀가 없어요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9DAB7),
              foregroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const TranslatedText('아이 추가하기'), // ✨
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          TranslatedText(message, textAlign: TextAlign.center), // ✨
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: onRetry, child: const TranslatedText('다시 시도')), // ✨
        ],
      ),
    );
  }
}
