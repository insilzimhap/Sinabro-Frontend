import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'; // ★ SelvyRecognizer 사용
import 'dart:async';

// 인트로 이미지(twin2)
const _twin2 = 'assets/img/contents/studyWrite/twin2.png';

/// ---------------------------------------------------------------------------
/// 레슨 스펙 (trace만 자유롭게 크기/위치 조절)
class LessonSpec2 {
  final String key; // 'nieun', 'rieul', ...
  final String bigChar; // ㄴ, ㄹ, ...
  final String nameKo; // 니은, 리을, ...
  final String wordLabel; // 나비, 라면, ...
  final String wordIconAsset; // 연상 아이콘
  final String maskAsset; // 마스크
  final List<String> traceAssets; // 트레이스 파일들(획 단위)
  final List<Offset> traceOffsets; // 각 획 오프셋(px)
  final List<double> traceScales; // 각 획 스케일
  final String previewAsset; // 완료 화면 프리뷰

  const LessonSpec2({
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

const String _base = 'assets/img/contents/studyWrite/';

/// 레슨 정의
const Map<String, LessonSpec2> LESSONS2 = {
  'nieun': LessonSpec2(
    key: 'nieun',
    bigChar: 'ㄴ',
    nameKo: '니은',
    wordLabel: '나비',
    wordIconAsset: '${_base}butterfly.png',
    maskAsset: '${_base}nieun_mask.png',
    traceAssets: ['${_base}nieun_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}nieun_preview.png',
  ),
  'rieul': LessonSpec2(
    key: 'rieul',
    bigChar: 'ㄹ',
    nameKo: '리을',
    wordLabel: '라면',
    wordIconAsset: '${_base}ramen.png',
    maskAsset: '${_base}rieul_mask.png',
    traceAssets: ['${_base}rieul_trace1.png'],
    traceOffsets: [Offset(-4, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}rieul_preview.png',
  ),
  'mieum': LessonSpec2(
    key: 'mieum',
    bigChar: 'ㅁ',
    nameKo: '미음',
    wordLabel: '마늘',
    wordIconAsset: '${_base}garlic.png',
    maskAsset: '${_base}mieum_mask.png',
    traceAssets: ['${_base}mieum_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}mieum_preview.png',
  ),
  'ieung': LessonSpec2(
    key: 'ieung',
    bigChar: 'ㅇ',
    nameKo: '이응',
    wordLabel: '오이',
    wordIconAsset: '${_base}cucumber.png',
    maskAsset: '${_base}ieung_mask.png',
    traceAssets: ['${_base}ieung_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [0.9],
    previewAsset: '${_base}ieung_preview.png',
  ),
  'chieut': LessonSpec2(
    key: 'chieut',
    bigChar: 'ㅊ',
    nameKo: '치읓',
    wordLabel: '치즈',
    wordIconAsset: '${_base}cheese.png',
    maskAsset: '${_base}chieut_mask.png',
    traceAssets: ['${_base}chieut_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [0.9],
    previewAsset: '${_base}chieut_preview.png',
  ),
  'pieup': LessonSpec2(
    key: 'pieup',
    bigChar: 'ㅍ',
    nameKo: '피읖',
    wordLabel: '포도',
    wordIconAsset: '${_base}grape.png',
    maskAsset: '${_base}pieup_mask.png',
    traceAssets: ['${_base}pieup_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}pieup_preview.png',
  ),
  'hieut': LessonSpec2(
    key: 'hieut',
    bigChar: 'ㅎ',
    nameKo: '히읗',
    wordLabel: '호랑이',
    wordIconAsset: '${_base}tiger.png',
    maskAsset: '${_base}hieut_mask.png',
    traceAssets: ['${_base}hieut_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}hieut_preview.png',
  ),
  'kieuk': LessonSpec2(
    key: 'kieuk',
    bigChar: 'ㅋ',
    nameKo: '키읔',
    wordLabel: '카레',
    wordIconAsset: '${_base}curry.png',
    maskAsset: '${_base}kieuk_mask.png',
    traceAssets: ['${_base}kieuk_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}kieuk_preview.png',
  ),
  'tieut': LessonSpec2(
    key: 'tieut',
    bigChar: 'ㅌ',
    nameKo: '티읕',
    wordLabel: '토끼',
    wordIconAsset: '${_base}rabbit.png',
    maskAsset: '${_base}tieut_mask.png',
    traceAssets: ['${_base}tieut_trace1.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: '${_base}tieut_preview.png',
  ),
};

const List<String> LESSON2_ORDER = [
  'nieun',
  'rieul',
  'mieum',
  'ieung',
  'chieut',
  'pieup',
  'hieut',
  'kieuk',
  'tieut',
];

class Writing22Page extends StatefulWidget {
  final String childId;
  final String lesson;

  /// 첫 진입에서만 인트로 보여주고, 다음 레슨부터는 false로 넘기면 인트로 생략
  final bool showIntro;

  const Writing22Page({
    super.key,
    required this.childId,
    this.lesson = 'nieun',
    this.showIntro = true,
  });

  @override
  State<Writing22Page> createState() => _Writing22PageState();
}

class _Writing22PageState extends State<Writing22Page> {
  late bool _showIntro; // 인트로 표시 여부
  bool _rewardShown = false;
  int step = 0; // 0: 따라쓰기, 1: 완료
  final _canvasKey = GlobalKey<WritingCanvasState>(); // 쓰기 캔버스 키

  // 마지막 레슨 여부 & 팝업 타이머
  bool get _isFinalLesson => widget.lesson == LESSON2_ORDER.last;
  Timer? _finalPopupTimer;
  bool _finalPopupScheduled = false;

  LessonSpec2 get spec => LESSONS2[widget.lesson] ?? LESSONS2['nieun']!;

  @override
  void initState() {
    super.initState();
    _showIntro = widget.showIntro;

    // 후보셋을 현재 레슨 글자로 강하게 제한 (엔진 레벨)
    _setLessonCandidate(spec.bigChar);
  }

  @override
  void dispose() {
    _finalPopupTimer?.cancel();
    super.dispose();
  }

  Future<void> _setLessonCandidate(String targetChar) async {
    try {
      await SelvyRecognizer.setCandidateSet([targetChar]);
      // 언어 타입은 WritingCanvas(targetType)에서 setLanguage 처리
      debugPrint('[Writing22] setCandidateSet([$targetChar])');
    } catch (e) {
      debugPrint('[Writing22] setCandidateSet 실패: $e');
    }
  }

  /// Selvy 라벨 정규화 (초성 호환)
  String _norm(String s) {
    const map = {
      'ᄂ': 'ㄴ',
      'U+1102': 'ㄴ',
      'ᄅ': 'ㄹ',
      'U+1105': 'ㄹ',
      'ᄆ': 'ㅁ',
      'U+1106': 'ㅁ',
      'ᄋ': 'ㅇ',
      'U+110B': 'ㅇ',
      'ᄎ': 'ㅊ',
      'U+110E': 'ㅊ',
      'ᄑ': 'ㅍ',
      'U+1111': 'ㅍ',
      'ᄒ': 'ㅎ',
      'U+1112': 'ㅎ',
      'ᄏ': 'ㅋ',
      'U+110F': 'ㅋ',
      'ᄐ': 'ㅌ',
      'U+1110': 'ㅌ',
    };
    final t = s.trim();
    return map[t] ?? t;
  }

  /// 인식 콜백: top1 라인만 사용 + [n] 토큰 제거 후 정규화 비교
  void _onRecognize(String recognized) {
    final top1Line = recognized.split('\n').first;
    final cleaned = top1Line.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();

    final got = _norm(cleaned);
    final target = _norm(spec.bigChar);

    if (got.isNotEmpty && got == target) {
      setState(() => step = 1);

      // 마지막 레슨이면 완료화면 렌더 직후 3초 뒤 리워드 팝업
      if (_isFinalLesson && !_rewardShown && !_finalPopupScheduled) {
        _finalPopupScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _finalPopupTimer = Timer(const Duration(seconds: 3), () {
            if (mounted && !_rewardShown && step == 1) _showRewardPopup();
          });
        });
      }
    } else {
      _canvasKey.currentState?.clearCanvas();
    }
  }

  String? _nextLessonKey() {
    final i = LESSON2_ORDER.indexOf(widget.lesson);
    if (i == -1 || i + 1 >= LESSON2_ORDER.length) return null;
    return LESSON2_ORDER[i + 1];
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
          builder:
              (_) => Writing22Page(
                childId: widget.childId,
                lesson: nextKey,
                showIntro: false,
              ),
        ),
      );
    }
  }

  /// 인트로 화면(탭하면 쓰기 화면으로)
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
                              _twin2,
                              width: imgW,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '자음 친구들이 찾아왔어요!',
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
    // “다음” 버튼은 완료 화면에서만 + 마지막 레슨이 아닐 때만
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
      body:
          _showIntro
              ? _buildIntro(context)
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      step == 0
                          ? _buildWriteStep(context)
                          : _buildCompleteStep(context),
                ),
              ),

      // FAB은 항상 두고 가시성만 토글
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

  /// 따라쓰기 화면
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
                              '${_base}hint_tailleft.png',
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

            // 오른쪽 패널: 노트패드 + 마스크 + 트레이스 + 쓰기 캔버스 (+ 떠 있는 채점 버튼)
            // 오른쪽 패널: 노트패드 + 마스크 + 트레이스 + 쓰기 캔버스 (+ 떠 있는 채점 버튼)
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, box) {
                  // ■ 노트패드 전체 크기 축소
                  //  - 가로 기준: box.maxWidth * 0.82 (기존 0.92 → 0.82)
                  //  - 세로 기준: box.maxHeight * 0.82 (여유 더 확보)
                  final padW = (box.maxWidth * 0.8).clamp(
                    260.0,
                    box.maxHeight * 0.74,
                  );

                  // ■ 내부 마스크/트레이스도 함께 축소
                  const innerScale = 0.74; // (기존 0.80 → 0.74)
                  final maskW = padW * innerScale;

                  final baseTraceW = maskW * 0.72; // (기존 0.75 → 0.72)
                  final captionSize = (padW * 0.095).clamp(18.0, 30.0);

                  // 버튼을 보드와 ‘분리’해서 원하는 위치에 띄우기 위해 Stack 사용
                  return Stack(
                    children: [
                      // 노트패드+마스크+트레이스+캔버스 (중앙 정렬)
                      Positioned.fill(
                        child: Center(
                          child: SizedBox(
                            width: padW,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 노트패드 프레임
                                  Image.asset(
                                    '${_base}notepad_frame.png',
                                    fit: BoxFit.contain,
                                  ),

                                  // 마스크
                                  SizedBox(
                                    width: maskW,
                                    child: Image.asset(
                                      spec.maskAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  // 트레이스
                                  ...List.generate(spec.traceAssets.length, (
                                    i,
                                  ) {
                                    final offs =
                                        (i < spec.traceOffsets.length)
                                            ? spec.traceOffsets[i]
                                            : const Offset(0, -2);
                                    final scale =
                                        (i < spec.traceScales.length)
                                            ? spec.traceScales[i]
                                            : 1.0;
                                    return SizedBox(
                                      width: baseTraceW * scale,
                                      child: Transform.translate(
                                        offset: offs,
                                        child: Image.asset(
                                          spec.traceAssets[i],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  }),

                                  // ★ Selvy 캔버스 (마스크 영역 거의 가득)
                                  SizedBox(
                                    width: maskW * 0.98,
                                    height: maskW * 0.98,
                                    child: WritingCanvas(
                                      key: _canvasKey,
                                      childId: widget.childId,
                                      targetChar: spec.bigChar,
                                      candidateSet: [spec.bigChar], // 강한 후보 제한
                                      targetType: "consonant", // 자음 모드
                                      onRecognize: _onRecognize,
                                    ),
                                  ),

                                  // 안내 문구
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

                      // ✅ 채점하기 버튼: 보드와 완전히 분리된 ‘떠 있는’ 버튼
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 30, // ← 더 올리고 싶으면 숫자 줄이거나 bottom으로 바꿔
                        child: Center(
                          child: SizedBox(
                            width: 200, // 버튼 폭
                            height: 42, // 버튼 높이
                            child: ElevatedButton(
                              onPressed:
                                  () =>
                                      _canvasKey.currentState
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

  /// 완료 화면
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
                        '${_base}notepad_frame.png',
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
                    image: AssetImage('${_base}apple1.png'),
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

    // 2초 뒤 팝업 닫고 AppleGarden으로 이동
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
      );
    });
  }
}
