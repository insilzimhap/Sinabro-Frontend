// lib/main/studyView/writeGame/level1/write_game_1.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';
import 'package:sinabro/main/gameView/writeGame/api/write_game_api.dart';

enum _Scene { cars, monkeys }

class WriteGameLevel1Page extends StatefulWidget {
  const WriteGameLevel1Page({super.key, required this.childId});
  final String childId;

  @override
  State<WriteGameLevel1Page> createState() => _WriteGameLevel1PageState();
}

class _WriteGameLevel1PageState extends State<WriteGameLevel1Page> {
  static const int lineCount = 5;
  _Scene scene = _Scene.cars;
  bool _showOutro = false;

  // 서버 기록용
  String? _resultId;
  final _sw = Stopwatch();
  bool _completing = false;

  // 씬 B의 5줄 x 좌표 비율
  static const List<double> _bXRatios = [0.12, 0.30, 0.50, 0.70, 0.88];

  List<bool> passed = List.filled(lineCount, false);
  int? activeLine;
  List<Offset> stroke = [];

  static const double tol = 22.0;
  static const double startPickTol = 80;
  static const double hitRatio = 0.75;
  static const double coverageRatio = 0.78;

  bool get allPassed => passed.every((e) => e);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startGame();
  }

  @override
  void dispose() {
    _sw.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _startGame() async {
    try {
      _resultId = await WriteGameApi.start(
        childId: widget.childId,
        stageCode: 'FR_WG_001', // ✅ Level1-1 코드
      );
    } catch (_) {
      _resultId = null;
    }
    _sw.start();
  }

  Future<void> _completeGame() async {
    if (_resultId == null || _completing) return;
    _completing = true;
    _sw.stop();
    try {
      await WriteGameApi.complete(
        resultId: _resultId!,
        totalQuestions: lineCount * 2,
        timeSpentSecs: _sw.elapsed.inSeconds,
      );
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  List<_HGuide> _buildGuidesA(Size size) {
    const leftPad = 180.0;
    const rightPad = 140.0;
    const top = 90.0;
    const bottom = 180.0;
    const shorten = 12.0;

    final usableH = size.height - top - bottom;
    final gap = usableH / (lineCount - 0.5);

    final x1 = leftPad + shorten;
    final x2 = size.width - rightPad - shorten;

    return List.generate(lineCount, (i) {
      final y = top + (i + 1) * gap;
      return _HGuide(start: Offset(x1, y), end: Offset(x2, y));
    });
  }

  List<_VGuide> _buildGuidesB(Size size) {
    const topPad = 210.0;
    const bottomPad = 120.0;
    const leftPad = 25.0;
    const rightPad = 25.0;
    const shorten = 8.0;

    final usableW = size.width - leftPad - rightPad;
    final y1 = topPad + shorten;
    final y2 = size.height - bottomPad - shorten;

    return List.generate(lineCount, (i) {
      final x = leftPad + usableW * _bXRatios[i];
      return _VGuide(start: Offset(x, y1), end: Offset(x, y2));
    });
  }

  // ─────────────────────────────────────────────
  void _onPanStart(DragStartDetails d, Size size) {
    if (_showOutro || allPassed) return;
    final line =
        (scene == _Scene.cars)
            ? _pickLineH(d.localPosition, size)
            : _pickLineV(d.localPosition, size);

    if (line == null || passed[line]) {
      activeLine = null;
      stroke.clear();
      setState(() {});
      return;
    }
    activeLine = line;
    stroke = [d.localPosition];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (activeLine == null || _showOutro || allPassed) return;
    stroke.add(d.localPosition);
    setState(() {});
  }

  void _onPanEnd(Size size) async {
    if (activeLine == null || allPassed) return;

    final ok =
        scene == _Scene.cars
            ? _gradeStrokeH(stroke, _buildGuidesA(size)[activeLine!])
            : _gradeStrokeV(stroke, _buildGuidesB(size)[activeLine!]);

    if (ok) {
      passed[activeLine!] = true;
      stroke.clear();
      activeLine = null;
      setState(() {});

      if (allPassed) {
        if (scene == _Scene.cars) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              scene = _Scene.monkeys;
              passed = List.filled(lineCount, false);
            });
          });
        } else {
          // ✅ 씬 B 완료 시 서버 완료 기록 + 아웃트로 실행
          await _completeGame();
          if (!mounted) return;
          setState(() => _showOutro = true);
        }
      }
    } else {
      stroke.clear();
      activeLine = null;
      setState(() {});
    }
  }

  // ─────────────────────────────────────────────
  int? _pickLineH(Offset p, Size size) {
    final gs = _buildGuidesA(size);
    for (int i = 0; i < gs.length; i++) {
      if (gs[i].distanceToPoint(p) <= startPickTol) return i;
    }
    return null;
  }

  int? _pickLineV(Offset p, Size size) {
    final gs = _buildGuidesB(size);
    for (int i = 0; i < gs.length; i++) {
      if (gs[i].distanceToPoint(p) <= startPickTol) return i;
    }
    return null;
  }

  bool _gradeStrokeH(List<Offset> pts, _HGuide g) {
    if (pts.length < 6) return false;
    int hit = 0;
    for (final p in pts) {
      if (g.distanceToPoint(p) <= tol) hit++;
    }
    final ratio = hit / pts.length;

    const bins = 40;
    final covered = List.generate(bins, (_) => false);
    for (final p in pts) {
      final t = g.project01(p);
      if (t >= 0 && t <= 1) {
        final idx = (t * (bins - 1)).round();
        covered[idx] = true;
      }
    }
    final coverage = covered.where((v) => v).length / bins;
    return ratio >= hitRatio && coverage >= coverageRatio;
  }

  bool _gradeStrokeV(List<Offset> pts, _VGuide g) {
    if (pts.length < 6) return false;
    int hit = 0;
    for (final p in pts) {
      if (g.distanceToPoint(p) <= tol) hit++;
    }
    final ratio = hit / pts.length;

    const bins = 40;
    final covered = List.generate(bins, (_) => false);
    for (final p in pts) {
      final t = g.project01(p);
      if (t >= 0 && t <= 1) {
        final idx = (t * (bins - 1)).round();
        covered[idx] = true;
      }
    }
    final coverage = covered.where((v) => v).length / bins;
    return ratio >= hitRatio && coverage >= coverageRatio;
  }

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            onPanStart: _showOutro ? null : (d) => _onPanStart(d, size),
            onPanUpdate: _showOutro ? null : _onPanUpdate,
            onPanEnd: _showOutro ? null : (_) => _onPanEnd(size),
            child: Stack(
              children: [
                const Positioned.fill(child: _TitleBanner(text: '따라그려봐요!')),
                if (scene == _Scene.cars) _buildSceneCars(size),
                if (scene == _Scene.monkeys) _buildSceneMonkeys(size),

                if (_showOutro)
                  Positioned.fill(
                    child: OutroOverlay(
                      onFinished: () {
                        if (!mounted) return;
                        setState(() => _showOutro = false);
                        _showClearPopup(context);
                      },
                      autoFinish: true,
                      config: const OutroConfig(
                        noteWidthRatio: 0.86,
                        noteAspect: 0.72,
                        overlayOpacity: 0.25,
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
                        stampPosPct: Offset(0.285, -0.25),
                        stampDropPx: Offset(120, -140),
                        stampStartScale: 0.10,
                        stampFinalScale: 0.3,
                        stampRotationDeg: -7,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

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

  // 씬 A
  Widget _buildSceneCars(Size size) {
    final guides = _buildGuidesA(size);
    return Stack(
      children: [
        CustomPaint(size: size, painter: _HGuidePainter(guides: guides)),
        CustomPaint(
          size: size,
          painter: _HPassedPainter(guides: guides, passed: passed),
        ),
        if (stroke.isNotEmpty)
          CustomPaint(
            size: size,
            painter: _StrokePainter(points: stroke, color: Colors.red),
          ),
        const Positioned(
          left: 16,
          top: 55,
          bottom: 32,
          width: 230,
          child: _Asset('assets/img/contents/gameWrite/car.png'),
        ),
        const Positioned(
          right: 16,
          top: 32,
          bottom: 32,
          width: 120,
          child: _Asset('assets/img/contents/gameWrite/flag.png'),
        ),
      ],
    );
  }

  // 씬 B
  Widget _buildSceneMonkeys(Size size) {
    const leftPad = 40.0, rightPad = 40.0;
    final usableW = size.width - leftPad - rightPad;
    final xPositions = List<double>.generate(
      lineCount,
      (i) => leftPad + usableW * _bXRatios[i],
    );
    final guides = _buildGuidesB(size);

    return Stack(
      children: [
        CustomPaint(size: size, painter: _VGuidePainter(guides: guides)),
        CustomPaint(
          size: size,
          painter: _VPassedPainter(guides: guides, passed: passed),
        ),
        if (stroke.isNotEmpty)
          CustomPaint(
            size: size,
            painter: _StrokePainter(points: stroke, color: Colors.blue),
          ),
        ...List.generate(lineCount, (i) {
          final img =
              (i % 2 == 0)
                  ? 'assets/img/contents/gameWrite/banana.png'
                  : 'assets/img/contents/gameWrite/apple.png';
          const w = 90.0, h = 120.0;
          return Positioned(
            top: 150,
            left: xPositions[i] - w / 2,
            width: w,
            height: h,
            child: _Asset(img),
          );
        }),
        ...List.generate(lineCount, (i) {
          const w = 100.0, h = 140.0;
          return Positioned(
            bottom: 32,
            left: xPositions[i] - w / 2,
            width: w,
            height: h,
            child: const _Asset('assets/img/contents/gameWrite/monkey.png'),
          );
        }),
      ],
    );
  }
}

// 이하 _Asset, _TitleBanner, OutroConfig, OutroOverlay, _StrikePainter, _CheckPainter,
// _HGuide/_VGuide, Painter 클래스들 원본 그대로 유지

// 간단한 Image.asset 래퍼(코드 줄이기용)
class _Asset extends StatelessWidget {
  const _Asset(this.path, {super.key});
  final String path;
  @override
  Widget build(BuildContext context) => Image.asset(path, fit: BoxFit.contain);
}

// ─────────────────────────────────────────────
// 상단 제목 배너
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
          margin: EdgeInsets.only(top: top + 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black54,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🔧 아웃트로 설정 구조체 (원하는 값만 바꿔서 쓰기)
class OutroConfig {
  const OutroConfig({
    this.noteWidthRatio = 0.86, // 노트 너비(화면폭 비율)
    this.noteAspect = 0.72, // 노트 높이 비율 (noteH = noteW * aspect)
    this.overlayOpacity = 0.25, // 배경 어둡기

    this.fadeDuration = const Duration(milliseconds: 700),
    this.sequenceDuration = const Duration(seconds: 3),

    // ─ 취소선(좌표 직접 모드와 각도 모드 둘 다 지원) ─
    this.strikeColor = const Color(0xFFD92B2B),
    this.strikeWidth = 8.0,
    this.strikeStartPct = const Offset(0.23, 0.31), // (직접모드) 시작점
    this.strikeEndPct = const Offset(0.82, 0.31), // (직접모드) 끝점
    this.strikeUseAngle = true, // 각도/길이 모드 ON
    this.strikeCenterPct = const Offset(0.52, 0.36), // 선 중심(비율)
    this.strikeAngleDeg = -18, // 기울기(도)
    this.strikeLengthRatio = 0.65, // 노트 너비 대비 길이(0~1)
    // ─ 체크 ─
    this.checkColor = const Color(0xFFD92B2B),
    this.checkStrokeWidth = 6.0,
    this.checkCenterPct = const Offset(0.195, 0.445),
    this.checkSizePx = 34.0,
    this.checkRotationDeg = 0.0, // 체크 기울기(도)
    // ─ 도장 ─
    this.stampPosPct = const Offset(0.705, 0.14),
    this.stampDropPx = const Offset(120, -140), // 날아오는 시작 오프셋(px)
    this.stampStartScale = 0.10,
    this.stampFinalScale = 1.00, // 최종 스케일
    this.stampRotationDeg = 0.0, // 최종 회전(도)
    this.stampSizePx, // 이미지 폭(px) 지정 시 사용
    this.stampAsset = 'assets/img/contents/gameWrite/stamp.png',
    this.noteAsset = 'assets/img/contents/gameWrite/outro_note.png',
  });

  // 레이아웃
  final double noteWidthRatio;
  final double noteAspect;
  final double overlayOpacity;

  // 타이밍
  final Duration fadeDuration;
  final Duration sequenceDuration;

  // 취소선
  final Color strikeColor;
  final double strikeWidth;

  // (A) 시작/끝 좌표 모드
  final Offset strikeStartPct;
  final Offset strikeEndPct;

  // (B) 각도/길이 모드
  final bool strikeUseAngle;
  final Offset strikeCenterPct;
  final double strikeAngleDeg;
  final double strikeLengthRatio;

  // 체크
  final Color checkColor;
  final double checkStrokeWidth;
  final Offset checkCenterPct;
  final double checkSizePx;
  final double checkRotationDeg;

  // 도장
  final Offset stampPosPct;
  final Offset stampDropPx;
  final double stampStartScale;
  final double stampFinalScale;
  final double stampRotationDeg;
  final double? stampSizePx;
  final String stampAsset;
  final String noteAsset;

  // 비율 → 실제 좌표로 변환
  Offset toNoteXY(Size noteSize, Offset pct) =>
      Offset(noteSize.width * pct.dx, noteSize.height * pct.dy);
}

// ─────────────────────────────────────────────
// 아웃트로 오버레이: (페이드인) → 1) 취소선 → 2) 체크 → 3) 스탬프
class OutroOverlay extends StatefulWidget {
  const OutroOverlay({
    super.key,
    required this.onFinished,
    this.config = const OutroConfig(),
    this.autoFinish = false, // 기본: 자동 종료 안 함
  });

  final VoidCallback onFinished;
  final OutroConfig config;
  final bool autoFinish;

  @override
  State<OutroOverlay> createState() => _OutroOverlayState();
}

class _OutroOverlayState extends State<OutroOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl; // 배경/노트 페이드
  late final AnimationController _seqCtrl; // 순차 애니메이션
  late final Animation<double> _fade; // 0→1

  // 순차 애니메이션 구간
  late final Animation<double> _tStrike; // 0.0~0.33
  late final Animation<double> _tCheck; // 0.33~0.66
  late final Animation<double> _tStamp; // 0.66~1.0

  OutroConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: cfg.fadeDuration);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _seqCtrl = AnimationController(vsync: this, duration: cfg.sequenceDuration);
    _tStrike = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.0, 0.33, curve: Curves.easeOutCubic),
    );
    _tCheck = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.33, 0.66, curve: Curves.easeOutCubic),
    );
    _tStamp = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.66, 1.0, curve: Curves.elasticOut),
    );

    // 시퀀스 완료 시 autoFinish가 true일 때만 콜백 호출
    _seqCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && widget.autoFinish) {
        widget.onFinished();
      }
    });

    // 페이드 완료 → 순차 실행
    _fadeCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _seqCtrl.forward();
      }
    });

    _fadeCtrl.forward(); // 이 위젯이 표시되면 바로 페이드 시작
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _seqCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withOpacity(cfg.overlayOpacity),
        child: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              final noteW = size.width * cfg.noteWidthRatio;
              final noteH = noteW * cfg.noteAspect;
              final noteSize = Size(noteW, noteH);

              // ── 취소선 좌표 계산(각도/길이 모드 우선)
              late final Offset strikeStart;
              late final Offset strikeEnd;
              if (cfg.strikeUseAngle) {
                final center = cfg.toNoteXY(noteSize, cfg.strikeCenterPct);
                final rad = cfg.strikeAngleDeg * math.pi / 180.0;
                final dir = Offset(math.cos(rad), math.sin(rad)); // 단위 방향
                final halfLen = (noteW * cfg.strikeLengthRatio) / 2; // 길이 절반
                strikeStart = center - dir * halfLen;
                strikeEnd = center + dir * halfLen;
              } else {
                // 좌표 직접 지정 모드
                strikeStart = cfg.toNoteXY(noteSize, cfg.strikeStartPct);
                strikeEnd = cfg.toNoteXY(noteSize, cfg.strikeEndPct);
              }

              final checkCenter = cfg.toNoteXY(noteSize, cfg.checkCenterPct);
              final stampPos = cfg.toNoteXY(noteSize, cfg.stampPosPct);

              return SizedBox(
                width: noteW,
                height: noteH,
                child: Stack(
                  children: [
                    // 노트 배경
                    Positioned.fill(child: _Asset(cfg.noteAsset)),

                    // 1) 취소선
                    AnimatedBuilder(
                      animation: _tStrike,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _StrikePainter(
                              start: strikeStart,
                              end: strikeEnd,
                              t: _tStrike.value,
                              color: cfg.strikeColor,
                              width: cfg.strikeWidth,
                            ),
                          ),
                    ),

                    // 2) 체크(회전 지원)
                    AnimatedBuilder(
                      animation: _tCheck,
                      builder:
                          (_, __) => CustomPaint(
                            painter: _CheckPainter(
                              center: checkCenter,
                              size: cfg.checkSizePx,
                              t: _tCheck.value,
                              color: cfg.checkColor,
                              strokeWidth: cfg.checkStrokeWidth,
                              rotationDeg: cfg.checkRotationDeg,
                            ),
                          ),
                    ),

                    // 3) 스탬프(드롭 + 스케일 + 회전)
                    AnimatedBuilder(
                      animation: _tStamp,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                          begin: cfg.stampDropPx,
                          end: Offset.zero,
                        ).transform(_tStamp.value);

                        final scale = Tween<double>(
                          begin: cfg.stampStartScale,
                          end: cfg.stampFinalScale,
                        ).transform(_tStamp.value);

                        final rot = cfg.stampRotationDeg * math.pi / 180.0;

                        final image = Image.asset(
                          cfg.stampAsset,
                          width: cfg.stampSizePx, // null이면 원본 크기
                          fit: BoxFit.contain,
                        );

                        return Positioned(
                          left: stampPos.dx,
                          top: stampPos.dy,
                          child: Transform.translate(
                            offset: drop,
                            child: Transform.rotate(
                              angle: rot,
                              child: Transform.scale(
                                scale: scale,
                                child: image,
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

// 취소선
class _StrikePainter extends CustomPainter {
  _StrikePainter({
    required this.start,
    required this.end,
    required this.t,
    required this.color,
    required this.width,
  });
  final Offset start, end;
  final double t;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round;

    final to = Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );
    canvas.drawLine(start, to, p);
  }

  @override
  bool shouldRepaint(covariant _StrikePainter old) =>
      old.t != t ||
      old.color != color ||
      old.width != width ||
      old.start != start ||
      old.end != end;
}

// 체크 마크(두 스트로크) + 회전 지원
class _CheckPainter extends CustomPainter {
  _CheckPainter({
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
  void paint(Canvas canvas, Size _) {
    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // 기본(미회전) 상대 좌표
    final ra = Offset(-0.24 * size, 0.06 * size);
    final rb = Offset(-0.06 * size, 0.35 * size);
    final rc = Offset(0.47 * size, -0.24 * size);

    // 회전 적용
    final rad = rotationDeg * math.pi / 180.0;
    Offset rot(Offset v) => Offset(
      v.dx * math.cos(rad) - v.dy * math.sin(rad),
      v.dx * math.sin(rad) + v.dy * math.cos(rad),
    );

    final a = center + rot(ra);
    final b = center + rot(rb);
    final c = center + rot(rc);

    if (t <= 0.5) {
      final tt = t / 0.5;
      final x = Offset(a.dx + (b.dx - a.dx) * tt, a.dy + (b.dy - a.dy) * tt);
      canvas.drawLine(a, x, p);
    } else {
      canvas.drawLine(a, b, p);
      final tt = (t - 0.5) / 0.5;
      final x = Offset(b.dx + (c.dx - b.dx) * tt, b.dy + (c.dy - b.dy) * tt);
      canvas.drawLine(b, x, p);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.t != t ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.size != size ||
      old.center != center ||
      old.rotationDeg != rotationDeg;
}

// ─────────────────────────────────────────────
// 가이드/페인터
class _HGuide {
  final Offset start, end;
  _HGuide({required this.start, required this.end});

  double distanceToPoint(Offset p) {
    final v = end - start, w = p - start;
    final c1 = (w.dx * v.dx + w.dy * v.dy);
    if (c1 <= 0) return (p - start).distance;
    final c2 = (v.dx * v.dx + v.dy * v.dy);
    if (c2 <= c1) return (p - end).distance;
    final b = c1 / c2;
    final pb = Offset(start.dx + b * v.dx, start.dy + b * v.dy);
    return (p - pb).distance;
  }

  double project01(Offset p) {
    final v = end - start;
    final c2 = v.dx * v.dx + v.dy * v.dy;
    if (c2 == 0) return 0;
    return ((p.dx - start.dx) * v.dx + (p.dy - start.dy) * v.dy) / c2;
  }

  Path toPath() =>
      Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
}

class _VGuide {
  final Offset start, end;
  _VGuide({required this.start, required this.end});

  double distanceToPoint(Offset p) {
    final v = end - start, w = p - start;
    final c1 = (w.dx * v.dx + w.dy * v.dy);
    if (c1 <= 0) return (p - start).distance;
    final c2 = v.dx * v.dx + v.dy * v.dy;
    if (c2 <= c1) return (p - end).distance;
    final b = c1 / c2;
    final pb = Offset(start.dx + b * v.dx, start.dy + b * v.dy);
    return (p - pb).distance;
  }

  double project01(Offset p) {
    final v = end - start;
    final c2 = v.dx * v.dx + v.dy * v.dy;
    if (c2 == 0) return 0;
    return ((p.dx - start.dx) * v.dx + (p.dy - start.dy) * v.dy) / c2;
  }

  Path toPath() =>
      Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
}

class _HGuidePainter extends CustomPainter {
  final List<_HGuide> guides;
  const _HGuidePainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    for (final g in guides) {
      _drawDashed(canvas, g.start, g.end, paint, dash: 16, gap: 24);
    }
  }

  void _drawDashed(
    Canvas c,
    Offset a,
    Offset b,
    Paint p, {
    double dash = 24,
    double gap = 18,
  }) {
    final total = (b - a).distance;
    final dir = Offset((b.dx - a.dx) / total, (b.dy - a.dy) / total);
    double t = 0.0;
    var cur = a;
    while (t < total) {
      final len = math.min(dash, total - t);
      final nxt = Offset(cur.dx + dir.dx * len, cur.dy + dir.dy * len);
      c.drawLine(cur, nxt, p);
      t += dash + gap;
      cur = Offset(
        cur.dx + dir.dx * (dash + gap),
        cur.dy + dir.dy * (dash + gap),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _HPassedPainter extends CustomPainter {
  final List<_HGuide> guides;
  final List<bool> passed;
  const _HPassedPainter({required this.guides, required this.passed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF27AE60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;
    for (int i = 0; i < guides.length; i++) {
      if (passed[i]) canvas.drawPath(guides[i].toPath(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HPassedPainter old) => old.passed != passed;
}

class _VGuidePainter extends CustomPainter {
  final List<_VGuide> guides;
  const _VGuidePainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    for (final g in guides) {
      _drawDashed(canvas, g.start, g.end, paint, dash: 16, gap: 24);
    }
  }

  void _drawDashed(
    Canvas c,
    Offset a,
    Offset b,
    Paint p, {
    double dash = 24,
    double gap = 18,
  }) {
    final total = (b - a).distance;
    final dir = Offset((b.dx - a.dx) / total, (b.dy - a.dy) / total);
    double t = 0.0;
    var cur = a;
    while (t < total) {
      final len = math.min(dash, total - t);
      final nxt = Offset(cur.dx + dir.dx * len, cur.dy + dir.dy * len);
      c.drawLine(cur, nxt, p);
      t += dash + gap;
      cur = Offset(
        cur.dx + dir.dx * (dash + gap),
        cur.dy + dir.dy * (dash + gap),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _VPassedPainter extends CustomPainter {
  final List<_VGuide> guides;
  final List<bool> passed;
  const _VPassedPainter({required this.guides, required this.passed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF2D9CDB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;
    for (int i = 0; i < guides.length; i++) {
      if (passed[i]) canvas.drawPath(guides[i].toPath(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VPassedPainter old) => old.passed != passed;
}

// 현재 그리는 손 스트로크
class _StrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  const _StrokePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint =
        Paint()
          ..color = color.withOpacity(0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) =>
      old.points != points || old.color != color;
}
