import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle

class PlaneWritePage extends StatefulWidget {
  const PlaneWritePage({super.key});

  @override
  State<PlaneWritePage> createState() => _PlaneWritePageState();
}

class _PlaneWritePageState extends State<PlaneWritePage> {
  // ====== Intro ======
  bool _showIntro = true; // 앱 진입 시 인트로 화면 노출

  // ====== Writing Stages ======
  // 진행 단계: 0 → plane1, 1 → plane2, 2 → plane3
  int _stage = 0;

  // 각 단계별 가이드 이미지
  static const _guideAssets = <String>[
    'assets/img/contents/studyWrite/plane1.png',
    'assets/img/contents/studyWrite/plane2.png',
    'assets/img/contents/studyWrite/plane3.png',
  ];

  // 진행도(0..1)
  double _progress = 0;

  // 상태 플래그
  bool _isCorrect = false; // 각 단계 정답 오버레이
  bool _showPerfect = false; // 마지막 단계 "완벽해요!"
  bool _showFinishPopup = false; // 완료 팝업
  bool _busyAdvancing = false; // 중복 타이머 방지

  // --------- 가이드라인 위치/크기/투명도 (필요 시 조절) ----------
  static const double _guideWidthFactor = 0.70; // 화면 너비의 70%
  static const double _guideDxFactor = 0.25; // 좌측에서 25% 지점에 시작(왼쪽 +)
  static const double _guideDyFactor = 0.25; // 상단에서 25% 지점에 시작(아래 +)
  static const double _guideOpacity = 0.35; // 가이드 표시 투명도
  // ---------------------------------------------------------------

  // ===== Intro(인트로) 이미지 개별 위치/크기 설정 =====
  // 값은 '화면 크기 대비 비율'이야(0.0 ~ 1.0). 바로 숫자만 바꿔서 미세 조정 가능.

  // plane0 (왼쪽 라인 이미지)
  static const double _introPlane0WidthFactor = 0.4; // 화면 너비의 28% 크기
  static const double _introPlane0LeftFactor = 0.09; // 왼쪽에서 6% 지점
  static const double _introPlane0TopFactor = 0.24; // 위에서 24% 지점

  // plane (오른쪽 비행기 이미지)
  static const double _introPlaneWidthFactor = 0.40; // 화면 너비의 40% 크기
  static const double _introPlaneRightFactor = 0.07; // 오른쪽에서 4% 지점(→ left로 환산)
  static const double _introPlaneTopFactor = 0.16; // 위에서 16% 지점

  void _startWriting() {
    if (!_showIntro) return;
    setState(() => _showIntro = false);
  }

  void _advanceToNextStage() {
    setState(() {
      _stage += 1;
      _isCorrect = false;
      _busyAdvancing = false;
      _progress = 0;
    });
  }

