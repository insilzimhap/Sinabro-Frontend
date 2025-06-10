import 'package:flutter/material.dart';

typedef RecognizeCallback = void Function(String result);

class WritingCanvas extends StatefulWidget {
  final RecognizeCallback onRecognize;

  const WritingCanvas({super.key, required this.onRecognize});

  @override
  State<WritingCanvas> createState() => _WritingCanvasState();
}

class _WritingCanvasState extends State<WritingCanvas> {
  // 예시용 컨트롤러, 실제 Selvy 필기 인식 클래스
  // late WritingRecognizer recognizer;

  @override
  void initState() {
    super.initState();
    // Selvy 초기화 로직은 try-catch 처리 필요
    try {
      // recognizer = WritingRecognizer();
      // recognizer.initialize();
    } catch (e) {
      debugPrint('⚠️ Selvy 초기화 실패: $e');
    }
  }

  void _onRecognize() {
    try {
      // 예시 결과
      // String result = recognizer.recognize();
      String result = "ㄹ"; // 테스트용 하드코딩
      widget.onRecognize(result);
    } catch (e) {
      debugPrint('⚠️ Selvy 인식 중 오류 발생: $e');
      widget.onRecognize(""); // 인식 실패 시 빈 문자열 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              'Selvy 필기 입력 영역 (예시)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        ElevatedButton(onPressed: _onRecognize, child: const Text('인식하기')),
      ],
    );
  }
}
