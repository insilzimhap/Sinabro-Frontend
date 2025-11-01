/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1 인트로 페이지]
 *  - 도움을 요청하는 스토리형식 페이지
 *  - <도와주기> 버튼을 통해 테마 페이지로 이동
 * ----------------------------------------------------------------
 */


// lib/main/studyView/gameListen/page/level1/intro_page.dart
import 'package:flutter/material.dart';

class Level1IntroPage extends StatefulWidget {
  final VoidCallback? onNext;
  const Level1IntroPage({super.key, this.onNext});

  @override
  State<Level1IntroPage> createState() => _Level1IntroPageState();
}

class _Level1IntroPageState extends State<Level1IntroPage>
    with SingleTickerProviderStateMixin {
  int _step = 0;

  // 각 컷의 대사 데이터
  final List<Map<String, String>> dialogues = [
    {
      'name': '양지',
      'text': '안녕하세요! 저는 양지라고 해요',
      'image': 'assets/img/contents/gameListen/level1/yangji_story_1.png',
    },
    {
      'name': '양지',
      'text': '내일 마법 시험이 있는데 성공을 못해요',
      'image': 'assets/img/contents/gameListen/level1/yangji_story_2.png',
    },
    {
      'name': '양지',
      'text': '저를 좀 도와주세요!',
      'image': 'assets/img/contents/gameListen/level1/yangji_story_2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = dialogues[_step];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 🐑 캐릭터 이미지
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  current['image']!,
                  key: ValueKey(current['image']),
                  width: MediaQuery.of(context).size.width * 0.45,
                ),
              ),
            ),

            // 💬 말풍선 (캐릭터명 + 대사)
            Positioned(
              top: 80,
              left: 40,
              right: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey(current['text']),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC067),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          current['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current['text']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A3E1B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ⬅️ 뒤로가기 버튼
            Positioned(
              top: 20,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.brown),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 🟡 다음 컷 / 도와주기 버튼
            Positioned(
              right: 24,
              bottom: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: (_step < dialogues.length - 1)
                    ? ElevatedButton(
                        key: const ValueKey('next'),
                        onPressed: () {
                          setState(() => _step++);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE27A),
                          foregroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('다음'),
                      )
                    : ElevatedButton(
                        key: const ValueKey('help'),
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE27A),
                          foregroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('도와주기'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  