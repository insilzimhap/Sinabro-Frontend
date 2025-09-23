// lib/main/parentView/layout/parent_layout.dart
// @채영: JWT 추가함에 따라 parent_id 넘겨주는 부분 수정함

import 'package:flutter/material.dart';

// 상단 앱바에서 "사용자 선택"으로 돌아갈 때 사용
import 'package:sinabro/main/mainView/page/user_select_screen.dart';

// 메뉴 대상 페이지들
import 'package:sinabro/main/parentView/page/notice_page.dart';
import 'package:sinabro/main/parentView/page/mypage.dart';
import 'package:sinabro/main/parentView/page/children_page.dart';
import 'package:sinabro/main/parentView/page/faq.dart';
import 'package:sinabro/main/parentView/page/setting.dart' as psettings;

/// 부모 공통 레이아웃
/// - 좌측 사이드바(접기/펼치기)
/// - 상단 AppBar(뒤로가기, 햄버거 토글)
class ParentLayout extends StatefulWidget {
  /// 현재 활성 메뉴 이름 (사이드바 하이라이트용)
  /// '공지사항' | '마이페이지' | '자녀페이지' | '문의사항' | '설정'
  final String activeMenu;

  /// 실제 본문 위젯
  final Widget content;

  /// 서버 연동 시 사이드바에서 부모정보를 불러올 일이 있으면 넘겨 쓸 ID(선택)
  final String? parentUserId;

  const ParentLayout({
    super.key,
    required this.activeMenu,
    required this.content,
    this.parentUserId,
  });

  @override
  State<ParentLayout> createState() => _ParentLayoutState();
}

class _ParentLayoutState extends State<ParentLayout> {
  bool _collapsed = false; // 사이드바 접힘 상태

  void _toggleSidebar() => setState(() => _collapsed = !_collapsed);

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade200;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'SINABRO 부모용 페이지',
          style: TextStyle(color: Colors.black),
        ),
        leading: Row(
          children: [
            // 뒤로가기: 사용자 선택 화면으로
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSelectScreen()),
                );
              },
            ),
            // 햄버거 (사이드바 토글)
            IconButton(
              icon: Icon(_collapsed ? Icons.menu_open : Icons.menu),
              onPressed: _toggleSidebar,
            ),
          ],
        ),
        leadingWidth: 104,
      ),
      body: Row(
        children: [
          _ParentSidebar(
            activeMenu: widget.activeMenu,
            collapsed: _collapsed,
            parentUserId: widget.parentUserId,
          ),
          // 본문
          Expanded(child: widget.content),
        ],
      ),
    );
  }
}

/// 좌측 사이드바 (메뉴만 간결히 표시)
class _ParentSidebar extends StatelessWidget {
  final String activeMenu;
  final bool collapsed;
  final String? parentUserId;

  const _ParentSidebar({
    required this.activeMenu,
    required this.collapsed,
    required this.parentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // 스타일
    const sideBg = Color(0xFFF5F5F5);
    const wCollapsed = 72.0;
    const wExpanded = 220.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: collapsed ? wCollapsed : wExpanded,
      color: sideBg,
      child: Column(
        crossAxisAlignment:
            collapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          const SizedBox(height: 8),

          // ✅ 메뉴 리스트 (공지사항/마이페이지/자녀페이지/문의사항/설정)
          Expanded(
            child: _MenuList(
              activeMenu: activeMenu, 
              collapsed: collapsed,
              parentUserId: parentUserId //추가
            ),
          ),
        ],
      ),
    );
  }
}

/// 메뉴 리스트 (현재 페이지는 초록 하이라이트)
class _MenuList extends StatelessWidget {
  final String activeMenu;
  final bool collapsed;
  final String? parentUserId; // ✅ 추가

  const _MenuList({required this.activeMenu, required this.collapsed, required this.parentUserId});

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(
        title: '공지사항',
        icon: Icons.campaign_outlined,
        destination: NoticePage(
          parentUserId: parentUserId,  // 전달

        ),
      ),
      _MenuItem(
        title: '마이페이지',
        icon: Icons.account_circle_outlined,
        destination: MyPage(
          parentUserId: parentUserId,  //전달
          
        ),
      ),
      _MenuItem(
        title: '자녀페이지',
        icon: Icons.family_restroom_outlined,
        // ⚠️ ChildrenPage가 필수 파라미터를 요구하면 아래처럼 실제 값 전달해 주세요.
        destination: ChildrenPage(
          parentUserId: parentUserId ?? '',          // ✅ 전달(빈문자열 폴백)
          parentDisplayName: '',                     
        ),
      ),
      _MenuItem(
        title: '문의사항',
        icon: Icons.mail_outline,
        destination: FaqPage(
          parentUserId: parentUserId,
        ),  //여기서부터는 하면서 넣을게
      ),
      _MenuItem(
        title: '설정',
        icon: Icons.settings_outlined,
        destination: psettings.SettingsPage(
          parentUserId: parentUserId,
        ),
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.only(
        left: collapsed ? 0 : 6,
        right: collapsed ? 0 : 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        final isActive = it.title == activeMenu;
        return _MenuTile(item: it, collapsed: collapsed, isActive: isActive);
      },
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget destination;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.destination,
  });
}

/// 단일 메뉴 타일
class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool collapsed;
  final bool isActive;

  const _MenuTile({
    required this.item,
    required this.collapsed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.green.shade600;

    final tile = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (!isActive) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.destination),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 0 : 8,
          vertical: 6,
        ),
        child: Row(
          mainAxisAlignment:
              collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            // 아이콘 + (활성 시) 초록 점
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isActive ? activeColor : Colors.black87,
                ),
                if (isActive)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? activeColor.withOpacity(0.08) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? activeColor : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return collapsed ? Tooltip(message: item.title, child: tile) : tile;
  }
}
