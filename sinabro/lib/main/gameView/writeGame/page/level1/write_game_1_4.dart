// lib/main/gameView/writeGame/page/level1/write_game_1_4.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';
import 'package:sinabro/main/gameView/writeGame/api/write_game_api.dart';
// ⬇️ AUDIO IMPORT
import 'package:audioplayers/audioplayers.dart';

// ⬇️ AUDIO ASSET DEFINITIONS
// 오디오 에셋 경로
const String _audioDir = 'audio/tts/gameWrite/level1/';

// 3세 쓰기 게임 1-4 레벨 오디오 에셋 정의
const Map<String, String> LEVEL3_AUDIO_ASSETS_1_4 = {
  // 구분: 공통 | 대사: 따라, 그려봐요~!
  'COMMON_1': _audioDir + 'write3_game_common_1.mp3',
  // 구분: 인트로 4 | 대사: 도형 그리기. (씬 A/B 유도용)
  'INTRO_4': _audioDir + 'write3_game_intro_4.mp3',
};
// ⬆️ AUDIO ASSET DEFINITIONS

enum _Scene { squares, triangles, outro }

class WriteGameLevel1_4Page extends StatefulWidget {
  const WriteGameLevel1_4Page({super.key, required this.childId});
  final String childId;

  @override
  State<WriteGameLevel1_4Page> createState() => _WriteGameLevel1_4PageState();
}

/* ───────────────── visuals ───────────────── */
const kGuideColor = Color(0xFFD9D9D9);
const kPassColor = Color(0xFF27AE60);
const kInkSquare = Color(0xFF2D9CDB);
const kInkTri = Color(0xFFEB5757);
const kStrokeW = 10.0;
const kDashLen = 16.0;
const kDashGap = 16.0;

const kTitleTopGap = 12.0;

/* ───────────────── layout (조정 가능) ───────────────── */
// 사각형 3개 절대 좌표 (left, top, width, height)
const List<Rect> kSquareRects = <Rect>[
  Rect.fromLTWH(150, 260, 250, 250),
  Rect.fromLTWH(375 + 136 + 32, 260, 250, 250),
  Rect.fromLTWH(600 + (136 + 32) * 2, 260, 250, 250),
];

// 정삼각형 3개: 밑변의 '좌하' 좌표 + 한 변 길이
class TriSpec {
  final Offset baseLeft;
  final double side;
  const TriSpec(this.baseLeft, this.side);
}

const List<TriSpec> kTriangles = <TriSpec>[
  TriSpec(Offset(150, 500), 250),
  TriSpec(Offset(325 + 160 + 54, 500), 250),
  TriSpec(Offset(500 + (160 + 54) * 2, 500), 250),
];

/* ───────────────── (참고) 기존 조절 상수 — 필요시 활용 ───────────────── */
// 씬A 네모 3개 (현재는 kSquareRects가 실제 레이아웃을 결정)
const kSquareTop = 150.0;
const kSquareSize = 136.0;
const kSquareGap = 32.0;
// 씬B 세모 3개 (실제 레이아웃은 kTriangles로 관리)
const kTriTop = 160.0;
const kTriSide = 160.0;
const kTriGap = 54.0;

// 판정 파라미터
const _tol = 22.0; // 허용 거리
const _startPickTol = 64.0;
const _hitRatio = 0.72;
const _coverageRatio = 0.72;

class _WriteGameLevel1_4PageState extends State<WriteGameLevel1_4Page> {
  _Scene scene = _Scene.squares;

  // 진행/입력
  late List<bool> passed = List.filled(_lineCount, false);
  int? activeLine;
  List<Offset> stroke = [];

  // API/시간
  String? _resultId;
  final _sw = Stopwatch();
  bool _completed = false;
  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();

  int get _lineCount =>
      scene == _Scene.squares ? 3 : (scene == _Scene.triangles ? 3 : 0);
  bool get _allPassed => passed.every((e) => e);

