import 'package:flutter/material.dart';

class Level1ClearPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const Level1ClearPage({super.key, this.onComplete});

  @override
  State<Level1ClearPage> createState() => _Level1ClearPageState();
}

class _Level1ClearPageState extends State<Level1ClearPage> {
  int _index = 0;

  // ✅ 내부에서 대사 & 이미지 정의
  final List<Map<String, String>> _dialogues = [
    {
      'text': '와! 정말 잘했어요!',
      'image': 'assets/img/contents/gameListen/level1/clear_1.png',
    },
    {
      'text': '이제 다음 단계로 나아갈 준비가 되었네요!',
      'image': 'assets/img/contents/gameListen/level1/clear_2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final dialogue = _dialogues[_index];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Image.asset(
                  dialogue['image']!,
                  key: ValueKey(dialogue['image']),
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 32,
              right: 32,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(dialogue['text']),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6B443),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '양지',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dialogue['text'] ?? '',
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
            Positioned(
              right: 24,
              bottom: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (_index < _dialogues.length - 1) {
                    setState(() => _index++);
                  } else {
                    widget.onComplete?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6B443),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _index < _dialogues.length - 1 ? '다음' : '완료',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
