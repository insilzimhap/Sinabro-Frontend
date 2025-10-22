// lib/main/gameView/writeGame/page/level1/write_game_1_3.dart
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';

enum _Scene { birds, snail, outro }

/* ───────────────── visual constants ───────────────── */
const Color kGuideBaseColor = Color(0xFFDBDBDB);
const Color kGuidePassColor = Color(0xFF27AE60);
const double kGuideStrokeWidth = 10.0;
const double kPassedStrokeWidth = 10.0;

/* ───────────────── layout constants ───────────────── */
const double kTitleTopGap = 12;

/* ======================= Scene A: Birds (이미지 마스크 3줄) ======================= */
// 오른쪽 새 PNG(보기용)
const int kBirdLines = 3;
const double kBirdTop = 160;
const double kBirdRowGap = 155;
const double kBirdImgRight = 24;
const double kBirdImgSize = 100;

// 마스크(plane3) 배치/판정
const String kBirdGuideAsset = 'assets/img/contents/studyWrite/plane3.png';

// 첫 줄 기준 배치(정규화). 두번째/세번째 줄은 화면 높이 대비 kBirdRowGap만큼 아래로.
const double kBirdGuideLeftNorm = 0.10; // 왼쪽에서 10%
const double kBirdGuideTopNorm = 0.22; // 첫 줄 top 비율(대략 새 첫 줄 높이와 맞춤)
const double kBirdGuideWidthNorm = 0.80; // 화면 너비의 80%
const double kBirdGuideOpacity = 1.0;
const Color kBirdGuideTint = Color(0xFFB3B3B3); // 항상 회색으로 보이게

// 각 줄(0,1,2)의 마스크 배치를 개별로 덮어쓰기 위한 설정
class BirdRowLayout {
  final double? leftNorm; // 0..1 (null이면 기본값 사용)
  final double? topNorm; // 0..1 (null이면 기본값 + 줄간격 사용)
  final double? widthNorm; // 0..1 (null이면 기본값 사용)
  final double dxPx; // 픽셀 이동(+우측/-좌측)
  final double dyPx; // 픽셀 이동(+아래/-위)
  const BirdRowLayout({
    this.leftNorm,
    this.topNorm,
    this.widthNorm,
    this.dxPx = 0,
    this.dyPx = 0,
  });
}

// ★ 여기서 숫자만 바꿔서 각 줄을 따로 조절하세요.
const List<BirdRowLayout> kBirdRowOverrides = <BirdRowLayout>[
  BirdRowLayout(
    // 예) 첫 줄을 살짝 왼쪽으로 8px, 위로 6px 올리기
    widthNorm: 0.4,
    dxPx: -8,
    dyPx: -50,
    // widthNorm: 0.78,
  ),
  BirdRowLayout(
    // 예) 가운데 줄만 좀 더 좁게
    // widthNorm: 0.76,
    widthNorm: 0.4,
    dxPx: 500,
    dyPx: -50,
  ),
  BirdRowLayout(
    // 예) 세 번째 줄을 오른쪽으로 12px, 아래로 10px
    // dxPx: 12, dyPx: 10,
    widthNorm: 0.4,
    dxPx: -8,
    dyPx: -50,
  ),
];

// 판정/드로잉
const double kBirdTargetCoverage = 0.70;
const double kBirdSnapRadiusPx = 26;
const int kBirdStampRadiusPx = 8;
const int kBirdSampleStridePx = 4;
const ui.Color kBirdStrokeColor = ui.Color(0xFF0050FF);
const double kBirdStrokeBasePx = 18;

/* ======================= Scene B: Snail (이미지 + 나선) ======================= */
const String kSnailAsset = 'assets/img/contents/gameWrite/snail.png';
const double kSnailImgLeft = 24;
const double kSnailImgTop = 110;
const double kSnailImgWidth = 650;
const double kSnailImgHeight = 650;

const double kSpiralCxRatio = 0.70;
const double kSpiralCyRatio = 0.50;
const Offset kSpiralCenterOffset = Offset(0, 0);
const double kSpiralStartR = 10.0; // a
const double kSpiralGrowth = 15.5; // b
const double kSpiralTurns = 2.5; // 회전수
const int kSpiralSteps = 240;

const double kSpiralDash = 16;
const double kSpiralGap = 20;

/* ───────────────── page ───────────────── */
class WriteGameLevel1_3Page extends StatefulWidget {
  const WriteGameLevel1_3Page({super.key, required this.childId});
  final String childId;

  @override
  State<WriteGameLevel1_3Page> createState() => _WriteGameLevel1_3PageState();
}

class _WriteGameLevel1_3PageState extends State<WriteGameLevel1_3Page> {
  _Scene scene = _Scene.birds;

