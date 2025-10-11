import 'package:flutter/material.dart';
import 'model/routine_content.dart';

class StoryPage extends StatefulWidget {
  final List<RoutineContent> stories; // 숫자-손-과일 순
  final VoidCallback onFinished;

  const StoryPage({
    super.key,
    required this.stories,
    required this.onFinished,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    await _fadeController.reverse(); // 페이드 아웃
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      await _fadeController.forward(); // 다음 페이지 페이드 인
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _nextPage,
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🖼 이미지
                  Image.asset(
                    story.imagePath ?? "",
                    width: MediaQuery.of(context).size.height * 0.45,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),

                  // 📝 텍스트
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      story.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 📍 안내 문구
                  const Text(
                    "화면을 터치하면 다음으로 넘어갑니다",
                    style: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
