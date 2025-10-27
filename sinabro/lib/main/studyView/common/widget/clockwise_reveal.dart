import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 시계방향 원형 채우기 애니메이션 위젯
/// - 배경(bgColor) 위에 revealColor가 시계방향으로 점점 덮이는 효과
class ClockwiseReveal extends StatefulWidget {
  const ClockwiseReveal({
    super.key,
    this.bgColor = const Color(0xFFFFF3E5), // 기본 배경 (베이지)
    required this.revealColor, // 덮일 색상 (빨강/노랑/파랑 등)
    this.duration = const Duration(seconds: 3),
    this.startAngle = -math.pi / 2, // 시작 각도 (12시 방향)
    this.centerBias = const Offset(0.5, 0.5), // 중심 위치 (0~1 비율)
    this.curve = Curves.easeInOutCubic,
    this.autoplay = true,
    this.keepFinalColor = false,
    this.onCompleted,
  });

  final Color bgColor;
  final Color revealColor;
  final Duration duration;
  final double startAngle;
  final Offset centerBias;
  final Curve curve;
  final bool autoplay;
  final bool keepFinalColor;
  final VoidCallback? onCompleted;

  @override
  State<ClockwiseReveal> createState() => _ClockwiseRevealState();
}

class _ClockwiseRevealState extends State<ClockwiseReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  bool _done = false; // 시계 애니메이션이 완료 되었는지

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _c, curve: widget.curve);

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _done = true);
        widget.onCompleted?.call();
      }
    });

    if (widget.autoplay) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 외부에서 제어 (다시 재생)
  void play({bool fromStart = false}) {
    if (fromStart) {
      _c.forward(from: 0);
    } else {
      _c.forward();
    }
  }

  /// 리셋
  void reset() => _c.value = 0;

  @override
  Widget build(BuildContext context) {
    // ✅ 완료 후 최종 색 유지 옵션
    if (_done && widget.keepFinalColor) {
      return ColoredBox(color: widget.revealColor);
    }

    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        return CustomPaint(
          painter: _SweepPainter(
            bg: widget.bgColor,
            fg: widget.revealColor,
            startAngle: widget.startAngle,
            sweep: _t.value * 2 * math.pi,
            centerBias: widget.centerBias,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

/// 내부 Painter: 시계방향 부채꼴 그리기
class _SweepPainter extends CustomPainter {
  const _SweepPainter({
    required this.bg,
    required this.fg,
    required this.startAngle,
    required this.sweep,
    required this.centerBias,
  });

  final Color bg, fg;
  final double startAngle, sweep;
  final Offset centerBias;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) 배경
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // 2) “거의 다 찼다”면 오차 없이 바로 전체 fg 칠하기 (틈 방지) ✅
    const double tau = 2 * math.pi;
    if (sweep >= tau - 1e-3) {
      canvas.drawRect(Offset.zero & size, Paint()..color = fg);
      return;
    }

    // 2) 반지름 (화면 대각선 길이)
    final radius =
        math.sqrt(size.width * size.width + size.height * size.height);
    final center = Offset(
      size.width * centerBias.dx,
      size.height * centerBias.dy,
    );
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 3) 부채꼴 경로
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, startAngle, sweep, false)
      ..close();

    // 4) 색상 채우기
    canvas.drawPath(path, Paint()..color = fg);
  }

  @override
  bool shouldRepaint(covariant _SweepPainter old) =>
      old.sweep != sweep ||
      old.bg != bg ||
      old.fg != fg ||
      old.startAngle != startAngle ||
      old.centerBias != centerBias;
}
