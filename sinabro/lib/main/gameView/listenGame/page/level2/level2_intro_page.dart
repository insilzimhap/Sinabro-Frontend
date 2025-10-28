// lib/main/gameView/listenGame/page/level2/level2_intro_page.dart
import 'package:flutter/material.dart';

class Level2IntroPage extends StatefulWidget {
  final VoidCallback? onNext;
  const Level2IntroPage({super.key, this.onNext});
  

  @override
  State<Level2IntroPage> createState() => _Level2IntroPageState();
}

class _Level2IntroPageState extends State<Level2IntroPage> {
  int _step = 0;

  final List<Map<String, String>> dialogues = [
    {
      'name': '꼬마요정',
      'text': '안녕하세요! 저는 꼬마요정이라고 해요',
      'image': 'assets/img/contents/gameListen/level2/fairy_story_1.png',
    },
    {
      'name': '꼬마요정',
      'text': '세상을 돌아다니면서 행운을 준답니다',
      'image': 'assets/img/contents/gameListen/level2/fairy_story_1.png',
    },
    {
      'name': '꼬마요정',
      'text': '저를 도와주실래요?',
      'image': 'assets/img/contents/gameListen/level2/fairy_story_1.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = dialogues[_step];

    return Scaffold(
      backgroundColor: const Color(0xFFD5FCDE),
      body: SafeArea(
        child: Stack(
          children: [
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
            Positioned(
              top: 80,
              left: 40,
              right: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey(current['text']),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6DBE78),
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
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2E6B3D)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: (_step < dialogues.length - 1)
                    ? OutlinedButton(
                        key: const ValueKey('next'),
                        onPressed: () => setState(() => _step++),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E6B3D), width: 2),
                          foregroundColor: const Color(0xFF2E6B3D),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('다음'),
                      )
                    : OutlinedButton(
                        key: const ValueKey('help'),
                        onPressed: widget.onNext,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E6B3D), width: 2),
                          foregroundColor: const Color(0xFF2E6B3D),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
