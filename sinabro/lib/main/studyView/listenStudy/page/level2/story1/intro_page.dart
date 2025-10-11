import 'package:flutter/material.dart';

class Level2IntroPage extends StatefulWidget {
  final VoidCallback onFinished; // ✅ 추가된 콜백
  const Level2IntroPage({super.key, required this.onFinished});

  @override
  State<Level2IntroPage> createState() => _Level2IntroPageState();
}

class _Level2IntroPageState extends State<Level2IntroPage> {
  final List<bool> _dustVisible = [true, true, true];
  int _pageIndex = 0;
  bool _showStartButton = false;

  final List<String> _messages = [
    "어라? 먼지 쌓인 무언가를 발견했어요\n먼지를 털어서 확인해볼까?",
    "우와! 우리 가족의 사진이네요~",
    "이번엔 우리 가족에 대해서 배워봐요!",
  ];

  void _clearDust(int index) {
    setState(() => _dustVisible[index] = false);

    if (_dustVisible.every((v) => v == false)) {
      setState(() => _pageIndex = 1);
      _startAfterDustCleared();
    }
  }

  void _startAfterDustCleared() async {
    await Future.delayed(const Duration(seconds: 5));
    setState(() => _pageIndex = 2);

    await Future.delayed(const Duration(seconds: 5));
    setState(() => _showStartButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🧡 텍스트
            Text(
              _messages[_pageIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 🖼️ 이미지
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/img/contents/studyListen/level2/family_frame.png",
                  height: 250,
                ),
                // 먼지
                if (_pageIndex == 0 && _dustVisible[0])
                  Positioned(
                    top: 40,
                    left: 60,
                    child: GestureDetector(
                      onTap: () => _clearDust(0),
                      child: Image.asset(
                        "assets/img/contents/studyListen/level2/dust.png",
                        height: 80,
                      ),
                    ),
                  ),
                if (_pageIndex == 0 && _dustVisible[1])
                  Positioned(
                    top: 100,
                    right: 70,
                    child: GestureDetector(
                      onTap: () => _clearDust(1),
                      child: Image.asset(
                        "assets/img/contents/studyListen/level2/dust.png",
                        height: 90,
                      ),
                    ),
                  ),
                if (_pageIndex == 0 && _dustVisible[2])
                  Positioned(
                    bottom: 50,
                    left: 100,
                    child: GestureDetector(
                      onTap: () => _clearDust(2),
                      child: Image.asset(
                        "assets/img/contents/studyListen/level2/dust.png",
                        height: 70,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // 🎬 시작하기 버튼
            if (_showStartButton)
              ElevatedButton(
                onPressed: widget.onFinished, // ✅ 콜백 실행
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[300],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "시작하기",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
