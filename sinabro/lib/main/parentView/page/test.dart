// 듣기 학습 기능 흐름 구현 (시나브로)
// 참고 이미지 기반 화면 흐름도 및 조건 검색 구조 반영

import 'package:flutter/material.dart';

class ListeningStudyFlow extends StatelessWidget {
  const ListeningStudyFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('듣기 학습 흐름 예시')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1️⃣ 상황 및 학습 유형 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTagBox('상황', ['집', '학교', '놀이터']),
                const SizedBox(width: 16),
                _buildTagBox('학습 유형', ['의성어/의태어', '일상회화']),
              ],
            ),
            const SizedBox(height: 24),
            const Text('2️⃣ 듣기 콘텐츠 불러오기 (DB 연동)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('listening_contents 테이블에서 조건에 맞는 콘텐츠 불러오기'),
            const SizedBox(height: 16),
            const Text('• 배경 이미지: 상황 기반 이미지 (DALL·E)'),
            const Text('• 학습 이미지: 클릭 가능한 요소들 (DALL·E)'),
            const Text('• 스토리 텍스트: 상황별 문장/대화 (GPT)'),
            const Text('• 음성 파일: 요소별 mp3 (Google TTS)'),
            const SizedBox(height: 24),
            const Text('3️⃣ 학습 화면 동작',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• 버튼 클릭 시 TTS 재생'),
            const Text('• 재생 완료 후 버튼 사라짐'),
            const Text('• 모든 버튼 클릭 시 학습 완료 처리'),
          ],
        ),
      ),
    );
  }

  Widget _buildTagBox(String title, List<String> tags) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
