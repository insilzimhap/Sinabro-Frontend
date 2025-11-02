// lib/main/gameView/writeGame/write_game_main.dart
import 'package:flutter/material.dart';

// ⬇️ 1-1 단계 페이지
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_3.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_4.dart';

// 열매ID, 게임 api
import 'package:sinabro/main/gameView/writeGame/api/fruit_state.dart';
import 'package:sinabro/main/gameView/writeGame/api/child_game_api.dart';

class WriteGameMainPage extends StatefulWidget {
  const WriteGameMainPage({super.key, required this.childId});
  final String childId;

  static const routeName = '/write/game/hub';
  static const String stageId = 'ST010'; // 쓰기게임 나무1(Stage 1)

  @override
  State<WriteGameMainPage> createState() => _WriteGameMainPageState();
}

class _WriteGameMainPageState extends State<WriteGameMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('write_game_1')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            return Stack(
              children: [
                // 사다리 (좌상) -> write_game_1_1.dart (FR_WG_001)
                _ObjectTile(
                  id: 'ladder',
                  rect: const Rect.fromLTWH(40, 30, 180, 180),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_1.png',
                  onTap: () async {
                    // fruitId + stageId 저장
                    FruitState.instance
                      ..setStage(WriteGameMainPage.stageId)
                      ..setFruit('FR_WG_001');

                    // start API 호출
                    final resultId = await ChildGameApi.startWritingGame();
                    if (resultId == null) {
                      _showSnack('⚠️ 입장할 수 없는 열매입니다.');
                      return;
                    }
                    // startAPI로 생성된 resultId를 저장해둠 → 다음 페이지에서 사용
                    FruitState.instance.setResult(resultId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1Page(
                              childId: widget.childId,
                              resultId: resultId,
                            ),
                      ),
                    );
                  },
                ),

                // 풍선 (우상) -> write_game_1_2.dart (FR_WG_002)
                _ObjectTile(
                  id: 'ballon',
                  rect: Rect.fromLTWH(c.maxWidth - 240, 30, 220, 170),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_2.png',
                  onTap: () async {
                    FruitState.instance
                      ..setStage(WriteGameMainPage.stageId)
                      ..setFruit('FR_WG_002');

                    final resultId = await ChildGameApi.startWritingGame();
                    if (resultId == null) {
                      _showSnack('⚠️ 입장할 수 없는 열매입니다.');
                      return;
                    }

                    FruitState.instance.setResult(resultId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1_2Page(
                              childId: widget.childId,
                              resultId: resultId,
                            ),
                      ),
                    );
                  },
                ),

                // 바행기 (좌하) -> write_game_1_3.dart (FR_WG_003)
                _ObjectTile(
                  id: 'airplane1',
                  rect: Rect.fromLTWH(30, c.maxHeight - 240, 220, 170),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_3.png',
                  onTap: () async {
                    FruitState.instance
                      ..setStage(WriteGameMainPage.stageId)
                      ..setFruit('FR_WG_003');

                    final resultId = await ChildGameApi.startWritingGame();
                    if (resultId == null) {
                      _showSnack('⚠️ 입장할 수 없는 열매입니다.');
                      return;
                    }

                    FruitState.instance.setResult(resultId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1_3Page(
                              childId: widget.childId,
                              resultId: resultId,
                            ),
                      ),
                    );
                  },
                ),

                // 블록 (우하) -> write_game_1_4.dart (FR_WG_004)
                _ObjectTile(
                  id: 'block',
                  rect: Rect.fromLTWH(
                    c.maxWidth - 260,
                    c.maxHeight - 240,
                    230,
                    210,
                  ),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_4.png',
                  onTap: () async {
                    FruitState.instance
                      ..setStage(WriteGameMainPage.stageId)
                      ..setFruit('FR_WG_004');

                    final resultId = await ChildGameApi.startWritingGame();
                    if (resultId == null) {
                      _showSnack('⚠️ 입장할 수 없는 열매입니다.');
                      return;
                    }

                    FruitState.instance.setResult(resultId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1_4Page(
                              childId: widget.childId,
                              resultId: resultId,
                            ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
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
class _ObjectTile extends StatelessWidget {
  const _ObjectTile({
    required this.id,
    required this.rect,
    required this.imageAsset,
    required this.onTap,
  });

  final String id;
  final Rect rect;
  final String imageAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          imageAsset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
