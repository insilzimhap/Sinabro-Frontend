// lib/main/gameView/writeGame/write_game_main.dart
import 'package:flutter/material.dart';

// ⬇️ 1-1 단계 페이지
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_3.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_4.dart';

class WriteGameMainPage extends StatefulWidget {
  const WriteGameMainPage({super.key, required this.childId});
  final String childId;

  static const routeName = '/write/game/hub';

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
                // 풍선 (좌상)
                _ObjectTile(
                  id: 'balloons',
                  rect: const Rect.fromLTWH(40, 30, 180, 180),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_1.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1Page(childId: widget.childId),
                      ),
                    );
                  },
                ),

                // 비행기 (우상)
                _ObjectTile(
                  id: 'airplane',
                  rect: Rect.fromLTWH(c.maxWidth - 240, 30, 220, 170),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_2.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1_2Page(childId: widget.childId),
                      ),
                    );
                  },
                ),

                // 달팽이 (좌하)
                _ObjectTile(
                  id: 'airplane2',
                  rect: Rect.fromLTWH(30, c.maxHeight - 240, 220, 170),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_3.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1_3Page(childId: widget.childId),
                      ),
                    );
                  },
                ),

                // 도형 (우하)
                _ObjectTile(
                  id: 'shapes',
                  rect: Rect.fromLTWH(
                    c.maxWidth - 260,
                    c.maxHeight - 240,
                    230,
                    210,
                  ),
                  imageAsset:
                      'assets/img/contents/gameWrite/write_game_1_4.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteGameLevel1_4Page(childId: widget.childId),
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
