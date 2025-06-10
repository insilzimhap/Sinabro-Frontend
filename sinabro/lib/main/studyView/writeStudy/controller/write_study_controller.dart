import 'package:flutter/material.dart';

class WriteStudyController extends ChangeNotifier {
  // 현재 학습 단계 (0: 자모음, 1: 단어, 2: 문장)
  int currentStep = 0;

  // 각 단계별 정답
  final List<String> correctAnswers = ['ㄹ', '사과', '안녕하세요'];

  // 현재 정답
  String get currentAnswer => correctAnswers[currentStep];

  // 인식된 사용자 필기 텍스트
  String recognizedText = '';

  // 시도 횟수 (1회차: 0, 2회차: 1)
  int attempt = 0;

  // 정답 여부
  bool isCorrect = false;

  /// 인식 결과 업데이트
  void updateRecognizedText(String text) {
    recognizedText = text.trim();
    notifyListeners();
  }

  /// 채점 로직 (결과 리턴)
  bool checkAnswer() {
    final correct = recognizedText == currentAnswer;
    isCorrect = correct;
    notifyListeners();
    return correct;
  }

  /// 다음 시도 or 다음 단계로 이동
  void nextStepOrRetry() {
    if (!isCorrect && attempt == 0) {
      // 첫 시도 실패 → 재도전
      attempt++;
    } else {
      // 1회 성공 or 2회 실패 → 다음 단계로
      if (currentStep < 2) {
        currentStep++;
        attempt = 0;
        recognizedText = '';
        isCorrect = false;
      } else {
        // 마지막 단계 완료
        // 현재는 아무 처리 안함 (페이지에서 alert 띄우면 됨)
      }
    }
    notifyListeners();
  }

  /// 초기화 (지우기 버튼 등)
  void reset() {
    recognizedText = '';
    isCorrect = false;
    notifyListeners();
  }
}
