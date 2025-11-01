class TreeProgress {
  final Map<String, bool> unlockedStages;
  final Map<String, bool> activeFruits;

  TreeProgress({
    required this.unlockedStages,
    required this.activeFruits,
  });

  factory TreeProgress.fromJson(Map<String, dynamic> json) {
    final Map<String, bool> stages = {};
    final Map<String, bool> fruits = {};

    // stage (챕터) 해제 여부
    if (json['stages'] != null) {
      for (final stage in json['stages']) {
        final id = stage['id'] as String;
        final unlocked = stage['unlocked'] == true;
        stages[id] = unlocked;

        // 각 stage 안의 fruit 상태
        if (stage['fruits'] != null) {
          for (final fruit in stage['fruits']) {
            final fruitId = fruit['id'] as String;
            final active = fruit['active'] == true;
            fruits[fruitId] = active;
          }
        }
      }
    }

    return TreeProgress(
      unlockedStages: stages,
      activeFruits: fruits,
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
}
