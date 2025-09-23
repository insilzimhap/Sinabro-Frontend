import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';
import 'level1_game.dart';

class Level1StoryPage extends StatefulWidget {
  const Level1StoryPage({super.key});

  @override
  State<Level1StoryPage> createState() => _Level1StoryPageState();
}

class _Level1StoryPageState extends State<Level1StoryPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<_StoryData> _stories = [
    _StoryData(
      imagePath: "assets/img/contents/gameListen/level1/yangji_story_1.png",
      dialogue: "안녕하세요! 저는 양지라고 해요",
    ),
    _StoryData(
      imagePath: "assets/img/contents/gameListen/level1/yangji_story_2.png",
      dialogue: "내일 마법 시험이 있는데 성공을 못했어요",
    ),
    _StoryData(
      imagePath: "assets/img/contents/gameListen/level1/yangji_story_2.png",
      dialogue: "저를 좀 도와주세요!",
      showButton: true,
    ),
  ];

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: story.showButton ? null : _nextStory,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _buildStoryCard(story, key: ValueKey(story.dialogue)),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(_StoryData story, {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 캐릭터 이미지 (등장 시 확대 효과)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Image.asset(story.imagePath, width: 240, height: 240),
        ),
        const SizedBox(height: 20),

        // 대사창 (살짝 흔들리는 애니메이션)
        TweenAnimationBuilder<Offset>(
          tween: Tween(begin: const Offset(0, 0.1), end: const Offset(0, 0)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          builder: (context, offset, child) => Transform.translate(
            offset: offset * 20,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEED7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEC186)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Text(
              story.dialogue,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // 마지막 컷에서 "도와주기" 버튼 표시 (애니메이션 효과)
        if (story.showButton) ...[
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEC186),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListenGameTransition(
                      nextPage: Level1GamePage(),
                    ),
                  ),
                );
              },
              child: const Text(
                "도와주기",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}

/// 내부 데이터 클래스
class _StoryData {
  final String imagePath;
  final String dialogue;
  final bool showButton;

  const _StoryData({
    required this.imagePath,
    required this.dialogue,
    this.showButton = false,
  });
}
