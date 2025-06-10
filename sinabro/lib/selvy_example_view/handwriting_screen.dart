/** 
 * @file lib/selvy_example_view/handwriting_screen.dart
 * @author 문채영
 * 
 * 필기 입력 화면을 구성하는 위젯. 사용자의 손글씨를 캔버스에 그려주고,
 * SelvyRecognizer 클래스를 통해 네이티브(Android)의 Selvy SDK에 필기 인식을 요청한다.
 *
 * 주요 기능:
 * - 손글씨 입력 좌표 기록
 * - Flutter ↔ Android MethodChannel 통신으로 인식 요청
 * - 인식 결과 화면 출력
 */
///

import 'package:flutter/material.dart';
import 'package:sinabro/selvy_example_view//selvy_recognizer.dart';


/// 하나의 획을 구성하는 좌표(x, y)와 타임스탬프(t)
/// t는 현재 시간(ms)으로, 필요 시 시간 흐름 추적용으로 사용 가능
class _StrokePoint {
  final int x, y, t;
  _StrokePoint({required this.x, required this.y, required this.t});
}



/// 여러 개의 점으로 구성된 획
class _Stroke {
  final List<_StrokePoint> points;
  _Stroke({required this.points});
}



/// 필기 입력 화면 (WritingView 역할)
/// GestureDetector로 입력 이벤트를 처리하고, CustomPaint로 획을 그린다.
class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({Key? key}) : super(key: key);

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}



class _HandwritingScreenState extends State<HandwritingScreen> {
  final List<Offset> _currentPoints = [];      // 현재 그리는 획
  final List<_Stroke> _finishedStrokes = [];   // 이전 획들 저장
  String _recognizedText = '';                 // 인식 결과
  bool _isRecognizing = false;                 // 인식 중 여부



  /// 새 획 시작
  /// 1. 현재 점 목록 초기화
  /// 2. 시작 좌표 기록 및 네이티브로 전달
  void _onPanStart(DragStartDetails details) {
    final pos = details.localPosition;
    final time = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _currentPoints.clear();
      _currentPoints.add(pos);
    });

    SelvyRecognizer.addPoint(pos.dx.toInt(), pos.dy.toInt());
  }

  /// 획 그리는 중
  /// 1. 현재 좌표를 계속 기록
  /// 2. 좌표 변화마다 네이티브에도 전달
  void _onPanUpdate(DragUpdateDetails details) {
    final pos = details.localPosition;
    final time = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _currentPoints.add(pos);
    });

    SelvyRecognizer.addPoint(pos.dx.toInt(), pos.dy.toInt());
  }

  /// 획 종료
  /// 1. 하나의 획(_Stroke)으로 저장
  /// 2. 현재 점 목록 초기화
  /// 3. 네이티브에 획 종료 신호 전송
  void _onPanEnd(DragEndDetails details) {
    final time = DateTime.now().millisecondsSinceEpoch;
    final stroke = _Stroke(
      points: _currentPoints.map((offset) {
        return _StrokePoint(
          x: offset.dx.toInt(),
          y: offset.dy.toInt(),
          t: time,
        );
      }).toList(),
    );

    setState(() {
      _finishedStrokes.add(stroke);
      _currentPoints.clear();
    });

    SelvyRecognizer.endStroke();
  }

  /// 인식 버튼
  /// - 인식 중 상태 표시(_isRecognizing)
  /// - SelvyRecognizer.recognize() 호출하여 결과 수신
  /// - 결과를 화면에 출력
  Future<void> _onRecognizePressed() async {

    print('🔍 [Flutter] 인식 버튼 눌림');

    if (_finishedStrokes.isEmpty) {
      setState(() {
        _recognizedText = '먼저 손글씨를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isRecognizing = true;
    });

    try {
      final result = await SelvyRecognizer.recognize();

      print('🎯 [Flutter] 네이티브에서 받은 결과: $result'); 

      setState(() {
        _recognizedText = result;
      });
    } catch (e) {
      setState(() {
        _recognizedText = '인식 실패: $e';
      });
    } finally {
      setState(() {
        _isRecognizing = false;
      });
    }
  }

  /// 지우기 버튼
  /// - 입력된 모든 획 제거, 화면 리셋
  /// - SelvyRecognizer.clearInk() 호출로 네이티브에서도 초기화
  void _onClearPressed() {
    setState(() {
      _finishedStrokes.clear();
      _currentPoints.clear();
      _recognizedText = '';
    });

    SelvyRecognizer.clearInk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selvy Pen 필기 인식')),
      body: Column(
        children: [
          // 필기 영역
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
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
      ),
    );
  }
}


/// 캔버스에 획을 그림 (CustomPainter)
/// 완료된 획 + 현재 입력 중인 획을 동시에 그림
class _HandwritingPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final List<Offset> currentPoints;

  const _HandwritingPainter({
    required this.strokes,
    required this.currentPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // 완료된 획
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = Offset(stroke.points[i].x.toDouble(), stroke.points[i].y.toDouble());
        final p2 = Offset(stroke.points[i + 1].x.toDouble(), stroke.points[i + 1].y.toDouble());
        canvas.drawLine(p1, p2, paint);
      }
    }

    // 현재 그리고 있는 획
    for (int i = 0; i < currentPoints.length - 1; i++) {
      canvas.drawLine(currentPoints[i], currentPoints[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(_HandwritingPainter oldDelegate) => true;
}
