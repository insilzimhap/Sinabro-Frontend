/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2 테마 선택 화면]
 *  - 챕터(레벨 2)의 테마(열매) 3개 중 하나를 선택하는 페이지
 *  - 각 테마 이미지를 터치하면 해당 테마 진입
 * 
 * < 레벨 2 > - ST008
 *
 *  테마1 - FR_LG_006
 *  테마2 - FR_LG_007
 *  테마3 - FR_LG_008
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';

// 🔹 공통 상태/API import (Level1과 동일 구조)
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';


class Level2ThemeSelectPage extends StatefulWidget {
  final Function(int) onThemeSelected;
  final String childId; //✅ childId 전달 추가

  const Level2ThemeSelectPage({
    super.key,
    required this.onThemeSelected,
    required this.childId, 
  });

  static const String stageId = 'ST008';  // 듣기게임 나무2(Stage 2)

  @override
  State<Level2ThemeSelectPage> createState() => _Level2ThemeSelectPageState();
}

class _Level2ThemeSelectPageState extends State<Level2ThemeSelectPage> {
  late Future<TreeProgress> _progressFuture;


  @override
  void initState() {
    super.initState();
    _progressFuture = TreeProgressLoader.load('listening_game');
  }


  @override
  Widget build(BuildContext context) {
    final themePaths = List.generate(
      3,
      (i) => 'assets/img/contents/gameListen/level2/theme/theme_${i + 1}.png',
    );
    const decoPath = 'assets/img/contents/gameListen/level2/theme/theme_deco.png';
    const bgPath = 'assets/img/contents/gameListen/level2/theme/background.png';

    final rects = [
      const Rect.fromLTWH(60, 220, 110, 110),   // 1번 (왼쪽)
      const Rect.fromLTWH(160, 160, 120, 120),  // 2번 (가운데)
      const Rect.fromLTWH(270, 210, 110, 110),  // 3번 (오른쪽, 반짝)
    ];

    // ✅ fruitId 매핑 (열매별로 start 요청 구분용)
    final fruitIds = [
      'FR_LG_006',
      'FR_LG_007',
      'FR_LG_008',
    ];


    return Scaffold(
      body: SafeArea(

        child: FutureBuilder<TreeProgress>( //추가
          future: _progressFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final progress = snapshot.data!;



            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(bgPath, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(decoPath, fit: BoxFit.cover, height: 100),
                ),
                // 뒤로가기
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF2E6B3D),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 왼쪽 테마 → theme_1.png (열매 FR_LG_006, 가족)
                _ThemeButton(
                  rect: rects[0],
                  fruitId: fruitIds[0],
                  isActive: progress.isFruitActive(fruitIds[0]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[0])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[0], 0);
                  },
                ),

                // 중앙 테마 → theme_2.png (열매 FR_LG_007, 단순감정)
                _ThemeButton(
                  rect: rects[1],
                  fruitId: fruitIds[1],
                  isActive: progress.isFruitActive(fruitIds[1]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[1])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[1], 1);
                  },
                ),

                // 오른쪽 테마 → theme_3.png (반짝) (열매 FR_LG_008, 복잡감정)
                _ThemeButton(
                  rect: rects[2],
                  fruitId: fruitIds[2],
                  isActive: progress.isFruitActive(fruitIds[2]),
                  onTap: () async {
                    if (!progress.isFruitActive(fruitIds[2])) {
                      _showSnack(context, '🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _handleStart(context, fruitIds[2], 2);
                  },
                ),
              ],
            );
          },

        ),
      ),
    );
  }
  /// ✅ start 호출 + 상태 저장 + 콜백 호출 (Level1과 동일 구조)
  Future<void> _handleStart(
      BuildContext context, String fruitId, int themeIndex) async {
    try {
      FruitState.instance
        ..setStage(Level2ThemeSelectPage.stageId)
        ..setFruit(fruitId);

      final resultId = await ChildGameApi.startListeningGame();
      if (resultId == null) {
        _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.');
        return;
      }

      FruitState.instance.setResult(resultId);
      widget.onThemeSelected(themeIndex); // ✅ 기존 구조 그대로 유지
    } catch (e) {
      debugPrint('⚠️ startListeningGame 실패: $e');
      _showSnack(context, '⚠️ 네트워크 오류가 발생했습니다.');
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ThemeButton extends StatefulWidget {
  final Rect rect;
  final String fruitId;
  final VoidCallback onTap;
  final bool isActive;
  final bool isShiny;

  const _ThemeButton({
    required this.rect,
    required this.fruitId,
    required this.onTap,
    this.isActive = true,
    this.isShiny = false,
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath, // ✅ 비활성 시 _deactivation.png 자동 표시,
              fit: BoxFit.contain,
            ),
            if (widget.isShiny)
              FadeTransition(
                opacity: Tween(begin: 0.4, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
