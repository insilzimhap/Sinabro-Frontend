import 'package:flutter/material.dart';

import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/mainView/page/user_select_screen.dart';
import 'package:sinabro/main/parentView/page/add_child.dart';

class SelectParentsPage extends StatelessWidget {
  const SelectParentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자녀 선택'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5), // 사이드바 색과 통일
        elevation: 0,
      ),
      body: Row(
        children: [
          // ✅ 공통 사이드바
          const ParentSidebar(activeMenu: '마이페이지'),

          // ✅ 오른쪽 콘텐츠
          Expanded(
            child: Container(
              color: const Color(0xFFE4F1FA), // 연파랑 배경
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ 이미지 삽입
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
                          'assets/img/icon/sorry.png', // ✅ 수정된 경로
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '아이를 추가하지 않으셨어요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddChildPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9DAB7),
                        foregroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        elevation: 6,
                      ),
                      child: const Text('아이 추가하기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
