import 'package:flutter/material.dart';

/// ✅ WriteStudyController
/// 쓰기 학습 진행 상태를 관리하는 컨트롤러 클래스
/// - 현재 단계 (0: 자모/글자, 1: 단어, 2: 문장 등)
/// - 시도 횟수, 정답 여부, 인식된 텍스트 상태 관리
class WriteStudyController extends ChangeNotifier {
  // 현재 학습 단계
  int currentStep = 0;

  // 각 단계별 정답 리스트 (필요시 외부에서 주입/교체해도 OK)
  final List<String> correctAnswers = ['ㄹ', '사과', '안녕하세요'];

  // 현재 단계의 정답
  String get currentAnswer => correctAnswers[currentStep];

  // 전체 단계 수
  int get totalSteps => correctAnswers.length;

  // 마지막 단계 여부
  bool get isLastStep => currentStep >= totalSteps - 1;

  // 인식된 사용자 필기 텍스트
  String recognizedText = '';

  // 시도 횟수 (0: 첫 시도, 1: 두 번째 시도)
  int attempt = 0;

  // 정답 여부
  bool isCorrect = false;

  /// ✏️ 인식된 텍스트 업데이트
  void updateRecognizedText(String text) {
    recognizedText = text.trim();
    notifyListeners();
  }

  /// ✅ 정답 여부를 외부에서 설정할 수 있도록 (UI/로직 공용)
  void setCorrect(bool value) {
    isCorrect = value;
    notifyListeners();
  }

  /// ✅ 한 단계 전진 (성공 시 호출)
  void nextStep() {
    if (!isLastStep) {
      currentStep++;
      attempt = 0;
      recognizedText = '';
      isCorrect = false;
      notifyListeners();
    }
  }

  /// ✅ 채점 로직
  /// - 정답과 인식 결과를 비교하여 결과 저장
  /// - 공백/표시문자 제거 등 정상화 후 비교
  bool checkAnswer() {
    // 여러 줄 중 첫 줄만 추출
    final firstLine = recognizedText.trim().split('\n').first;

    // [1] 같은 인덱스 표기 제거
    final cleanedText = firstLine.replaceAll(RegExp(r'\[\d+\]'), '');

    // 모든 공백 제거
    final noSpaceText = cleanedText.replaceAll(' ', '').trim();

    final correct = noSpaceText == currentAnswer;
    isCorrect = correct;
    notifyListeners();
    return correct;
  }

  /// ⏭️ 다음 시도 or 다음 단계로 이동
  /// - 1회 실패 시 → 재시도
  /// - 정답이거나 2회 실패 시 → 다음 단계
  void nextStepOrRetry() {
    if (!isCorrect && attempt == 0) {
      // 첫 시도 실패 → 두 번째 시도로
      attempt++;
    } else {
      // 1회 성공 또는 2회 실패 → 다음 단계
      if (!isLastStep) {
        currentStep++;
      }
      // 단계 이동 후 상태 초기화
      attempt = 0;
      recognizedText = '';
      isCorrect = false;
    }
    notifyListeners();
  }

  /// 🧼 현재 단계 상태 초기화 (지우기 버튼 등에서 호출)
  void reset() {
    recognizedText = '';
    isCorrect = false;
    attempt = 0;
    notifyListeners();
  }

  /// 🔁 전체 초기화(필요 시 사용)
  void resetAll() {
    currentStep = 0;
    recognizedText = '';
    isCorrect = false;
    attempt = 0;
    notifyListeners();
  }
}
