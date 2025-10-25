/*
 * @file lib/selvy_example_view/handwriting_screen.dart
 * 필기 입력 화면(데모). 배치 전송/캔버스 크기 전달/세트 제한/타겟 전달 반영.
 */

import 'package:flutter/material.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart';

/// 하나의 획을 구성하는 좌표(x, y)와 타임스탬프(t)
class _StrokePoint {
  final int x, y, t;
  _StrokePoint({required this.x, required this.y, required this.t});
}

/// 여러 점으로 구성된 획
class _Stroke {
  final List<_StrokePoint> points;
  _Stroke({required this.points});
}

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({Key? key}) : super(key: key);

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  // 화면 타겟/세트 — 실제 페이지에서 주입 가능
  static const _candidateSet = [
    'ㄱ',
    'ㄲ',
    'ㄷ',
    'ㄸ',
    'ㅅ',
    'ㅆ',
    'ㅈ',
    'ㅉ',
    'ㅂ',
    'ㅃ',
  ];
  final String _targetChar = 'ㄱ';

  final List<Offset> _currentPoints = []; // 현재 그리는 획
  final List<_Stroke> _finishedStrokes = []; // 완료된 획들
  final List<Offset> _batch = []; // 네이티브 전송용 배치 버퍼

  String _recognizedText = '';
  bool _isRecognizing = false;
  bool _begun = false; // beginInk 호출 여부

  // ----- Gesture handlers -----

  void _ensureBeginInk(BoxConstraints c) {
    if (_begun) return;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    SelvyRecognizer.beginInk(
      width: c.maxWidth,
      height: c.maxHeight,
      devicePixelRatio: dpr,
    );
    _begun = true;
  }

  void _onPanStart(DragStartDetails details, BoxConstraints c) {
    _ensureBeginInk(c);
    final pos = details.localPosition;

    setState(() {
      _currentPoints.clear();
      _currentPoints.add(pos);
    });

    _batch
      ..clear()
      ..add(pos);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final pos = details.localPosition;

    setState(() => _currentPoints.add(pos));
    _batch.add(pos);

    // 포인트 6개마다 배치 전송
    if (_batch.length >= 6) {
      SelvyRecognizer.addPoints(
        _batch
            .map(
              (p) => {
                'x': p.dx,
                'y': p.dy,
                // 필요하면 't': DateTime.now().millisecondsSinceEpoch,
              },
            )
            .toList(),
      );
      _batch.clear();
    }
  }

  void _flushBatch() {
    if (_batch.isEmpty) return;
    SelvyRecognizer.addPoints(
      _batch.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    );
    _batch.clear();
  }

  void _onPanEnd(DragEndDetails details) {
    _flushBatch();

    final now = DateTime.now().millisecondsSinceEpoch;
    final stroke = _Stroke(
      points:
          _currentPoints
              .map(
                (o) => _StrokePoint(x: o.dx.toInt(), y: o.dy.toInt(), t: now),
              )
              .toList(),
    );

    setState(() {
      _finishedStrokes.add(stroke);
      _currentPoints.clear();
    });

    SelvyRecognizer.endStroke();
  }

  void _onPanCancel() {
    _flushBatch();
    _currentPoints.clear();
    SelvyRecognizer.endStroke();
    setState(() {});
  }

  // ----- Actions -----

  Future<void> _onRecognizePressed() async {
    if (_finishedStrokes.isEmpty && _currentPoints.isEmpty) {
      setState(() => _recognizedText = '먼저 손글씨를 입력해주세요.');
      return;
    }

    setState(() => _isRecognizing = true);

    try {
      await SelvyRecognizer.setCandidateSet(_candidateSet);
      final result = await SelvyRecognizer.recognize(target: _targetChar);

      setState(() => _recognizedText = result);
    } catch (e) {
      setState(() => _recognizedText = '인식 실패: $e');
    } finally {
      setState(() => _isRecognizing = false);
    }
  }

  void _onClearPressed() {
    setState(() {
      _finishedStrokes.clear();
      _currentPoints.clear();
      _recognizedText = '';
    });
    SelvyRecognizer.clearInk();
  }

  // ----- UI -----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selvy Pen 필기 인식')),
      body: LayoutBuilder(
        builder: (context, c) {
          // 첫 build 때 1회 beginInk
          _ensureBeginInk(c);

          return Column(
            children: [
              // 필기 영역
              Expanded(
                child: GestureDetector(
                  onPanStart: (d) => _onPanStart(d, c),
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onPanCancel: _onPanCancel,
                  child: Container(
                    color: Colors.white,
                    child: SizedBox.expand(
                      child: CustomPaint(
                        painter: _HandwritingPainter(
                          strokes: _finishedStrokes,
                          currentPoints: _currentPoints,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 인식 결과
              if (_isRecognizing)
                const Text('⏳ 인식 중...', style: TextStyle(color: Colors.orange)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRecognizing ? null : _onRecognizePressed,
                      child: const Text('인식'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onClearPressed,
                      child: const Text('지우기'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

// ----- Painter -----

class _HandwritingPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final List<Offset> currentPoints;

  const _HandwritingPainter({
    required this.strokes,
    required this.currentPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round;

    // 완료된 획
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = Offset(
          stroke.points[i].x.toDouble(),
          stroke.points[i].y.toDouble(),
        );
        final p2 = Offset(
          stroke.points[i + 1].x.toDouble(),
          stroke.points[i + 1].y.toDouble(),
        );
        canvas.drawLine(p1, p2, paint);
      }
    }

    // 현재 그리는 획
    for (int i = 0; i < currentPoints.length - 1; i++) {
      canvas.drawLine(currentPoints[i], currentPoints[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(_HandwritingPainter oldDelegate) => true;
}
