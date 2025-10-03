import 'package:flutter/material.dart';

/// 레벨3 스토리 페이지
/// - 크크 등장 → 대사 진행 → 마지막 컷에서 [도와주기] → onStoryEnd 호출
class Level3StoryPage extends StatefulWidget {
  final VoidCallback? onStoryEnd; // ✅ Flow 연결용 콜백

  const Level3StoryPage({super.key, this.onStoryEnd});

  @override
  State<Level3StoryPage> createState() => _Level3StoryPageState();
}

class _Level3StoryPageState extends State<Level3StoryPage> {
  int _step = 0;

  final List<Map<String, dynamic>> _stories = [
    {
      "image": "assets/img/contents/gameListen/level3/kuku_1.png",
      "dialogue": "안녕하크! 나는 크크라고 하크!",
    },
    {
      "image": "assets/img/contents/gameListen/level3/kuku_2.png",
      "dialogue": "엄마의 심부름을 해야한다크!",
      "memo": "assets/img/contents/gameListen/level3/kuku_memo.png",
    },
    {
      "image": "assets/img/contents/gameListen/level3/kuku_3.png",
      "dialogue": "그치만 숫자를 못 센다크… 도와달라크!",
      "button": true,
    },
  ];

  void _nextStep() {
    if (_step < _stories.length - 1) {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_step];
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      body: SafeArea(
        child: Column(
          children: [
            const Align(alignment: Alignment.topLeft, child: BackButton()),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(story["image"], width: 220, height: 220),
                  const SizedBox(height: 16),
                  if (story["memo"] != null)
                    Image.asset(story["memo"], width: 180),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "크크\n${story["dialogue"]}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (story["button"] == true)
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onStoryEnd != null) {
                          widget.onStoryEnd!();
                        }
                      },
                      child: const Text("도와주기"),
                    )
                  else
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: const Text("다음"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
