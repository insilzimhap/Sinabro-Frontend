import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/user_select_screen.dart'; // ✅ 뒤로가기용

// ✅ 동적 사이드바용 API (parentUserId 전달 시에만 네트워크 호출)
import 'package:sinabro/main/parentView/api/parent_api.dart';

import '../widget/child_tag.dart';
import '../page/mypage.dart';
import '../page/study_report.dart';
import '../page/notice_page.dart';
import '../page/faq.dart';
import '../page/setting.dart';

class ParentLayout extends StatelessWidget {
  final String activeMenu;
  final Widget content;

  // ✅ 하위 호환: optional 로 추가. 안 넘기면 기존처럼 정적 사이드바 표시됨.
  final String? parentUserId;

  const ParentLayout({
    super.key,
    required this.activeMenu,
    required this.content,
    this.parentUserId, // ← 선택 파라미터 (기존 페이지들 오류 안 남)
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text(
          'SINABRO 부모용 페이지',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const UserSelectScreen(),
              ),
            );
          },
        ),
      ),
      body: Row(
        children: [
          ParentSidebar(
            activeMenu: activeMenu,
            parentUserId: parentUserId, // ← null 이면 정적, 값 있으면 동적
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class ParentSidebar extends StatelessWidget {
  final String activeMenu;

  // ✅ 하위 호환: optional 로 추가. null 이면 기존 정적 표시 유지.
  final String? parentUserId;

  const ParentSidebar({
    super.key,
    required this.activeMenu,
    this.parentUserId, // ← 선택 파라미터
  });

  Future<_SidebarData> _load(String userId) async {
    final name = await ParentApi.fetchParentName(userId);
    final children = await ParentApi.fetchChildren(userId);
    return _SidebarData(parentName: name, children: children);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ parentUserId 가 null 이면 예전 정적 사이드바를 그대로 렌더링 (기존 페이지들 보호)
    if (parentUserId == null) {
      return Container(
        width: 180,
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '(부모)님의 자녀',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  // ✅ 기존 정적 태그 유지
                  ChildTag(label: '성민콩', color: Color(0xFFB5E5B8)),
                  ChildTag(label: '세로이', color: Color(0xFFD6D6D6)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildMenuItem(context, '마이페이지', activeMenu == '마이페이지', const MyPage()),
            _buildMenuItem(context, '학습리포트', activeMenu == '학습리포트', const StudyReportPage()),
            _buildMenuItem(context, '공지사항', activeMenu == '공지사항', const NoticePage()),
            _buildMenuItem(context, '문의하기', activeMenu == '문의하기', const FaqPage()),
            _buildMenuItem(context, '설정', activeMenu == '설정', const SettingsPage()),
          ],
        ),
      );
    }

    // ✅ parentUserId 가 있으면 동적 로딩 버전
    return Container(
      width: 180,
      color: const Color(0xFFF5F5F5),
      child: FutureBuilder<_SidebarData>(
        future: _load(parentUserId!), // ← 안전하게 ! (위에서 null 분기 처리)
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('사이드바 로딩 실패\n${snap.error}', style: const TextStyle(fontSize: 12)),
            );
          }
          final data = snap.data!;
          final parentName = data.parentName.isEmpty ? '부모' : data.parentName;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '($parentName)님의 자녀',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: (data.children.isEmpty)
                    ? const Text('등록된 자녀가 없어요',
                        style: TextStyle(fontSize: 12, color: Colors.grey))
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.children
                            .map((c) => ChildTag(
                                  label: c.displayName, // ✅ 닉네임 우선, 없으면 이름
                                  color: const Color(0xFFD6D6D6),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 30),
              _buildMenuItem(context, '마이페이지', activeMenu == '마이페이지', const MyPage()),
              _buildMenuItem(
                  context, '학습리포트', activeMenu == '학습리포트', const StudyReportPage()),
              _buildMenuItem(context, '공지사항', activeMenu == '공지사항', const NoticePage()),
              _buildMenuItem(context, '문의하기', activeMenu == '문의하기', const FaqPage()),
              _buildMenuItem(context, '설정', activeMenu == '설정', const SettingsPage()),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildMenuItem(
    BuildContext context,
    String title,
    bool isActive,
    Widget destination,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.green : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _SidebarData {
  final String parentName;
  final List<ChildSummary> children;

  _SidebarData({required this.parentName, required this.children});
}
