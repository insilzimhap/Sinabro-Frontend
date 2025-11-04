/*
 * ---------------------------------------------------------------------------
 * 🎁 StickerProgress
 * - 자녀별 도감(스티커북) 진행 상태 모델
 * - /api/app/reward/sticker 응답 기반
 * ---------------------------------------------------------------------------
 */

import 'package:sinabro/main/childView/model/sticker_model.dart';

class StickerProgress {
  /// 도감별 획득 상태 (예: DEX_LS_01 → [true, false, true, ...])
  final Map<String, List<bool>> obtainedByDex;

  /// 전체 스티커 Map (stickerId → Sticker 객체)
  final Map<String, Sticker> allStickers;

  const StickerProgress({
    required this.obtainedByDex,
    required this.allStickers,
  });

  /// ✅ JSON 리스트 → StickerProgress 변환
  factory StickerProgress.fromStickerList(List<Sticker> stickers) {
    final obtainedByDex = <String, List<bool>>{};
    final allStickers = <String, Sticker>{};

    // 도감별 리스트 생성
    for (final s in stickers) {
      obtainedByDex.putIfAbsent(s.dexId, () => []);
      obtainedByDex[s.dexId]!.add(s.isObtained);
      allStickers[s.stickerId] = s;
    }

    return StickerProgress(
      obtainedByDex: obtainedByDex,
      allStickers: allStickers,
    );
  }

  /// ✅ 특정 스티커 획득 여부
  bool isStickerObtained(String stickerId) {
    return allStickers[stickerId]?.isObtained ?? false;
  }

  /// ✅ 특정 도감의 진행률 (0~1.0)
  double progressOfDex(String dexId) {
    final list = obtainedByDex[dexId];
    if (list == null || list.isEmpty) return 0.0;
    final obtainedCount = list.where((e) => e).length;
    return obtainedCount / list.length;
  }

  /// ✅ 전체 진행률
  double totalProgress() {
    final all = obtainedByDex.values.expand((e) => e).toList();
    if (all.isEmpty) return 0.0;
    final obtainedCount = all.where((e) => e).length;
    return obtainedCount / all.length;
  }

  /// 🧩 디버깅용
  void debugPrintStatus() {
    print('🎁 [StickerProgress] 도감별 획득 상태: $obtainedByDex');
  }
}
