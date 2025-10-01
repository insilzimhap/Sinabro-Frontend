import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';

/// ---------------------------------------------------------------------------
/// 레슨 스펙 (mask / trace / preview 모두 개별 조정 가능)
class VowelLessonSpec2 {
  final String key; // ex) 'a', 'ae', ...
  final String bigChar; // ex) 'ㅏ'
  final String nameKo; // ex) '아'
  final String wordLabel; // ex) '아기'
  final String wordIconAsset; // 연상 아이콘

  // ─ Mask ─
  final String maskAsset;
  final double maskScale; // 마스크 크기(기본 1.0)
  final Offset maskOffset; // 마스크 위치 보정

  // ─ Trace ─
  final List<String> traceAssets;
  final List<double> traceScales; // 획별 크기(기본 1.0)
  final List<Offset> traceOffsets; // 획별 위치

  // ─ Preview ─
  final String previewAsset;
  final double previewScale; // 완료 프리뷰 크기(기본 1.0)
  final Offset previewOffset; // 완료 프리뷰 위치

  const VowelLessonSpec2({
    required this.key,
    required this.bigChar,
    required this.nameKo,
    required this.wordLabel,
    required this.wordIconAsset,
    required this.maskAsset,
    this.maskScale = 1.0,
    this.maskOffset = Offset.zero,
    required this.traceAssets,
    this.traceScales = const [],
    this.traceOffsets = const [],
    required this.previewAsset,
    this.previewScale = 1.0,
    this.previewOffset = Offset.zero,
  });
}

/// ---------------------------------------------------------------------------
/// 이미지 파일명 규칙 (2-3 세트)
const String _base = 'assets/img/contents/studyWrite/';
const String _introImg = '${_base}twin3.png';

const Map<String, VowelLessonSpec2> VOWEL_LESSONS2 = {
  'a': VowelLessonSpec2(
    key: 'a',
    bigChar: 'ㅏ',
    nameKo: '아',
    wordLabel: '아기',
    wordIconAsset: '${_base}baby.png',
    maskAsset: '${_base}a_mask.png',
    maskScale: 0.4,
    maskOffset: Offset(0, 0),
    traceAssets: ['${_base}a_trace1.png'],
    traceScales: [0.27],
    traceOffsets: [Offset(-6, -4)],
    previewAsset: '${_base}a_preview.png',
    previewScale: 0.3,
    previewOffset: Offset(0, 30),
  ),
  'ae': VowelLessonSpec2(
    key: 'ae',
    bigChar: 'ㅐ',
    nameKo: '애',
    wordLabel: '배',
    wordIconAsset: '${_base}pear.png',
    maskAsset: '${_base}ae_mask.png',
    maskScale: 0.4,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}ae_trace1.png'],
    traceScales: [0.3],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}ae_preview.png',
    previewScale: 0.35,
    previewOffset: Offset(0, 30),
  ),
  'eo': VowelLessonSpec2(
    key: 'eo',
    bigChar: 'ㅓ',
    nameKo: '어',
    wordLabel: '어항',
    wordIconAsset: '${_base}fishbowl.png',
    maskAsset: '${_base}eo_mask.png',
    maskScale: 0.4,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}eo_trace1.png'],
    traceScales: [0.3],
    traceOffsets: [Offset(0, -6)],
    previewAsset: '${_base}eo_preview.png',
    previewScale: 0.35,
    previewOffset: Offset(0, 30),
  ),
  'e': VowelLessonSpec2(
    key: 'e',
    bigChar: 'ㅔ',
    nameKo: '에',
    wordLabel: '네모',
    wordIconAsset: '${_base}square.png',
    maskAsset: '${_base}e_mask.png',
    maskScale: 0.45,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}e_trace1.png'],
    traceScales: [0.35],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}e_preview.png',
    previewScale: 0.4,
    previewOffset: Offset(0, 30),
  ),
  'o': VowelLessonSpec2(
    key: 'o',
    bigChar: 'ㅗ',
    nameKo: '오',
    wordLabel: '소방차',
    wordIconAsset: '${_base}firetruck.png',
    maskAsset: '${_base}o_mask.png',
    maskScale: 1.00,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}o_trace1.png'],
    traceScales: [1.00],
    traceOffsets: [Offset(-4, 2)],
    previewAsset: '${_base}o_preview.png',
    previewScale: 1.00,
    previewOffset: Offset(0, 60),
  ),
  'u': VowelLessonSpec2(
    key: 'u',
    bigChar: 'ㅜ',
    nameKo: '우',
    wordLabel: '우유',
    wordIconAsset: '${_base}milk.png',
    maskAsset: '${_base}u_mask.png',
    maskScale: 1.00,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}u_trace1.png'],
    traceScales: [1.00],
    traceOffsets: [Offset(-4, -8)],
    previewAsset: '${_base}u_preview.png',
    previewScale: 1.00,
    previewOffset: Offset(0, 60),
  ),
  'eu': VowelLessonSpec2(
    key: 'eu',
    bigChar: 'ㅡ',
    nameKo: '으',
    wordLabel: '그림',
    wordIconAsset: '${_base}painting.png',
    maskAsset: '${_base}eu_mask.png',
    maskScale: 1.00,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}eu_trace.png'],
    traceScales: [1.00],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}eu_preview.png',
    previewScale: 1.00,
    previewOffset: Offset(0, 45),
  ),
  'i': VowelLessonSpec2(
    key: 'i',
    bigChar: 'ㅣ',
    nameKo: '이',
    wordLabel: '기차',
    wordIconAsset: '${_base}train.png',
    maskAsset: '${_base}i_mask.png',
    maskScale: 0.25,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}i_trace.png'],
    traceScales: [0.1],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}i_preview.png',
    previewScale: 0.12,
    previewOffset: Offset(0, 30),
  ),
  'wi': VowelLessonSpec2(
    key: 'wi',
    bigChar: 'ㅟ',
    nameKo: '위',
    wordLabel: '귀',
    wordIconAsset: '${_base}ear.png',
    maskAsset: '${_base}wi_mask.png',
    maskScale: 0.7,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}wi_trace1.png'],
    traceScales: [0.7],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}wi_preview.png',
    previewScale: 0.8,
    previewOffset: Offset(0, 30),
  ),
  'oe': VowelLessonSpec2(
    key: 'oe',
    bigChar: 'ㅚ',
    nameKo: '외',
    wordLabel: '참외',
    wordIconAsset: '${_base}melon.png',
    maskAsset: '${_base}oe_mask.png',
    maskScale: 0.7,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}oe_trace1.png'],
    traceScales: [0.7],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}oe_preview.png',
    previewScale: 0.7,
    previewOffset: Offset(0, 30),
  ),
};

