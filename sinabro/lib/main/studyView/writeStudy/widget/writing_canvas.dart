// lib/main/studyView/writeStudy/widget/writing_canvas.dart
import 'package:flutter/material.dart';
import 'package:sinabro/selvy_example_view/selvy_recognizer.dart';

typedef RecognizeCallback = void Function(String result);

/// 공용 쓰기 캔버스
/// - 제스처로 잉크 수집 → Selvy에 배치 전송(addPoints)
/// - 후보셋/타겟 전달로 정확도 향상
/// - penWidth: 펜 굵기 (writing_2_ = 40, writing_3_ = 15 권장)
class WritingCanvas extends StatefulWidget {
  final RecognizeCallback onRecognize;
  final String childId;

  /// 이번 라운드 타겟 (예: '강아지'). 없으면 자유 인식
  final String? targetChar;

  /// 허용 후보 집합 (없으면 targetChar 단일 후보로 대체)
  final List<String>? candidateSet;

  /// 펜을 떼면 자동 recognize() 수행 여부
  final bool autoRecognizeOnEnd;

  /// 펜 굵기 (픽셀 단위)
  final double penWidth;

  /// 획이 끝날 때 호출되는 콜백 (부가 동작 위해)
  final VoidCallback? onStrokeEnd;

  final String targetType; // changed: 'consonant' | 'vowel' | 'word'

  // ✅ controller 옵션 추가
  final WritingCanvasController? controller;

  const WritingCanvas({
    super.key,
    required this.onRecognize,
    this.childId = "",
    this.targetChar,
    this.candidateSet,
    this.autoRecognizeOnEnd = false,
    this.penWidth = 20.0, // 기본값
    this.onStrokeEnd,
    this.targetType = "word", // changed: 기본값 단어 모드
    this.controller, // changed
  });

  @override
  State<WritingCanvas> createState() => WritingCanvasState();
}

class WritingCanvasState extends State<WritingCanvas> {
  // 화면 렌더용
  final List<Offset> _currentStroke = [];
  final List<List<Offset>> _strokes = [];

  // 네이티브 전송 배치 버퍼
  final List<Offset> _batch = [];

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this); // changed
    _initializeSelvy();
  }

  @override
  void dispose() {
    widget.controller?._unbind(); // changed
    super.dispose();
  }

  // --- WritingCanvasState: _initializeSelvy 교체 ---
  Future<void> _initializeSelvy() async {
    try {
      if (widget.targetType == "consonant") {
        // changed
        await SelvyRecognizer.setLanguage(101, 1 << 3); // DTYPE_CONSONANT
      } else if (widget.targetType == "vowel") {
        // changed
        await SelvyRecognizer.setLanguage(101, 1 << 4); // DTYPE_VOWEL
      } else {
        // changed
        await SelvyRecognizer.setLanguage(101, 1 << 19); // DTYPE_KOREAN (완성형)
      }
      await SelvyRecognizer.clearInk();
      debugPrint("🟢 Selvy 초기화 완료 (${widget.targetType})"); // changed
    } catch (e) {
      debugPrint('⚠️ Selvy 초기화 실패: $e');
    }
  }

  void _onPanStart(DragStartDetails details) {
    final pos = details.localPosition;
    _currentStroke.clear(); // changed: 리스트 초기화
    _currentStroke.add(pos); // changed: 새 점 추가
    SelvyRecognizer.addPoint(pos.dx.toInt(), pos.dy.toInt()); // 기본 포인트 전송
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final pos = details.localPosition;
    _currentStroke.add(pos);
    SelvyRecognizer.addPoint(pos.dx.toInt(), pos.dy.toInt());
    setState(() {});
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_currentStroke.isNotEmpty) {
      _strokes.add(List.from(_currentStroke));
      _currentStroke.clear();
      await SelvyRecognizer.endStroke();
      debugPrint('🛑 endStroke 호출됨');
      setState(() {});
    }

    widget.onStrokeEnd?.call(); // changed
    if (widget.autoRecognizeOnEnd) {
      await recognizeAndCheckText(); // changed
    }
  }

  Future<void> clearCanvas() async {
    _strokes.clear();
    _currentStroke.clear();
    await SelvyRecognizer.clearInk();
    setState(() {});
    debugPrint('🧽 캔버스 클리어'); // changed
  }

  Future<void> recognizeAndCheckText() async {
    if (_strokes.isEmpty) {
      widget.onRecognize('');
      return;
    }

    try {
      await SelvyRecognizer.endStroke();

      // 후보셋 전달
      final List<String> effectiveSet =
          (widget.candidateSet != null && widget.candidateSet!.isNotEmpty)
              ? widget.candidateSet!
              : (widget.targetChar != null ? [widget.targetChar!] : const []);
      if (effectiveSet.isNotEmpty) {
        await SelvyRecognizer.setCandidateSet(effectiveSet); // changed
        debugPrint('📥 허용 답 리스트 전달 ($effectiveSet)'); // changed
      }

      final raw = await SelvyRecognizer.recognize(
        target: widget.targetChar,
      ); // changed

      // 후보 1~3 로그
      // final lines = raw.split("\n");
      // for (int i = 0; i < lines.length && i < 3; i++) {
      //   debugPrint("🎯 후보${i + 1}: ${lines[i]}"); // changed
      // }

      widget.onRecognize(raw); // raw 그대로 전달
    } catch (e) {
      debugPrint('❌ Selvy 인식 오류: $e');
      widget.onRecognize('');
    } finally {
      //await clearCanvas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _HandwritingPainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          penWidth: widget.penWidth, // changed
        ),
        child: Container(),
      ),
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final double penWidth; // changed

  _HandwritingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.penWidth, // changed
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = penWidth // changed
      ..strokeCap = StrokeCap.round;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WritingCanvasController {
  WritingCanvasState? _state;

  void _bind(WritingCanvasState state) {
    _state = state;
  }

  void _unbind() {
    _state = null;
  }

  Future<void> recognizeAndCheckText() async {
    await _state?.recognizeAndCheckText();
  }

  Future<void> clearCanvas() async {
    await _state?.clearCanvas();
  }
}
