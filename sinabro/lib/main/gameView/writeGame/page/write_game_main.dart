// lib/main/gameView/writeGame/write_game_main.dart
import 'package:flutter/material.dart';

// ⬇️ 1-1 단계 페이지
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_3.dart';
import 'package:sinabro/main/gameView/writeGame/page/level1/write_game_1_4.dart';

// ⬇️ 메인2, 메인3 이동
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart'
    show WriteGameMain2Page;
import 'package:sinabro/main/gameView/writeGame/page/write_game_main3.dart'
    show WriteGameMain3Page;

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
                // 사다리 (좌상) -> write_game_1_1.dart (FR_WG_001)
                _ObjectTile(
                  id: 'ladder',
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

                // 풍선 (우상) -> write_game_1_2.dart FR_WG_002
                _ObjectTile(
                  id: 'ballon',
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

                // 비행기 (좌하) -> write_game_1_3.dart FR_WG_003
                _ObjectTile(
                  id: 'airplane',
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

                // 중앙 버튼 영역
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔵 메인2 이동 버튼
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WriteGameMain2Page(
                                  childId: widget.childId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '다음 메인으로 가기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 🟢 메인3 이동 버튼 (추가됨)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WriteGameMain3Page(
                                  childId: widget.childId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '쓰기게임 메인3로 가기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
