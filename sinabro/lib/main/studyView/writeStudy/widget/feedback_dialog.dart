import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  final bool isCorrect;
  final bool isLastStep;

  const FeedbackDialog({
    super.key,
    required this.isCorrect,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final String title =
        isLastStep
            ? '학습 완료 🎉'
            : isCorrect
            ? '정답이에요!'
            : '다시 한 번 해볼까요?';

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
