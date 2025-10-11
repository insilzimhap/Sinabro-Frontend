import 'dart:async';
import 'package:flutter/material.dart';
import 'model/routine_content.dart';

/// 🎞️ Story2 - 감정 스토리 페이지
/// 3개의 감정 스토리를 자동으로 순차 재생.
/// (탭하지 않아도 3~4초마다 다음 이미지로 넘어감)
class StoryPage extends StatefulWidget {
  final List<RoutineContent> data; // 3개의 스토리
  final VoidCallback onFinished; // 다음 감정으로 이동

  const StoryPage({
    super.key,
    required this.data,
    required this.onFinished,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < widget.data.length - 1) {
        setState(() => _currentIndex++);
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(seconds: 1), widget.onFinished);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.data[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ 이미지
              Image.asset(
                story.imagePath ?? "",
                width: MediaQuery.of(context).size.width * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // 🧠 텍스트
              Text(
                story.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 40),

              // 📍 진행 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.data.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i == _currentIndex ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? Colors.brown
                          : Colors.brown.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
