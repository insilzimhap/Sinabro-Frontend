// lib/main/gameView/writeGame/page/level1/write_game_1_3.dart
// 레벨1-3 (따라그려봐요 - 곡선)
// 씬 A: plane3 이미지 1장 가이드(plane_write 로직 이식) → 성공 시 씬 B
// 씬 B: 달팽이(나선) → 성공 시 아웃트로 → 메인 복귀
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

/* ───────────────── Audio ───────────────── */
const String _audioDir = 'audio/tts/gameWrite/level1/';
// “따라, 그려봐요~!” 공통 오디오
const String kAudioFollow = '${_audioDir}write3_game_common_1.mp3';
// (선택) 씬 유도 멘트 있으면 사용
const String kAudioIntro = '${_audioDir}write3_game_intro_3.mp3';

/* ───────────────── Assets ───────────────── */
// 씬 A 가이드 (흰 배경에서도 보이도록 틴트)
const String kGuidePlane3 = 'assets/img/contents/studyWrite/plane3.png';
// (선택) 장식용 새
const String kBirdAsset = 'assets/img/contents/gameWrite/bird.png';
// 씬 B 달팽이 이미지
const String kSnailAsset = 'assets/img/contents/gameWrite/snail.png';

/* ───────────────── Scene enum ───────────────── */
enum _Scene { aPlane, snail, outro }

/* ───────────────── Scene A layout & tuning ───────────────── */
const double kATitleTopGap = 12;
const double kAGuideLeftNorm = 0.06;
const double kAGuideTopNorm = 0.32;
const double kAGuideWidthNorm = 0.78;
const double kAGuideOpacity = 0.18;
const Color kAGuideTint = Color(0xFF77BFFF);

// 펜 굵기(씬 A) — 여기 숫자만 바꾸면 즉시 반영
const double kAStrokeBasePx = 60;
// 판정 파라미터(씬 A)
const double kATargetCoverage = 0.10;
const double kASnapRadiusPx = 28;
const int kAStampRadiusPx = 9;
const int kASampleStridePx = 4;
const ui.Color kAStrokeColor = ui.Color(0xFF0050FF);

/* ───────────────── Scene B: Snail (나선) ───────────────── */
const double kSnailImgLeft = 24;
const double kSnailImgTop = 110;
const double kSnailImgWidth = 650;
const double kSnailImgHeight = 650;

const double kSpiralCxRatio = 0.70;
const double kSpiralCyRatio = 0.50;
const Offset kSpiralCenterOffset = Offset(0, 0);
const double kSpiralStartR = 10.0;
const double kSpiralGrowth = 15.5;
const double kSpiralTurns = 2.5;
const int kSpiralSteps = 240;

const double kSpiralDash = 16;
const double kSpiralGap = 20;

const Color kGuideBaseColor = Color(0xFFDBDBDB);
const Color kGuidePassColor = Color(0xFF27AE60);
const double kGuideStrokeWidth = 10.0;
const double kPassedStrokeWidth = 10.0;

// 달팽이 판정 튜닝
const double kTol = 22.0;
const double kStartPickTol = 64.0;
const double kHitRatio = 0.72;
const double kCoverageRatio = 0.72;

/* ───────────────── Page ───────────────── */
class WriteGameLevel1_3Page extends StatefulWidget {
  const WriteGameLevel1_3Page(
      {super.key, required this.childId, this.resultId});
  final String childId;
  final String? resultId;

  @override
  State<WriteGameLevel1_3Page> createState() => _WriteGameLevel1_3PageState();
}

class _WriteGameLevel1_3PageState extends State<WriteGameLevel1_3Page> {
  _Scene scene = _Scene.aPlane;

  // 공통
  final _sw = Stopwatch();
  String? resultId;
  final AudioPlayer _audio = AudioPlayer();

  // 씬 A
  double _aProgress = 0.0;
  bool _aPassedOverlay = false;

