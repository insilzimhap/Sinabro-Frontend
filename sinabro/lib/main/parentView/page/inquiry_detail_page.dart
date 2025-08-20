import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart'; // ParentLayout 임포트

// Inquiry 클래스 정의
// 이 클래스는 모든 문의 관련 파일에서 동일하게 사용되어야 합니다.
class Inquiry {
  final int id;
  final String title;
  final String date;
  final String author;
  final String content;
  final List<String> attachments; // 첨부 파일 경로 (예시용, 실제는 URL이나 로컬 경로)

  // const 생성자를 사용하여 Inquiry 객체를 불변(immutable)하게 만듭니다.
  const Inquiry({
    required this.id,
    required this.title,
    required this.date,
    required this.author,
    required this.content,
    this.attachments = const [], // 기본값으로 빈 리스트를 가집니다.
  });
}

class InquiryDetailPage extends StatelessWidget {
  final Inquiry inquiry; // 표시할 문의 객체

  // const 생성자를 사용하여 위젯을 불변하게 만듭니다.
  const InquiryDetailPage({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      // '공지/문의 사항' 메뉴를 활성화된 상태로 보여주기 위해 activeMenu 설정
      activeMenu: '공지/문의 사항',
      content:
          _InquiryDetailContent(inquiry: inquiry), // 실제 내용을 담을 위젯에 문의 객체 전달
    );
  }
}

class _InquiryDetailContent extends StatelessWidget {
  final Inquiry inquiry; // 표시할 문의 객체

  // const 생성자를 사용하여 위젯을 불변하게 만듭니다.
  const _InquiryDetailContent({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        // 내용이 길어질 경우 스크롤 가능하도록 SingleChildScrollView 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // 뒤로가기 버튼
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('BACK'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // 텍스트 색상
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              inquiry.title, // 문의 제목
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '작성일: ${inquiry.date}', // 작성일
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              '작성자: ${inquiry.author}', // 작성자
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              '내용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, // 부모 너비에 맞춤
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300), // 테두리
                borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
              ),
              child: Text(
                inquiry.content, // 문의 내용
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            if (inquiry.attachments.isNotEmpty) // 첨부파일이 있을 경우에만 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '첨부파일',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: inquiry.attachments.map((fileName) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileName
                                    .split('/')
                                    .last, // 파일 경로에서 파일 이름만 추출하여 표시
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (inquiry.attachments.isEmpty) // 첨부파일이 없을 경우 메시지 표시
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '첨부된 파일이 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 30),
            // 이곳에 '수정' 또는 '삭제' 버튼을 추가할 수 있습니다.
            // 예시:
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // TODO: 수정 기능 구현
            //     },
            //     child: const Text('수정'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
