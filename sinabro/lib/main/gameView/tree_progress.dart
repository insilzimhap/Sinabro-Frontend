// lib/main/gameView/tree_progress.dart

/*
 * ----------------------------------------------------------------
 * [TreeProgress]
 *  - 자녀별 진행도 모델
 *  - 2개 API 응답을 함께 관리:
 *    1️⃣ /stage/all → 열매(Fruit) 활성 여부
 *    2️⃣ /stage/ui/current → 나무(Stage) 잠금/해금 여부
 * ----------------------------------------------------------------
 */

class TreeProgress {
  /// 🌳 스테이지(나무) 잠금/해금 상태
  final Map<String, bool> unlockedStages;

  /// 🍎 열매(테마) 활성/비활성 상태
  final Map<String, bool> activeFruits;

  TreeProgress({
    required this.unlockedStages,
    required this.activeFruits,
  });

  /// ✅ 1️⃣ /stage/all 응답 기반: 열매 활성화 파싱
  factory TreeProgress.fromStageAllJson(Map<String, dynamic> json) {
    final fruits = <String, bool>{};
    final stages = <String, bool>{};

    final stagesList = json['stages'] as List<dynamic>? ?? [];

    for (final s in stagesList) {
      final stageId = s['stageId'] ?? '';
      if (stageId.isEmpty) continue;

      // fruits 내부 active 여부 확인
      final fruitsList = s['fruits'] as List<dynamic>? ?? [];
      bool stageHasActiveFruit = false;

      for (final f in fruitsList) {
        final fruitId = f['fruitId'] ?? '';
        if (fruitId.isEmpty) continue;

        final active = f['active'] == true;
        fruits[fruitId] = active;
        if (active) stageHasActiveFruit = true;
      }

      // 하나라도 active면 그 stage도 잠금 해제된 걸로 일단 표시
      stages[stageId] = stageHasActiveFruit;
    }

    return TreeProgress(
      unlockedStages: stages,
      activeFruits: fruits,
    );
  }

  /// ✅ 2️⃣ /stage/ui/current 응답 기반: 나무 해금 상태 파싱
  factory TreeProgress.fromStageCurrentJson(Map<String, dynamic> json) {
    final unlockedStages = <String, bool>{};

    final unlockedMap =
        (json['unlockedUntilByStage'] as Map<String, dynamic>?) ?? {};

    unlockedMap.forEach((stageId, value) {
      final int unlockedCount = (value is int) ? value : 0;
      unlockedStages[stageId] = unlockedCount > 0;
    });

    return TreeProgress(
      unlockedStages: unlockedStages,
      activeFruits: const {}, // 열매는 아직 없음
    );
  }

  /// 🔄 3️⃣ 두 개의 진행도 병합
  TreeProgress merge(TreeProgress other) {
    final mergedStages = Map<String, bool>.from(unlockedStages);
    final mergedFruits = Map<String, bool>.from(activeFruits);

    // stage 쪽은 OR 조건으로 병합 (둘 중 하나라도 true면 해금)
    other.unlockedStages.forEach((key, value) {
      mergedStages[key] = (mergedStages[key] ?? false) || value;
    });

    // fruit 쪽은 덮어쓰기
    mergedFruits.addAll(other.activeFruits);

    return TreeProgress(
      unlockedStages: mergedStages,
      activeFruits: mergedFruits,
    );
  }

  // 🔓 챕터(나무) 해금 여부
  bool isStageUnlocked(String stageId) {
    return unlockedStages[stageId] ?? false;
  }

  // 🍎 열매(테마) 활성화 여부
  bool isFruitActive(String fruitId) {
    return activeFruits[fruitId] ?? false;
  }

  // 🧩 디버깅용
  void debugPrintStatus() {
    print('🌳 [TreeProgress] 해금 Stage: $unlockedStages');
    print('🍎 [TreeProgress] 활성 Fruit: $activeFruits');
  }
}
