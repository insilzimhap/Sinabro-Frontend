// lib/main/studyView/listenStudy/level2/story2/intro_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'data/routine_data.dart';

class Story2IntroPage extends StatefulWidget {
  final VoidCallback onNext;
  const Story2IntroPage({super.key, required this.onNext});

  @override
  State<Story2IntroPage> createState() => _Story2IntroPageState();
}

class _Story2IntroPageState extends State<Story2IntroPage> {
  Timer? _timer;
  bool _canTap = false;

  @override
  void initState() {
    super.initState();
    // 5초 뒤 → 터치 가능
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _canTap = true);
    });
    // 20초 뒤 → 자동 진행
    _timer = Timer(const Duration(seconds: 20), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_canTap) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final intro = introData.first;
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(intro.imagePath ?? "", width: 240),
              const SizedBox(height: 24),
              Text(intro.text, style: const TextStyle(fontSize: 20)),
              if (!_canTap)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text("잠시만 기다려주세요...",
                      style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
