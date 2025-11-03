// lib/main/gameView/writeGame/write_game_main.dart
import 'package:flutter/material.dart';

// ⬇️ 1-1 단계 페이지
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_3.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_4.dart';

// 열매ID, 게임 api
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

// 진행도
import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';

class WriteGameMainPage extends StatefulWidget {
  const WriteGameMainPage({super.key, required this.childId});
  final String childId;

  static const routeName = '/write/game/hub';
  static const String stageId = 'ST010'; // 쓰기게임 나무1(Stage 1)

  @override
  State<WriteGameMainPage> createState() => _WriteGameMainPageState();
}

class _WriteGameMainPageState extends State<WriteGameMainPage> {
  late Future<TreeProgress> _progressFuture;

  // ==== SIZE (그대로 유지) ====
  static const double ladderW = 400, ladderH = 400;
  static const double balloonW = 440, balloonH = 360;
  static const double airplaneW = 420, airplaneH = 350;
  static const double blockW = 460, blockH = 380;



  // ==== 위치 (드래그 로그 기반) ====
  double ladderLeft = 67.33, ladderTop = 0.0;
  double balloonRight = 280.0, balloonTop = 2.0;
  double airplaneLeft = 273.33, airplaneBottom = 0.67;
  double blockRight = 28.0, blockBottom = 12.0;

  @override
  void initState() {
    super.initState();
    _progressFuture = TreeProgressLoader.load('writing_game');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('write_game_1')),
      body: SafeArea(

        child: FutureBuilder<TreeProgress>(
          future: _progressFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final progress = snapshot.data!;

            return LayoutBuilder(
              builder: (context, c) {

                Rect _lt(double left, double top, double w, double h) =>
                  Rect.fromLTWH(left, top, w, h);

                Rect _rt(double right, double top, double w, double h) =>
                  Rect.fromLTWH(c.maxWidth - w - right, top, w, h);

                Rect _lb(double left, double bottom, double w, double h) =>
                  Rect.fromLTWH(left, c.maxHeight - h - bottom, w, h);

                Rect _rb(double right, double bottom, double w, double h) =>
                  Rect.fromLTWH(
                    c.maxWidth - w - right, c.maxHeight - h - bottom, w, h);


                return Stack(
                  children: [

                    // 사다리 (좌상) -> write_game_1_1.dart (FR_WG_001)
                    _ObjectTile(
                      id: 'ladder',
                      rect: _lt(ladderLeft, ladderTop, ladderW, ladderH),
                      fruitId: 'FR_WG_001',
                      isActive: progress.isFruitActive('FR_WG_001'),
                      onTap: () async {
                        if (!progress.isFruitActive('FR_WG_001')) {
                          _showSnack('🔒 잠긴 테마입니다.');
                          return;
                        }
                        await _startGame(context, 'FR_WG_001', WriteGameLevel1Page.new);
                      },
                    ),

                    // 풍선 (우상) -> write_game_1_2.dart (FR_WG_002)
                    _ObjectTile(
                      id: 'ballon',
                      rect: _rt(balloonRight, balloonTop, balloonW, balloonH),
                      fruitId: 'FR_WG_002',
                      isActive: progress.isFruitActive('FR_WG_002'),
                      onTap: () async {
                        if (!progress.isFruitActive('FR_WG_002')) {
                          _showSnack('🔒 잠긴 테마입니다.');
                          return;
                        }
                        await _startGame(context, 'FR_WG_002', WriteGameLevel1_2Page.new);
                      },
                    ),

                    // 바행기 (좌하) -> write_game_1_3.dart (FR_WG_003)
                    _ObjectTile(
                      id: 'airplane1',
                      rect: _lb(airplaneLeft, airplaneBottom, airplaneW, airplaneH),
                      fruitId: 'FR_WG_003',
                      isActive: progress.isFruitActive('FR_WG_003'),
                      onTap: () async {
                        if (!progress.isFruitActive('FR_WG_003')) {
                          _showSnack('🔒 잠긴 테마입니다.');
                          return;
                        }
                        await _startGame(context, 'FR_WG_003', WriteGameLevel1_3Page.new);
                      },
                    ),

                    // 블록 (우하) -> write_game_1_4.dart (FR_WG_004)
                    _ObjectTile(
                      id: 'block',
                      rect: _rb(blockRight, blockBottom, blockW, blockH),
                      fruitId: 'FR_WG_004',
                      isActive: progress.isFruitActive('FR_WG_004'),
                      onTap: () async {
                        if (!progress.isFruitActive('FR_WG_004')) {
                          _showSnack('🔒 잠긴 테마입니다.');
                          return;
                        }
                        await _startGame(context, 'FR_WG_004', WriteGameLevel1_4Page.new);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),//layout
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
        ..setStage(WriteGameMainPage.stageId)
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

  // SnackBar 헬퍼
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

/// 오브젝트 이미지 하나
/// ---------------------------------------------------------------------------
/// 🎨 [개별 오브젝트 위젯]
/// - 활성/비활성 상태에 따라 이미지 변경
/// - 클릭 시 onTap 실행
/// ---------------------------------------------------------------------------
class _ObjectTile extends StatelessWidget {
  const _ObjectTile({
    required this.id,
    required this.rect,
    required this.fruitId,
    required this.isActive,
    required this.onTap,
  });

  final String id;
  final Rect rect;
  final String fruitId;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    final entry = fruitImageMap[fruitId];
    if (entry == null) {
      debugPrint('⚠️ 이미지 매핑 없음: $fruitId');
      return const SizedBox.shrink();
    }

    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        onTap: isActive ? onTap : null,
        child: Image.asset(
          isActive ? entry.active : entry.inactive,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