/// 이동 순서
const List<String> VOWEL_ORDER2 = [
  'a',
  'ae',
  'eo',
  'e',
  'o',
  'u',
  'eu',
  'i',
  'wi',
  'oe',
];

/// ---------------------------------------------------------------------------
/// 페이지 (2-3)
class Writing23Page extends StatefulWidget {
  final String childId;
  final String lesson; // 기본 시작 키
  final bool showIntro; // 인트로 표시 여부 (첫 진입만 true로 넘겨줘)
  const Writing23Page({
    super.key,
    required this.childId,
    this.lesson = 'a',
    this.showIntro = true,
  });

  @override
  State<Writing23Page> createState() => _Writing23PageState();
}

class _Writing23PageState extends State<Writing23Page> {
  int step = 0; // 0: 따라쓰기, 1: 학습완료
  late bool _showIntro;
  bool _rewardShown = false;

  // 마지막 레슨/팝업 예약 관리
  bool get _isFinalLesson => widget.lesson == VOWEL_ORDER2.last;
  Timer? _finalPopupTimer;
  bool _finalPopupScheduled = false;

  // ✍️ 오답 시 캔버스 지우려고 필요
  final _canvasKey = GlobalKey<WritingCanvasState>();

  @override
  void initState() {
    super.initState();
    _showIntro = widget.showIntro;
  }

  @override
  void dispose() {
    _finalPopupTimer?.cancel();
    super.dispose();
  }

  VowelLessonSpec2 get spec =>
      VOWEL_LESSONS2[widget.lesson] ?? VOWEL_LESSONS2['a']!;