  // ⬇️ AUDIO PLAYBACK LOGIC
  /// 오디오 재생 헬퍼 함수
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (1-4): $assetPath');
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startGame();
    // ⬇️ 씬 A (Squares) 시작 오디오 재생 (추가됨: COMMON_1 + INTRO_4 재생)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_4['COMMON_1']!);
      _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_4['INTRO_4']!);
    });
  }

  @override
  void dispose() {
    _sw.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // ⬇️ AUDIO PLAYER DISPOSE
    _audioPlayer.dispose();
    super.dispose();
  }
  // ⬆️ AUDIO PLAYBACK LOGIC

  Future<void> _startGame() async {
    try {
      _resultId = await WriteGameApi.start(
        childId: widget.childId,
        stageCode: 'FR_WG_004', // Level1-4
      );
    } catch (_) {
      _resultId = null;
    }
    _sw.start();
  }

  Future<void> _completeGame() async {
    if (_completed) return;
    _completed = true;
    _sw.stop();
    try {
      if (_resultId != null) {
        await WriteGameApi.complete(
          resultId: _resultId!,
          totalQuestions: 6, // 사각형 3 + 삼각형 3
          timeSpentSecs: _sw.elapsed.inSeconds,
        );
      }
    } catch (_) {}
  }

  /* ───────────────── guides ───────────────── */

  // ✔ 사각형 가이드
  List<_GuidePath> _buildSquareGuides(Size size) {
    return kSquareRects.map((r) => _rectPath(r, stepsPerSide: 40)).toList();
  }

  // ✔ 삼각형 가이드
  List<_GuidePath> _buildTriangleGuides(Size size) {
    return kTriangles
        .map((t) => _trianglePath(baseLeft: t.baseLeft, side: t.side))
        .toList();
  }

  _GuidePath _rectPath(Rect r, {int stepsPerSide = 36}) {
    final pts = <Offset>[];
    // 시계 방향: 상, 우, 하, 좌
    for (int i = 0; i <= stepsPerSide; i++) {
      pts.add(Offset(r.left + r.width * (i / stepsPerSide), r.top));
    }
    for (int i = 1; i <= stepsPerSide; i++) {
      pts.add(Offset(r.right, r.top + r.height * (i / stepsPerSide)));
    }
    for (int i = 1; i <= stepsPerSide; i++) {
      pts.add(Offset(r.right - r.width * (i / stepsPerSide), r.bottom));
    }
    for (int i = 1; i <= stepsPerSide; i++) {
      pts.add(Offset(r.left, r.bottom - r.height * (i / stepsPerSide)));
    }
    return _GuidePath.polyline(pts);
  }

  _GuidePath _trianglePath({required Offset baseLeft, required double side}) {
    // 정삼각형(밑변 수평)
    final a = baseLeft; // 좌하
    final b = baseLeft + Offset(side, 0); // 우하
    final h = side * math.sqrt(3) / 2;
    final c = Offset((a.dx + b.dx) / 2, a.dy - h); // 꼭짓점

    List<Offset> edge(Offset s, Offset e) {
      const n = 48;
      return List.generate(n + 1, (i) {
        final t = i / n;
        return Offset(s.dx + (e.dx - s.dx) * t, s.dy + (e.dy - s.dy) * t);
      });
    }

    final pts = <Offset>[]
      ..addAll(edge(a, b)..removeLast())
      ..addAll(edge(b, c)..removeLast())
      ..addAll(edge(c, a));
    return _GuidePath.polyline(pts);
  }

  /* ───────────────── input & grade ───────────────── */
  void _onPanStart(DragStartDetails d, Size size) {
    if (_allPassed || scene == _Scene.outro) return;
    final guides = scene == _Scene.squares
        ? _buildSquareGuides(size)
        : _buildTriangleGuides(size);

    int? pick;
    double best = double.infinity;
    for (int i = 0; i < guides.length; i++) {
      if (passed[i]) continue;
      final dist = guides[i].distanceTo(d.localPosition);
      if (dist < best && dist <= _startPickTol) {
        best = dist;
        pick = i;
      }
    }
    activeLine = pick;
    stroke = pick == null ? [] : [d.localPosition];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (activeLine == null || _allPassed || scene == _Scene.outro) return;
    stroke.add(d.localPosition);
    setState(() {});
  }

  Future<void> _onPanEnd(Size size) async {
    if (activeLine == null || _allPassed || scene == _Scene.outro) return;

    final guides = scene == _Scene.squares
        ? _buildSquareGuides(size)
        : _buildTriangleGuides(size);
    final ok = _gradeStroke(stroke, guides[activeLine!]);

    if (ok) {
      passed[activeLine!] = true;
      stroke.clear();
      activeLine = null;
      setState(() {});
      if (_allPassed) {
        if (scene == _Scene.squares) {
          Future.delayed(const Duration(milliseconds: 280), () {
            if (!mounted) return;
            setState(() {
              scene = _Scene.triangles;
              passed = List.filled(_lineCount, false);
            });
            // ⬇️ 씬 B (Triangles) 시작 오디오 재생 (추가됨: COMMON_1 + INTRO_4 재생)
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_4['COMMON_1']!);
              _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_4['INTRO_4']!);
            });
          });
        } else {
          await _completeGame();
          if (!mounted) return;
          setState(() => scene = _Scene.outro);
        }
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
      if (guide.distanceTo(p) <= _tol) hit++;
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
    return ratio >= _hitRatio && coverage >= _coverageRatio;
  }

  /* ───────────────── UI ───────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            onPanStart: (d) => _onPanStart(d, size),
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(size),
            child: Stack(
              children: [
                const _TitleBanner(text: '따라그려봐요!'),
                if (scene == _Scene.squares) _buildSceneSquares(size),
                if (scene == _Scene.triangles) _buildSceneTriangles(size),
                if (scene == _Scene.outro)
                  Positioned.fill(
                    child: OutroOverlayNote3(
                      autoFinish: true,
                      onFinished: () => _showClearPopup(context),
                      config: const Outro4Config(
                        noteAsset:
                            'assets/img/contents/gameWrite/outro_note3.png',
                        // row1 고정
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
                          stampFinalScale: 1.0,
                          stampRotationDeg: -7,
                        ),
                        // row2 고정
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
                        // row3 고정
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
                        // row4 커스텀
                        row4: OutroRowConfig(
                          strikeUseAngle: true,
                          strikeCenterPct: Offset(0.48, 0.80),
                          strikeAngleDeg: -22,
                          strikeLengthRatio: 0.32,
                          strikeWidth: 8.0,
                          strikeColor: Color(0xFFD92B2B),
                          checkCenterPct: Offset(0.29, 0.89),
                          checkSizePx: 65.0,
                          checkStrokeWidth: 8.0,
                          checkColor: Color(0xFFD92B2B),
                          checkRotationDeg: -8,
                          stampPosPct: Offset(0.62, 0.54),
                          stampDropPx: Offset(140, -170),
                          stampStartScale: 0.10,
                          stampFinalScale: 1.0,
                          stampRotationDeg: -10,
                        ),
                      ),
                    ),
                  ),
                if (stroke.isNotEmpty && scene != _Scene.outro)
                  CustomPaint(
                    size: size,
                    painter: _StrokePainter(
                      points: stroke,
                      color: scene == _Scene.squares ? kInkSquare : kInkTri,
                      width: kStrokeW,
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
      builder: (_) => Center(
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
                width: 80,
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

  Widget _buildSceneSquares(Size size) {
    final guides = _buildSquareGuides(size);
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: _GuidePainter(
            guides: guides,
            dash: kDashLen,
            gap: kDashGap,
            strokeWidth: kStrokeW,
            color: kGuideColor,
          ),
        ),
        CustomPaint(
          size: size,
          painter: _PassedPainter(
            guides: guides,
            passed: passed,
            strokeWidth: kStrokeW,
            color: kPassColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSceneTriangles(Size size) {
    final guides = _buildTriangleGuides(size);
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: _GuidePainter(
            guides: guides,
            dash: kDashLen,
            gap: kDashGap,
            strokeWidth: kStrokeW,
            color: kGuideColor,
          ),
        ),
        CustomPaint(
          size: size,
          painter: _PassedPainter(
            guides: guides,
            passed: passed,
            strokeWidth: kStrokeW,
            color: kPassColor,
          ),
        ),
      ],
    );
  }
}

/* ────────────── Outro config (4 rows) ────────────── */
class OutroRowConfig {
  const OutroRowConfig({
    // strike
    this.strikeColor = const Color(0xFFD92B2B),
    this.strikeWidth = 8.0,
    // A) 좌표 직접
    this.strikeStartPct = const Offset(0.23, 0.31),
    this.strikeEndPct = const Offset(0.82, 0.31),
    // B) 각도/길이
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

  // strike
  final Color strikeColor;
  final double strikeWidth;
  final Offset strikeStartPct;
  final Offset strikeEndPct;
  final bool strikeUseAngle;
  final Offset strikeCenterPct;
  final double strikeAngleDeg;
  final double strikeLengthRatio;

  // check
  final Color checkColor;
  final double checkStrokeWidth;
  final Offset checkCenterPct;
  final double checkSizePx;
  final double checkRotationDeg;

  // stamp
  final String stampAsset;
  final Offset stampPosPct;
  final Offset stampDropPx;
  final double stampStartScale;
  final double stampFinalScale;
  final double stampRotationDeg;
  final double? stampWidthRatio;
  final double? stampSizePx;
}

class Outro4Config {
  const Outro4Config({
    this.noteWidthRatio = 0.86,
    this.noteAspect = 0.72,
    this.backgroundColor = Colors.white,
    this.noteAsset = 'assets/img/contents/gameWrite/outro_note3.png',
    this.fadeDuration = const Duration(milliseconds: 500),
    this.sequenceDuration = const Duration(milliseconds: 4200),
    this.row1 = const OutroRowConfig(),
    this.row2 = const OutroRowConfig(),
    this.row3 = const OutroRowConfig(),
    this.row4 = const OutroRowConfig(),
  });

  final double noteWidthRatio;
  final double noteAspect;
  final Color backgroundColor;
  final String noteAsset;
  final Duration fadeDuration;
  final Duration sequenceDuration;

  final OutroRowConfig row1, row2, row3, row4;

  Offset _toNoteXY(Size noteSize, Offset pct) =>
      Offset(noteSize.width * pct.dx, noteSize.height * pct.dy);
}

/* ───────────────── Outro: outro_note3, 4줄 시퀀스 ───────────────── */
class OutroOverlayNote3 extends StatefulWidget {
  const OutroOverlayNote3({
    super.key,
    required this.onFinished,
    this.config = const Outro4Config(),
    this.autoFinish = false,
  });

  final VoidCallback onFinished;
  final Outro4Config config;
  final bool autoFinish;

  @override
  State<OutroOverlayNote3> createState() => _OutroOverlayNote3State();
}

class _OutroOverlayNote3State extends State<OutroOverlayNote3>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _seq;
  late final Animation<double> _fade;

  Outro4Config get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: cfg.fadeDuration);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _seq = AnimationController(vsync: this, duration: cfg.sequenceDuration);

