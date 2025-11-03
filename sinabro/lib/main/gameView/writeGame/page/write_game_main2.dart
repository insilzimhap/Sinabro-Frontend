// lib/main/gameView/writeGame/write_game_main2.dart
import 'package:flutter/material.dart';

// 단계 페이지 import (경로/클래스명은 네 프로젝트에 맞게 확인)
import 'package:sinabro/main/gameView/writeGame/page/level2/write_game_2_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level2/write_game_2_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level2/write_game_2_3.dart';

// 열매ID, 게임 api
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

// 진행도
import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';

class WriteGameMain2Page extends StatefulWidget {
  const WriteGameMain2Page({super.key, required this.childId});
  final String childId;

  static const String routeName = '/write/game/hub2';
  static const String stageId = 'ST011'; // ✅ 쓰기게임 나무2(Stage 2)

  @override
  State<WriteGameMain2Page> createState() => _WriteGameMain2PageState();
}

class _WriteGameMain2PageState extends State<WriteGameMain2Page> {
  late Future<TreeProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = TreeProgressLoader.load('writing_game');
  }

  // 에셋 경로
  static const _dir = 'assets/img/contents/gameWrite/';
  static const _bear = '${_dir}chef_bear.png';
  // static const _bagLeft = '${_dir}bag_left.png';
  // static const _bagRightTop = '${_dir}bag_right_top.png';
  // static const _bagRightBottom = '${_dir}bag_right_bottom.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DF), // 상단 기본색과 어울리는 바탕
      body: SafeArea(
        
        child: FutureBuilder<TreeProgress>(
          future: _progressFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final progress = snapshot.data!;
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;

            // 비율 기반 사이즈
            final bearW = (w * 0.38).clamp(260.0, 520.0);
            final bagW = (w * 0.22).clamp(140.0, 320.0);

            // 주머니 위치 비율 (스크린 비율에 맞춰 자연스러운 위치)
            final leftBagRect = Rect.fromCenter(
              center: Offset(w * 0.18, h * 0.33),
              width: bagW,
              height: bagW,
            );
            final rightTopBagRect = Rect.fromCenter(
              center: Offset(w * 0.80, h * 0.26),
              width: bagW,
              height: bagW,
            );
            final rightBottomBagRect = Rect.fromCenter(
              center: Offset(w * 0.78, h * 0.72),
              width: bagW,
              height: bagW,
            );

            return Stack(
              children: [
                // 상/하 배경(상단: 크림색, 하단: 테이블 베이지)
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(color: const Color(0xFFFCEEDB)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(color: const Color(0xFFD1B79A)),
                    ),
                  ],
                ),

                // 뒤로가기
                Positioned(
                  left: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.black54,
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '뒤로',
                  ),
                ),

                // 중앙 곰(도마 포함 이미지 한 장 권장)
                Positioned(
                  left: (w - bearW) / 2,
                  top: h * -0.05,
                  width: bearW,
                  child: IgnorePointer(
                    child: Image.asset(
                      _bear,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                // 왼쪽 주머니 → write_game_2_1.dart (FR_WG_005)
                _BagButton(
                  rect: leftBagRect,
                  semanticLabel: '왼쪽 과자 주머니',
                  fruitId: 'FR_WG_005',
                  isActive: progress.isFruitActive('FR_WG_005'),
                  onTap: () async {
                    if (!progress.isFruitActive('FR_WG_005')) {
                      _showSnack('🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _startGame(context, 'FR_WG_005', WriteGameLevel2_1Page.new);
                  },
                ),

                // 오른쪽 위 주머니 → write_game_2_2.dart (FR_WG_006)
                _BagButton(
                  rect: rightTopBagRect,
                  semanticLabel: '오른쪽 위 과자 주머니',
                  fruitId: 'FR_WG_006',
                  isActive: progress.isFruitActive('FR_WG_006'),
                  onTap: () async {
                    if (!progress.isFruitActive('FR_WG_006')) {
                      _showSnack('🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _startGame(context, 'FR_WG_006', WriteGameLevel2_2Page.new);
                  },
                ),

                // 오른쪽 아래 주머니 → write_game_2_3.dart (FR_WG_007)
                _BagButton(
                  rect: rightBottomBagRect,
                  semanticLabel: '오른쪽 아래 과자 주머니',
                  fruitId: 'FR_WG_007',
                  isActive: progress.isFruitActive('FR_WG_007'),
                  onTap: () async {
                    if (!progress.isFruitActive('FR_WG_007')) {
                      _showSnack('🔒 잠긴 테마입니다.');
                      return;
                    }
                    await _startGame(context, 'FR_WG_007', WriteGameLevel2_3Page.new);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ✅ 공통 Start 로직
  Future<void> _startGame(
    BuildContext context,
    String fruitId,
    Widget Function({required String childId, required String resultId}) pageBuilder,
  ) async {
    try {
      FruitState.instance
        ..setStage(WriteGameMain2Page.stageId)
        ..setFruit(fruitId);

      final resultId = await ChildGameApi.startWritingGame();
      if (resultId == null) {
        _showSnack('⚠️ 입장할 수 없는 열매입니다.');
        return;
      }

      FruitState.instance.setResult(resultId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => pageBuilder(
            childId: widget.childId,
            resultId: resultId,
          ),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ startWritingGame 실패: $e');
      _showSnack('⚠️ 네트워크 오류가 발생했습니다.');
    }
  }

  // changed: SnackBar 헬퍼 추가
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.brown.shade400,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// 주머니 버튼(탭영역을 Rect로 배치)
/// ---------------------------------------------------------------------------
/// 🎨 [주머니 버튼]
/// - 활성/비활성 상태에 따라 이미지 전환
/// ---------------------------------------------------------------------------
class _BagButton extends StatefulWidget {
  const _BagButton({
    required this.rect,
    required this.fruitId,
    required this.isActive,
    required this.onTap,
    this.semanticLabel,
  });

  final Rect rect;
  final String fruitId;
  final bool isActive;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  State<_BagButton> createState() => _BagButtonState();
}

class _BagButtonState extends State<_BagButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // ✅ fruitId로 이미지 매핑 (active/inactive)
    final entry = fruitImageMap[widget.fruitId];
    if (entry == null) {
      debugPrint('⚠️ [BagButton] 이미지 매핑 없음: ${widget.fruitId}');
      return const SizedBox.shrink();
    }

    final imagePath =
        widget.isActive ? entry.active : entry.inactive; // 활성/비활성 이미지 선택

    return Positioned.fromRect(
      rect: widget.rect,
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          // 🔒 잠금 상태면 터치 비활성화
          onTap: widget.isActive ? widget.onTap : null,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 80),
            scale: _pressed ? 0.96 : 1.0,
            child: Image.asset(
              imagePath, // ✅ 비활성 시 *_deactivation.png 사용
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  
}
