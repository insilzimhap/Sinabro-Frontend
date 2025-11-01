/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 3 인트로 페이지]
 *  - 도움을 요청하는 스토리형식 페이지
 *  - <도와주기> 버튼을 통해 테마 페이지로 이동
 * ----------------------------------------------------------------
 */

// lib/main/studyView/gameListen/page/level3/intro_page.dart
import 'package:flutter/material.dart';

class Level3IntroPage extends StatefulWidget {
  final VoidCallback? onNext;
  const Level3IntroPage({super.key, this.onNext});

  @override
  State<Level3IntroPage> createState() => _Level3IntroPageState();
}

class _Level3IntroPageState extends State<Level3IntroPage> {
  int _step = 0;

  final List<Map<String, String>> dialogues = [
    {
      'name': '크크',
      'text': '안녕하크! 나는 크크라고 하크!',
      'image': 'assets/img/contents/gameListen/level3/kuku_story1.png',
    },
    {
      'name': '크크',
      'text': '엄마의 심부름을 해야한다크!',
      'image': 'assets/img/contents/gameListen/level3/kuku_story1.png',
    },
    {
      'name': '크크',
      'text': '그치만 숫자를 못 센다크... 도와달라크!',
      'image': 'assets/img/contents/gameListen/level3/kuku_story2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = dialogues[_step];

    return Scaffold(
      backgroundColor: const Color(0xFFB9EEFF), // 하늘색 배경
      body: SafeArea(
        child: Stack(
          children: [
            // 🦈 캐릭터 이미지
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  current['image']!,
                  key: ValueKey(current['image']),
                  width: MediaQuery.of(context).size.width * 0.5,
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
                    color: const Color(0xFFFFE5E5), // 연핑크
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA8B0),
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

            // 📜 두 번째 컷에만: 심부름 리스트 메모 표시
            if (_step == 1)
              Positioned(
                right: 60,
                top: 200,
                child: AnimatedOpacity(
                  opacity: _step == 1 ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('크크에게', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('□ 문어 3마리'),
                        Text('□ 생선 7마리'),
                        Text('□ 사과 2개'),
                        Text('□ 포도 10개'),
                        SizedBox(height: 8),
                        Text('꼭 사와야한다크~! ^^',
                            style: TextStyle(color: Colors.grey)),
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
                    color: Colors.pink),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 🩷 다음 / 도와주기 버튼
            Positioned(
              right: 24,
              bottom: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: (_step < dialogues.length - 1)
                    ? ElevatedButton(
                        key: const ValueKey('next'),
                        onPressed: () => setState(() => _step++),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA8B0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('다음'),
                      )
                    : ElevatedButton(
                        key: const ValueKey('help'),
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.pink, width: 2),
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
