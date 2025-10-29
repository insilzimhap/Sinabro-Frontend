import 'dart:async';
import 'child_state.dart';
import 'fruit_state.dart';

/// 🎯 더미 게임 API (childId + fruitId 자동 포함)
class ChildGameApi {
  static Future<void> startWritingGame() async {
    final childId = ChildState.instance.childId;
    final fruitId = FruitState.instance.fruitId;
    print('[DummyAPI] startWritingGame → childId=$childId, fruitId=$fruitId');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> recordWritingChoice({
    required String resultId,
    required String questionId,
    required bool isCorrect,
    String? childWrittenText,
  }) async {
    print(
      '[DummyAPI] recordWritingChoice → '
      'resultId=$resultId, questionId=$questionId, isCorrect=$isCorrect',
    );
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> completeWritingGame({
    required String resultId,
    int timeSpentSecs = 0,
  }) async {
    final childId = ChildState.instance.childId;
    final fruitId = FruitState.instance.fruitId;
    print(
      '[DummyAPI] completeWritingGame → '
      'childId=$childId, fruitId=$fruitId, resultId=$resultId',
    );
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
