import 'package:flutter/material.dart';
import 'package:sinabro/main/childView/data/sticker_progress.dart';
import 'package:sinabro/main/childView/api/reward_api.dart';
import 'package:sinabro/main/childView/model/sticker_model.dart';
import 'package:sinabro/main/childView/data/sticker_image_map.dart';

typedef StickerTapCallback = void Function(String stickerId);

/// ---------------------------------------------------------------------------
/// 🎨 Sticker Renderer
/// - StickerProgress를 기반으로 스티커를 활성/비활성 상태로 렌더링.
/// ---------------------------------------------------------------------------
Widget buildStickerGrid(
  StickerProgress progress,
  String dexId, {
  StickerTapCallback? onTap,
}) {
  final stickers = progress.allStickers.values
      .where((s) => s.dexId == dexId)
      .toList()
    ..sort((a, b) => a.sequenceInDex.compareTo(b.sequenceInDex));

  return Stack(
    children: [
      for (int i = 0; i < stickers.length; i++)
        _StickerWidget(
          sticker: stickers[i],
          active: stickers[i].isObtained,
          onTap: onTap,
        ),
    ],
  );
}

class _StickerWidget extends StatelessWidget {
  final Sticker sticker;
  final bool active;
  final StickerTapCallback? onTap;

  const _StickerWidget({
    required this.sticker,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entry = stickerImageMap[sticker.stickerId];
    if (entry == null) {
      debugPrint('⚠️ Sticker 이미지 매핑 없음: ${sticker.stickerId}');
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => onTap?.call(sticker.stickerId),
      child: Image.asset(
        active ? entry.active : entry.inactive,
        width: 50,
      ),
    );
  }
}
