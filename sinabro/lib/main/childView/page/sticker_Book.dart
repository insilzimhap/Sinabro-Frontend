// lib/main/childView/page/sticker_book.dart
/*
 * StickerBookPage
 * - 하이라이트 제거된 단순한 도감 페이지
 * - 활성: $key{index}.png, 비활성: $key{index}_deactivation.png
 * - 하단 '홈으로' 버튼 (로비로 이동)
 */

import 'package:flutter/material.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({super.key});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage>
    with TickerProviderStateMixin {
  final String nickname = "(닉네임)";
  final List<String> levels = ["1", "2", "3"];

  // 실제로는 백엔드에서 받아올 데이터로 대체하세요
  final Map<String, List<bool>> stickerUnlocked = {
    "listen1": [true, true, false, false, false],
    "write1": [true, false, true, false, false],
    "listen2": [true, false, false, false, false],
    "write2": [false, false, false, false],
    "listen3": [false, false, false, false],
    "write3": [false, false, false, false],
  };

  final Map<String, int> stickerCount = {
    "listen1": 5,
    "write1": 4,
    "listen2": 5,
    "write2": 4,
    "listen3": 4,
    "write3": 4,
  };

  final Map<String, Map<int, Offset>> stickerPositions = {
    "listen1": {
      0: Offset(40, 90),
      1: Offset(120, 100),
      2: Offset(210, 160),
      3: Offset(60, 220),
      4: Offset(180, 260)
    },
    "write1": {
      0: Offset(50, 120),
      1: Offset(130, 160),
      2: Offset(200, 190),
      3: Offset(80, 230),
      4: Offset(160, 260)
    },
    "listen2": {
      0: Offset(40, 90),
      1: Offset(120, 100),
      2: Offset(210, 160),
      3: Offset(60, 220),
      4: Offset(180, 260)
    },
    "write2": {
      0: Offset(50, 120),
      1: Offset(130, 160),
      2: Offset(200, 190),
      3: Offset(80, 230),
      4: Offset(160, 260)
    },
    "listen3": {
      0: Offset(40, 90),
      1: Offset(120, 100),
      2: Offset(210, 160),
      3: Offset(60, 220),
      4: Offset(180, 260)
    },
    "write3": {
      0: Offset(50, 120),
      1: Offset(130, 160),
      2: Offset(200, 190),
      3: Offset(80, 230),
      4: Offset(160, 260)
    },
  };

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final leftKey = "listen${levels[currentIndex]}";
    final rightKey = "write${levels[currentIndex]}";

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D0),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              "$nickname님의 학습도감",
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPage(leftKey),
                      const SizedBox(width: 30),
                      _buildPage(rightKey),
                    ],
                  ),
                  Positioned(left: 40, child: _arrowButton(Icons.arrow_back_ios, _previousSet)),
                  Positioned(right: 40, child: _arrowButton(Icons.arrow_forward_ios, _nextSet)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String key) {
    final stickerNum = stickerCount[key] ?? 0;

    return Container(
      width: 410,
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/img/contents/stickerBook/$key.png", fit: BoxFit.cover),
          ),
          for (int i = 0; i < stickerNum; i++) _buildSticker(key, i),
        ],
      ),
    );
  }

  Widget _buildSticker(String key, int index) {
    final unlocked = stickerUnlocked[key]?[index] ?? false;
    final offset = stickerPositions[key]?[index] ?? const Offset(0, 0);
    final base = "assets/img/contents/stickerBook/stickers";
    final stickerPath = unlocked
        ? "$base/$key${index + 1}.png"
        : "$base/${key}${index + 1}_deactivation.png";

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Image.asset(stickerPath, width: 50),
    );
  }

  void _nextSet() {
    if (currentIndex < levels.length - 1) setState(() => currentIndex++);
  }

  void _previousSet() {
    if (currentIndex > 0) setState(() => currentIndex--);
  }

  Widget _arrowButton(IconData icon, VoidCallback onPressed) {
    return IconButton(icon: Icon(icon, size: 32, color: Colors.brown), onPressed: onPressed);
  }
}