  // 씬 B(달팽이) 판정용
  late List<bool> passed = List.filled(_lineCount, false);
  int? activeLine;
  List<Offset> stroke = [];

  // 씬 A(새) 3줄 완료 여부
  List<bool> birdsPassed = List<bool>.filled(kBirdLines, false);

  static const double tol = 22.0;
  static const double startPickTol = 64.0;
  static const double hitRatio = 0.72;
  static const double coverageRatio = 0.72;

  int get _lineCount => scene == _Scene.snail ? 1 : 0;
  bool get _allPassed => passed.every((e) => e);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /* ───────────────── guides (씬 B) ───────────────── */
  List<_GuidePath> _buildSnailGuide(Size size) {
    final center =
        Offset(size.width * kSpiralCxRatio, size.height * kSpiralCyRatio) +
        kSpiralCenterOffset;

    final a = kSpiralStartR, b = kSpiralGrowth, turns = kSpiralTurns;
    const steps = kSpiralSteps;

    final pts = <Offset>[];
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final th = t * turns * 2 * math.pi;
      final r = a + b * th;
      pts.add(
        Offset(center.dx + r * math.cos(th), center.dy + r * math.sin(th)),
      );
    }
    return [_GuidePath.polyline(pts)];
  }

  /* ───────────────── input (씬 B) ───────────────── */
  void _onPanStart(DragStartDetails d, Size size) {
    if (_allPassed || scene != _Scene.snail) return;

    final guides = _buildSnailGuide(size);

    int? pick;
    double best = double.infinity;
    for (int i = 0; i < guides.length; i++) {
      if (passed[i]) continue;
      final dist = guides[i].distanceTo(d.localPosition);
      if (dist < best && dist <= startPickTol) {
        best = dist;
        pick = i;
      }
    }
    activeLine = pick;
    stroke = pick == null ? [] : [d.localPosition];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (activeLine == null || scene != _Scene.snail) return;
    stroke.add(d.localPosition);
    setState(() {});
  }

  void _onPanEnd(Size size) {
    if (activeLine == null || scene != _Scene.snail) return;

    final guides = _buildSnailGuide(size);
    final ok = _gradeStroke(stroke, guides[activeLine!]);

    if (ok) {
      passed[activeLine!] = true;
      stroke.clear();
      activeLine = null;
      setState(() {});
      if (_allPassed) {
        setState(() => scene = _Scene.outro);
      }
    } else {
      stroke.clear();
      activeLine = null;
      setState(() {});
    }
  }

  bool _gradeStroke(List<Offset> pts, _GuidePath guide) {
    if (pts.length < 6) return false;

    int hit = 0;
    for (final p in pts) {
      if (guide.distanceTo(p) <= tol) hit++;
    }
    final ratio = hit / pts.length;

    const bins = 48;
    final covered = List<bool>.filled(bins, false);
    for (final p in pts) {
      final t = guide.project01(p);
      if (t >= 0 && t <= 1) {
        final idx = (t * (bins - 1)).round().clamp(0, bins - 1);
        covered[idx] = true;
      }
    }
    final coverage = covered.where((v) => v).length / bins;
    return ratio >= hitRatio && coverage >= coverageRatio;
  }

  /* ───────────────── UI ───────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);

          // ===== Scene A: 새 3줄(plane3 마스크 3개) =====
          if (scene == _Scene.birds) {
            return Stack(
              children: [
                const _TitleBanner(text: '따라그려봐요!'),

                _buildSceneBirdsImageGuide(size),

                // 오른쪽 새 PNG 3개(장식)
                ...List.generate(kBirdLines, (i) {
                  final top = kBirdTop - 10 + i * kBirdRowGap;
                  return Positioned(
                    right: kBirdImgRight,
                    top: top.toDouble(),
                    width: kBirdImgSize,
                    height: kBirdImgSize,
                    child: Image.asset(
                      'assets/img/contents/gameWrite/bird.png',
                      fit: BoxFit.contain,
                    ),
                  );
                }),
              ],
            );
          }

          // ===== Scene B / Outro =====
          return GestureDetector(
            onPanStart: (d) => _onPanStart(d, size),
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(size),
            child: Stack(
              children: [
                const _TitleBanner(text: '따라그려봐요!'),

                if (scene == _Scene.snail) _buildSceneSnail(size),

                if (scene == _Scene.outro)
                  Positioned.fill(
                    child: OutroOverlay(
                      autoFinish: true,
                      onFinished: () {
                        if (!mounted) return;
                        _showClearPopup(context);
                      },
                      config: const Outro3Config(
                        row1: OutroRowConfig(
                          strikeUseAngle: true,
                          strikeCenterPct: Offset(0.36, 0.33),
                          strikeAngleDeg: -22,
                          strikeLengthRatio: 0.35,
                          strikeWidth: 8.0,
                          strikeColor: Color(0xFFD92B2B),
                          checkCenterPct: Offset(0.155, 0.425),
                          checkSizePx: 65.0,
                          checkStrokeWidth: 8.0,
                          checkColor: Color(0xFFD92B2B),
                          checkRotationDeg: -8,
                          stampPosPct: Offset(0.505, 0.07),
                          stampDropPx: Offset(120, -140),
                          stampStartScale: 0.10,
                          stampFinalScale: 1,
                          stampRotationDeg: -7,
                        ),
                        row2: OutroRowConfig(
                          strikeUseAngle: true,
                          strikeCenterPct: Offset(0.45, 0.47),
                          strikeAngleDeg: -22,
                          strikeLengthRatio: 0.45,
                          strikeWidth: 8.0,
                          strikeColor: Color(0xFFD92B2B),
                          checkCenterPct: Offset(0.2, 0.584),
                          checkSizePx: 65.0,
                          checkStrokeWidth: 8.0,
                          checkColor: Color(0xFFD92B2B),
                          checkRotationDeg: -8,
                          stampPosPct: Offset(0.655, 0.16),
                          stampDropPx: Offset(150, -140),
                          stampStartScale: 0.10,
                          stampFinalScale: 1.0,
                          stampRotationDeg: -8,
                        ),
                        row3: OutroRowConfig(
                          strikeUseAngle: true,
                          strikeCenterPct: Offset(0.5, 0.63),
                          strikeAngleDeg: -22,
                          strikeLengthRatio: 0.46,
                          strikeWidth: 8.0,
                          strikeColor: Color(0xFFD92B2B),
                          checkCenterPct: Offset(0.25, 0.74),
                          checkSizePx: 65.0,
                          checkStrokeWidth: 8.0,
                          checkColor: Color(0xFFD92B2B),
                          checkRotationDeg: -8,
                          stampPosPct: Offset(0.7, 0.32),
                          stampDropPx: Offset(160, -160),
                          stampStartScale: 0.10,
                          stampFinalScale: 1.0,
                          stampRotationDeg: -8,
                        ),
                      ),
                    ),
                  ),

                if (stroke.isNotEmpty && scene == _Scene.snail)
                  CustomPaint(
                    size: size,
                    painter: _StrokePainter(
                      points: stroke,
                      color: const Color(0xFFEB5757),
                      width: kPassedStrokeWidth,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 씬 A: plane3 마스크 3줄(참새 높이 정렬) ──
  // ── 씬 A: plane3 마스크 3줄(참새 높이 정렬 + 개별 오버라이드) ──
  Widget _buildSceneBirdsImageGuide(Size size) {
    // 기본: 첫줄은 kBirdGuideTopNorm, 2/3줄은 화면높이 대비 kBirdRowGap 만큼 아래
    final rowGapNorm = kBirdRowGap / size.height;

    return Stack(
      children: List.generate(kBirdLines, (i) {
        final baseTopNorm = kBirdGuideTopNorm + rowGapNorm * i;

        // 줄별 오버라이드 적용
        final ov =
            (i < kBirdRowOverrides.length)
                ? kBirdRowOverrides[i]
                : const BirdRowLayout();

        final leftNorm =
            (ov.leftNorm ?? kBirdGuideLeftNorm) + (ov.dxPx / size.width);
        final topNorm = (ov.topNorm ?? baseTopNorm) + (ov.dyPx / size.height);
        final widthNorm = (ov.widthNorm ?? kBirdGuideWidthNorm);

        return ImageMaskGuideLayer(
          key: ValueKey(
            'bird-row-$i-${birdsPassed[i]}-$leftNorm-$topNorm-$widthNorm',
          ),
          enabled: !birdsPassed[i],
          guideAsset: kBirdGuideAsset,
          leftNorm: leftNorm.clamp(0.0, 1.0),
          topNorm: topNorm.clamp(0.0, 1.0),
          widthNorm: widthNorm.clamp(0.0, 1.0),
          guideOpacity: kBirdGuideOpacity,
          guideTint: kBirdGuideTint, // 회색 틴트
          targetCoverage: kBirdTargetCoverage,
          snapRadiusPx: kBirdSnapRadiusPx,
          stampRadiusPx: kBirdStampRadiusPx,
          sampleStridePx: kBirdSampleStridePx,
          strokeColor: kBirdStrokeColor,
          strokeWidthBasePx: kBirdStrokeBasePx,
          onProgress: (_) {},
          onDone: () {
            if (!mounted) return;
            setState(() => birdsPassed[i] = true);
            if (birdsPassed.every((e) => e)) {
              setState(() {
                scene = _Scene.snail;
                passed = List.filled(_lineCount, false);
              });
            }
          },
        );
      }),
    );
  }

  // ── 씬 B: 달팽이 ──
  Widget _buildSceneSnail(Size size) {
    final guides = _buildSnailGuide(size);
    return Stack(
      children: [
        const Positioned(
          left: kSnailImgLeft,
          top: kSnailImgTop,
          width: kSnailImgWidth,
          height: kSnailImgHeight,
          child: _Asset(kSnailAsset),
        ),
        CustomPaint(
          size: size,
          painter: _GuidePainter(
            guides: guides,
            dash: kSpiralDash,
            gap: kSpiralGap,
            color: kGuideBaseColor,
            strokeWidth: kGuideStrokeWidth,
          ),
        ),
        CustomPaint(
          size: size,
          painter: _PassedPainter(
            guides: guides,
            passed: passed,
            color: kGuidePassColor,
            strokeWidth: kPassedStrokeWidth,
          ),
        ),
      ],
    );
  }

  // 완료 팝업 → 메인
  void _showClearPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8DC),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/contents/gameWrite/stamp.png',
                    width: 84,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '이번 단계를 클리어했어요!\n다음 단계도 도전해봐요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WriteGameMainPage(childId: widget.childId),
        ),
      );
    });
  }
}

/* ───────────────── Outro: 3 rows configurable ───────────────── */
class OutroRowConfig {
  const OutroRowConfig({
    // strike
    this.strikeColor = const Color(0xFFD92B2B),
    this.strikeWidth = 8.0,
    // (A) direct
    this.strikeStartPct = const Offset(0.23, 0.31),
    this.strikeEndPct = const Offset(0.82, 0.31),
    // (B) angle/length
    this.strikeUseAngle = false,
    this.strikeCenterPct = const Offset(0.52, 0.36),
    this.strikeAngleDeg = -18,
    this.strikeLengthRatio = 0.65,
    // check
    this.checkColor = const Color(0xFFD92B2B),
    this.checkStrokeWidth = 6.0,
    this.checkCenterPct = const Offset(0.195, 0.445),
    this.checkSizePx = 34.0,
    this.checkRotationDeg = 0.0,
    // stamp
    this.stampAsset = 'assets/img/contents/gameWrite/stamp.png',
    this.stampPosPct = const Offset(0.705, 0.14),
    this.stampDropPx = const Offset(120, -140),
    this.stampStartScale = 0.10,
    this.stampFinalScale = 1.00,
    this.stampRotationDeg = 0.0,
    this.stampWidthRatio,
    this.stampSizePx,
  });