    _fadeCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _seq.forward();
    });
    _seq.addStatusListener((s) {
      if (s == AnimationStatus.completed && widget.autoFinish) {
        widget.onFinished();
      }
    });

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _seq.dispose();
    super.dispose();
  }

  // 4줄 타임라인 윈도우
  (double, double) _win(int i) {
    const w = 0.24; // 한 줄에 쓰는 시간 비율
    const gap = 0.01; // 줄 간 간격
    final a = i * (w + gap);
    final b = a + w;
    return (a, b.clamp(0.0, 1.0));
  }

  // (a,b) 내의 부분 구간
  Interval _segIn(
    double a,
    double b,
    double from,
    double to, [
    Curve c = Curves.easeOutCubic,
  ]) {
    final begin = a + (b - a) * from;
    final end = a + (b - a) * to;
    return Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: c);
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

  double _stampW(double noteW, OutroRowConfig rc) =>
      rc.stampSizePx ??
      (rc.stampWidthRatio != null ? noteW * rc.stampWidthRatio! : noteW * 0.20);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: cfg.backgroundColor,
        child: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final noteW = c.maxWidth * cfg.noteWidthRatio;
              final noteH = noteW * cfg.noteAspect;
              final noteSize = Size(noteW, noteH);

              final rows = [cfg.row1, cfg.row2, cfg.row3, cfg.row4];

              return SizedBox(
                width: noteW,
                height: noteH,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(cfg.noteAsset, fit: BoxFit.contain),
                    ),

                    // ===== 각 줄 애니메이션 =====
                    ...List.generate(4, (i) {
                      final rc = rows[i];
                      final (a, b) = _win(i);

                      final tStrike = CurvedAnimation(
                        parent: _seq,
                        curve: _segIn(a, b, 0.00, 0.33),
                      );
                      final tCheck = CurvedAnimation(
                        parent: _seq,
                        curve: _segIn(a, b, 0.33, 0.66),
                      );
                      final tStamp = CurvedAnimation(
                        parent: _seq,
                        curve: _segIn(a, b, 0.66, 1.00, Curves.elasticOut),
                      );

                      final strike = _strikePoints(noteSize, noteW, rc);
                      final checkC = cfg._toNoteXY(noteSize, rc.checkCenterPct);
                      final stampP = cfg._toNoteXY(noteSize, rc.stampPosPct);
                      final rot = rc.stampRotationDeg * math.pi / 180.0;

                      return AnimatedBuilder(
                        animation: _seq,
                        builder: (_, __) => Stack(
                          children: [
                            CustomPaint(
                              size: Size(noteW, noteH),
                              painter: _StrikePainter(
                                start: strike.start,
                                end: strike.end,
                                t: tStrike.value,
                                color: rc.strikeColor,
                                width: rc.strikeWidth,
                              ),
                            ),
                            CustomPaint(
                              size: Size(noteW, noteH),
                              painter: _CheckPainter(
                                center: checkC,
                                size: rc.checkSizePx,
                                t: tCheck.value,
                                color: rc.checkColor,
                                strokeWidth: rc.checkStrokeWidth,
                                rotationDeg: rc.checkRotationDeg,
                              ),
                            ),
                            Positioned(
                              left: stampP.dx,
                              top: stampP.dy,
                              child: Transform.translate(
                                offset: Tween<Offset>(
                                  begin: rc.stampDropPx,
                                  end: Offset.zero,
                                ).transform(tStamp.value),
                                child: Transform.rotate(
                                  angle: rot,
                                  child: Transform.scale(
                                    scale: Tween<double>(
                                      begin: rc.stampStartScale,
                                      end: rc.stampFinalScale,
                                    ).transform(tStamp.value),
                                    child: SizedBox(
                                      width: _stampW(noteW, rc),
                                      child: Image.asset(
                                        rc.stampAsset,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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

/* ─────────── util painters & geometry ─────────── */

class _StrikePainter extends CustomPainter {
  _StrikePainter({
    required this.start,
    required this.end,
    required this.t,
    this.color = const Color(0xFFD92B2B),
    this.width = 8,
  });

  final Offset start, end;
  final double t;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
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
      old.t != t || old.color != color || old.width != width;
}

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
  final double size; // 체크마크 기준 스케일(px)
  final double t; // 0..1
  final Color color;
  final double strokeWidth;
  final double rotationDeg;

  @override
  void paint(Canvas canvas, Size _) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 상대 좌표(원점 기준). size를 스케일로 사용.
    final ra = Offset(-0.24 * size, 0.06 * size);
    final rb = Offset(-0.06 * size, 0.35 * size);
    final rc = Offset(0.47 * size, -0.23 * size);

    // 회전 + 이동
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
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.t != t ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.rotationDeg != rotationDeg ||
      old.size != size ||
      old.center != center;
}

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
    double best = double.infinity, bestT = 0, accPrev = 0;
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
  final double dash, gap, strokeWidth;
  final Color color;
  const _GuidePainter({
    required this.guides,
    this.dash = 16,
    this.gap = 22,
    this.strokeWidth = 10,
    this.color = kGuideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
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
    this.color = kPassColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < guides.length; i++) {
      if (!passed[i]) continue;
      final path = Path()
        ..moveTo(guides[i].points.first.dx, guides[i].points.first.dy);
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
    final p = Paint()
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
