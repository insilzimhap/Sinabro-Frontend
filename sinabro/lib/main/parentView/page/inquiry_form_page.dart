// lib/main/parentView/inquiry/inquiry_form_page.dart

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart'; // ParentLayout 임포트
import 'package:file_picker/file_picker.dart'; // file_picker 패키지 임포트 (pubspec.yaml에 추가 필수!)
// import 'dart:io'; // 파일 경로 접근이 필요한 경우에만 필요하지만, PlatformFile 사용시 필수는 아님

class InquiryFormPage extends StatelessWidget {
  const InquiryFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      // '공지/문의 사항' 메뉴를 활성화된 상태로 보여주기 위해 activeMenu 설정
      activeMenu: '공지/문의 사항',
      content: const _InquiryFormContent(), // 페이지의 실제 내용을 담을 위젯 (const 추가)
    );
  }
}

class _InquiryFormContent extends StatefulWidget {
  const _InquiryFormContent(); // const 생성자 추가

  @override
  State<_InquiryFormContent> createState() => _InquiryFormContentState();
}

class _InquiryFormContentState extends State<_InquiryFormContent> {
  // 문의 내용을 위한 TextEditingController
  final TextEditingController _contentController = TextEditingController();
  List<PlatformFile> _attachedFiles = []; // 첨부된 파일 목록

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // 여러 파일 선택 허용
        type:
            FileType
                .any, // 모든 종류의 파일 허용 (image, video, audio, media, custom 등 선택 가능)
      );

      if (result != null) {
        setState(() {
          // 새로 선택된 파일들을 기존 리스트에 추가합니다.
          // 중복 첨부를 막으려면 여기서 file.name 등으로 필터링 로직을 추가할 수 있습니다.
          _attachedFiles.addAll(result.files);
        });
      } else {
        // 사용자가 파일 선택을 취소했습니다.
        // print('User canceled the picker');
      }
    } catch (e) {
      // 파일 선택 중 오류 발생 시 처리
      print('Error while picking the file: $e');
      // 사용자에게 오류 메시지를 표시할 수도 있습니다.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('파일 선택 중 오류가 발생했습니다: $e')));
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

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
            const Text(
              '새로운 문의 작성', // 제목 변경
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 작성일 및 작성자는 사용자가 작성하는 것이므로 이 페이지에서는 제거합니다.
            const SizedBox(height: 30),
            const Text(
              '내용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 5, // 여러 줄 입력 가능
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  // 테두리 스타일
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: '문의 내용을 입력해주세요.', // 힌트 텍스트
                contentPadding: const EdgeInsets.all(12.0), // 내부 패딩
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 정렬
              children: [
                const Text(
                  '첨부파일',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFiles, // 파일 선택 함수 호출
                  icon: const Icon(Icons.attach_file),
                  label: const Text('파일 첨부'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 첨부된 파일 목록을 표시합니다.
            if (_attachedFiles.isNotEmpty) // 첨부된 파일이 있을 때만 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _attachedFiles.map((file) {
                      final index = _attachedFiles.indexOf(file);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                file.name,
                                overflow:
                                    TextOverflow.ellipsis, // 파일 이름이 길면 ...으로 표시
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18), // 제거 아이콘
                              onPressed:
                                  () => _removeFile(index), // 파일 제거 함수 호출
                              color: Colors.red, // 제거 아이콘 색상
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            // 첨부 파일이 없을 때 메시지를 표시하고 싶다면
            if (_attachedFiles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '첨부된 파일이 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 실제 문의 내용 및 첨부 파일 처리 로직 구현 (서버 전송 등)
                  print('문의 내용: ${_contentController.text}');
                  for (var file in _attachedFiles) {
                    print('첨부 파일: ${file.name} (${file.size} bytes)');
                    // file.path를 통해 실제 파일 경로에 접근할 수 있습니다.
                    // 파일을 서버로 업로드하려면 해당 경로의 파일을 읽어 전송해야 합니다.
                  }
                  // 문의 제출 후 처리 (예: 성공 메시지 표시, 이전 페이지로 이동)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('문의가 제출되었습니다 (실제 기능은 미구현)')),
                  );
                  Navigator.pop(context); // 제출 후 이전 페이지로 돌아갈 수 있습니다.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 배경색
                  foregroundColor: Colors.white, // 버튼 글자색
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('문의 제출'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
