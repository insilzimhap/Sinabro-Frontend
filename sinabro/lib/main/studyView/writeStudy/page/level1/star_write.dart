import 'dart:math';
import 'package:flutter/material.dart';

/// 별-잇기: 인트로(별들을 이어봐요!) -> 플레이 -> 완료(배너/별들/보상)
class ConstellationDrawPage extends StatefulWidget {
  const ConstellationDrawPage({super.key});
  @override
  State<ConstellationDrawPage> createState() => _ConstellationDrawPageState();
}

// 에셋 경로
const _dir = 'assets/img/contents/studyWrite/';
const _bgSky = '${_dir}bg_sky.png';
const _starImg = '${_dir}star.png';
const _celeStars = '${_dir}stars.png'; // ⭐ 세 개 별 이미지 (파일명: stars.png)
const _appleImg = '${_dir}apple.png';

enum _FlowPhase { intro, play, banner, celebrate, reward }

class _ConstellationDrawPageState extends State<ConstellationDrawPage> {
  /// 0~1 정규화 좌표
  final List<Offset> _stars = const [
    Offset(0.18, 0.72),
    Offset(0.24, 0.46),
    Offset(0.44, 0.37),
    Offset(0.58, 0.53),
    Offset(0.80, 0.42),
    Offset(0.88, 0.68),
  ];

  int _progress = 0; // 현재 목표: star[i] -> star[i+1]
  final List<Offset> _stroke = []; // 진행 중 빨간 선
  final List<List<Offset>> _confirmed = []; // 확정된 노란 선
  _FlowPhase _phase = _FlowPhase.intro; // 인트로부터 시작

  // ------------------ 제스처 ------------------
  bool get _gesturesEnabled => _phase == _FlowPhase.play;

  void _onPanStart(DragStartDetails d, Size size) {
    if (!_gesturesEnabled) return;
    _stroke.clear();
    final p = d.localPosition;

    final start = _px(size, _stars[_progress]);
    if ((p - start).distance <= _starRadius(size) * 1.6) {
      setState(() => _stroke.add(p));
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_gesturesEnabled) return;
    if (_stroke.isNotEmpty) {
      setState(() => _stroke.add(d.localPosition));
    }
  }

  void _onPanEnd(Size size) {
    if (!_gesturesEnabled) return;
    if (_stroke.length < 3) {
      setState(() => _stroke.clear());
      return;
    }

    final a = _px(size, _stars[_progress]);
    final b = _px(size, _stars[_progress + 1]);

    final ok = _validateStroke(_stroke, a, b, corridor: _corridor(size));
    if (ok) {
      setState(() {
        _confirmed.add([a, b]);
        _progress++;
        _stroke.clear();
      });

      if (_progress >= _stars.length - 1) {
        _startFinishFlow(); // 모두 연결 완료
      }
    } else {
      setState(() => _stroke.clear());
    }
  }

