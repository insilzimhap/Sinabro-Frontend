import 'package:flutter/material.dart';
import '../layout/parent_layout.dart';

class StudyReportPage extends StatelessWidget {
  const StudyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentLayout(
      activeMenu: '학습리포트',
      content: Center(
        child: Text(
          '학습리포트 내용 없음',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
