import 'package:flutter/material.dart';
import '../../../user_select/user_select_screen.dart';
import '../layout/parent_layout.dart';
import '../widget/child_tag.dart';

class ParentMainScreen extends StatelessWidget {
  const ParentMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ 공통 사이드바
          const ParentSidebar(activeMenu: '공지사항'),

          // ✅ 오른쪽 콘텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '공지사항',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),

                  // ✅ 오른쪽 상단 뒤로가기 버튼
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
