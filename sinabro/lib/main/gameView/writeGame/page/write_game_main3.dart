// lib/main/gameView/writeGame/page/write_game_main3.dart
import 'package:flutter/material.dart';

// Level3 (ST012) 단계별 페이지 import (경로 고정)
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_3.dart';
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_4.dart';

// 열매ID, 게임 api
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

// 진행도 관련
import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/fruit_image_map.dart';

class WriteGameMain3Page extends StatefulWidget {
  const WriteGameMain3Page({super.key, required this.childId});
  final String childId;

  static const String routeName = '/write/game/hub3';
  static const String stageId = 'ST012'; // ✅ 쓰기게임 나무3(Stage 3)

  @override
  State<WriteGameMain3Page> createState() => _WriteGameMain3PageState();
}

class _WriteGameMain3PageState extends State<WriteGameMain3Page> {
  late Future<TreeProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = TreeProgressLoader.load('writing_game');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<TreeProgress>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snapshot.data!;

          return Stack(
            children: [
              // 배경
              Positioned.fill(
                child: Image.asset(
                  'assets/img/contents/gameWrite/write_game_3_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 한글박사 (독립 배치)
              const Positioned(top: 25, left: 0, right: 0, child: _Professor()),

              // 말풍선 (독립 배치: 위치/크기 여기서 조절)
              const Positioned(
                top: 60, // 화면 위에서부터 거리
                right: 120, // 오른쪽 여백
                child: _Balloon(
                  width: 380,
                  height: 220,
                  text: '벌써 마지막까지...\n대단한 아이로군',
                ),
              ),

              // ── 컵 4개 ─────────────────────────────────────────
              // 아래 예시는 '정규화(비율) 방식'으로 균형 잡힌 배치값을 넣어둔 상태야.
              // 각 컵마다 width/height/alignX/alignY 숫자만 바꿔 미세 조정하면 됨.
              _CupButton(
                // 동물 컵 -> FR_WG_008
                fruitId: 'FR_WG_008',
                isActive: progress.isFruitActive('FR_WG_008'),
                width: 370,
                height: 390,
                alignX: -0.92, // 왼쪽
                alignY: 0.82, // 아래쪽
                onTap: (context) async {
                  await _startGame(
                      context, 'FR_WG_008', WriteGameLevel3_1Page.new);
                },
              ),
              _CupButton(
                // 과일 컵 -> FR_WG_009
                fruitId: 'FR_WG_009',
                isActive: progress.isFruitActive('FR_WG_009'),
                width: 370,
                height: 390,
                alignX: -0.34,
                alignY: 0.82,
                onTap: (context) async {
                  await _startGame(
                      context, 'FR_WG_009', WriteGameLevel3_2Page.new);
                },
              ),
              _CupButton(
                // 채소 컵 -> FR_WG_010
                fruitId: 'FR_WG_010',
                isActive: progress.isFruitActive('FR_WG_010'),
                width: 370,
                height: 390,
                alignX: 0.28,
                alignY: 0.82,
                onTap: (context) async {
                  await _startGame(
                      context, 'FR_WG_010', WriteGameLevel3_3Page.new);
                },
              ),
              _CupButton(
                // 우리 몸 컵 -> FR_WG_011
                fruitId: 'FR_WG_011',
                isActive: progress.isFruitActive('FR_WG_011'),
                width: 370,
                height: 390,
                alignX: 0.8,
                alignY: 0.844,
                onTap: (context) async {
                  await _startGame(
                      context, 'FR_WG_011', WriteGameLevel3_4Page.new);
                },
              ),

              // 만약 픽셀 기준으로 움직이고 싶으면 이렇게도 가능(alignX/Y 미지정):
              // _CupButton(
              //   asset: '...',
              //   width: 170,
              //   height: 190,
              //   left: 60,      // px
              //   bottom: 40,    // px
              //   onTap: ...
              // ),
            ],
          );
        },
      ),
    );
  }

  /// ✅ 공통 시작 로직
  Future<void> _startGame(
    BuildContext context,
    String fruitId,
    Widget Function({required String childId, required String resultId})
        pageBuilder,
  ) async {
    try {
      FruitState.instance
        ..setStage(WriteGameMain3Page.stageId)
        ..setFruit(fruitId);

      final resultId = await ChildGameApi.startWritingGame();
      if (resultId == null) {
        _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.');
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
      _showSnack(context, '⚠️ 네트워크 오류가 발생했습니다.');
    }
  }

  // SnackBar 헬퍼
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

/* ───────────── 분리 위젯들 ───────────── */

class _Professor extends StatelessWidget {
  const _Professor();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/contents/gameWrite/write_game_professor.png',
      width: 460,
      height: 480,
      fit: BoxFit.contain,
    );
  }
}

class _Balloon extends StatelessWidget {
  const _Balloon({
    required this.width,
    required this.height,
    required this.text,
  });

  final double width;
  final double height;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/contents/gameWrite/text_balloon.png',
              fit: BoxFit.contain,
            ),
          ),
          // 안쪽 텍스트
          Positioned.fill(
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30, // ← 글자 크기
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 컵 버튼
/// - 두 가지 배치 방법 지원:
///   1) 픽셀 방식: left/right/top/bottom 중 필요한 것 지정
///   2) 정규화(비율) 방식: alignX, alignY (-1.0~1.0)
///      * alignX=-1는 왼쪽 끝, 0은 가운데, 1은 오른쪽 끝
///      * alignY=-1는 위쪽 끝, 1은 아래쪽 끝
class _CupButton extends StatelessWidget {
  const _CupButton({
    required this.fruitId,
    required this.isActive,
    required this.onTap,
    this.width = 160,
    this.height = 180,

    // 픽셀 방식
    this.left,
    this.right,
    this.top,
    this.bottom,

    // 정규화(비율) 방식
    this.alignX,
    this.alignY,
  });

  final String fruitId;
  final bool isActive;

  final void Function(BuildContext context) onTap;
  final double width;
  final double height;

  // 픽셀 위치
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  // 정규화 위치 (-1.0 ~ 1.0)
  final double? alignX;
  final double? alignY;

  @override
  Widget build(BuildContext context) {
    final entry = fruitImageMap[fruitId];
    if (entry == null) {
      debugPrint('⚠️ [CupButton] 이미지 매핑 없음: $fruitId');
      return const SizedBox.shrink();
    }

    final path = isActive ? entry.active : entry.inactive;

    final image = GestureDetector(
      onTap: isActive
          ? () => onTap(context)
          : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🔒 잠긴 테마입니다.'),
                  backgroundColor: Colors.brown.shade400,
                  duration: const Duration(seconds: 2),
                ),
              ),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );

    // 정규화(비율) 방식이 지정되면 Align로 배치
    if (alignX != null || alignY != null) {
      return Align(
        alignment: Alignment(alignX ?? 0.0, alignY ?? 0.0),
        child: image,
      );
    }

    // 아니면 픽셀 방식(기존 Positioned)으로 배치
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: image,
    );
  }
}
