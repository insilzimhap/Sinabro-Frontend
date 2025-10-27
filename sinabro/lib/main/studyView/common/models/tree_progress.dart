// lib/main/studyView/common/models/tree_progress.dart

import 'package:flutter/foundation.dart';

/// 서버에서 받은 자녀의 학습/게임 진행 상태를 담는 모델 클래스
@immutable
class TreeProgress {
  /// 각 스테이지(나무)별로 해금된 열매의 개수를 담는 맵
  /// 예: { "ST001": 5, "ST002": 1, "ST003": 0 }
  final Map<String, int> unlockedUntilByStage;

  const TreeProgress({
    required this.unlockedUntilByStage,
  });

  /// JSON 맵에서 TreeProgress 객체를 생성하는 팩토리 생성자
  factory TreeProgress.fromJson(Map<String, dynamic> json) {
    // API 응답의 'unlockedUntilByStage' 키를 찾습니다.
    final Map<String, dynamic> unlockedMap =
        json['unlockedUntilByStage'] as Map<String, dynamic>? ?? {};

    return TreeProgress(
      // value가 int가 아닐 수도 있으므로 안전하게 변환합니다.
      unlockedUntilByStage: unlockedMap.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
    );
  }

  /// 특정 스테이지의 특정 순서(sequence)에 있는 열매가 활성화되었는지 확인하는 헬퍼 함수
  ///
  /// [stageId]는 확인할 나무의 ID (예: "ST001")
  /// [sequence]는 해당 나무에서 몇 번째 열매인지 (1부터 시작)
  bool isActive(String stageId, int sequence) {
    // 이 스테이지에 대해 해금된 열매 개수를 가져옵니다. (없으면 0)
    final unlockedCount = unlockedUntilByStage[stageId] ?? 0;
    // 열매의 순서가 해금된 개수보다 작거나 같으면 활성화된 것입니다.
    return sequence <= unlockedCount;
  }
}
