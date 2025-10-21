// lib/main/studyView/writeStudy/page/writing_2_1.dart (예시 경로)
// ↑ 네가 쓰던 파일 경로대로 저장해줘

import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/selvy_example_view/selvy_recognizer.dart';
import 'dart:async';
import 'dart:math' as math;

// 인트로 이미지
const _twin1 = 'assets/img/contents/studyWrite/twin1.png';

/// ---------------------------------------------------------------------------
/// 레슨 스펙
class LessonSpec {
  final String key;
  final String bigChar;
  final String nameKo;
  final String wordLabel;
  final String wordIconAsset;
  final String maskAsset;
  final List<String> traceAssets;
  final List<Offset> traceOffsets;
  final List<double> traceScales;
  final String previewAsset;

  const LessonSpec({
    required this.key,
    required this.bigChar,
    required this.nameKo,
    required this.wordLabel,
    required this.wordIconAsset,
    required this.maskAsset,
    required this.traceAssets,
    this.traceOffsets = const [],
    this.traceScales = const [],
    required this.previewAsset,
  });
}

/// ---------------------------------------------------------------------------
/// 레슨 정의 (네가 준 것 그대로)
const Map<String, LessonSpec> LESSONS = {
  'giyeok': LessonSpec(
    key: 'giyeok',
    bigChar: 'ㄱ',
    nameKo: '기역',
    wordLabel: '가위',
    wordIconAsset: 'assets/img/contents/studyWrite/scissors.png',
    maskAsset: 'assets/img/contents/studyWrite/giyeok_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/giyeok_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: 'assets/img/contents/studyWrite/giyeok_preview.png',
  ),
  'giyeokssang': LessonSpec(
    key: 'giyeokssang',
    bigChar: 'ㄲ',
    nameKo: '쌍기역',
    wordLabel: '꿀',
    wordIconAsset: 'assets/img/contents/studyWrite/honey.png',
    maskAsset: 'assets/img/contents/studyWrite/giyeokssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/giyeokssang_trace1.png',
      'assets/img/contents/studyWrite/giyeokssang_trace2.png',
    ],
    traceOffsets: [Offset(-90, -5), Offset(90, -2)],
    traceScales: [0.45, 0.45],
    previewAsset: 'assets/img/contents/studyWrite/giyeokssang_preview.png',
  ),
  'digeut': LessonSpec(
    key: 'digeut',
    bigChar: 'ㄷ',
    nameKo: '디귿',
    wordLabel: '다리미',
    wordIconAsset: 'assets/img/contents/studyWrite/iron.png',
    maskAsset: 'assets/img/contents/studyWrite/digeut_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/digeut_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: 'assets/img/contents/studyWrite/digeut_preview.png',
  ),
  'digeutssang': LessonSpec(
    key: 'digeutssang',
    bigChar: 'ㄸ',
    nameKo: '쌍디귿',
    wordLabel: '떡볶이',
    wordIconAsset: 'assets/img/contents/studyWrite/tteokbokki.png',
    maskAsset: 'assets/img/contents/studyWrite/digeutssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/digeutssang_trace1.png',
      'assets/img/contents/studyWrite/digeutssang_trace2.png',
    ],
    traceOffsets: [Offset(-90, -2), Offset(90, -2)],
    traceScales: [0.4, 0.4],
    previewAsset: 'assets/img/contents/studyWrite/digeutssang_preview.png',
  ),
  'siot': LessonSpec(
    key: 'siot',
    bigChar: 'ㅅ',
    nameKo: '시옷',
    wordLabel: '사과',
    wordIconAsset: 'assets/img/contents/studyWrite/apple1.png',
    maskAsset: 'assets/img/contents/studyWrite/siot_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/siot_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [0.8],
    previewAsset: 'assets/img/contents/studyWrite/siot_preview.png',
  ),
  'siotssang': LessonSpec(
    key: 'siotssang',
    bigChar: 'ㅆ',
    nameKo: '쌍시옷',
    wordLabel: '씨앗',
    wordIconAsset: 'assets/img/contents/studyWrite/seed.png',
    maskAsset: 'assets/img/contents/studyWrite/siotssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/siotssang_trace1.png',
      'assets/img/contents/studyWrite/siotssang_trace2.png',
    ],
    traceOffsets: [Offset(-60, -2), Offset(70, -2)],
    traceScales: [0.53, 0.50],
    previewAsset: 'assets/img/contents/studyWrite/siotssang_preview.png',
  ),
  'jieut': LessonSpec(
    key: 'jieut',
    bigChar: 'ㅈ',
    nameKo: '지읒',
    wordLabel: '자동차',
    wordIconAsset: 'assets/img/contents/studyWrite/car.png',
    maskAsset: 'assets/img/contents/studyWrite/jieut_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/jieut_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [0.87],
    previewAsset: 'assets/img/contents/studyWrite/jieut_preview.png',
  ),
  'jieutssang': LessonSpec(
    key: 'jieutssang',
    bigChar: 'ㅉ',
    nameKo: '쌍지읒',
    wordLabel: '짜장면',
    wordIconAsset: 'assets/img/contents/studyWrite/jajangmyeon.png',
    maskAsset: 'assets/img/contents/studyWrite/jieutssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/jieutssang_trace1.png',
      'assets/img/contents/studyWrite/jieutssang_trace2.png',
    ],
    traceOffsets: [Offset(-60, -10), Offset(80, -10)],
    traceScales: [0.5, 0.47],
    previewAsset: 'assets/img/contents/studyWrite/jieutssang_preview.png',
  ),
  'bieup': LessonSpec(
    key: 'bieup',
    bigChar: 'ㅂ',
    nameKo: '비읍',
    wordLabel: '바나나',
    wordIconAsset: 'assets/img/contents/studyWrite/banana.png',
    maskAsset: 'assets/img/contents/studyWrite/bieup_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/bieup_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: 'assets/img/contents/studyWrite/bieup_preview.png',
  ),
  'bieupssang': LessonSpec(
    key: 'bieupssang',
    bigChar: 'ㅃ',
    nameKo: '쌍비읍',
    wordLabel: '빵',
    wordIconAsset: 'assets/img/contents/studyWrite/bread1.png',
    maskAsset: 'assets/img/contents/studyWrite/bieupssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/bieupssang_trace1.png',
      'assets/img/contents/studyWrite/bieupssang_trace2.png',
    ],
    traceOffsets: [Offset(-90, -2), Offset(90, -2)],
    traceScales: [0.43, 0.43],
    previewAsset: 'assets/img/contents/studyWrite/bieupssang_preview.png',
  ),
};