  // 씬 B
  late List<bool> passed = List.filled(1, false); // 달팽이 1개
  int? activeLine;
  List<Offset> stroke = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      resultId = widget.resultId ?? FruitState.instance.resultId;
      if (resultId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류. 잠시 후 다시 시도하세요.')),
        );
        Navigator.of(context).maybePop();
        return;
      }
      _sw.start();
      // 진입 멘트
      _play(kAudioFollow);
      // 필요 시 추가 멘트
      _play(kAudioIntro);
    });
  }

  @override
  void dispose() {
    _sw.stop();
    _audio.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _play(String assetPath, {bool loop = false}) async {
    if (!mounted) return;
    await _audio.stop();
    await _audio.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await _audio.play(AssetSource(assetPath));
  }

  /* ───────── Scene B guide/stroke/grade ───────── */
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
          Offset(center.dx + r * math.cos(th), center.dy + r * math.sin(th)));
    }
    return [_GuidePath.polyline(pts)];
  }

  void _onPanStart(DragStartDetails d, Size size) {
    if (scene != _Scene.snail || passed.every((e) => e)) return;
    final guides = _buildSnailGuide(size);

    int? pick;
    double best = double.infinity;
    for (int i = 0; i < guides.length; i++) {
      if (passed[i]) continue;
      final dist = guides[i].distanceTo(d.localPosition);
      if (dist < best && dist <= kStartPickTol) {
        best = dist;
        pick = i;
      }
    }
    activeLine = pick;
    stroke = pick == null ? [] : [d.localPosition];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (scene != _Scene.snail || activeLine == null) return;
    stroke.add(d.localPosition);
    setState(() {});
  }

  Future<void> _onPanEnd(Size size) async {
    if (scene != _Scene.snail || activeLine == null) return;
    final guides = _buildSnailGuide(size);
    final ok = _gradeStroke(stroke, guides[activeLine!]);

    if (ok) {
      passed[activeLine!] = true;
      stroke.clear();
      activeLine = null;
      setState(() {});
      if (passed.every((e) => e)) {
        // ✅ 달팽이 성공 → choice + complete → 아웃트로
        if (resultId != null) {
          await ChildGameApi.recordWritingChoice(
            resultId: resultId!,
            questionId: 'WG_Q3_01', // 레벨1-3 questionId (DB와 일치 확인)
            childWrittenText: null,
            isCorrect: true,
          );
          await ChildGameApi.completeWritingGame(
            resultId: resultId!,
            timeSpentSecs: _sw.elapsed.inSeconds,
          );
        }
        if (!mounted) return;
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
      if (guide.distanceTo(p) <= kTol) hit++;
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
    return ratio >= kHitRatio && coverage >= kCoverageRatio;
  }

  /* ───────── UI ───────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);

          if (scene == _Scene.aPlane) {
            return Stack(
              children: [
                _TitleBanner(text: '따라그려봐요!', topGap: kATitleTopGap),
                // 씬 A: plane3 이미지 가이드(틴트/굵기/판정)
                _GameImageGuideLayer(
                  key: const ValueKey('wg-1-3-plane3'),
                  guideAsset: kGuidePlane3,
                  leftNorm: kAGuideLeftNorm,
                  topNorm: kAGuideTopNorm,
                  widthNorm: kAGuideWidthNorm,
                  guideOpacity: kAGuideOpacity,
                  guideTint: kAGuideTint,
                  targetCoverage: kATargetCoverage,
                  snapRadiusPx: kASnapRadiusPx,
                  stampRadiusPx: kAStampRadiusPx,
                  sampleStridePx: kASampleStridePx,
                  onProgress: (p) => setState(() => _aProgress = p),
                  onDone: () async {
                    setState(() => _aPassedOverlay = true);
                    await Future.delayed(const Duration(milliseconds: 800));
                    if (!mounted) return;
                    setState(() {
                      _aPassedOverlay = false;
                      scene = _Scene.snail;
                      passed = List.filled(1, false);
                    });
                    // 씬 B 진입 멘트
                    _play(kAudioFollow);
                    _play(kAudioIntro);
                  },
                  onFail: () => _play(kAudioFollow),
                  strokeColor: kAStrokeColor,
                  strokeWidthBasePx: kAStrokeBasePx,
                ),

                // 오른쪽 새(장식)
                Positioned(
                  right: 24,
                  bottom: size.height * 0.22,
                  width: 130,
                  height: 130,
                  child: Image.asset(kBirdAsset, fit: BoxFit.contain),
                ),

                // 하단 진행 안내
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '선을 따라 그려보세요! ${(_aProgress * 100).round()}%',
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
                                blurRadius: 4)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (_aPassedOverlay) const _OverlayLabel(text: '정답입니다! 🎉'),

                // 뒤로가기
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
              ],
            );
          }

          // 씬 B / Outro
          return GestureDetector(
            onPanStart: (d) => _onPanStart(d, size),
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(size),
            child: Stack(
              children: [
                _TitleBanner(text: '따라그려봐요!', topGap: kATitleTopGap),
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
                        width: kPassedStrokeWidth),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

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
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 14),
              Text(
                '이번 단계를 클리어했어요!\n다음 단계도 도전해봐요',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
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
            builder: (_) => WriteGameMainPage(childId: widget.childId)),
      );
    });
  }
}

/* ───────────────── Common small widgets ───────────────── */
class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(12)),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25),
        ),
      ),
    );
  }
}