  String? _nextLessonKey() {
    final i = VOWEL_ORDER2.indexOf(widget.lesson);
    if (i == -1 || i + 1 >= VOWEL_ORDER2.length) return null;
    return VOWEL_ORDER2[i + 1];
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
      // 다음 레슨은 인트로 없이
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => Writing23Page(
                childId: widget.childId,
                lesson: nextKey,
                showIntro: false,
              ),
        ),
      );
    }
  }

  /// ✅ Selvy 라벨 정규화 (중세자모 라벨 → 현대자모)
  String _norm(String s) {
    const map = {
      // 모음
      'ᅡ': 'ㅏ', 'U+1161': 'ㅏ',
      'ᅢ': 'ㅐ', 'U+1162': 'ㅐ',
      'ᅥ': 'ㅓ', 'U+1165': 'ㅓ',
      'ᅦ': 'ㅔ', 'U+1166': 'ㅔ',
      'ᅩ': 'ㅗ', 'U+1169': 'ㅗ',
      'ᅮ': 'ㅜ', 'U+116E': 'ㅜ',
      'ᅳ': 'ㅡ', 'U+1173': 'ㅡ',
      'ᅵ': 'ㅣ', 'U+1175': 'ㅣ',
      'ᅱ': 'ㅟ', 'U+1171': 'ㅟ',
      'ᅬ': 'ㅚ', 'U+116D': 'ㅚ',
      // 자음(재사용 대비)
      'ᄂ': 'ㄴ', 'U+1102': 'ㄴ',
      'ᄅ': 'ㄹ', 'U+1105': 'ㄹ',
      'ᄆ': 'ㅁ', 'U+1106': 'ㅁ',
      'ᄋ': 'ㅇ', 'U+110B': 'ㅇ',
      'ᄎ': 'ㅊ', 'U+110E': 'ㅊ',
      'ᄑ': 'ㅍ', 'U+1111': 'ㅍ',
      'ᄒ': 'ㅎ', 'U+1112': 'ㅎ',
      'ᄏ': 'ㅋ', 'U+110F': 'ㅋ',
      'ᄐ': 'ㅌ', 'U+1110': 'ㅌ',
    };
    final t = s.trim();
    return map[t] ?? t;
  }

  /// ✅ 인식 콜백: top1 라인만 사용 + [n] 토큰 제거 후 정규화 비교
  void _handleRecognize(String recognized) {
    final top1Line = recognized.split('\n').first;
    final cleaned = top1Line.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();

    final got = _norm(cleaned);
    final target = _norm(spec.bigChar);

    if (got.isNotEmpty && got == target) {
      setState(() => step = 1);

      // 마지막 레슨이면 완료화면 렌더 직후 3초 뒤 팝업
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    '${_base}apple.png',
                    height: 72,
                    fit: BoxFit.contain,
                  ),
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
          ),
        );
      },
    );

    // 2초 뒤 팝업 닫고 사과나무로 이동
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
      );
    });
  }

  /// 인트로 화면
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

              final double lift = c.maxHeight * 0.16; // 이미지+제목 위로
              final double hintBottom = 120.0; // 하단 문구 여백

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
                              _introImg,
                              width: imgW,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '모음 친구들이 찾아왔어요!',
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
    // ✅ 완료 화면에서만, 그리고 마지막 레슨은 아닐 때만 다음 버튼 보이기
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

      // ✅ FAB은 항상 깔고 보임만 제어(페이드)
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
            // 왼쪽 : 큰 글자/이름/연상 단어 + 말풍선
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
                      // 말풍선
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

            // 오른쪽 : 노트패드 + 마스크 + 트레이스 + WritingCanvas (보드 축소 + 버튼 위로)
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, box) {
                  // ■ 노트패드 전체 크기 축소
                  final padW = (box.maxWidth * 0.76).clamp(
                    260.0,
                    box.maxHeight * 0.76,
                  );

                  // ■ 내부 마스크/트레이스도 함께 축소
                  const double baseMaskFill = 0.74; // (기존 0.80 근처 → 0.74)
                  const double baseTraceFill = 0.70; // (기존 0.75 근처 → 0.70)

                  final maskW = padW * baseMaskFill * spec.maskScale;
                  final captionSize = (padW * 0.095).clamp(18.0, 30.0);

                  // 버튼을 보드와 ‘분리’해서 원하는 위치에 띄우기 위해 Stack 사용
                  return Stack(
                    children: [
                      // 노트패드(중앙)
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

                                  // MASK
                                  SizedBox(
                                    width: maskW,
                                    child: Transform.translate(
                                      offset: spec.maskOffset,
                                      child: Image.asset(
                                        spec.maskAsset,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  // TRACE
                                  ...List.generate(spec.traceAssets.length, (
                                    i,
                                  ) {
                                    final scale =
                                        (i < spec.traceScales.length)
                                            ? spec.traceScales[i]
                                            : 1.0;
                                    final offs =
                                        (i < spec.traceOffsets.length)
                                            ? spec.traceOffsets[i]
                                            : const Offset(0, -2);
                                    final traceW =
                                        (padW * baseMaskFill * baseTraceFill) *
                                        scale;

                                    return SizedBox(
                                      width: traceW,
                                      child: Transform.translate(
                                        offset: offs,
                                        child: Image.asset(
                                          spec.traceAssets[i],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  }),

                                  // ✍️ 쓰기 캔버스 (전체 덮기)
                                  SizedBox(
                                    width: padW,
                                    height: padW,
                                    child: WritingCanvas(
                                      key: _canvasKey,
                                      targetChar: spec.bigChar,
                                      candidateSet: [spec.bigChar], // 강한 후보 제한
                                      targetType: "vowel", // 모음 모드
                                      onRecognize: _handleRecognize,
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
                        top: 24, // ← 더 올리고 싶으면 숫자 더 작게
                        child: Center(
                          child: SizedBox(
                            width: 200, // 버튼 폭 고정
                            height: 42, // 버튼 높이 고정
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

  /// 2) 학습 완료 화면
  Widget _buildCompleteStep(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final padW = (c.maxWidth * 0.60).clamp(320.0, c.maxHeight * 0.80);
        final basePreviewW = padW * 0.62;
        final previewW = basePreviewW * spec.previewScale;
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
                      // PREVIEW (scale + offset 적용)
                      Transform.translate(
                        offset: spec.previewOffset,
                        child: Column(
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '‘${spec.bigChar}’를 학습했어요!',
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
