// lib/main/gameView/writeGame/page/level1/write_game_1_2.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';
// 열매ID, 게임 api
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

// ⬇️ AUDIO IMPORT
import 'package:audioplayers/audioplayers.dart';

// ⬇️ AUDIO ASSET DEFINITIONS
// 오디오 에셋 경로
const String _audioDir = 'audio/tts/gameWrite/level1/';

// 3세 쓰기 게임 1-2 레벨 오디오 에셋 정의 (추가됨)
const Map<String, String> LEVEL3_AUDIO_ASSETS_1_2 = {
  // 구분: 공통 | 대사: 따라, 그려봐요~!
  'COMMON_1': _audioDir + 'write3_game_common_1.mp3',
  // 구분: 인트로 2 | 대사: 꾸붓~ 꾸붓~ 그리기. (씬 A/B 유도용)
  'INTRO_2': _audioDir + 'write3_game_intro_2.mp3',
};
// ⬆️ AUDIO ASSET DEFINITIONS

enum _Scene { swim, balloon, outro }

// ───────────────────────── 레이아웃/튜닝 상수 ─────────────────────────
const double kSwimmersWidth = 350;
const double kSwimmersTop = 80;
const double kSwimmersBottom = 40;

const double kGuideYOffset = 200;
const double kSwimLengthRatio = 0.78;
const double kSwimRowGap = 190.0;

const double kBalloonImageTop = 130;
const double kBalloonImageHeight = 270;

const double kStringTopOffset = 8;
const double kStringBottomPad = 120;

const List<double> kBalloonRatios = [0.10, 0.30, 0.50, 0.70, 0.90];

class WriteGameLevel1_2Page extends StatefulWidget {
  const WriteGameLevel1_2Page({
    super.key,
    required this.childId,
    this.resultId,
    });
  final String childId;
  final String? resultId;

  @override
  State<WriteGameLevel1_2Page> createState() => _WriteGameLevel1_2PageState();
}

class _WriteGameLevel1_2PageState extends State<WriteGameLevel1_2Page> {
  _Scene scene = _Scene.swim;

  // 진행/입력
  late List<bool> passed = List.filled(_lineCount, false);
  int? activeLine;
  List<Offset> stroke = [];

  // 판정 파라미터
  static const double tol = 24.0;
  static const double startPickTol = 48;
  static const double hitRatio = 0.70;
  static const double coverageRatio = 0.70;

  // API/시간
  String? resultId;
  final _sw = Stopwatch();
  bool _completing = false;

  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();
  // ⬆️ AUDIO PLAYER INSTANCE

  int get _lineCount =>
      scene == _Scene.swim ? 3 : (scene == _Scene.balloon ? 5 : 0);
  bool get _allPassed => passed.every((e) => e);

  // ⬇️ AUDIO PLAYBACK LOGIC
  /// 오디오 재생 헬퍼 함수
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (1-2): $assetPath');
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initAndStart();