  // ------------------ 완료 시퀀스 ------------------
  void _startFinishFlow() async {
    if (!mounted) return;
    setState(() => _phase = _FlowPhase.banner); // 1) 완벽해요!

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _phase = _FlowPhase.celebrate); // 2) 별들(stars)

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _phase = _FlowPhase.reward); // 3) 보상 팝업

    await Future.delayed(const Duration(seconds: 2)); // 자동 복귀
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  // ------------------ 판정 ------------------
  bool _validateStroke(
    List<Offset> pts,
    Offset a,
    Offset b, {
    required double corridor,
  }) {
    // ▶ 시작/끝 문턱을 조금 넓게
    final gate = max(corridor * 1.3, 22);
    final startNear = (pts.first - a).distance <= gate;
    final endNear = (pts.last - b).distance <= gate;
    if (!(startNear && endNear)) return false;

    // 커버리지 및 거리 통계
    double maxD = 0;
    double tMin = double.infinity, tMax = -double.infinity;
    final ab = b - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    int insideCount = 0;
    final tube = corridor * 1.4; // ▶ 관 통로 조금 더 굵게

    for (final p in pts) {
      final ap = p - a;
      double t = (ap.dx * ab.dx + ap.dy * ab.dy) / ab2;
      t = t.clamp(0.0, 1.0);
      final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
      final d = (p - proj).distance;

      if (d > maxD) maxD = d;
      if (t < tMin) tMin = t;
      if (t > tMax) tMax = t;
      if (d <= tube) insideCount++;
    }

    // ▶ 덜 빡센 커버리지: 시작·끝에서 25%~75% 이상 커버
    final coveredEnough = tMin <= 0.25 && tMax >= 0.75;
    // ▶ 전체 포인트 중 70% 이상이 통로 안이면 성공
    final fractionInside = insideCount / pts.length;
    final insideEnough = fractionInside >= 0.70;
    // ▶ 큰 튀김(아웃라이어)도 어느 정도 허용
    final outlierOK = maxD <= corridor * 1.8;

    return coveredEnough && insideEnough && outlierOK;
  }

  // ------------------ 유틸 ------------------
  int _visibleCount() {
    final v = _progress + 2; // 처음 2개, 성공 때마다 +1
    return v > _stars.length ? _stars.length : v;
  }

  Offset _px(Size size, Offset norm) =>
      Offset(norm.dx * size.width, norm.dy * size.height);

  double _starRadius(Size size) => max(24, size.shortestSide * 0.04);
  double _corridor(Size size) => max(14, size.shortestSide * 0.03);

  void _reset() {
    setState(() {
      _progress = 0;
      _stroke.clear();
      _confirmed.clear();
      _phase = _FlowPhase.play;
    });
  }

  void _goPlay() => setState(() => _phase = _FlowPhase.play);

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // 1) 인트로
    if (_phase == _FlowPhase.intro) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF4F0),
        body: Stack(
          children: [
            Positioned(
              left: 8,
              top: 8 + topPad,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: const Color(0xFF5A4032),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _goPlay, // 탭하면 시작
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(_starImg, width: 180, height: 180),
                    const SizedBox(height: 20),
                    const Text(
                      '별들을 이어봐요!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5A4032),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6A7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '화면을 탭하면 시작해요',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4E3B00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2) 플레이/연출
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final starR = _starRadius(size);
          final corridor = _corridor(size);

          return GestureDetector(
            onPanStart: (d) => _onPanStart(d, size),
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(size),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 배경
                Image.asset(_bgSky, fit: BoxFit.cover),

                // 노란(확정) + 빨간(진행)
                CustomPaint(
                  painter: _PathPainter(
                    confirmed: _confirmed,
                    liveStroke: _gesturesEnabled ? _stroke : const [],
                    liveColor: Colors.redAccent,
                    corridor: corridor,
                  ),
                ),

                // 별들 (현재 단계까지만)
                ...List.generate(_visibleCount(), (i) {
                  final p = _px(size, _stars[i]);
                  return Positioned(
                    left: p.dx - starR,
                    top: p.dy - starR,
                    width: starR * 2,
                    height: starR * 2,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('star-$i-$_progress'),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 280),
                      builder:
                          (_, t, child) => Transform.scale(
                            scale: 0.85 + 0.15 * t,
                            child: Opacity(opacity: t, child: child),
                          ),
                      child: Image.asset(_starImg, fit: BoxFit.contain),
                    ),
                  );
                }),

                // 좌상단 리셋
                Positioned(
                  left: 8,
                  top: 8 + topPad,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.white.withOpacity(0.9),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),

                // ✅ 우상단 단계 텍스트(1->2번 …)는 제거됨

                // 1) 완료 배너
                if (_phase == _FlowPhase.banner) _PerfectBanner(),

                // 2) 축하: stars.png 페이드/스케일 인
                if (_phase == _FlowPhase.celebrate)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder:
                          (_, t, child) => Opacity(
                            opacity: t,
                            child: Transform.scale(
                              scale: 0.85 + 0.15 * t,
                              child: child,
                            ),
                          ),
                      child: Image.asset(
                        _celeStars,
                        width: size.shortestSide * 0.65,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // 3) 보상 팝업
                if (_phase == _FlowPhase.reward) _RewardPopup(size: size),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 노란 확정 선 + 빨간 진행 선
class _PathPainter extends CustomPainter {
  final List<List<Offset>> confirmed;
  final List<Offset> liveStroke;
  final Color liveColor;
  final double corridor;

  _PathPainter({
    required this.confirmed,
    required this.liveStroke,
    required this.liveColor,
    required this.corridor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final yellow =
        Paint()
          ..color = const Color(0xFFF6D648)
          ..strokeWidth = max(6, size.shortestSide * 0.01)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (final seg in confirmed) {
      final path =
          Path()
            ..moveTo(seg.first.dx, seg.first.dy)
            ..lineTo(seg.last.dx, seg.last.dy);
      canvas.drawPath(path, yellow);
    }

    if (liveStroke.length > 1) {
      final red =
          Paint()
            ..color = liveColor
            ..strokeWidth = max(5, size.shortestSide * 0.012)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(liveStroke.first.dx, liveStroke.first.dy);
      for (int i = 1; i < liveStroke.length; i++) {
        path.lineTo(liveStroke[i].dx, liveStroke[i].dy);
      }
      canvas.drawPath(path, red);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.confirmed != confirmed ||
      old.liveStroke != liveStroke ||
      old.corridor != corridor;
}

// ------------------ 완벽해요 배너 ------------------
class _PerfectBanner extends StatefulWidget {
  @override
  State<_PerfectBanner> createState() => _PerfectBannerState();
}

class _PerfectBannerState extends State<_PerfectBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE27A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            '완벽해요!',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4E3B00),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ 보상 팝업 ------------------
class _RewardPopup extends StatelessWidget {
  final Size size;
  const _RewardPopup({required this.size});

  @override
  Widget build(BuildContext context) {
    final cardW = min(size.width * 0.72, 520.0);
    return Container(
      color: Colors.black.withOpacity(0.25), // dim
      alignment: Alignment.center,
      child: Container(
        width: cardW,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF1C8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_appleImg, height: 72, fit: BoxFit.contain),
            const SizedBox(height: 14),
            const Text(
              '이번 나무의 사과를 획득했어요!\n잠시 후 나무로 돌아가요~',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5A4032),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
