// lib/main/gameView/tree_progress_loader.dart

import 'package:sinabro/main/gameView/writeGame/api/child_game_api.dart';
import 'package:sinabro/main/gameView/tree_progress.dart';

/// 🌳 TreeProgressLoader
/// - /stage/all + /stage/ui/current 두 API를 함께 호출하여
///   TreeProgress를 자동 구성해주는 헬퍼 클래스
class TreeProgressLoader {
  /// category: listening_game / writing_game / listening_study / writing_study
  static Future<TreeProgress> load(String category) async {
    try {
      final resAll = await ChildGameApi.fetchStageAll(category);
      final resCurrent = await ChildGameApi.fetchStageCurrent(category);

      final progressAll = TreeProgress.fromStageAllJson(resAll ?? {});
      final progressCurrent = TreeProgress.fromStageCurrentJson(resCurrent ?? {});

      final merged = progressAll.merge(progressCurrent);
      merged.debugPrintStatus();
      return merged;
    } catch (e) {
      print('[TreeProgressLoader] ⚠️ 예외 발생: $e');
      return TreeProgress(unlockedStages: {}, activeFruits: {});
    }
  }
}
