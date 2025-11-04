import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart';
import 'package:sinabro/main/childView/model/sticker_model.dart';

/// ---------------------------------------------------------------------------
/// 🎁 RewardApi
/// - 보상(스티커/도감) 관련 API 통신 클래스
/// ---------------------------------------------------------------------------
/// ✅ 기능:
///   1️⃣ fetchStickers(childId) → 자녀별 스티커 획득 여부 조회
/// ---------------------------------------------------------------------------

class RewardApi {
  /// 👦 자녀별 스티커 현황 조회
  /// GET /api/app/reward/sticker?childId={childId}
  static Future<List<Sticker>> fetchStickers(String childId) async {
    final url = Uri.parse('$baseUrl/api/app/reward/sticker?childId=$childId');

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(res.bodyBytes));
        final stickers = data.map((e) => Sticker.fromJson(e)).toList();
        print('✅ [RewardApi] 스티커 ${stickers.length}건 불러옴 (childId=$childId)');
        return stickers;
      } else {
        print('⚠️ [RewardApi] 스티커 조회 실패: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('🚨 [RewardApi] 예외 발생: $e');
      return [];
    }
  }

}