class _TitleBanner extends StatelessWidget {
  final String text;
  final double topGap;
  const _TitleBanner({required this.text, this.topGap = 12});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: top + topGap),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12)),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.black)),
        ),
      ),
    );
  }
}

class _Asset extends StatelessWidget {
  const _Asset(this.path, {super.key});
  final String path;
  @override
  Widget build(BuildContext context) => Image.asset(path, fit: BoxFit.contain);
}

/* ───────────────── Outro: 3 rows configurable ───────────────── */
class OutroRowConfig {
  const OutroRowConfig({
    this.strikeColor = const Color(0xFFD92B2B),
    this.strikeWidth = 8.0,
    this.strikeStartPct = const Offset(0.23, 0.31),
    this.strikeEndPct = const Offset(0.82, 0.31),
    this.strikeUseAngle = false,
    this.strikeCenterPct = const Offset(0.52, 0.36),
    this.strikeAngleDeg = -18,
    this.strikeLengthRatio = 0.65,
    this.checkColor = const Color(0xFFD92B2B),
    this.checkStrokeWidth = 6.0,
    this.checkCenterPct = const Offset(0.195, 0.445),
    this.checkSizePx = 34.0,
    this.checkRotationDeg = 0.0,
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
  const OutroOverlay(
      {super.key,
      required this.onFinished,
      this.config = const Outro3Config(),
      this.autoFinish = false});
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
        curve: const Interval(0.00, 0.11, curve: Curves.easeOutCubic));
    _tCheck1 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.11, 0.22, curve: Curves.easeOutCubic));
    _tStamp1 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.22, 0.333, curve: Curves.elasticOut));

    _tStrike2 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.333, 0.444, curve: Curves.easeOutCubic));
    _tCheck2 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.444, 0.555, curve: Curves.easeOutCubic));
    _tStamp2 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.555, 0.666, curve: Curves.elasticOut));

    _tStrike3 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.666, 0.777, curve: Curves.easeOutCubic));
    _tCheck3 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.777, 0.888, curve: Curves.easeOutCubic));
    _tStamp3 = CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.888, 1.000, curve: Curves.elasticOut));

    _seqCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && widget.autoFinish)
        widget.onFinished();
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
    return OffsetPair(cfg._toNoteXY(noteSize, rc.strikeStartPct),
        cfg._toNoteXY(noteSize, rc.strikeEndPct));
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
                        child: Image.asset(cfg.noteAsset, fit: BoxFit.contain)),

                    // Row1
                    AnimatedBuilder(
                      animation: _tStrike1,
                      builder: (_, __) => CustomPaint(
                          painter: _OutroStrikePainter(
                              start: r1Strike.start,
                              end: r1Strike.end,
                              t: _tStrike1.value)),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck1,
                      builder: (_, __) => CustomPaint(
                          painter: _OutroCheckPainter(
                              center: r1CheckC,
                              size: r1.checkSizePx,
                              t: _tCheck1.value,
                              color: r1.checkColor,
                              strokeWidth: r1.checkStrokeWidth,
                              rotationDeg: r1.checkRotationDeg)),
                    ),
                    AnimatedBuilder(
                      animation: _tStamp1,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                                begin: r1.stampDropPx, end: Offset.zero)
                            .transform(_tStamp1.value);
                        final scale = Tween<double>(
                                begin: r1.stampStartScale,
                                end: r1.stampFinalScale)
                            .transform(_tStamp1.value);
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
                                    child: Image.asset(r1.stampAsset,
                                        fit: BoxFit.contain)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Row2
                    AnimatedBuilder(
                      animation: _tStrike2,
                      builder: (_, __) => CustomPaint(
                          painter: _OutroStrikePainter(
                              start: r2Strike.start,
                              end: r2Strike.end,
                              t: _tStrike2.value)),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck2,
                      builder: (_, __) => CustomPaint(
                          painter: _OutroCheckPainter(
                              center: r2CheckC,
                              size: r2.checkSizePx,
                              t: _tCheck2.value,
                              color: r2.checkColor,
                              strokeWidth: r2.checkStrokeWidth,
                              rotationDeg: r2.checkRotationDeg)),
                    ),
                    AnimatedBuilder(
                      animation: _tStamp2,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                                begin: r2.stampDropPx, end: Offset.zero)
                            .transform(_tStamp2.value);
                        final scale = Tween<double>(
                                begin: r2.stampStartScale,
                                end: r2.stampFinalScale)
                            .transform(_tStamp2.value);
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
                                    child: Image.asset(r2.stampAsset,
                                        fit: BoxFit.contain)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Row3
                    AnimatedBuilder(
                      animation: _tStrike3,
                      builder: (_, __) => CustomPaint(
                          painter: _OutroStrikePainter(
                              start: r3Strike.start,
                              end: r3Strike.end,
                              t: _tStrike3.value)),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck3,
                      builder: (_, __) => CustomPaint(
                          painter: _OutroCheckPainter(
                              center: r3CheckC,
                              size: r3.checkSizePx,
                              t: _tCheck3.value,
                              color: r3.checkColor,
                              strokeWidth: r3.checkStrokeWidth,
                              rotationDeg: r3.checkRotationDeg)),
                    ),
                    AnimatedBuilder(
                      animation: _tStamp3,
                      builder: (_, __) {
                        final drop = Tween<Offset>(
                                begin: r3.stampDropPx, end: Offset.zero)
                            .transform(_tStamp3.value);
                        final scale = Tween<double>(
                                begin: r3.stampStartScale,
                                end: r3.stampFinalScale)
                            .transform(_tStamp3.value);
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
                                    child: Image.asset(r3.stampAsset,
                                        fit: BoxFit.contain)),
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

/* ───────── Outro painters ───────── */
class _OutroStrikePainter extends CustomPainter {
  _OutroStrikePainter(
      {required this.start, required this.end, required this.t});
  final Offset start, end;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFD92B2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final to = Offset(
        start.dx + (end.dx - start.dx) * t, start.dy + (end.dy - start.dy) * t);
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
    final p = Paint()
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
      final x =
          Offset(ra.dx + (rb.dx - ra.dx) * tt, ra.dy + (rb.dy - ra.dy) * tt);
      canvas.drawLine(ra, x, p);
    } else {
      canvas.drawLine(ra, rb, p);
      final tt = (t - 0.5) / 0.5;
      final x =
          Offset(rb.dx + (rc.dx - rb.dx) * tt, rb.dy + (rc.dy - rb.dy) * tt);
      canvas.drawLine(rb, x, p);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OutroCheckPainter old) => old.t != t;
}

