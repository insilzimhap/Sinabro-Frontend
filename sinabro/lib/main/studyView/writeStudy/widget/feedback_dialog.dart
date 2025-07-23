import 'package:flutter/material.dart';

/// 학습 피드백 다이얼로그
/// - 정답 / 오답 / 학습 완료 메시지를 상황에 따라 보여줌
class FeedbackDialog extends StatelessWidget {
  final bool isCorrect; // 정답 여부
  final bool isLastStep; // 마지막 단계 여부

  const FeedbackDialog({
    super.key,
    required this.isCorrect,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    // 제목 메시지 설정
    final String title =
        isLastStep
            ? '학습 완료 🎉'
            : isCorrect
            ? '정답이에요!'
            : '다시 한 번 해볼까요?';

    // 본문 메시지 설정
    final String content =
        isLastStep
            ? '모든 단계를 완료했어요!'
            : isCorrect
            ? '아주 잘했어요~ 다음 단계로 넘어가요.'
            : '한 번 더 써볼까요?';

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
