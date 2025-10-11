import 'package:flutter/material.dart';

typedef FigmaBuilder = Widget Function(
  BuildContext context,
  double scale,
  double dx,
  double dy,
);

class FigmaBoard extends StatelessWidget {
  const FigmaBoard({
    super.key,
    required this.baseWidth,
    required this.baseHeight,
    this.child,
    this.builder,
    this.alignToSafeTop = false, // 상단 노치 보정
    this.lockTextScale = true, // 시스템 글자크기 무시(피그마 1:1)
    this.snapPixel = true, // 픽셀 스냅(블러막음)
  }) : assert(child != null || builder != null);

  final double baseWidth;
  final double baseHeight;
  final Widget? child;
  final FigmaBuilder? builder;
  final bool alignToSafeTop;
  final bool lockTextScale;
  final bool snapPixel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final insets = MediaQuery.viewPaddingOf(context);

    final scale = _calcScale(size.width, size.height, baseWidth, baseHeight);
    double dx = (size.width - baseWidth * scale) / 2;
    double dy = (size.height - baseHeight * scale) / 2;

    // 상단 안전영역 보정(선택)
    if (alignToSafeTop && insets.top > 0) {
      dy = dy < insets.top ? insets.top : dy;
    }

    // 픽셀 스냅 (서브픽셀 렌더링 블러 방지)
    if (snapPixel) {
      dx = dx.floorToDouble() + 0.5;
      dy = dy.floorToDouble() + 0.5;
    }

    Widget content;
    if (builder != null) {
      content = builder!(context, scale, dx, dy);
    } else {
      content = Stack(
        children: [
          Positioned(
            left: dx,
            top: dy,
            width: baseWidth * scale,
            height: baseHeight * scale,
            child: FittedBox(
              alignment: Alignment.topLeft,
              fit: BoxFit.fill,
              child: SizedBox(
                width: baseWidth,
                height: baseHeight,
                child: child!,
              ),
            ),
          ),
        ],
      );
    }

    // 시스템 글자 크기 무시(옵션) → 피그마 타이포 정확 매칭
    if (lockTextScale) {
      final mq = MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      );
      return MediaQuery(data: mq, child: content);
    }
    return content;
  }

  static double _calcScale(double w, double h, double bw, double bh) {
    final sw = w / bw, sh = h / bh;
    return sw < sh ? sw : sh; // 짧은 변 기준
  }
}

/// Figma 스케일 헬퍼들: sx/sy/sw/sp 로 한 줄 배치
class FigmaUnits {
  final double scale, dx, dy;
  const FigmaUnits(this.scale, this.dx, this.dy);

  double sx(double x) => dx + x * scale; // left
  double sy(double y) => dy + y * scale; // top
  double sw(double v) => v * scale; // size/radius/border
  double sp(double fs) => fs * scale; // font size
}
