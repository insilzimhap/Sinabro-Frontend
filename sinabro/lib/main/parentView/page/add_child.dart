import 'package:flutter/material.dart';
import '../layout/parent_layout.dart';
import 'no_child_parent.dart'; // ← 돌아갈 페이지

class AddChildPage extends StatelessWidget {
  const AddChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ 공통 사이드바
          const ParentSidebar(activeMenu: '마이페이지'),

          // ✅ 오른쪽 콘텐츠 (배경 + 팝업 박스)
          Expanded(
            child: Container(
              color: const Color(0xFFE9DAB7),
              child: Stack(
                children: [
                  // ✅ 가운데 팝업 박스
                  Center(
                    child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ 상단 텍스트 + 닫기 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '지금 시나브로를 할 아이는 누구인가요?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
                                              const SelectParentsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // ✅ 아이 추가 버튼 영역
                          Column(
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('아이 추가', style: TextStyle(fontSize: 16)),
                            ],
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