/* ───────── Stroke & guide utils (씬 B) ───────── */
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
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final g in guides) {
      _drawDashedPolyline(canvas, g.points, p, dash: dash, gap: gap);
    }
  }

  void _drawDashedPolyline(Canvas c, List<Offset> pts, Paint p,
      {double dash = 20, double gap = 16}) {
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
  const _StrokePainter(
      {required this.points, required this.color, this.width = 10});

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

/* ───────────────── Scene A: plane_write 경량 이식 ───────────────── */
class _GameImageGuideLayer extends StatefulWidget {
  const _GameImageGuideLayer({
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
    this.onFail,
    required this.strokeColor,
    required this.strokeWidthBasePx,
    this.guideTint,
  });

  final String guideAsset;
  final double leftNorm, topNorm, widthNorm, guideOpacity;
  final Color? guideTint; // 흰 배경에서도 보이게 틴트 가능

  final double targetCoverage, snapRadiusPx;
  final int stampRadiusPx, sampleStridePx;

  final ValueChanged<double> onProgress;
  final VoidCallback onDone;
  final VoidCallback? onFail;

  final ui.Color strokeColor;
  final double strokeWidthBasePx;

  @override
  State<_GameImageGuideLayer> createState() => _GameImageGuideLayerState();
}

class _GameImageGuideLayerState extends State<_GameImageGuideLayer> {
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
      (screenPt.dy - _guideRect.top) * _my);

  double _distanceToRect(Offset p, Rect r) {
    final dx = (p.dx < r.left)
        ? (r.left - p.dx)
        : (p.dx > r.right)
            ? (p.dx - r.right)
            : 0.0;
    final dy = (p.dy < r.top)
        ? (r.top - p.dy)
        : (p.dy > r.bottom)
            ? (p.dy - r.bottom)
            : 0.0;
    return math.sqrt(dx * dx + dy * dy);
  }

  Offset? _nearestMaskPoint(Offset rawScreen) {
    if (_distanceToRect(rawScreen, _guideRect) > widget.snapRadiusPx)
      return null;

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
        _guideRect.left + best.dx / _mx, _guideRect.top + best.dy / _my);
  }

  void _stampAtMaskGrid(Offset maskPt) {
    final cx = (maskPt.dx / _stride).round();
    final cy = (maskPt.dy / _stride).round();
    final rGrid = math.max(1, (widget.stampRadiusPx / _stride).ceil());

    for (int gy = cy - rGrid; gy <= cy + rGrid; gy++) {
      if (gy < 0 || gy >= _gridH) continue;
      for (int gx = cx - rGrid; gx <= cx + rGrid; gx++) {
        if (gx < 0 || gx >= _gridW) continue;
        if ((gx - cx) * (gx - cx) + (gy - cy) * (gy - cy) > rGrid * rGrid)
          continue;

        final idx = gy * _gridW + gx;
        if (!_coveredGrid[idx] && _alphaOnAtGrid(gx, gy)) {
          _coveredGrid[idx] = true;
          _coveredSamples++;
        }
      }
    }
  }

  void _updateProgress(Offset maskPt) {
    widget.onProgress(_coverage);
    _lastMaskPt = maskPt;
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    final imageWidget = RawImage(image: _maskImg, fit: BoxFit.fill);
    final guideImage = (widget.guideTint == null)
        ? imageWidget
        : ColorFiltered(
            colorFilter: ColorFilter.mode(widget.guideTint!, BlendMode.srcATop),
            child: imageWidget);

    return Stack(
      children: [
        // 반투명 가이드
        Positioned.fromRect(
          rect: _guideRect,
          child: Opacity(opacity: widget.guideOpacity, child: guideImage),
        ),

        // 제스처 + 스트로크(마스크 밖 잘림)
        Positioned.fill(
          child: GestureDetector(
            onPanStart: (d) {
              _resetAttempt();
              final snapped = _nearestMaskPoint(d.localPosition);
              if (snapped == null) return;

              final m = _toMask(snapped);
              _stampAtMaskGrid(m);
              _stroke.add(snapped);
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
              // ✅ 이제는 커버리지나 끝점 체크 없이,
              // 조금이라도 그렸으면 바로 성공 처리
              if (_stroke.length > 5) {
                widget.onDone();
              } else {
                widget.onFail?.call();
                _resetAttempt();
              }
            },
            child: CustomPaint(
              painter: _MaskClippedStrokePainter(
                stroke: _stroke,
                maskImage: _maskImg!,
                maskSrcRect:
                    Rect.fromLTWH(0, 0, _gw.toDouble(), _gh.toDouble()),
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
      ],
    );
  }
}

// 마스크(dstIn)로 밖을 잘라내는 스트로크 렌더러
class _MaskClippedStrokePainter extends CustomPainter {
  _MaskClippedStrokePainter({
    required this.stroke,
    required this.maskImage,
    required this.maskSrcRect,
    required this.maskDstRect,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final List<Offset> stroke;
  final ui.Image maskImage;
  final Rect maskSrcRect;
  final Rect maskDstRect;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (stroke.length < 2) return;

    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }

    canvas.saveLayer(maskDstRect, Paint());

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, paint);

    canvas.drawImageRect(maskImage, maskSrcRect, maskDstRect,
        Paint()..blendMode = BlendMode.dstIn);
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