  final Color strikeColor;
  final double strikeWidth;
  final Offset strikeStartPct;
  final Offset strikeEndPct;
  final bool strikeUseAngle;
  final Offset strikeCenterPct;
  final double strikeAngleDeg;
  final double strikeLengthRatio;

  final Color checkColor;
  final double checkStrokeWidth;
  final Offset checkCenterPct;
  final double checkSizePx;
  final double checkRotationDeg;

  final String stampAsset;
  final Offset stampPosPct;
  final Offset stampDropPx;
  final double stampStartScale;
  final double stampFinalScale;
  final double stampRotationDeg;
  final double? stampWidthRatio;
  final double? stampSizePx;
}

class Outro3Config {
  const Outro3Config({
    this.noteWidthRatio = 0.86,
    this.noteAspect = 0.72,
    this.backgroundColor = Colors.white,
    this.noteAsset = 'assets/img/contents/gameWrite/outro_note2.png',
    this.fadeDuration = const Duration(milliseconds: 600),
    this.sequenceDuration = const Duration(milliseconds: 5400),
    this.row1 = const OutroRowConfig(),
    this.row2 = const OutroRowConfig(),
    this.row3 = const OutroRowConfig(),
  });

  final double noteWidthRatio;
  final double noteAspect;
  final Color backgroundColor;
  final String noteAsset;
  final Duration fadeDuration;
  final Duration sequenceDuration;

