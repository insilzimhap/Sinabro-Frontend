// lib/main/childView/page/sticker_book.dart
/*
 * StickerBookPage
 * - 하이라이트 제거된 단순한 도감 페이지
 * - 활성: $key{index}.png, 비활성: $key{index}_deactivation.png
 * - 하단 '홈으로' 버튼 (로비로 이동)
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/childView/data/sticker_progress.dart';
import 'package:sinabro/main/childView/data/sticker_progress_loader.dart';
import 'package:sinabro/main/childView/data/sticker_image_map.dart';
import 'package:sinabro/main/childView/model/sticker_model.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart';


class StickerBookPage extends StatefulWidget {
  final String childId;
  const StickerBookPage({super.key,required this.childId});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage>
    with TickerProviderStateMixin {
  final String nickname = "(닉네임)";
  final List<String> levels = ["1", "2", "3"];

  late Future<StickerProgress> _futureProgress;
  StickerProgress? _progress;

  final Map<String, Map<int, Offset>> stickerPositions = {
    "listen1": {
      0: Offset(80, 130),
      1: Offset(260, 120),
      2: Offset(380, 120),
      3: Offset(60, 475),
      4: Offset(390, 475)
    },
    "write1": {
      0: Offset(60, 60),
      1: Offset(280, 160),
      2: Offset(50, 480),
      3: Offset(320, 400)
    },
    "listen2": {
      0: Offset(60, 380),
      1: Offset(180, 470),
      2: Offset(260, 350),
      3: Offset(40, 190),
      4: Offset(450, 360)
    },
    "write2": {
      0: Offset(214, 100),
      1: Offset(206, 150),
      2: Offset(210, 250),
      3: Offset(210, 320),
    },
    "listen3": {
      0: Offset(50, 200),
      1: Offset(350, 240),
      2: Offset(200, 400),
      3: Offset(470, 460),
    },
    "write3": {
      0: Offset(50, 280),
      1: Offset(200, 280),
      2: Offset(350, 315),
      3: Offset(480, 310),
    },
  };

  @override
  void initState() {
    super.initState();
    _futureProgress = StickerProgressLoader.load(widget.childId);
  }


  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final leftKey = "listen${levels[currentIndex]}"; //듣기 도감
    final rightKey = "write${levels[currentIndex]}"; //쓰기 도감

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D0),
      body: FutureBuilder<StickerProgress>(
        future: _futureProgress,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('로드 실패: ${snapshot.error}'));
          }

          _progress = snapshot.data;
          if (_progress == null) {
            return const Center(child: Text('데이터를 불러올 수 없습니다.'));
          }



      return Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              "$nickname님의 학습도감",
              style: const TextStyle(
                fontSize: 82,
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
      );
        },
      ),
    );
  }

  /// ---------------------------------------------------------------------------
  /// 🧩 도감 하나 렌더링 (예: listen1, write2 ...)
  /// ---------------------------------------------------------------------------
  Widget _buildPage(String key) {
    final dexId = key.startsWith("listen")
        ? "DEX_LS_0${key.replaceAll(RegExp(r'listen'), '')}"
        : "DEX_WR_0${key.replaceAll(RegExp(r'write'), '')}";

     // 널 안전하게 로컬 리스트로 받아서 sort
    final List<Sticker> stickers = _progress?.allStickers.values
            .where((s) => s.dexId == dexId)
            .toList() ??
        [];
    stickers.sort((a, b) => a.sequenceInDex.compareTo(b.sequenceInDex));

    if (stickers.isEmpty) {
      return Container(
        width: 410,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text("데이터 없음 ($dexId)")),
      );
    }

    return Container(
      width: 615,
      height: 675,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/img/contents/stickerBook/$key.png",
              fit: BoxFit.cover,
            ),
          ),
          for (int i = stickers.length - 1; i >= 0; i--)
            _buildSticker(key, stickers[i], i),
        ],
      ),
    );
  }

  /// ---------------------------------------------------------------------------
  /// 🧷 스티커 활성/비활성 표시
  /// ---------------------------------------------------------------------------
  Widget _buildSticker(String key, Sticker sticker, int index) {
    final entry = stickerImageMap[sticker.stickerId];
    if (entry == null) {
      debugPrint('⚠️ 이미지 매핑 없음: ${sticker.stickerId}');
      return const SizedBox.shrink();
    }

    final offset = stickerPositions[key]?[index] ?? const Offset(0, 0);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Image.asset(
        sticker.isObtained ? entry.active : entry.inactive,
        height: 200,
      ),
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
