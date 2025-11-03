/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 3 테마 선택 화면]
 *  - 챕터(레벨 3)의 테마(열매) 2개 중 하나를 선택하는 페이지
 *  - 각 테마 이미지를 터치하면 해당 테마 진입
 * 
 *  < 레벨 3 > - ST009
 *  테마1 - FR_LG_009
 *  테마2 - FR_LG_010
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';

//🔹 공통 상태/API import
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';


class Level3ThemeSelectPage extends StatefulWidget {
  final Function(int) onThemeSelected;
  final String childId;

  const Level3ThemeSelectPage({
    super.key,
    required this.onThemeSelected,
    required this.childId, 
  });

  static const String stageId = 'ST009'; //changed: 듣기게임 나무3(Stage 3)

  @override
  State<Level3ThemeSelectPage> createState() => _Level3ThemeSelectPageState();
}

class _Level3ThemeSelectPageState extends State<Level3ThemeSelectPage> {
  late Future<TreeProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = TreeProgressLoader.load('listening_game');
  }



  @override
  Widget build(BuildContext context) {
    final themePaths = List.generate(
      2,
      (i) => 'assets/img/contents/gameListen/level3/theme/theme_${i + 1}.png',
    );

    const decoPath = 'assets/img/contents/gameListen/level3/theme/theme_deco.png';
    const bgPath = 'assets/img/contents/gameListen/level3/theme/background.png';

    final rects = [
      const Rect.fromLTWH(80, 220, 120, 120), // theme_1 (왼쪽)
      const Rect.fromLTWH(220, 230, 120, 120), // theme_2 (오른쪽, 반짝)
    ];

    //fruitId 매핑 (열매별로 start 요청 구분용)
    final fruitIds = [
      'FR_LG_009',
      'FR_LG_010',
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
    
                _ThemeButton( // theme_1 (왼쪽) (열매 FR_LG_009, 1~5)
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
                _ThemeButton( // theme_2 (오른쪽, 반짝) (열매 FR_LG_010, 6~10)
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
                  isShiny: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  /// ✅ startListeningGame 호출 + 상태 저장 + 콜백 실행
  Future<void> _handleStart(
      BuildContext context, String fruitId, int themeIndex) async {
    try {
      FruitState.instance
        ..setStage(Level3ThemeSelectPage.stageId)
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