  final OutroRowConfig row1, row2, row3;

  Offset _toNoteXY(Size noteSize, Offset pct) =>
      Offset(noteSize.width * pct.dx, noteSize.height * pct.dy);
}

class OutroOverlay extends StatefulWidget {
  const OutroOverlay({
    super.key,
    required this.onFinished,
    this.config = const Outro3Config(),
    this.autoFinish = false,
  });

  final VoidCallback onFinished;
  final Outro3Config config;
  final bool autoFinish;

  @override
  State<OutroOverlay> createState() => _OutroOverlayState();
}

class _OutroOverlayState extends State<OutroOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _seqCtrl;
  late final Animation<double> _fade;

  late final Animation<double> _tStrike1, _tCheck1, _tStamp1;
  late final Animation<double> _tStrike2, _tCheck2, _tStamp2;
  late final Animation<double> _tStrike3, _tCheck3, _tStamp3;

  Outro3Config get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: cfg.fadeDuration);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _seqCtrl = AnimationController(vsync: this, duration: cfg.sequenceDuration);

    _tStrike1 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.00, 0.11, curve: Curves.easeOutCubic),
    );
    _tCheck1 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.11, 0.22, curve: Curves.easeOutCubic),
    );
    _tStamp1 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.22, 0.333, curve: Curves.elasticOut),
    );

    _tStrike2 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.333, 0.444, curve: Curves.easeOutCubic),
    );
    _tCheck2 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.444, 0.555, curve: Curves.easeOutCubic),
    );
    _tStamp2 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.555, 0.666, curve: Curves.elasticOut),
    );

    _tStrike3 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.666, 0.777, curve: Curves.easeOutCubic),
    );
    _tCheck3 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.777, 0.888, curve: Curves.easeOutCubic),
    );
    _tStamp3 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.888, 1.000, curve: Curves.elasticOut),
    );

    _seqCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && widget.autoFinish) {
        widget.onFinished();
      }
    });
    _fadeCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _seqCtrl.forward();
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _seqCtrl.dispose();
    super.dispose();
  }

  OffsetPair _strikePoints(Size noteSize, double noteW, OutroRowConfig rc) {
    if (rc.strikeUseAngle) {
      final center = cfg._toNoteXY(noteSize, rc.strikeCenterPct);
      final rad = rc.strikeAngleDeg * math.pi / 180.0;
      final dir = Offset(math.cos(rad), math.sin(rad));
      final half = (noteW * rc.strikeLengthRatio) / 2;
      return OffsetPair(center - dir * half, center + dir * half);
    }
    return OffsetPair(
      cfg._toNoteXY(noteSize, rc.strikeStartPct),
      cfg._toNoteXY(noteSize, rc.strikeEndPct),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: cfg.backgroundColor,
        child: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              final noteW = size.width * cfg.noteWidthRatio;
              final noteH = noteW * cfg.noteAspect;
              final noteSize = Size(noteW, noteH);

              // rows
              final r1 = cfg.row1;
              final r1Strike = _strikePoints(noteSize, noteW, r1);
              final r1CheckC = cfg._toNoteXY(noteSize, r1.checkCenterPct);
              final r1StampP = cfg._toNoteXY(noteSize, r1.stampPosPct);

              final r2 = cfg.row2;
              final r2Strike = _strikePoints(noteSize, noteW, r2);
              final r2CheckC = cfg._toNoteXY(noteSize, r2.checkCenterPct);
              final r2StampP = cfg._toNoteXY(noteSize, r2.stampPosPct);

              final r3 = cfg.row3;
              final r3Strike = _strikePoints(noteSize, noteW, r3);
              final r3CheckC = cfg._toNoteXY(noteSize, r3.checkCenterPct);
              final r3StampP = cfg._toNoteXY(noteSize, r3.stampPosPct);

              double _stampW(OutroRowConfig rc) =>
                  rc.stampSizePx ??
                  (rc.stampWidthRatio != null
                      ? noteW * rc.stampWidthRatio!
                      : noteW * 0.20);

              return SizedBox(
                width: noteW,
                height: noteH,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(cfg.noteAsset, fit: BoxFit.contain),
                    ),

                    // Row1
                    AnimatedBuilder(
                      animation: _tStrike1,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _OutroStrikePainter(
                              start: r1Strike.start,
                              end: r1Strike.end,
                              t: _tStrike1.value,
                            ),
                          ),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck1,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _OutroCheckPainter(
                              center: r1CheckC,
                              size: r1.checkSizePx,
                              t: _tCheck1.value,
                              color: r1.checkColor,
                              strokeWidth: r1.checkStrokeWidth,
                              rotationDeg: r1.checkRotationDeg,
                            ),
                          ),
                    ),
                    AnimatedBuilder(
                      animation: _tStamp1,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                          begin: r1.stampDropPx,
                          end: Offset.zero,
                        ).transform(_tStamp1.value);
                        final scale = Tween<double>(
                          begin: r1.stampStartScale,
                          end: r1.stampFinalScale,
                        ).transform(_tStamp1.value);
                        final rot = r1.stampRotationDeg * math.pi / 180.0;
                        return Positioned(
                          left: r1StampP.dx,
                          top: r1StampP.dy,
                          child: Transform.translate(
                            offset: drop,
                            child: Transform.rotate(
                              angle: rot,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: _stampW(r1),
                                  child: Image.asset(
                                    r1.stampAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Row2
                    AnimatedBuilder(
                      animation: _tStrike2,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _OutroStrikePainter(
                              start: r2Strike.start,
                              end: r2Strike.end,
                              t: _tStrike2.value,
                            ),
                          ),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck2,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _OutroCheckPainter(
                              center: r2CheckC,
                              size: r2.checkSizePx,
                              t: _tCheck2.value,
                              color: r2.checkColor,
                              strokeWidth: r2.checkStrokeWidth,
                              rotationDeg: r2.checkRotationDeg,
                            ),
                          ),
                    ),
                    AnimatedBuilder(
                      animation: _tStamp2,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                          begin: r2.stampDropPx,
                          end: Offset.zero,
                        ).transform(_tStamp2.value);
                        final scale = Tween<double>(
                          begin: r2.stampStartScale,
                          end: r2.stampFinalScale,
                        ).transform(_tStamp2.value);
                        final rot = r2.stampRotationDeg * math.pi / 180.0;
                        return Positioned(
                          left: r2StampP.dx,
                          top: r2StampP.dy,
                          child: Transform.translate(
                            offset: drop,
                            child: Transform.rotate(
                              angle: rot,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: _stampW(r2),
                                  child: Image.asset(
                                    r2.stampAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Row3
                    AnimatedBuilder(
                      animation: _tStrike3,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _OutroStrikePainter(
                              start: r3Strike.start,
                              end: r3Strike.end,
                              t: _tStrike3.value,
                            ),
                          ),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck3,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _OutroCheckPainter(
                              center: r3CheckC,
                              size: r3.checkSizePx,
                              t: _tCheck3.value,
                              color: r3.checkColor,
                              strokeWidth: r3.checkStrokeWidth,
                              rotationDeg: r3.checkRotationDeg,
                            ),
                          ),
                    ),
                    AnimatedBuilder(
                      animation: _tStamp3,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                          begin: r3.stampDropPx,
                          end: Offset.zero,
                        ).transform(_tStamp3.value);
                        final scale = Tween<double>(
                          begin: r3.stampStartScale,
                          end: r3.stampFinalScale,
                        ).transform(_tStamp3.value);
                        final rot = r3.stampRotationDeg * math.pi / 180.0;
                        return Positioned(
                          left: r3StampP.dx,
                          top: r3StampP.dy,
                          child: Transform.translate(
                            offset: drop,
                            child: Transform.rotate(
                              angle: rot,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: _stampW(r3),
                                  child: Image.asset(
                                    r3.stampAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OffsetPair {
  const OffsetPair(this.start, this.end);
  final Offset start, end;
}

/* ─────────── outro painters ─────────── */
class _OutroStrikePainter extends CustomPainter {
  _OutroStrikePainter({
    required this.start,
    required this.end,
    required this.t,
  });
  final Offset start, end;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = const Color(0xFFD92B2B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;
    final to = Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );
    canvas.drawLine(start, to, p);
  }

  @override
  bool shouldRepaint(covariant _OutroStrikePainter old) => old.t != t;
}

class _OutroCheckPainter extends CustomPainter {
  _OutroCheckPainter({
    required this.center,
    required this.size,
    required this.t,
    required this.color,
    required this.strokeWidth,
    this.rotationDeg = 0.0,
  });
  final Offset center;
  final double size;
  final double t;
  final Color color;
  final double strokeWidth;
  final double rotationDeg;

  @override
  void paint(Canvas canvas, Size sizeCanvas) {
    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final ra = Offset(-0.24 * size, 0.06 * size);
    final rb = Offset(-0.06 * size, 0.35 * size);
    final rc = Offset(0.47 * size, -0.23 * size);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationDeg * math.pi / 180.0);

    if (t <= 0.5) {
      final tt = t / 0.5;
      final x = Offset(
        ra.dx + (rb.dx - ra.dx) * tt,
        ra.dy + (rb.dy - ra.dy) * tt,
      );
      canvas.drawLine(ra, x, p);
    } else {
      canvas.drawLine(ra, rb, p);
      final tt = (t - 0.5) / 0.5;
      final x = Offset(
        rb.dx + (rc.dx - rb.dx) * tt,
        rb.dy + (rc.dy - rb.dy) * tt,
      );
      canvas.drawLine(rb, x, p);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OutroCheckPainter old) => old.t != t;
}

/* ─────────── stroke & guide utils (씬 B) ─────────── */
class _GuidePath {
  _GuidePath._(this.points) : _lengths = _buildLengths(points);
  final List<Offset> points;
  final List<double> _lengths;

  factory _GuidePath.polyline(List<Offset> pts) => _GuidePath._(pts);

  double get totalLen => _lengths.isNotEmpty ? _lengths.last : 0;

  static List<double> _buildLengths(List<Offset> pts) {
    final len = <double>[];
    double acc = 0;
    for (int i = 0; i < pts.length; i++) {
      if (i == 0) {
        len.add(0);
      } else {
        acc += (pts[i] - pts[i - 1]).distance;
        len.add(acc);
      }
    }
    return len;
  }

  double distanceTo(Offset p) {
    double best = double.infinity;
    for (int i = 1; i < points.length; i++) {
      best = math.min(best, _distPointToSegment(p, points[i - 1], points[i]));
    }
    return best;
  }

  double project01(Offset p) {
    double best = double.infinity;
    double bestT = 0;
    double accPrev = 0;
    for (int i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      final segLen = (b - a).distance;
      if (segLen == 0) continue;
      final t = _project01OnSegment(p, a, b);
      final proj = Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
      final dist = (p - proj).distance;
      if (dist < best) {
        best = dist;
        bestT = (accPrev + segLen * t) / totalLen;
      }
      accPrev += segLen;
    }
    return bestT.isNaN ? 0 : bestT.clamp(0.0, 1.0);
  }

  static double _distPointToSegment(Offset p, Offset a, Offset b) {
    final ap = p - a, ab = b - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (ab2 == 0) return (p - a).distance;
    double t = (ap.dx * ab.dx + ap.dy * ab.dy) / ab2;
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - proj).distance;
  }

  static double _project01OnSegment(Offset p, Offset a, Offset b) {
    final ap = p - a, ab = b - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (ab2 == 0) return 0;
    return ((ap.dx * ab.dx + ap.dy * ab.dy) / ab2).clamp(0.0, 1.0);
  }
}

class _GuidePainter extends CustomPainter {
  final List<_GuidePath> guides;
  final double dash;
  final double gap;
  final double strokeWidth;
  final Color color;

  const _GuidePainter({
    required this.guides,
    this.dash = 16,
    this.gap = 22,
    this.strokeWidth = 10,
    this.color = kGuideBaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    for (final g in guides) {
      _drawDashedPolyline(canvas, g.points, p, dash: dash, gap: gap);
    }
  }

  void _drawDashedPolyline(
    Canvas c,
    List<Offset> pts,
    Paint p, {
    double dash = 20,
    double gap = 16,
  }) {
    if (pts.length < 2) return;
    double remain = 0;
    bool draw = true;
    for (int i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final seg = (b - a);
      final segLen = seg.distance;
      if (segLen == 0) continue;
      final dir = Offset(seg.dx / segLen, seg.dy / segLen);
      double t = 0;
      while (t < segLen) {
        final len = (draw ? dash : gap) - remain;
        final step = math.min(len, segLen - t);
        if (draw) c.drawLine(a + dir * t, a + dir * (t + step), p);
        t += step;
        remain = 0;
        if (step >= len) draw = !draw;
      }
      remain = 0;
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) =>
      old.guides != guides ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth ||
      old.color != color;
}

class _PassedPainter extends CustomPainter {
  final List<_GuidePath> guides;
  final List<bool> passed;
  final double strokeWidth;
  final Color color;

  const _PassedPainter({
    required this.guides,
    required this.passed,
    this.strokeWidth = 10,
    this.color = kGuidePassColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < guides.length; i++) {
      if (!passed[i]) continue;
      final path =
          Path()..moveTo(guides[i].points.first.dx, guides[i].points.first.dy);
      for (final pt in guides[i].points.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PassedPainter old) =>
      old.passed != passed ||
      old.guides != guides ||
      old.strokeWidth != strokeWidth ||
      old.color != color;
}

class _StrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double width;
  const _StrokePainter({
    required this.points,
    required this.color,
    this.width = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final p =
        Paint()
          ..color = color.withOpacity(0.96)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) =>
      old.points != points || old.color != color || old.width != width;
}

class _Asset extends StatelessWidget {
  const _Asset(this.path, {super.key});
  final String path;
  @override
  Widget build(BuildContext context) => Image.asset(path, fit: BoxFit.contain);
}

class _TitleBanner extends StatelessWidget {
  final String text;
  const _TitleBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: top + kTitleTopGap),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────────── 이미지 마스크 레이어 (씬 A) ───────────────── */
class ImageMaskGuideLayer extends StatefulWidget {
  final bool enabled;

  final String guideAsset;
  final double leftNorm, topNorm, widthNorm, guideOpacity;
  final Color guideTint; // 알파가 있는 부분을 이 색으로 표시
  final double targetCoverage, snapRadiusPx;
  final int stampRadiusPx, sampleStridePx;
  final ValueChanged<double> onProgress;
  final VoidCallback onDone;
  final ui.Color strokeColor;
  final double strokeWidthBasePx;

  const ImageMaskGuideLayer({
    super.key,
    this.enabled = true,
    required this.guideAsset,
    required this.leftNorm,
    required this.topNorm,
    required this.widthNorm,
    required this.guideOpacity,
    this.guideTint = const Color(0xFFB3B3B3),
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
  State<ImageMaskGuideLayer> createState() => _ImageMaskGuideLayerState();
}

class _ImageMaskGuideLayerState extends State<ImageMaskGuideLayer> {
  ui.Image? _maskImg;
  Uint8List? _rgba;
  int _gw = 0, _gh = 0;

  Offset? _lastMaskPt;

  late Rect _guideRect;
  late double _mx, _my;

  late int _gridW, _gridH, _stride;
  late List<bool> _coveredGrid;
  int _totalSamples = 0, _coveredSamples = 0;

  final List<Offset> _stroke = [];

  bool get _ready => _maskImg != null && _rgba != null;
  double get _coverage =>
      _totalSamples == 0 ? 0.0 : _coveredSamples / _totalSamples;

  int _minGXEdge = 0, _maxGXEdge = 0;
  int _minGYEdge = 0, _maxGYEdge = 0;
  bool _useHorizontal = true;

  static const double _kEndBandPct = 0.12;
  static const double _kOrthoSlackPct = 0.70;
  static const double _kCoverageGrace = 0.92;

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

    final left = size.width * widget.leftNorm;
    final top = size.height * widget.topNorm;
    final guideW = size.width * widget.widthNorm;

    final raw = await rootBundle.load(widget.guideAsset);
    final codec0 = await ui.instantiateImageCodec(raw.buffer.asUint8List());
    final frame0 = await codec0.getNextFrame();
    final srcImg = frame0.image;
    final aspect = srcImg.height / srcImg.width;
    final guideH = guideW * aspect;

    _guideRect = Rect.fromLTWH(left, top, guideW, guideH);

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

    _stride = widget.sampleStridePx.clamp(2, 16);
    _gridW = (_gw + _stride - 1) ~/ _stride;
    _gridH = (_gh + _stride - 1) ~/ _stride;
    _coveredGrid = List<bool>.filled(_gridW * _gridH, false);

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

  bool _alphaOnAtGrid(int gx, int gy) {
    final x = (gx * _stride).clamp(0, _gw - 1);
    final y = (gy * _stride).clamp(0, _gh - 1);
    final a = _rgba![(y * _gw + x) * 4 + 3];
    return a > 32;
  }

  Offset _toMask(Offset screenPt) => Offset(
    (screenPt.dx - _guideRect.left) * _mx,
    (screenPt.dy - _guideRect.top) * _my,
  );

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
    return math.sqrt(dx * dx + dy * dy);
  }

  Offset? _nearestMaskPoint(Offset rawScreen) {
    if (_distanceToRect(rawScreen, _guideRect) > widget.snapRadiusPx) {
      return null;
    }

    final local = Offset(
      (rawScreen.dx - _guideRect.left).clamp(0.0, _guideRect.width),
      (rawScreen.dy - _guideRect.top).clamp(0.0, _guideRect.height),
    );
    final m = Offset(local.dx * _mx, local.dy * _my);

    final rMask = math.max(1, (widget.snapRadiusPx * _mx).ceil());
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
        if (a <= 32) continue;
        final d2 = (dx * dx + dy * dy).toDouble();
        if (d2 < bestD2) {
          bestD2 = d2;
          best = Offset(x.toDouble(), y.toDouble());
        }
      }
    }
    if (best == null) return null;
    if (math.sqrt(bestD2) > widget.snapRadiusPx * _mx) return null;

    return Offset(
      _guideRect.left + best.dx / _mx,
      _guideRect.top + best.dy / _my,
    );
  }

  void _stampAtMaskGrid(Offset maskPt) {
    final cx = (maskPt.dx / _stride).round();
    final cy = (maskPt.dy / _stride).round();
    final rGrid = math.max(1, (widget.stampRadiusPx / _stride).ceil());

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
        // 회색 틴트로 가이드 확실히 보이게
        Positioned.fromRect(
          rect: _guideRect,
          child: Opacity(
            opacity: widget.guideOpacity,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(widget.guideTint, BlendMode.srcIn),
              child: RawImage(image: _maskImg, fit: BoxFit.fill),
            ),
          ),
        ),

        // 제스처 + 스트로크
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: GestureDetector(
              onPanStart: (d) {
                _resetAttempt();
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
                if (_stroke.isEmpty ||
                    (_stroke.last - snapped).distance >= 2.0) {
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
                  _resetAttempt();
                }
              },
              child: CustomPaint(
                painter: _MaskClippedStrokePainter(
                  stroke: _stroke,
                  maskImage: _maskImg!,
                  maskSrcRect: Rect.fromLTWH(
                    0,
                    0,
                    _gw.toDouble(),
                    _gh.toDouble(),
                  ),
                  maskDstRect: _guideRect,
                  strokeColor: widget.strokeColor,
                  strokeWidth: math.max(
                    widget.strokeWidthBasePx,
                    MediaQuery.of(context).size.shortestSide * 0.028,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