    // ⬇️ 씬 A (Swim) 시작 오디오 재생 (수정됨: COMMON_1 + INTRO_2 재생)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_2['COMMON_1']!);
      _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_2['INTRO_2']!);
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

  Future<void> _initAndStart() async {
    try {
      // ✅ 부모(WriteGameMainPage)에서 이미 /start 호출로 resultId 전달됨
      resultId = widget.resultId ?? FruitState.instance.resultId;
      if (resultId == null) {
        throw Exception('resultId 없음 (/start 누락)');
      }

      // 게임 시작 시각 기록
      _sw.start();
      debugPrint('[1-2] 🎯 resultId=$resultId → 게임 시작 타이머 시작');

    } catch (e) {
      debugPrint('[1-2] ⚠️ 초기화 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류. 잠시 후 다시 시도하세요.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // ───────────── 가이드 생성 (폴리라인) ─────────────
  List<_GuidePath> _buildSwimGuides(Size size) {
    const double left = 140.0;
    const double right = 24.0;
    const double top0 = 80.0;

    final double startX0 = left + 50;
    final double endX0 = size.width - right;
    final double fullW = endX0 - startX0;

    final double startX = startX0 + (fullW * (1 - kSwimLengthRatio)) / 2;
    final double endX = startX + fullW * kSwimLengthRatio;

    final out = <_GuidePath>[];
    for (int i = 0; i < 3; i++) {
      final double yBase = top0 + i * kSwimRowGap + kGuideYOffset;
      final int teeth = 8 + i;
      final double amp = 50.0;
      final pts = _buildZigZag(
        startX: startX,
        endX: endX,
        baseY: yBase,
        amp: amp,
        teeth: teeth,
      );
      out.add(_GuidePath.polyline(pts));
    }
    return out;
  }

  List<Offset> _buildZigZag({
    required double startX,
    required double endX,
    required double baseY,
    required double amp,
    required int teeth,
  }) {
    final pts = <Offset>[];
    final double w = endX - startX;

    for (int i = 0; i <= teeth; i++) {
      final double t = i / teeth;
      final double x = startX + w * t;
      final double y = baseY + ((i % 2 == 0) ? -amp : amp);
      pts.add(Offset(x, y));
    }
    return pts;
  }

  List<_GuidePath> _buildBalloonGuides(Size size) {
    final double imgBottom = kBalloonImageTop + kBalloonImageHeight;
    final double stringStartY = imgBottom + kStringTopOffset;
    final double stringEndY = size.height - kStringBottomPad;

    const double leftPad = 40.0;
    const double rightPad = 40.0;
    final double usableW = size.width - leftPad - rightPad;
    final List<double> xs =
        kBalloonRatios.map((r) => leftPad + usableW * r).toList();

    final out = <_GuidePath>[];
    for (int i = 0; i < xs.length; i++) {
      final x0 = xs[i];
      final steps = 64;
      final amp = 30.0;
      final period = 2.2 + i * 0.15;

      final pts = <Offset>[];
      for (int s = 0; s <= steps; s++) {
        final t = s / steps;
        final y = stringStartY + (stringEndY - stringStartY) * t;
        final x = x0 + amp * math.sin(t * period * 2 * math.pi + i);
        pts.add(Offset(x, y));
      }
      out.add(_GuidePath.polyline(pts));
    }
    return out;
  }

  // ───────────── 입력 처리 ─────────────
  void _onPanStart(DragStartDetails d, Size size) {
    if (_allPassed || scene == _Scene.outro) return;

    final guides = scene == _Scene.swim
        ? _buildSwimGuides(size)
        : _buildBalloonGuides(size);

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
    if (activeLine == null || _allPassed || scene == _Scene.outro) return;
    stroke.add(d.localPosition);
    setState(() {});
  }

  Future<void> _onPanEnd(Size size) async {
    if (activeLine == null || _allPassed || scene == _Scene.outro) return;

    final guides = scene == _Scene.swim
        ? _buildSwimGuides(size)
        : _buildBalloonGuides(size);

    final ok = _gradeStroke(stroke, guides[activeLine!]);

    if (ok) {
      passed[activeLine!] = true;
      stroke.clear();
      activeLine = null;
      setState(() {});

      if (_allPassed) {
        if (scene == _Scene.swim) {

          Future.delayed(const Duration(milliseconds: 350), () {
            if (!mounted) return;
            setState(() {
              scene = _Scene.balloon;
              passed = List.filled(_lineCount, false);
            });
            // ⬇️ 씬 A (Swim) 시작 오디오 재생 (수정됨: COMMON_1 + INTRO_2 재생)
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_2['COMMON_1']!);
              _playAssetAudio(LEVEL3_AUDIO_ASSETS_1_2['INTRO_2']!);
            });
          });
        } else {
          // ✅ 씬 B 완료 → 두 번째 choice + complete 전송
          if (resultId != null) {
            await ChildGameApi.recordWritingChoice(
              resultId: resultId!,
              questionId: 'WG_Q2_01',
              childWrittenText: null,
              isCorrect: true,
            );
            debugPrint('[1-2] ✅ choice 기록 완료 (WG_Q2_01)');

            await ChildGameApi.completeWritingGame(
              resultId: resultId!,
              timeSpentSecs: _sw.elapsed.inSeconds,
            );
            debugPrint('[1-2] 🎉 complete 전송 완료');
          }
         
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

  // ─────────────────────────────────────────────
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

  // ───────────── UI ─────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            onPanStart: (d) => _onPanStart(d, size),
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(size),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const _TitleBanner(text: '따라그려봐요!'),
                if (scene == _Scene.swim) _buildSceneSwim(size),
                if (scene == _Scene.balloon) _buildSceneBalloon(size),
                if (scene == _Scene.outro)
                  Positioned.fill(
                    child: OutroOverlay(
                      autoFinish: true,
                      onFinished: () => _showClearPopup(context),
                      config: OutroConfig(
                        noteWidthRatio: 0.86,
                        noteAspect: 0.72,
                        backgroundColor: Colors.white,
                        row1: const OutroRowConfig(
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
                          stampFinalScale: 0.30,
                          stampRotationDeg: -7,
                        ),
                        row2: const OutroRowConfig(
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
                          stampFinalScale: 1,
                          stampRotationDeg: -8,
                        ),
                      ),
                    ),
                  ),
                if (stroke.isNotEmpty && scene != _Scene.outro)
                  CustomPaint(
                    size: size,
                    painter: _StrokePainter(
                      points: stroke,
                      color: scene == _Scene.swim
                          ? const Color(0xFFEB5757)
                          : const Color(0xFF2D9CDB),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSceneSwim(Size size) {
    final guides = _buildSwimGuides(size);
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: kSwimmersTop,
          bottom: kSwimmersBottom,
          width: kSwimmersWidth,
          child: Image.asset(
            'assets/img/contents/gameWrite/swimming.png',
            fit: BoxFit.contain,
          ),
        ),
        CustomPaint(size: size, painter: _GuidePainter(guides: guides)),
        CustomPaint(
          size: size,
          painter: _PassedPainter(guides: guides, passed: passed),
        ),
      ],
    );
  }

  Widget _buildSceneBalloon(Size size) {
    final guides = _buildBalloonGuides(size);

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: kBalloonImageTop,
          height: kBalloonImageHeight,
          child: Transform.scale(
            scaleX: 1.18,
            child: Image.asset(
              'assets/img/contents/gameWrite/balloon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        CustomPaint(size: size, painter: _GuidePainter(guides: guides)),
        CustomPaint(
          size: size,
          painter: _PassedPainter(guides: guides, passed: passed),
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

// ───────────────────── Outro Config ─────────────────────
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

class OutroConfig {
  const OutroConfig({
    this.noteWidthRatio = 0.86,
    this.noteAspect = 0.72,
    this.backgroundColor = Colors.white,
    this.noteAsset = 'assets/img/contents/gameWrite/outro_note1.png',
    this.fadeDuration = const Duration(milliseconds: 600),
    this.sequenceDuration = const Duration(milliseconds: 3600),
    this.row1 = const OutroRowConfig(),
    this.row2 = const OutroRowConfig(),
  });

  final double noteWidthRatio;
  final double noteAspect;
  final Color backgroundColor;
  final String noteAsset;
  final Duration fadeDuration;
  final Duration sequenceDuration;

  final OutroRowConfig row1;
  final OutroRowConfig row2;

  Offset _toNoteXY(Size noteSize, Offset pct) =>
      Offset(noteSize.width * pct.dx, noteSize.height * pct.dy);
}

// ───────────────────── Outro Overlay ─────────────────────
class OutroOverlay extends StatefulWidget {
  const OutroOverlay({
    super.key,
    required this.onFinished,
    this.config = const OutroConfig(),
    this.autoFinish = false,
  });

  final VoidCallback onFinished;
  final OutroConfig config;
  final bool autoFinish;

  @override
  State<OutroOverlay> createState() => _OutroOverlayState();
}

class _OutroOverlayState extends State<OutroOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _seqCtrl;
  late final Animation<double> _fade;

  late final Animation<double> _tStrike1;
  late final Animation<double> _tCheck1;
  late final Animation<double> _tStamp1;

  late final Animation<double> _tStrike2;
  late final Animation<double> _tCheck2;
  late final Animation<double> _tStamp2;

  OutroConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: cfg.fadeDuration);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _seqCtrl = AnimationController(vsync: this, duration: cfg.sequenceDuration);

    _tStrike1 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.00, 0.17, curve: Curves.easeOutCubic),
    );
    _tCheck1 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.17, 0.34, curve: Curves.easeOutCubic),
    );
    _tStamp1 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.34, 0.50, curve: Curves.elasticOut),
    );

    _tStrike2 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.50, 0.67, curve: Curves.easeOutCubic),
    );
    _tCheck2 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.67, 0.84, curve: Curves.easeOutCubic),
    );
    _tStamp2 = CurvedAnimation(
      parent: _seqCtrl,
      curve: const Interval(0.84, 1.00, curve: Curves.elasticOut),
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

              OffsetPair _strikePoints(OutroRowConfig rc) {
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

              final r1 = cfg.row1;
              final r1Strike = _strikePoints(r1);
              final r1CheckCenter = cfg._toNoteXY(noteSize, r1.checkCenterPct);
              final r1StampPos = cfg._toNoteXY(noteSize, r1.stampPosPct);

              final r2 = cfg.row2;
              final r2Strike = _strikePoints(r2);
              final r2CheckCenter = cfg._toNoteXY(noteSize, r2.checkCenterPct);
              final r2StampPos = cfg._toNoteXY(noteSize, r2.stampPosPct);

              return SizedBox(
                width: noteW,
                height: noteH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(cfg.noteAsset, fit: BoxFit.contain),
                    ),

                    // Row1
                    AnimatedBuilder(
                      animation: _tStrike1,
                      builder: (_, __) => CustomPaint(
                        painter: _StrikePainter(
                          start: r1Strike.start,
                          end: r1Strike.end,
                          t: _tStrike1.value,
                          color: r1.strikeColor,
                          width: r1.strikeWidth,
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck1,
                      builder: (_, __) => CustomPaint(
                        painter: _CheckPainter(
                          center: r1CheckCenter,
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

                        final double? w1 = r1.stampSizePx ??
                            (r1.stampWidthRatio != null
                                ? noteW * r1.stampWidthRatio!
                                : null);

                        final img = Image.asset(
                          r1.stampAsset,
                          width: w1,
                          fit: BoxFit.contain,
                        );

                        return Positioned(
                          left: r1StampPos.dx,
                          top: r1StampPos.dy,
                          child: Transform.translate(
                            offset: drop,
                            child: Transform.rotate(
                              angle: rot,
                              child: Transform.scale(scale: scale, child: img),
                            ),
                          ),
                        );
                      },
                    ),

                    // Row2
                    AnimatedBuilder(
                      animation: _tStrike2,
                      builder: (_, __) => CustomPaint(
                        painter: _StrikePainter(
                          start: r2Strike.start,
                          end: r2Strike.end,
                          t: _tStrike2.value,
                          color: r2.strikeColor,
                          width: r2.strikeWidth,
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _tCheck2,
                      builder: (_, __) => CustomPaint(
                        painter: _CheckPainter(
                          center: r2CheckCenter,
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

                        final double w2 = r2.stampSizePx ??
                            (r2.stampWidthRatio != null
                                ? noteW * r2.stampWidthRatio!
                                : noteW * 0.20);

                        final img = Image.asset(
                          r2.stampAsset,
                          fit: BoxFit.contain,
                        );

                        return Positioned(
                          left: r2StampPos.dx,
                          top: r2StampPos.dy,
                          child: Transform.translate(
                            offset: drop,
                            child: Transform.rotate(
                              angle: rot,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(width: w2, child: img),
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

// ───────────────────── 유틸/페인터 ─────────────────────
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
      old.t != t ||
      old.color != color ||
      old.width != width ||
      old.start != start ||
      old.end != end;
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
  final double size;
  final double t;
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

    final ra = Offset(-0.24 * size, 0.06 * size);
    final rb = Offset(-0.06 * size, 0.35 * size);
    final rc = Offset(0.47 * size, -0.24 * size);

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

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

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
      final a = points[i - 1];
      final b = points[i];
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
    final ap = p - a;
    final ab = b - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (ab2 == 0) return (p - a).distance;
    double t = (ap.dx * ab.dx + ap.dy * ab.dy) / ab2;
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - proj).distance;
  }

  static double _project01OnSegment(Offset p, Offset a, Offset b) {
    final ap = p - a;
    final ab = b - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (ab2 == 0) return 0;
    return ((ap.dx * ab.dx + ap.dy * ab.dy) / ab2).clamp(0.0, 1.0);
  }
}

class _GuidePainter extends CustomPainter {
  final List<_GuidePath> guides;
  const _GuidePainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (final g in guides) {
      _drawDashedPolyline(canvas, g.points, p, dash: 16, gap: 22);
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
  bool shouldRepaint(covariant _GuidePainter old) => false;
}

class _PassedPainter extends CustomPainter {
  final List<_GuidePath> guides;
  final List<bool> passed;
  const _PassedPainter({required this.guides, required this.passed});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF27AE60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
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
      old.passed != passed || old.guides != guides;
}

class _StrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  const _StrokePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final p = Paint()
      ..color = color.withOpacity(0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
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
      old.points != points || old.color != color;
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
            ),
          ),
        ),
      ),
    );
  }
}
