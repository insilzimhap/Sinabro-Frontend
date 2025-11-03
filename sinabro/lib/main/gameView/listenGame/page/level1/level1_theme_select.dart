/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 챕터1(나무1=레벨1=ST007) 테마 선택 화면]
 *  - 챕터(레벨 1)의 테마(열매) 5개 중 하나를 선택하는 페이지
 *  - 각 테마 이미지를 터치하면 해당 테마(열매)의 게임 실행 페이지로 이동
 * 
 * < 레벨 1 > - ST007
 * 테마1 - FR_LG_001
 * 테마2 - FR_LG_002
 * 테마3 - FR_LG_003
 * 테마4 - FR_LG_004
 * 테마5 - FR_LG_005
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';

// 🔹 공통 상태/API import
import 'package:sinabro/main/gameView/writeGame/api/fruit_state.dart';
import 'package:sinabro/main/gameView/writeGame/api/child_game_api.dart';

import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart'; // ✅ 추가 (이미지 매핑)

class Level1ThemeSelectPage extends StatefulWidget {
  //changed: Stateful로 변경
  final Function(int) onThemeSelected;
  final String childId;

  const Level1ThemeSelectPage({
    super.key,
    required this.onThemeSelected,
    required this.childId,
  });

  static const String stageId = 'ST007'; // 듣기게임 나무1(Stage 1)

  @override
  State<Level1ThemeSelectPage> createState() =>
      _Level1ThemeSelectPageState(); //changed
}

class _Level1ThemeSelectPageState extends State<Level1ThemeSelectPage> {
  //changed
  late Future<TreeProgress> _progressFuture; //changed

  @override
  void initState() {
    super.initState();
    _progressFuture = TreeProgressLoader.load('listening_game');
  }

  @override
  Widget build(BuildContext context) {
    final themes = List.generate(
      5,
      (i) => 'assets/img/contents/gameListen/level1/theme/theme_${i + 1}.png',
    );

    final rects = [
      const Rect.fromLTWH(40, 120, 100, 100), // 1번 위치
      const Rect.fromLTWH(160, 90, 100, 100), // 2번 위치
      const Rect.fromLTWH(280, 140, 100, 100), // 3번 위치
      const Rect.fromLTWH(100, 260, 100, 100), // 4번 위치
      const Rect.fromLTWH(230, 280, 100, 100), // 5번 위치 (특별)
    ];

    // ✅ fruitId 매핑 (열매별로 start 요청 구분용)
    final fruitIds = [
      'FR_LG_001',
      'FR_LG_002',
      'FR_LG_003',
      'FR_LG_004',
      'FR_LG_005',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: FutureBuilder<TreeProgress>(
          //추가
          future: _progressFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final progress = snapshot.data!;
            return Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFB05E2E),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 왼쪽 책 → theme_1.png (열매 FR_LG_001, 기본색상)
                _ThemeButton(
                  rect: rects[0],
                  fruitId: fruitIds[0],
                  semanticLabel: '왼쪽 책',
                  isActive: progress.isFruitActive(fruitIds[0]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[0])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[0], 0);
                  },
                ),

                // 중앙 위 책 → theme_2.png (열매 FR_LG_002, 심화색상)
                _ThemeButton(
                  rect: rects[1],
                  fruitId: fruitIds[1],
                  semanticLabel: '중앙 위 책',
                  isActive: progress.isFruitActive(fruitIds[1]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[1])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[1], 1);
                  },
                ),

                // 오른쪽 책 → theme_3.png (열매 FR_LG_003, 집 동물)
                _ThemeButton(
                  rect: rects[2],
                  fruitId: fruitIds[2],
                  semanticLabel: '오른쪽 책',
                  isActive: progress.isFruitActive(fruitIds[2]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[2])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[2], 2);
                  },
                ),

                // 왼쪽 아래 책 → theme_4.png (열매 FR_LG_004, 동물원 동물)
                _ThemeButton(
                  rect: rects[3],
                  fruitId: fruitIds[3],
                  semanticLabel: '왼쪽 아래 책',
                  isActive: progress.isFruitActive(fruitIds[3]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[3])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[3], 3);
                  },
                ),

                // 오른쪽 아래 책 → theme_5.png (특별) (열매 FR_LG_005, 연못/강가 동물)
                _ThemeButton(
                  rect: rects[4],
                  fruitId: fruitIds[4],
                  semanticLabel: '오른쪽 아래 책',
                  isSpecial: true,
                  isActive: progress.isFruitActive(fruitIds[4]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[4])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[4], 4);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ start 호출 + 상태 저장 + 콜백 호출
  Future<void> _handleStart(
      BuildContext context, String fruitId, int themeIndex) async {
    try {
      FruitState.instance
        ..setStage(Level1ThemeSelectPage.stageId)
        ..setFruit(fruitId);

      final resultId = await ChildGameApi.startListeningGame();
      if (resultId == null) {
        _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.');
        return;
      }

      FruitState.instance.setResult(resultId);
      widget.onThemeSelected(themeIndex); // ✅ 기존 구조 그대로
    } catch (e) {
      debugPrint('⚠️ startListeningGame 실패: $e');
      _showSnack(context, '⚠️ 네트워크 오류가 발생했습니다.');
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.brown.shade400,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ThemeButton extends StatefulWidget {
  final Rect rect;
  final String fruitId;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool isSpecial;
  final bool isActive;

  const _ThemeButton({
    required this.rect,
    required this.fruitId,
    required this.semanticLabel,
    required this.onTap,
    this.isSpecial = false,
    this.isActive = true,
  });

  @override
  State<_ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<_ThemeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = fruitImageMap[widget.fruitId];
    if (entry == null) {
      debugPrint('⚠️ [ThemeButton] 이미지 매핑 없음: ${widget.fruitId}');
      return const SizedBox.shrink();
    }

    // ✅ 활성/비활성 이미지 스위칭
    final imagePath = widget.isActive ? entry.active : entry.inactive;

    return Positioned(
      left: widget.rect.left,
      top: widget.rect.top,
      width: widget.rect.width,
      height: widget.rect.height,
      child: GestureDetector(
        onTap: widget.isActive ? widget.onTap : null, // 🔒 잠긴 상태는 클릭 막기
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.05).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imagePath, // ✅ 비활성 시 _deactivation.png 자동 표시,
                fit: BoxFit.contain,
                semanticLabel: widget.semanticLabel,
              ),
              if (widget.isSpecial)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.amber.withOpacity(0.8),
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
