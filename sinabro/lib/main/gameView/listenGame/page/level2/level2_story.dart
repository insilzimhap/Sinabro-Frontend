import 'package:flutter/material.dart';

/// 레벨2 스토리 페이지
/// - 꼬마요정 등장 → 대사 진행 → 마지막 컷에서 [도와주기] → onStoryEnd 호출
class Level2StoryPage extends StatefulWidget {
  final VoidCallback? onStoryEnd; // ✅ Flow 연결용 콜백

  const Level2StoryPage({super.key, this.onStoryEnd});

  @override
  State<Level2StoryPage> createState() => _Level2StoryPageState();
}

class _Level2StoryPageState extends State<Level2StoryPage> {
  int _step = 0;

  final List<Map<String, dynamic>> _stories = [
    {
      "image": "assets/img/contents/gameListen/level2/fairy_1.png",
      "dialogue": "안녕하세요! 저는 꼬마요정이라고 해요",
    },
    {
      "image": "assets/img/contents/gameListen/level2/fairy_2.png",
      "dialogue": "세상을 돌아다니면서 행운을 준답니다",
    },
    {
      "image": "assets/img/contents/gameListen/level2/fairy_3.png",
      "dialogue": "저를 도와주실래요?",
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
      backgroundColor: const Color(0xFFE8F5E9),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "꼬마요정\n${story["dialogue"]}",
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
