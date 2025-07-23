import 'package:flutter/material.dart';

/// ✅ WriteStudyController
/// 쓰기 학습 진행 상태를 관리하는 컨트롤러 클래스
/// - 현재 단계 (자모음, 단어, 문장)
/// - 시도 횟수, 정답 여부, 인식된 텍스트 상태 관리
class WriteStudyController extends ChangeNotifier {
  // 현재 학습 단계 (0: 자모음, 1: 단어, 2: 문장)
  int currentStep = 0;

  // 각 단계별 정답 리스트
  final List<String> correctAnswers = ['ㄹ', '사과', '안녕하세요'];

  // 현재 단계의 정답 반환
  String get currentAnswer => correctAnswers[currentStep];

  // 인식된 사용자 필기 텍스트
  String recognizedText = '';

  // 시도 횟수 (0: 첫 시도, 1: 두 번째 시도)
  int attempt = 0;

  // 정답 여부
  bool isCorrect = false;

  /// ✏️ 인식된 텍스트를 업데이트하고 notifyListeners()로 UI 갱신
  void updateRecognizedText(String text) {
    recognizedText = text.trim();
    notifyListeners();
  }

  /// ✅ 채점 로직
  /// - 정답과 인식 결과를 비교하여 결과 저장
  /// - 정답이면 isCorrect = true
  /// - 결과 리턴
  bool checkAnswer() {
    // 여러 줄 중 첫 줄만 추출 → [1] 안 녕 하 세 요
    final firstLine = recognizedText.trim().split('\n').first;

    // [1] 제거 → 안 녕 하 세 요
    final cleanedText = firstLine.replaceAll(RegExp(r'\[\d+\]'), '');

    // ✂️ 모든 공백 제거 (글자 사이 포함)
    final noSpaceText = cleanedText.replaceAll(' ', '').trim();

    final correct = noSpaceText == currentAnswer;
    isCorrect = correct;
    notifyListeners();
    return correct;
  }

  /// ⏭️ 다음 시도 or 다음 단계로 이동
  /// - 1회 실패 시 → 재시도
  /// - 정답이거나 2회 실패 시 → 다음 단계로
  void nextStepOrRetry() {
    if (!isCorrect && attempt == 0) {
      // 첫 시도 실패 → 두 번째 시도로
      attempt++;
    } else {
      // 1회 성공 또는 2회 실패 → 다음 단계
      if (currentStep < 2) {
        currentStep++;
        attempt = 0;
        recognizedText = '';
        isCorrect = false;
      } else {
        // 마지막 단계 완료 (따로 처리 필요 없음 → UI에서 Alert 처리)
      }
    }
    notifyListeners();
  }

  /// 🧼 입력값 초기화 (지우기 버튼에서 호출됨)
  void reset() {
    recognizedText = '';
    isCorrect = false;
    notifyListeners();
  }
}
