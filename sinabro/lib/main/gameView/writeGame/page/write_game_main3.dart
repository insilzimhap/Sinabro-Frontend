// lib/main/gameView/writeGame/page/write_game_main3.dart
import 'package:flutter/material.dart';

// Level3 (ST012) 단계별 페이지 import (경로 고정)
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_3.dart';
import 'package:sinabro/main/gameView/writeGame/page/level3/write_game_3_4.dart';

// 열매ID, 게임 api
import 'package:sinabro/main/gameView/writeGame/api/fruit_state.dart';
import 'package:sinabro/main/gameView/writeGame/api/child_game_api.dart';

class WriteGameMain3Page extends StatelessWidget {
  const WriteGameMain3Page({super.key, required this.childId});
  final String childId;

  static const String routeName = '/write/game/hub3';
  static const String stageId = 'ST012'; // ✅ 쓰기게임 나무3(Stage 3)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
            asset: 'assets/img/contents/gameWrite/write_game_3_cup_red.png',
            width: 370,
            height: 390,
            alignX: -0.92, // 왼쪽
            alignY: 0.82, // 아래쪽
            onTap: (context) async {

              FruitState.instance //changed
                ..setStage(stageId) 
                ..setFruit('FR_WG_008'); 

              final resultId = await ChildGameApi.startWritingGame(); 
              if (resultId == null) { 
                _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.'); 
                return; 
              } 
              FruitState.instance.setResult(resultId); 

              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteGameLevel3_1Page(
                    childId: childId,
                    resultId: resultId,
                  ),
                ),
              );
            },
          ),
          _CupButton(
            // 과일 컵 -> FR_WG_009
            asset: 'assets/img/contents/gameWrite/write_game_3_cup_blue.png',
            width: 370,
            height: 390,
            alignX: -0.34,
            alignY: 0.82,
            onTap: (context) async {

              FruitState.instance //changed
                ..setStage(stageId)
                ..setFruit('FR_WG_009');

              final resultId = await ChildGameApi.startWritingGame(); //changed
              if (resultId == null) {
                _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.');
                return;
              }
              FruitState.instance.setResult(resultId); //changed

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteGameLevel3_2Page(
                    childId: childId,
                    resultId: resultId,
                  ),
                ),
              );
            },
          ),
          _CupButton(
            // 채소 컵 -> FR_WG_010
            asset: 'assets/img/contents/gameWrite/write_game_3_cup_yellow.png',
            width: 370,
            height: 390,
            alignX: 0.28,
            alignY: 0.82,
            onTap: (context) async {
              FruitState.instance //changed
                ..setStage(stageId) 
                ..setFruit('FR_WG_010'); 

              final resultId = await ChildGameApi.startWritingGame(); 
              if (resultId == null) { 
                _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.'); 
                return; 
              } 
              FruitState.instance.setResult(resultId); 

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteGameLevel3_3Page(
                    childId: childId,
                    resultId: resultId,
                  ),
                ),
              );
            },
          ),
          _CupButton(
            // 우리 몸 컵 -> FR_WG_011
            asset: 'assets/img/contents/gameWrite/write_game_3_cup_green.png',
            width: 310,
            height: 310,
            alignX: 0.8,
            alignY: 0.72,
            onTap: (context) async {
              FruitState.instance //changed
                ..setStage(stageId) 
                ..setFruit('FR_WG_011'); 

              final resultId = await ChildGameApi.startWritingGame(); 
              if (resultId == null) { 
                _showSnack(context, '⚠️ 입장할 수 없는 열매입니다.'); 
                return; 
              } 
              FruitState.instance.setResult(resultId); 

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteGameLevel3_4Page(
                    childId: childId,
                    resultId: resultId,
                  ),
                ),
              );
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
      ),
    );
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
    required this.asset,
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

  final String asset;
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
    final image = GestureDetector(
      onTap: () => onTap(context),
      child: Image.asset(
        asset,
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