  void _onStageDone() {
    if (_isCorrect || _busyAdvancing) return;
    setState(() => _isCorrect = true);
    _busyAdvancing = true;

    if (_stage < 2) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        _advanceToNextStage();
      });
    } else {
      // 마지막 단계
      setState(() => _showPerfect = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _showPerfect = false;
          _showFinishPopup = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).maybePop(); // AppleGarden 로 복귀
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ====== 배경 (쓰기 단계용) ======
          if (!_showIntro)
            Image.asset(
              'assets/img/contents/studyWrite/bg_plane.png',
              fit: BoxFit.cover,
            ),

          // ====== 드로잉 레이어(가이드 안에서만, 스냅/마스킹/커버리지 판정) ======
          if (!_showIntro)
            PlaneImageGuideLayer(
              key: ValueKey('plane-stage-$_stage'),
              guideAsset: _guideAssets[_stage],
              // 화면 사각형 배치 규칙(정규화)
              leftNorm: _guideDxFactor,
              topNorm: _guideDyFactor,
              widthNorm: _guideWidthFactor,
              guideOpacity: _guideOpacity,
              // 판정 세팅
              targetCoverage: 0.70, // 70% 이상
              snapRadiusPx: 28, // 화면에서 스냅 허용 반경
              stampRadiusPx: 9, // 커버리지 도장 반경
              sampleStridePx: 4, // 샘플 그리드 간격
              onProgress: (p) => setState(() => _progress = p),
              onDone: _onStageDone,
              strokeColor: const ui.Color.fromARGB(255, 0, 80, 255), // 파란 펜
              strokeWidthBasePx: 20,
            ),

          // ====== 인트로 화면 (탭 시 시작) ======
          if (_showIntro)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _startWriting,
              child: Container(
                color: const Color(0xFFFFF2F4), // 연분홍 배경 느낌
                child: Stack(
                  children: [
                    // 선(plane0) + 비행기(plane)
                    // 선(plane0) + 비행기(plane) — 개별 위치/크기 제어
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (_, c) {
                          final w = c.maxWidth;
                          final h = c.maxHeight;

                          // plane0 (왼쪽)
                          final p0W = w * _introPlane0WidthFactor;
                          final p0L = w * _introPlane0LeftFactor;
                          final p0Top = h * _introPlane0TopFactor;

                          // plane (오른쪽 고정 → left 계산으로 변환)
                          final pW = w * _introPlaneWidthFactor;
                          final pLeft = w - (w * _introPlaneRightFactor + pW);
                          final pTop = h * _introPlaneTopFactor;

                          return Stack(
                            children: [
                              // plane0
                              Positioned(
                                left: p0L,
                                top: p0Top,
                                child: SizedBox(
                                  width: p0W, // 높이는 원본 비율대로 자동
                                  child: Image.asset(
                                    'assets/img/contents/studyWrite/plane0.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // plane
                              Positioned(
                                left: pLeft,
                                top: pTop,
                                child: SizedBox(
                                  width: pW, // 높이는 원본 비율대로 자동
                                  child: Image.asset(
                                    'assets/img/contents/studyWrite/plane.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // 하단 문구(2줄)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '비행기를 날려봐요!',
                              style: TextStyle(
                                color: const Color(0xFF7A5F57),
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 2),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                  255,
                                  120,
                                  192,
                                  250,
                                ), // 파란 박스
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Text(
                                '화면을 탭하면 시작해요',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ====== 뒤로가기 ======
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),

          // ====== 하단 안내 문구 (쓰기 단계에서만) ======
          if (!_showIntro)
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '비행기 선을 따라 그려보세요!  ${(_progress * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ====== 단계 정답 오버레이 ======
          if (_isCorrect && _stage < 2) _overlayLabel('정답입니다! 🎉'),

          // ====== 마지막 단계 "완벽해요!" ======
          if (_showPerfect) _overlayLabel('완벽해요! ✨'),

          // ====== 완료 팝업 ======
          if (_showFinishPopup)
            Center(
              child: Container(
                width: 380,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 64,
                      width: 64,
                      child: Image.asset(
                        'assets/img/contents/studyWrite/apple.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '이번 나무의 사과를 획득했어요!\n잠시 후 나무로 돌아가요~',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
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

  // 공통 오버레이 라벨 위젯
  Widget _overlayLabel(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

/* ──────────────────────────────────────────────
   이미지(투명 PNG) 가이드 기반 드로잉/판정 레이어 (완화판)
   ────────────────────────────────────────────── */
class PlaneImageGuideLayer extends StatefulWidget {
  final String guideAsset;

  // 화면 배치 규칙 (정규화: 0..1)
  final double leftNorm;
  final double topNorm;
  final double widthNorm;
  final double guideOpacity;

  // 판정 세팅
  final double targetCoverage; // 예: 0.70
  final double snapRadiusPx; // 화면상 스냅 반경
  final int stampRadiusPx; // 커버 도장 반경(px, 마스크 좌표 기준)
  final int sampleStridePx; // 샘플 격자 간격(px, 마스크 기준)

  final ValueChanged<double> onProgress; // 0..1
  final VoidCallback onDone;

  final ui.Color strokeColor;
  final double strokeWidthBasePx;

  const PlaneImageGuideLayer({
    super.key,
    required this.guideAsset,
    required this.leftNorm,
    required this.topNorm,
    required this.widthNorm,
    required this.guideOpacity,
    required this.targetCoverage,
    required this.snapRadiusPx,
    required this.stampRadiusPx,
    required this.sampleStridePx,
    required this.onProgress,
    required this.onDone,
    required this.strokeColor,
    required this.strokeWidthBasePx,
  });

  @override
  State<PlaneImageGuideLayer> createState() => _PlaneImageGuideLayerState();
}

class _PlaneImageGuideLayerState extends State<PlaneImageGuideLayer> {
  ui.Image? _maskImg;
  Uint8List? _rgba;
  int _gw = 0, _gh = 0;

  // 마지막 포인터의 "마스크 픽셀 좌표"
  Offset? _lastMaskPt;

  // 사각/스케일
  late Rect _guideRect;
  late double _mx, _my;

  // 격자 & 커버리지
  late int _gridW, _gridH, _stride;
  late List<bool> _coveredGrid;
  int _totalSamples = 0, _coveredSamples = 0;

  final List<Offset> _stroke = [];

  bool get _ready => _maskImg != null && _rgba != null;
  double get _coverage =>
      _totalSamples == 0 ? 0.0 : _coveredSamples / _totalSamples;

  // ── 끝점 완화 판정용 엣지/주축 ──
  int _minGXEdge = 0, _maxGXEdge = 0;
  int _minGYEdge = 0, _maxGYEdge = 0;
  bool _useHorizontal = true; // true=가로형(좌↔우), false=세로형(상↔하)

  // 튜닝 상수(원하면 숫자만 바꿔)
  static const double _kEndBandPct = 0.12; // 끝 밴드 폭(주축 대비 비율)
  static const double _kOrthoSlackPct = 0.70; // 직교축 슬랙(비율)
  static const double _kCoverageGrace = 0.92; // 커버리지 그레이스(예: 0.7*0.92=0.644)

  void _resetAttempt() {
    _stroke.clear();
    _coveredGrid = List<bool>.filled(_gridW * _gridH, false);
    _coveredSamples = 0;
    _lastMaskPt = null;
    widget.onProgress(0.0);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMask();
  }

  Future<void> _loadMask() async {
    final size = MediaQuery.of(context).size;

    // 1) 가이드 사각 계산
    final left = size.width * widget.leftNorm;
    final top = size.height * widget.topNorm;
    final guideW = size.width * widget.widthNorm;

    // 원본 비율 유지
    final raw = await rootBundle.load(widget.guideAsset);
    final codec0 = await ui.instantiateImageCodec(raw.buffer.asUint8List());
    final frame0 = await codec0.getNextFrame();
    final srcImg = frame0.image;
    final aspect = srcImg.height / srcImg.width; // H/W
    final guideH = guideW * aspect;

    _guideRect = Rect.fromLTWH(left, top, guideW, guideH);

    // 2) 가이드 크기에 맞춰 다시 디코딩(마스크 용)
    final codec = await ui.instantiateImageCodec(
      raw.buffer.asUint8List(),
      targetWidth: guideW.toInt().clamp(1, 4096),
      targetHeight: guideH.toInt().clamp(1, 4096),
    );
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (!mounted) return;
    _maskImg = img;
    _rgba = byteData!.buffer.asUint8List();
    _gw = img.width;
    _gh = img.height;

    _mx = _gw / _guideRect.width;
    _my = _gh / _guideRect.height;

    // 3) 격자 구축
    _stride = widget.sampleStridePx.clamp(2, 16);
    _gridW = (_gw + _stride - 1) ~/ _stride;
    _gridH = (_gh + _stride - 1) ~/ _stride;
    _coveredGrid = List<bool>.filled(_gridW * _gridH, false);

    // 4) 엣지/주축 계산
    _totalSamples = 0;
    int minGX = 1 << 30, maxGX = -1;
    int minGY = 1 << 30, maxGY = -1;

    for (int gy = 0; gy < _gridH; gy++) {
      for (int gx = 0; gx < _gridW; gx++) {
        if (_alphaOnAtGrid(gx, gy)) {
          _totalSamples++;
          if (gx < minGX) minGX = gx;
          if (gx > maxGX) maxGX = gx;
          if (gy < minGY) minGY = gy;
          if (gy > maxGY) maxGY = gy;
        }
      }
    }

    _minGXEdge = minGX < 0 ? 0 : minGX;
    _maxGXEdge = maxGX < 0 ? _gridW - 1 : maxGX;
    _minGYEdge = minGY < 0 ? 0 : minGY;
    _maxGYEdge = maxGY < 0 ? _gridH - 1 : maxGY;

    final spanX = (_maxGXEdge - _minGXEdge).abs();
    final spanY = (_maxGYEdge - _minGYEdge).abs();
    _useHorizontal = spanX >= spanY;

    _coveredSamples = 0;
    _lastMaskPt = null;
    _stroke.clear();

    setState(() {});
  }

  /// 알파 존재 여부(격자 좌표 -> 실제 샘플 픽셀)
  bool _alphaOnAtGrid(int gx, int gy) {
    final x = (gx * _stride).clamp(0, _gw - 1);
    final y = (gy * _stride).clamp(0, _gh - 1);
    final a = _rgba![(y * _gw + x) * 4 + 3];
    return a > 32;
  }

  // 화면→마스크/마스크→화면
  Offset _toMask(Offset screenPt) => Offset(
    (screenPt.dx - _guideRect.left) * _mx,
    (screenPt.dy - _guideRect.top) * _my,
  );

  // 점-사각형 최소거리
  double _distanceToRect(Offset p, Rect r) {
    final dx =
        (p.dx < r.left)
            ? (r.left - p.dx)
            : (p.dx > r.right)
            ? (p.dx - r.right)
            : 0.0;
    final dy =
        (p.dy < r.top)
            ? (r.top - p.dy)
            : (p.dy > r.bottom)
            ? (p.dy - r.bottom)
            : 0.0;
    return sqrt(dx * dx + dy * dy);
  }

  // 화면 점을 가이드 선 근처의 가장 가까운 마스크 픽셀로 스냅
  Offset? _nearestMaskPoint(Offset rawScreen) {
    if (_distanceToRect(rawScreen, _guideRect) > widget.snapRadiusPx) {
      return null;
    }

    final local = Offset(
      (rawScreen.dx - _guideRect.left).clamp(0.0, _guideRect.width),
      (rawScreen.dy - _guideRect.top).clamp(0.0, _guideRect.height),
    );
    final m = Offset(local.dx * _mx, local.dy * _my);

    final rMask = max(1, (widget.snapRadiusPx * _mx).ceil());
    double bestD2 = 1e12;
    Offset? best;
    final cx = m.dx.round(), cy = m.dy.round();

    for (int dy = -rMask; dy <= rMask; dy++) {
      final y = cy + dy;
      if (y < 0 || y >= _gh) continue;
      for (int dx = -rMask; dx <= rMask; dx++) {
        final x = cx + dx;
        if (x < 0 || x >= _gw) continue;
        final a = _rgba![(y * _gw + x) * 4 + 3];
        if (a <= 32) continue; // 투명 제외
        final d2 = (dx * dx + dy * dy).toDouble();
        if (d2 < bestD2) {
          bestD2 = d2;
          best = Offset(x.toDouble(), y.toDouble());
        }
      }
    }
    if (best == null) return null;
    if (sqrt(bestD2) > widget.snapRadiusPx * _mx) return null;
    // 마스크→스크린 변환
    return Offset(
      _guideRect.left + best.dx / _mx,
      _guideRect.top + best.dy / _my,
    );
  }

  // 격자에 도장
  void _stampAtMaskGrid(Offset maskPt) {
    final cx = (maskPt.dx / _stride).round();
    final cy = (maskPt.dy / _stride).round();
    final rGrid = max(1, (widget.stampRadiusPx / _stride).ceil());

    for (int gy = cy - rGrid; gy <= cy + rGrid; gy++) {
      if (gy < 0 || gy >= _gridH) continue;
      for (int gx = cx - rGrid; gx <= cx + rGrid; gx++) {
        if (gx < 0 || gx >= _gridW) continue;
        if ((gx - cx) * (gx - cx) + (gy - cy) * (gy - cy) > rGrid * rGrid) {
          continue;
        }

        final idx = gy * _gridW + gx;
        if (!_coveredGrid[idx] && _alphaOnAtGrid(gx, gy)) {
          _coveredGrid[idx] = true;
          _coveredSamples++;
        }
      }
    }
  }

  // 진행 업데이트
  void _updateProgress(Offset maskPt) {
    final cov = _coverage;
    widget.onProgress(cov);
    _lastMaskPt = maskPt;
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    return Stack(
      children: [
        // 반투명 가이드
        Positioned.fromRect(
          rect: _guideRect,
          child: Opacity(
            opacity: widget.guideOpacity,
            child: RawImage(image: _maskImg, fit: BoxFit.fill),
          ),
        ),

        // 제스처 + 스트로크(마스크 밖으로는 dstIn으로 잘림)
        Positioned.fill(
          child: GestureDetector(
            onPanStart: (d) {
              _resetAttempt(); // 한 번의 연속 획만 판단
              final snapped = _nearestMaskPoint(d.localPosition);
              if (snapped == null) return;

              final m = _toMask(snapped);
              _stroke.add(snapped);
              _stampAtMaskGrid(m);
              _updateProgress(m);
              setState(() {});
            },
            onPanUpdate: (d) {
              final snapped = _nearestMaskPoint(d.localPosition);
              if (snapped == null) return;
              if (_stroke.isEmpty || (_stroke.last - snapped).distance >= 2.0) {
                _stroke.add(snapped);
                final m = _toMask(snapped);
                _stampAtMaskGrid(m);
                _updateProgress(m);
                setState(() {});
              }
            },
            onPanEnd: (d) {
              final cov = _coverage;

              bool endReached = false;
              if (_lastMaskPt != null) {
                final gm = Offset(
                  _lastMaskPt!.dx / _stride,
                  _lastMaskPt!.dy / _stride,
                );

                if (_useHorizontal) {
                  // X 밴드 + Y 슬랙
                  final bandGX = (_gridW * _kEndBandPct).ceil().clamp(
                    1,
                    _gridW,
                  );
                  final leftBandMaxX = (_minGXEdge + bandGX).clamp(
                    0,
                    _gridW - 1,
                  );
                  final rightBandMinX = (_maxGXEdge - bandGX).clamp(
                    0,
                    _gridW - 1,
                  );

                  final ySlack = (_gridH * _kOrthoSlackPct * 0.5).ceil();
                  final centerY = _gridH / 2.0;

                  final inLeftBand = gm.dx <= leftBandMaxX;
                  final inRightBand = gm.dx >= rightBandMinX;
                  final inYSlack = (gm.dy - centerY).abs() <= ySlack;

                  endReached = (inLeftBand || inRightBand) && inYSlack;
                } else {
                  // Y 밴드 + X 슬랙
                  final bandGY = (_gridH * _kEndBandPct).ceil().clamp(
                    1,
                    _gridH,
                  );
                  final topBandMaxY = (_minGYEdge + bandGY).clamp(
                    0,
                    _gridH - 1,
                  );
                  final bottomBandMinY = (_maxGYEdge - bandGY).clamp(
                    0,
                    _gridH - 1,
                  );

                  final xSlack = (_gridW * _kOrthoSlackPct * 0.5).ceil();
                  final centerX = _gridW / 2.0;

                  final inTopBand = gm.dy <= topBandMaxY;
                  final inBottomBand = gm.dy >= bottomBandMinY;
                  final inXSlack = (gm.dx - centerX).abs() <= xSlack;

                  endReached = (inTopBand || inBottomBand) && inXSlack;
                }
              }

              final covNeed = (widget.targetCoverage * _kCoverageGrace).clamp(
                0.0,
                1.0,
              );
              final success = endReached && cov >= covNeed;

              if (success) {
                widget.onDone();
              } else {
                _resetAttempt(); // 실패 시 재시도
              }
            },
            child: CustomPaint(
              painter: _MaskClippedStrokePainter(
                stroke: _stroke,
                maskImage: _maskImg!, // _ready일 때만
                maskSrcRect: Rect.fromLTWH(
                  0,
                  0,
                  _gw.toDouble(),
                  _gh.toDouble(),
                ),
                maskDstRect: _guideRect,
                strokeColor: widget.strokeColor,
                strokeWidth: max(
                  widget.strokeWidthBasePx,
                  MediaQuery.of(context).size.shortestSide * 0.028,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* 마스크(dstIn)로 밖을 잘라내는 스트로크 렌더러 (변경 없음) */
class _MaskClippedStrokePainter extends CustomPainter {
  final List<Offset> stroke;

  final ui.Image maskImage;
  final Rect maskSrcRect;
  final Rect maskDstRect;
  final Color strokeColor;
  final double strokeWidth;

  _MaskClippedStrokePainter({
    required this.stroke,
    required this.maskImage,
    required this.maskSrcRect,
    required this.maskDstRect,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stroke.length < 2) return;

    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }

    canvas.saveLayer(maskDstRect, Paint());

    final paint =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;
    canvas.drawPath(path, paint);

    canvas.drawImageRect(
      maskImage,
      maskSrcRect,
      maskDstRect,
      Paint()..blendMode = BlendMode.dstIn,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MaskClippedStrokePainter old) =>
      old.stroke != stroke ||
      old.maskImage != maskImage ||
      old.maskSrcRect != maskSrcRect ||
      old.maskDstRect != maskDstRect ||
      old.strokeColor != strokeColor ||
      old.strokeWidth != strokeWidth;
}
