/*
 * 파일: lib/main/parentView/page/children_page.dart
 * 개요: 부모용 ‘자녀페이지’ 목록 화면. 사이드바(ParentLayout) 내 자녀 리스트를 보여주고,
 * 자녀 추가/상세(리포트)로 이동하는 허브 역할.
 * @ 채영: JWT+api 연결 완료
 * @ 정화: ChildReportPage 호출 시 progressToNext 파라미터 제거
 * @ 연수: 언어팩 지원 연결 완료
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/child/add_child_form.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart'; // ChildSummary
// ⭐️ [수정] sub 브랜치의 경로와 import를 사용 (children_state.dart, child_report_page.dart)
import 'package:sinabro/main/parentView/page/child/children_state.dart'; // 세션 + 상태 저장소
import 'package:sinabro/main/parentView/page/child/child_report_page.dart';
import 'package:sinabro/main/parentView/widget/translated_text.dart'; // ✨ sub 브랜치 import

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
    // 첫 프레임 빌드 후에 상태 로드 및 이름 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.loadOnce(widget.parentUserId);
      setState(() {
        _nameFuture = _ensureName();
      });
    });
  }

  // 페이지가 다시 활성화될 때마다 자녀 목록 새로고침
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 현재 라우트가 활성화될 때 새로고침 (선택적: 필요 없다면 제거 가능)
    // ModalRoute.of(context)?.isCurrent ?? false 로 확인 가능
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // 최초 로드 시 중복 호출 방지 위해 조건 추가 가능
       if (!_store.loading) {
         _store.refresh();
       }
    });
  }

  // 전달값 → 세션 순으로 uid 얻기
  String _resolvedUid() {
    final fromProp = (widget.parentUserId ?? '').trim();
    if (fromProp.isNotEmpty) return fromProp;
    return (_store.sessionUserId ?? '').trim();
  }

  // 부모 이름 확보 로직 (기존과 동일)
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

  // 자녀 추가 페이지로 이동
  Future<void> _goAdd() async {
    final uid = _resolvedUid();
    if (uid.isEmpty) {
      if (mounted) {
        // ⭐️ [수정] sub 브랜치의 mounted 체크 방식 사용
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            const SnackBar(content: Text('로그인 정보를 확인해주세요.'))); // TODO: 번역
      }
      return;
    }
    // 자녀 추가 후 돌아왔을 때 true 값이 넘어오면 목록 새로고침
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddChildFormPage(parentUserId: uid)),
    );
    if (ok == true && mounted) {
      await _store.refresh(); // 목록 새로고침
      setState(() => _nameFuture = _ensureName()); // 이름 다시 확인
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidebarUid = _resolvedUid();

    return ParentLayout(
      activeMenu: '자녀페이지', // ✨ (향후 번역 키 'child_page'로 변경)
      parentUserId: sidebarUid,
      content: AnimatedBuilder( // ChildrenState 변경 감지하여 UI 업데이트
        animation: _store,
        builder: (_, __) {
          final uid = _resolvedUid();

          // 로딩 상태 처리
          if (uid.isEmpty && _store.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 로그인 정보 없을 때 에러 뷰
          if (uid.isEmpty) {
            return _ErrorView(
              message: '로그인 정보가 없습니다. (userId 비어 있음)', // ✨ (향후 번역 키로 변경)
              onRetry: () {
                _store.loadOnce(widget.parentUserId);
                setState(() => _nameFuture = _ensureName());
              },
            );
          }
          // 초기 로딩 중일 때 (아이템 없을 때만)
          if (_store.loading && _store.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 부모 이름 로드 후 자녀 목록 또는 빈 상태 표시
          return FutureBuilder<String>(
            future: _nameFuture,
            builder: (context, snap) {
              final parentName = (snap.data ?? '').trim().isNotEmpty
                  ? snap.data!.trim()
                  : '부모'; // ✨ (향후 번역 키로 변경)

              // 자녀 목록이 비어있으면 EmptyState 표시
              if (_store.items.isEmpty) {
                return _EmptyState(parentName: parentName, onAdd: _goAdd);
              }

              // 자녀 목록이 있으면 ChildList 표시
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

// 자녀 목록 GridView 위젯
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
    // 화면 너비에 따라 GridView 컬럼 수 조절
    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 헤더 (타이틀 + 추가하기 버튼)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ⭐️ [수정] sub 브랜치의 번역 지원 구조 (Wrap) 사용
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$parentName ',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const TranslatedText(
                    '님의 자녀 리스트', // ✨ (향후 번역 키로 변경)
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: onAdd, // 추가하기 버튼 클릭 시 _goAdd 함수 호출
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9DAB7),
                  foregroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const TranslatedText('추가하기'), // ✨ (향후 번역 키로 변경)
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 자녀 카드 목록 (GridView)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: GridView.builder(
                itemCount: items.length, // 자녀 수만큼 아이템 생성
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // 화면 너비에 따른 컬럼 수
                  mainAxisSpacing: 18, // 카드 세로 간격
                  crossAxisSpacing: 18, // 카드 가로 간격
                  childAspectRatio: 0.88, // 카드 가로세로 비율
                ),
                // ⭐️ [수정] HEAD와 sub 브랜치 로직 병합
                itemBuilder: (_, i) {
                  final c = items[i];

                  // 1번 코드 로직: ReportPage에 넘길 non-nullable int (기본값 0)
                  final int ageForReport = c.childAge ?? 0;
                  // 2번 코드 로직: _ChildCard에 넘길 nullable int? (번역 처리를 위해)
                  final int? ageForCard = c.childAge;
                  // 1번 코드 로직: level 기본값 0
                  const int lvl = 0;

                  // 각 자녀 정보를 _ChildCard 위젯에 전달하여 생성
                  return _ChildCard(
                    name: c.childName,
                    age: ageForCard, // ✨ sub 브랜치의 nullable int? 전달
                    onTap: () async {
                      // 1번 코드 로직: push<bool> 및 mounted 확인
                      final updated =
                          await Navigator.of(context, rootNavigator: true)
                              .push<bool>(
                        // ⭐️ <bool> 타입 명시 (HEAD)
                        MaterialPageRoute(
                          builder: (_) => ChildReportPage(
                            parentUserId: parentUserId,
                            childId: c.childId,
                            childName: c.childName,
                            childAge: ageForReport, // ⭐️ HEAD 로직
                            level: lvl,
                          ),
                        ),
                      );
                      // 1번 코드 로직: context.mounted 확인
                      if (updated == true && context.mounted) {
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

// ⭐️ [수정] sub 브랜치의 _ChildCard (번역 지원) 사용
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
      child: InkWell( // 탭 효과
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 기본 프로필 아이콘 (향후 이미지로 대체 가능)
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              // ✨ sub 브랜치의 나이 표시 로직 (번역 가능)
              age == null
                  ? const TranslatedText(
                      '나이 정보 없음', // ✨ (향후 번역 키로 변경)
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
                          '세', // ✨ (향후 번역 키로 변경)
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
              // 자녀 이름
              Text(
                name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis, // 이름 길면 ... 처리
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ⭐️ [수정] sub 브랜치의 _EmptyState (번역 지원) 사용
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
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.brown),
          const SizedBox(height: 12),
          // ✨ sub 브랜치의 번역 적용 구조 (Wrap)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              const TranslatedText(
                '현재', // ✨ (향후 번역 키로 변경)
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                parentName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const TranslatedText(
                '님의 자녀가 없어요', // ✨ (향후 번역 키로 변경)
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAdd, // 버튼 클릭 시 자녀 추가 함수 호출
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9DAB7),
              foregroundColor: Colors.brown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const TranslatedText('아이 추가하기'), // ✨ (향후 번역 키로 변경)
          ),
        ],
      ),
    );
  }
}

// ⭐️ [수정] sub 브랜치의 _ErrorView (번역 지원) 사용
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
              onPressed: onRetry,
              child: const TranslatedText('다시 시도')), // ✨ (향후 번역 키로 변경)
        ],
      ),
    );
  }
}