/// 이동 순서
const List<String> LESSON_ORDER = [
  'giyeok',
  'giyeokssang',
  'digeut',
  'digeutssang',
  'siot',
  'siotssang',
  'jieut',
  'jieutssang',
  'bieup',
  'bieupssang',
];

/// (참고용) 레슨별 획 수 — 현재 캔버스에 직접 쓰진 않지만 남겨둠
const Map<String, int> REQUIRED_STROKES = {
  'giyeok': 1,
  'giyeokssang': 2,
  'digeut': 2,
  'digeutssang': 4,
  'siot': 2,
  'siotssang': 4,
  'jieut': 3,
  'jieutssang': 6,
  'bieup': 4,
  'bieupssang': 8,
};

/// ---------------------------------------------------------------------------
/// 페이지
class Writing21Page extends StatefulWidget {
  final String childId;
  final String lesson;
  final bool showIntro;

  const Writing21Page({
    super.key,
    required this.childId,
    this.lesson = 'giyeok',
    this.showIntro = true,
  });

  @override
  State<Writing21Page> createState() => _Writing21PageState();
}

class _Writing21PageState extends State<Writing21Page> {
  late bool _showIntro;
  int step = 0; // 0: 따라쓰기, 1: 학습완료

  final _canvasKey = GlobalKey<WritingCanvasState>();
  bool _rewardShown = false;
  bool get _isFinalLesson => widget.lesson == LESSON_ORDER.last;
  Timer? _finalPopupTimer;
  bool _finalPopupScheduled = false;

  LessonSpec get spec => LESSONS[widget.lesson] ?? LESSONS['giyeok']!;

  @override
  void initState() {
    super.initState();
    _showIntro = widget.showIntro;
    _setLessonCandidate(spec.bigChar); // ✅ 네이티브 후보셋 제한
  }

  @override
  void dispose() {
    _finalPopupTimer?.cancel();
    super.dispose();
  }

  String? _nextLessonKey() {
    final i = LESSON_ORDER.indexOf(widget.lesson);
    if (i == -1 || i + 1 >= LESSON_ORDER.length) return null;
    return LESSON_ORDER[i + 1];
  }

