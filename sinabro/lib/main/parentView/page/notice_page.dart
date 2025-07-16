import 'package:flutter/material.dart';
import '../layout/parent_layout.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentLayout(
      activeMenu: '마이페이지',
      content: Center(
        child: Text(
          '공지 내용 없음',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
