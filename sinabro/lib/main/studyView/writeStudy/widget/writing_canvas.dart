import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/selvy_example_view/selvy_recognizer.dart';
import 'package:sinabro/main/studyView/writeStudy/controller/write_study_controller.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/feedback_dialog.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart';

typedef RecognizeCallback = void Function(String result);

class WritingCanvas extends StatefulWidget {
  final RecognizeCallback onRecognize;
  final String childId; 


  const WritingCanvas({super.key, required this.onRecognize,
                       this.childId = ""});

  @override
  State<WritingCanvas> createState() => WritingCanvasState();
}

class WritingCanvasState extends State<WritingCanvas> {
  List<Offset> _currentStroke = [];
  List<List<Offset>> _strokes = [];

  @override
  void initState() {
    super.initState();
    _initializeSelvy();
  }

  Future<void> _initializeSelvy() async {
    try {
      await SelvyRecognizer.setLanguage(101, 0);
      await SelvyRecognizer.clearInk();
    } catch (e) {
      debugPrint('⚠️ Selvy 초기화 실패: $e');
    }
  }

  void _onPanStart(DragStartDetails details) {
    final pos = details.localPosition;
    _currentStroke = [pos];
    SelvyRecognizer.addPoint(pos.dx.toInt(), pos.dy.toInt());
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final pos = details.localPosition;
    _currentStroke.add(pos);
    SelvyRecognizer.addPoint(pos.dx.toInt(), pos.dy.toInt());
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke.isNotEmpty) {
      _strokes.add(List.from(_currentStroke));
      _currentStroke.clear();
      SelvyRecognizer.endStroke();
      debugPrint('🛑 endStroke 호출됨');
      setState(() {});
    }
  }

  Future<void> clearCanvas() async {
    _strokes.clear();
    _currentStroke.clear();
    await SelvyRecognizer.clearInk();
    setState(() {});
  }

  Future<void> recognizeAndCheckText() async {
    if (_strokes.isEmpty) {
      widget.onRecognize('');
      return;
    }

    try {
      await SelvyRecognizer.endStroke();
      final result = await SelvyRecognizer.recognize();
      widget.onRecognize(result);

      final controller = Provider.of<WriteStudyController>(
        context,
        listen: false,
      );
      controller.updateRecognizedText(result);

      final isCorrect = controller.checkAnswer();
      final player = AudioPlayer();

      if (isCorrect) {
        await player.play(AssetSource('audio/tts/studyWrite/correct.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500)); // ✅ 재생 기다림

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => FeedbackDialog(
                isCorrect: true,
                isLastStep: controller.currentStep == 2,
              ),
        );

        if (controller.currentStep == 2) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (_) => AlertDialog(
                  title: const Text('🎉 학습 완료'),
                  content: const Text('모든 단계를 완료했어요!\n수고했어요 😊'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Alert 닫기
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  LobbyChildScreen(childId: widget.childId),
                          ),
                        );
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
          );
        } else {
          controller.nextStepOrRetry();
        }
      } else {
        if (controller.attempt == 0) {
          await player.play(AssetSource('audio/tts/studyWrite/incorrect.mp3'));
          await Future.delayed(const Duration(milliseconds: 1500));
        }

        controller.nextStepOrRetry();

        if (controller.currentStep == 2 && controller.attempt > 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LobbyChildScreen(childId: widget.childId,)),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Selvy 인식 오류: $e');
      widget.onRecognize('');
    } finally {
      await clearCanvas(); // 항상 초기화
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
        ),
        child: Container(),
      ),
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _HandwritingPainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4.0
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