  String _normalizeKoreanLabel(String s) {
    final t = s.trim();
    const map = {
      'ᄀ': 'ㄱ',
      'U+1100': 'ㄱ',
      'ᄁ': 'ㄲ',
      'U+1101': 'ㄲ',
      'ᄃ': 'ㄷ',
      'U+1103': 'ㄷ',
      'ᄄ': 'ㄸ',
      'U+1104': 'ㄸ',
      'ᄉ': 'ㅅ',
      'U+1109': 'ㅅ',
      'ᄊ': 'ㅆ',
      'U+110A': 'ㅆ',
      'ᄌ': 'ㅈ',
      'U+110C': 'ㅈ',
      'ᄍ': 'ㅉ',
      'U+110D': 'ㅉ',
      'ᄇ': 'ㅂ',
      'U+1107': 'ㅂ',
      'ᄈ': 'ㅃ',
      'U+1108': 'ㅃ',
    };
    return map[t] ?? t;
  }

  /// 🔁 인식 콜백: top1 줄만 쓰고 [n] 토큰 제거 후 정규화 비교
  void _onRecognizeFromSelvy(String recognized) {
    final top1Line = recognized.split('\n').first;
    final cleaned = top1Line.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();

    final norm = _normalizeKoreanLabel(cleaned);
    final target = _normalizeKoreanLabel(spec.bigChar);

    if (norm.isNotEmpty && norm == target) {
      setState(() => step = 1);

      if (_isFinalLesson && !_rewardShown && !_finalPopupScheduled) {
        _finalPopupScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _finalPopupTimer = Timer(const Duration(seconds: 3), () {
            if (!mounted || step != 1 || _rewardShown) return;
            _showRewardPopup();
          });
        });
      }
    } else {
      _canvasKey.currentState?.clearCanvas();
    }
  }

  Future<void> _setLessonCandidate(String targetChar) async {
    try {
      await SelvyRecognizer.setCandidateSet([targetChar]);
      // 언어 타입은 WritingCanvas가 targetType에 맞춰 setLanguage() 해줌
      debugPrint('[Writing21] setCandidateSet([$targetChar])');
    } catch (e) {
      debugPrint('[Writing21] setCandidateSet 실패: $e');
    }
  }

  void _goBackToAppleTree() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
    );
  }

  void _goNext() {
    final nextKey = _nextLessonKey();
    if (nextKey == null) {
      _goBackToAppleTree();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Writing21Page(
            childId: widget.childId,
            lesson: nextKey,
            showIntro: false,
          ),
        ),
      );
    }
  }

  Widget _buildIntro(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _showIntro = false),
      child: Container(
        color: const Color(0xFFFFF4F3),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final shortest =
                  (c.maxWidth < c.maxHeight) ? c.maxWidth : c.maxHeight;
              final imgW = shortest * 0.55;
              final double lift = c.maxHeight * 0.16;
              final double hintBottom = 120.0;

              return Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, -lift),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              _twin1,
                              width: imgW,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '자음 쌍둥이들이 찾아왔어요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5A4032),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: hintBottom + MediaQuery.of(context).padding.bottom,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3D6).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          '화면을 탭하면 넘어가요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4E3B00),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showNextFab = !_showIntro && step == 1 && !_isFinalLesson;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: _goBackToAppleTree,
        ),
      ),
      body: _showIntro
          ? _buildIntro(context)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: step == 0
                    ? _buildWriteStep(context)
                    : _buildCompleteStep(context),
              ),
            ),

      // FAB은 고정 두고 가시성만 토글
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: IgnorePointer(
            ignoring: !showNextFab,
            child: AnimatedOpacity(
              opacity: showNextFab ? 1 : 0,
              duration: const Duration(milliseconds: 140),
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: const Color(0xFFD9CCFF),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                  onPressed: _goNext,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    _nextLessonKey() == null ? '확인' : '다음',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  /// 1) 따라쓰기 화면
  Widget _buildWriteStep(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Row(
          children: [
            // 왼쪽 패널
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, l) {
                  final colW = l.maxWidth;
                  final glyphSize = (colW * 0.65).clamp(160.0, 260.0);
                  final wordSize = (colW * 0.12).clamp(36.0, 52.0);
                  final iconSize = (colW * 0.40).clamp(90.0, 140.0);
                  final labelSize = (colW * 0.11).clamp(28.0, 38.0);
                  final hintW = (colW * 0.56).clamp(170.0, 300.0);

                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              spec.bigChar,
                              style: TextStyle(
                                fontSize: glyphSize,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: glyphSize * 0.06),
                            Text(
                              spec.nameKo,
                              style: TextStyle(
                                fontSize: wordSize,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: glyphSize * 0.14),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  spec.wordIconAsset,
                                  width: iconSize,
                                  height: iconSize,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  spec.wordLabel,
                                  style: TextStyle(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 250,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Image.asset(
                              'assets/img/contents/studyWrite/hint_tailleft.png',
                              width: 180,
                              fit: BoxFit.contain,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 13, bottom: 6),
                              child: Text(
                                '누르면 들어볼 수 있어요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFDB7C7C),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 오른쪽 패널
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, box) {
                  // ── 버튼/여백 예약치 정의 ───────────────────────────────────────────────
                  const double buttonH = 42; // 버튼 높이
                  const double buttonLift = 56; // 하단에서 띄울 거리(↑로 올림)
                  final double safeBottom =
                      MediaQuery.of(context).padding.bottom;
                  final double reservedBottom =
                      buttonH + buttonLift + safeBottom;

                  // ── 보드 최대 크기 계산 (버튼이 차지하는 영역 제외) ─────────────────────
                  final double maxBoardHeight = (box.maxHeight - reservedBottom)
                      .clamp(240.0, box.maxHeight);

                  final double padW = math
                      .min(
                        box.maxWidth * 0.86, // 가로 기준 너비 제한
                        maxBoardHeight * 0.88, // 세로 기준(예약 높이 제외)
                      )
                      .clamp(280.0, 900.0);

                  const innerScale = 0.80;
                  const baseTraceScale = 0.75;

                  final maskW = padW * innerScale;
                  final traceW = maskW * baseTraceScale;
                  final captionSize = (padW * 0.10).clamp(18.0, 32.0);

                  // ── 버튼을 하단에서 띄워서 고정하기 위해 Stack 사용 ────────────────────
                  return Stack(
                    children: [
                      // 보드(노트패드) 영역: 가운데에 배치
                      Positioned.fill(
                        child: Center(
                          child: SizedBox(
                            width: padW,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/img/contents/studyWrite/notepad_frame.png',
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(
                                    width: maskW,
                                    child: Image.asset(
                                      spec.maskAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  ...List.generate(spec.traceAssets.length, (
                                    i,
                                  ) {
                                    final offs = (i < spec.traceOffsets.length)
                                        ? spec.traceOffsets[i]
                                        : const Offset(0, -2);
                                    final scale = (i < spec.traceScales.length)
                                        ? spec.traceScales[i]
                                        : 1.0;
                                    return SizedBox(
                                      width: traceW * scale,
                                      child: Transform.translate(
                                        offset: offs,
                                        child: Image.asset(
                                          spec.traceAssets[i],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(
                                    width: maskW * 0.98,
                                    height: maskW * 0.98,
                                    child: WritingCanvas(
                                      key: _canvasKey,
                                      childId: widget.childId,
                                      targetChar: spec.bigChar,
                                      candidateSet: [spec.bigChar],
                                      targetType: "consonant",
                                      onRecognize: _onRecognizeFromSelvy,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: padW * 0.06,
                                    child: Text(
                                      '따라 써봐요!',
                                      style: TextStyle(
                                        fontSize: captionSize,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFFF6B6B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 채점하기 버튼: 하단에서 buttonLift 만큼 띄워 고정
                      // 채점하기 버튼: 하단에서 buttonLift 만큼 띄워 고정
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 30,
                        child: Center(
                          child: SizedBox(
                            width: 200, // ✅ 버튼 폭 직접 지정
                            height: buttonH,
                            child: ElevatedButton(
                              onPressed: () => _canvasKey.currentState
                                  ?.recognizeAndCheckText(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD966),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                '채점하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRewardPopup() {
    if (_rewardShown || !mounted) return;
    _rewardShown = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'reward',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        final size = MediaQuery.of(context).size;
        final cardW = size.width * 0.72 > 520 ? 520.0 : size.width * 0.72;

        return Center(
          child: Material(
            color: Colors.transparent,
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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage(
                      'assets/img/contents/studyWrite/apple1.png',
                    ),
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 14),
                  Text(
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
          ),
        );
      },
    );

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
      );
    });
  }

  /// 2) 학습 완료 화면
  Widget _buildCompleteStep(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final padW = (c.maxWidth * 0.60).clamp(320.0, c.maxHeight * 0.80);
        final previewW = padW * 0.62;
        final labelSize = (padW * 0.13).clamp(30.0, 42.0);
        final titleSize = (padW * 0.12).clamp(24.0, 34.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: padW,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/img/contents/studyWrite/notepad_frame.png',
                        fit: BoxFit.contain,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            spec.previewAsset,
                            width: previewW,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            spec.nameKo,
                            style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '‘${spec.bigChar}’을 학습했어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF7A5C51),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
