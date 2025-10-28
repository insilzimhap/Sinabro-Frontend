import 'package:flutter/material.dart';
import 'package:page_turn/page_turn.dart'; // pubspec.yaml에 추가 필요

class LearningAlbumPage extends StatefulWidget {
  const LearningAlbumPage({Key? key}) : super(key: key);

  @override
  State<LearningAlbumPage> createState() => _LearningAlbumPageState();
}

class _LearningAlbumPageState extends State<LearningAlbumPage> with TickerProviderStateMixin {
  final _controller = GlobalKey<PageTurnState>();

  // 각 페이지 정보 (레벨 + 모드)
  final List<Map<String, String>> levels = [
    {"level": "1", "mode": "듣기"},
    {"level": "1", "mode": "쓰기"},
    {"level": "2", "mode": "듣기"},
    {"level": "2", "mode": "쓰기"},
    {"level": "3", "mode": "듣기"},
    {"level": "3", "mode": "쓰기"},
  ];

  // 각 페이지별 스티커 개수
  final Map<String, int> stickerCount = {
    "1_듣기": 5,
    "1_쓰기": 5,
    "2_듣기": 5,
    "2_쓰기": 4,
    "3_듣기": 4,
    "3_쓰기": 4,
  };

  // 스티커 좌표 (자유롭게 조정 가능)
  final Map<String, Map<int, Offset>> stickerPositions = {
    "1_듣기": {0: Offset(40, 90), 1: Offset(120, 100), 2: Offset(210, 160), 3: Offset(60, 220), 4: Offset(180, 260)},
    "1_쓰기": {0: Offset(50, 120), 1: Offset(130, 160), 2: Offset(200, 190), 3: Offset(80, 230), 4: Offset(160, 260)},
    "2_듣기": {0: Offset(30, 80), 1: Offset(130, 120), 2: Offset(220, 160), 3: Offset(60, 230), 4: Offset(180, 260)},
    "2_쓰기": {0: Offset(50, 90), 1: Offset(140, 130), 2: Offset(200, 190), 3: Offset(100, 240)},
    "3_듣기": {0: Offset(40, 100), 1: Offset(140, 130), 2: Offset(200, 200), 3: Offset(100, 260)},
    "3_쓰기": {0: Offset(60, 90), 1: Offset(150, 150), 2: Offset(210, 210), 3: Offset(120, 260)},
  };

  // TODO: AWS 백엔드에서 획득 여부 데이터 불러올 예정
  final Map<String, List<bool>> stickerUnlocked = {
    "1_듣기": [true, true, false, false, false],
    "1_쓰기": [true, false, true, false, false],
    "2_듣기": [true, false, false, false, false],
    "2_쓰기": [false, false, false, false],
    "3_듣기": [false, false, false, false],
    "3_쓰기": [false, false, false, false],
  };

  // TODO: AWS 백엔드에서 닉네임 받아오기
  final String nickname = "(닉네임)"; // 예: "홍길동"

  // 페이지 리스트 (배경 + 스티커)
  late final List<Widget> pages = [
    for (var page in levels)
      _buildBookPage(page["level"]!, page["mode"]!),
  ];

  static Widget _whitePage() => Container(color: Colors.white);

  // 화살표 제어
  void _nextPage() => _controller.currentState?.nextPage(duration: const Duration(milliseconds: 800));
  void _previousPage() => _controller.currentState?.previousPage(duration: const Duration(milliseconds: 800));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D0),
      body: Stack(
        children: [
          // 실제 책 넘김 효과
          PageTurn(
            key: _controller,
            backgroundColor: Colors.white,
            showDragCutoff: false,
            lastPage: _whitePage(),
            children: pages,
          ),

          // 왼쪽 화살표
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 30),
              onPressed: _previousPage,
            ),
          ),

          // 오른쪽 화살표
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 30),
              onPressed: _nextPage,
            ),
          ),
        ],
      ),
    );
  }

  // 도감 페이지 생성
  Widget _buildBookPage(String level, String mode) {
    final key = "${level}_${mode}";
    final stickerNum = stickerCount[key] ?? 0;
    final prefix = mode == "듣기" ? "listen" : "write";

    return Stack(
      children: [
        // 페이지 배경
        Positioned.fill(
          child: Image.asset(
            "img/contents/(폴더명)/$prefix$level.png",
            fit: BoxFit.contain,
          ),
        ),

        // 닉네임 텍스트
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "$nickname님의 학습도감 ($mode $level레벨)",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
          ),
        ),

        // 스티커들
        for (int i = 0; i < stickerNum; i++)
          _buildSticker(key, prefix, level, i),
      ],
    );
  }

  Widget _buildSticker(String key, String prefix, String level, int index) {
    final unlocked = stickerUnlocked[key]?[index] ?? false;
    final offset = stickerPositions[key]?[index] ?? const Offset(0, 0);
    final stickerPath = "img/contents/(폴더명)/stickers/$prefix${level}${index + 1}.png";

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    final animation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: unlocked
            ? () async {
                await controller.forward();
                await controller.reverse();
                showOverlayEffect(context, offset);
              }
            : null,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: Image.asset(
                stickerPath,
                width: 50,
                fit: BoxFit.contain,
                color: unlocked ? null : Colors.black.withOpacity(0.9),
                colorBlendMode: unlocked ? BlendMode.dst : BlendMode.srcATop,
              ),
            );
          },
        ),
      ),
    );
  }

  // 스티커 클릭 시 5초간 반짝이는 후광 효과
  void showOverlayEffect(BuildContext context, Offset pos) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: pos.dx - 20,
        top: pos.dy - 20,
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.yellow.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 5), () => entry.remove());
  }
}