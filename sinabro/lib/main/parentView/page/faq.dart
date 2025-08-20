import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentLayout(
      activeMenu: '문의하기',
      content: FaqContent(), // 수정: FaqContent로 이름 변경
    );
  }
}

class FaqContent extends StatefulWidget {
  const FaqContent({super.key});

  @override
  State<FaqContent> createState() => _FaqContentState();
}

class _FaqContentState extends State<FaqContent> {
  int? _openedIndex;

  final List<Map<String, String>> notices = [
    {
      'title': '[육아처방전]#12 한 뿅, 두 뿅! 측정놀이로 기르는 우리 아이 수학 자신감',
      'date': '2025.05.11',
      'content':
          '측정놀이는 아이의 수 개념과 수학적 사고를 길러주는 중요한 놀이예요. 일상 속에서 길이, 무게, 시간 등을 재보며 즐겁게 수학을 익혀보세요!',
    },
    {
      'title': '[육아처방전]#11 유아 인지발달의 첫걸음, 분류 연습하기',
      'date': '2025.05.11',
      'content':
          '같은 속성끼리 물건을 분류하는 활동은 인지 능력 향상에 큰 도움이 됩니다. 모양, 색깔, 크기 등으로 정리하는 놀이를 추천해요!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tableMaxWidth = screenWidth - 24.0 * 2;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '새로운 소식을 확인해보세요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMaxWidth),
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(label: Expanded(flex: 1, child: Text('No'))),
                      DataColumn(label: Expanded(flex: 4, child: Text('제목'))),
                      DataColumn(label: Expanded(flex: 2, child: Text('작성일'))),
                      DataColumn(label: Expanded(flex: 2, child: Text('작성자'))),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('1')),
                        DataCell(Text('사용법 관련 문의')),
                        DataCell(Text('2025-05-11')),
                        DataCell(Text('박성민')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('2')),
                        DataCell(Text('자녀 계정 연동이 안돼요')),
                        DataCell(Text('2025-05-10')),
                        DataCell(Text('김다영')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('3')),
                        DataCell(Text('학습 리포트 오류 문의')),
                        DataCell(Text('2025-05-08')),
                        DataCell(Text('이준수')),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/parent/inquiry_form');
              },
              icon: const Icon(Icons.edit),
              label: const Text('문의하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
