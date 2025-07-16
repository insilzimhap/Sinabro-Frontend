import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/user_select_screen.dart'; // ✅ 뒤로가기용
import '../widget/child_tag.dart';
import '../page/mypage.dart';
import '../page/study_report.dart';
import '../page/notice_page.dart';
import '../page/faq.dart';
import '../page/setting.dart';

class ParentLayout extends StatelessWidget {
  final String activeMenu;
  final Widget content;

  const ParentLayout({
    super.key,
    required this.activeMenu,
    required this.content,
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
          ParentSidebar(activeMenu: activeMenu),
          Expanded(child: content),
        ],
      ),
    );
  }
}

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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                ChildTag(label: '성민콩', color: Color(0xFFB5E5B8)),
                ChildTag(label: '세로이', color: Color(0xFFD6D6D6)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuItem(
              context, '마이페이지', activeMenu == '마이페이지', const MyPage()),
          _buildMenuItem(
              context, '학습리포트', activeMenu == '학습리포트', const StudyReportPage()),
          _buildMenuItem(
              context, '공지사항', activeMenu == '공지사항', const NoticePage()),
          _buildMenuItem(
              context, '문의하기', activeMenu == '문의하기', const FaqPage()),
          _buildMenuItem(
              context, '설정', activeMenu == '설정', const SettingsPage()),
        ],
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
