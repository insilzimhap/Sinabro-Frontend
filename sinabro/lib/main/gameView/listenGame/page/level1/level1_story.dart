// lib/main/gameView/listenGame/page/level1/level1_story.dart
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_game.dart';

/// 레벨1 스토리 인트로 페이지
/// - 간단한 컷씬 → 버튼 클릭 시 게임 시작
class Level1StoryPage extends StatefulWidget {
  final int themeId;
  const Level1StoryPage({super.key, required this.themeId});

  @override
  State<Level1StoryPage> createState() => _Level1StoryPageState();
}

class _Level1StoryPageState extends State<Level1StoryPage> {
  int _step = 0;

  final List<Map<String, dynamic>> _storyData = [
    {
      "image": "assets/img/contents/gameListen/level1/yangji_story_1.png",
      "dialogue": "안녕하세요! 저는 양지라고 해요",
    },
    {
      "image": "assets/img/contents/gameListen/level1/yangji_story_2.png",
      "dialogue": "내일 마법 시험이 있는데 성공을 못해요",
    },
    {
      "image": "assets/img/contents/gameListen/level1/yangji_story_2.png",
      "dialogue": "저를 좀 도와주세요!",
      "showButton": true,
    },
  ];

  void _nextStep() {
    if (_step < _storyData.length - 1) {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _storyData[_step];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (!(current["showButton"] == true)) {
            _nextStep();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  current["image"],
                  fit: BoxFit.contain,
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC80),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "양지",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      current["dialogue"],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            if (current["showButton"] == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Level1GamePage(themeId: widget.themeId),
                      ),
                    );
                  },
                  child: const Text(
                    "도와주기",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
