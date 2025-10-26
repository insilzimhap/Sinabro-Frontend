// lib/main/gameView/writeGame/write_game_main2.dart
import 'package:flutter/material.dart';

// 단계 페이지 import (경로/클래스명은 네 프로젝트에 맞게 확인)
import 'package:sinabro/main/gameView/writeGame/page/level2/write_game_2_1.dart';
import 'package:sinabro/main/gameView/writeGame/page/level2/write_game_2_2.dart';
import 'package:sinabro/main/gameView/writeGame/page/level2/write_game_2_3.dart';

class WriteGameMain2Page extends StatelessWidget {
  const WriteGameMain2Page({super.key, required this.childId});
  final String childId;

  static const String routeName = '/write/game/hub2';

  // 에셋 경로
  static const _dir = 'assets/img/contents/gameWrite/';
  static const _bear = '${_dir}chef_bear.png';
  static const _bagLeft = '${_dir}bag_left.png';
  static const _bagRightTop = '${_dir}bag_right_top.png';
  static const _bagRightBottom = '${_dir}bag_right_bottom.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DF), // 상단 기본색과 어울리는 바탕
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, cons) {
            final w = cons.maxWidth;
            final h = cons.maxHeight;

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

                // 왼쪽 주머니 → write_game_2_1.dart
                _BagButton(
                  rect: leftBagRect,
                  imageAsset: _bagLeft,
                  semanticLabel: '왼쪽 과자 주머니',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WriteGameLevel2_1Page(childId: childId),
                      ),
                    );
                  },
                ),

                // 오른쪽 위 주머니 → write_game_2_2.dart
                _BagButton(
                  rect: rightTopBagRect,
                  imageAsset: _bagRightTop,
                  semanticLabel: '오른쪽 위 과자 주머니',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WriteGameLevel2_2Page(childId: childId),
                      ),
                    );
                  },
                ),

                // 오른쪽 아래 주머니 → write_game_2_3.dart
                _BagButton(
                  rect: rightBottomBagRect,
                  imageAsset: _bagRightBottom,
                  semanticLabel: '오른쪽 아래 과자 주머니',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WriteGameLevel2_3Page(childId: childId),
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

/// 주머니 버튼(탭영역을 Rect로 배치)
class _BagButton extends StatefulWidget {
  const _BagButton({
    required this.rect,
    required this.imageAsset,
    required this.onTap,
    this.semanticLabel,
  });

  final Rect rect;
  final String imageAsset;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  State<_BagButton> createState() => _BagButtonState();
}

class _BagButtonState extends State<_BagButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.rect,
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 80),
            scale: _pressed ? 0.96 : 1.0,
            child: Image.asset(
              widget.imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
