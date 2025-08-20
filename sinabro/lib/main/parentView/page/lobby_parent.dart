import 'package:flutter/material.dart';

import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/add_child_form.dart';

// ✅ API: 부모 이름 / 자녀 목록
import 'package:sinabro/main/parentView/api/parent_api.dart';

class SelectParentsPage extends StatelessWidget {
  final String parentUserId;
  const SelectParentsPage({super.key, required this.parentUserId});

  Future<_LobbyData> _load() async {
    final parentName = await ParentApi.fetchParentName(parentUserId);
    final children = await ParentApi.fetchChildren(parentUserId);
    return _LobbyData(parentName: parentName, children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자녀 선택'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: Row(
        children: [
          // ✅ 공통 사이드바(동적)
          ParentSidebar(
            activeMenu: '마이페이지',
            parentUserId: parentUserId,
          ),

          // ✅ 오른쪽 콘텐츠(동적)
          Expanded(
            child: Container(
              color: const Color(0xFFE4F1FA),
              child: FutureBuilder<_LobbyData>(
                future: _load(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('로드 실패: ${snap.error}'),
                      ),
                    );
                  }
                  final data = snap.data!;
                  final parentName =
                      (data.parentName.isEmpty) ? '부모' : data.parentName;

                  // ▶ 자녀가 없을 때: 기존 빈 화면 + 추가하기 버튼 유지
                  if (data.children.isEmpty) {
                    return _EmptyState(
                      parentName: parentName,
                      onAdd: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddChildFormPage(parentUserId: parentUserId),
                          ),
                        );
                      },
                    );
                  }

                  // ▶ 자녀가 있을 때: 카드 리스트로 표시
                  return _ChildList(
                    parentName: parentName,
                    items: data.children,
                    onAdd: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddChildFormPage(parentUserId: parentUserId),
                        ),
                      ).then((_) {
                        // 돌아왔을 때 새로고침이 필요하면 Stateful로 바꾸거나
                        // 라우트 재진입 시 setState가 되는 구조로 사용해도 됨.
                      });
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

class _ChildList extends StatelessWidget {
  final String parentName;
  final List<ChildSummary> items;
  final VoidCallback onAdd;

  const _ChildList({
    required this.parentName,
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
          // 상단 타이틀 + 추가하기
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$parentName 님의 자녀 리스트',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9DAB7),
                  foregroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('추가하기'),
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
                  return _ChildCard(
                    name: c.displayName,
                    ageLabel: c.displayAge,
                    // onTap: () { /* 여기서 자녀 로비/레벨테스트 페이지로 이동 로직 붙이면 됨 */ },
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
  final String ageLabel;
  final VoidCallback? onTap;

  const _ChildCard({
    required this.name,
    required this.ageLabel,
    this.onTap,
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
              Text(
                ageLabel.isEmpty ? '나이 정보 없음' : ageLabel,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
          // ✅ 이미지 삽입 (기존 유지)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/img/icon/sorry.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '현재 $parentName 님의 자녀가 없어요',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9DAB7),
              foregroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              elevation: 6,
            ),
            child: const Text('아이 추가하기'),
          ),
        ],
      ),
    );
  }
}

class _LobbyData {
  final String parentName;
  final List<ChildSummary> children;
  _LobbyData({required this.parentName, required this.children});
}
