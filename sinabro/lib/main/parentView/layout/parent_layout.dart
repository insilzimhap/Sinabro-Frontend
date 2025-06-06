import 'package:flutter/material.dart';
import '../widget/child_tag.dart'; // 공통 자녀 태그 불러오기

// ✅ 공통 사이드바만 쓰고 싶을 때 이걸 불러와!
class ParentSidebar extends StatelessWidget {
  final String activeMenu;

  const ParentSidebar({super.key, required this.activeMenu});

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: const [
                ChildTag(label: '성민콩', color: Color(0xFFB5E5B8)),
                ChildTag(label: '세로이', color: Color(0xFFD6D6D6)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuItem('마이페이지', activeMenu == '마이페이지'),
          _buildMenuItem('학습리포트', activeMenu == '학습리포트'),
          _buildMenuItem('공지사항', activeMenu == '공지사항'),
          _buildMenuItem('문의하기', activeMenu == '문의하기'),
          _buildMenuItem('설정', activeMenu == '설정'),
        ],
      ),
    );
  }

  static Widget _buildMenuItem(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.green : Colors.black,
        ),
      ),
    );
  }
}

// ✅ 고정 레이아웃 통으로 감쌀 때는 이걸 사용해도 됨 (선택사항)
class ParentLayout extends StatelessWidget {
  final Widget content;
  final String activeMenu;

  const ParentLayout({
    super.key,
    required this.content,
    required this.activeMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ParentSidebar(activeMenu: activeMenu),
          Expanded(child: content),
        ],
      ),
    );
  }
}
