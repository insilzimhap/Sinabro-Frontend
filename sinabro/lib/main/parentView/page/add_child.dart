import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/page/lobby_parent.dart';
import 'package:sinabro/main/parentView/page/add_child_form.dart';

class AddChildPage extends StatelessWidget {
  final String parentUserId;
  const AddChildPage({super.key, required this.parentUserId});


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = 180.0;
    final contentWidth = screenWidth - sidebarWidth;
    final popupWidth = contentWidth * 0.7; // 📌 너비 70%로 확대

    return Scaffold(
      appBar: AppBar(
        title: const Text('자녀 추가'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: Row(
        children: [
          const ParentSidebar(activeMenu: '마이페이지'),

          Expanded(
            child: Container(
              color: const Color(0xFFE4F1FA),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: popupWidth,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 237, 246, 225),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Center(
                                child: Text(
                                  '지금 시나브로를 할 아이는 누구인가요?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              SelectParentsPage(parentUserId: parentUserId),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // ✅ 아이 추가 버튼을 GestureDetector로 감쌈
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          AddChildFormPage(parentUserId: parentUserId,), // ✅ 폼 화면으로 이동
                                ),
                              );
                            },
                            child: Container(
                              width: 120,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text('아이 추가', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
