import 'package:sinabro/main/childView/model/sticker_model.dart';
import 'package:sinabro/main/childView/api/reward_api.dart';
import 'package:sinabro/main/childView/data/sticker_progress.dart';

/// ---------------------------------------------------------------------------
/// 🎁 StickerProgressLoader
/// - /api/app/reward/sticker 호출해서 StickerProgress로 변환하는 헬퍼 클래스
/// ---------------------------------------------------------------------------
class StickerProgressLoader {
  static Future<StickerProgress> load(String childId) async {
    try {
      final stickers = await RewardApi.fetchStickers(childId);
      final progress = StickerProgress.fromStickerList(stickers);
      progress.debugPrintStatus();
      return progress;
    } catch (e) {
      print('[StickerProgressLoader] ⚠️ 예외 발생: $e');
      return const StickerProgress(obtainedByDex: {}, allStickers: {});
    }
  }
}
