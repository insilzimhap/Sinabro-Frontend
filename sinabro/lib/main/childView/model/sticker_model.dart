/// ---------------------------------------------------------------------------
/// 🧩 Sticker Model
/// - 백엔드 API(/api/app/reward/sticker) 응답 구조를 매핑하는 데이터 클래스
/// ---------------------------------------------------------------------------

class Sticker {
  final String stickerId;       // ST_LS_001 등
  final String stickerName;     // 예: '남동생', '사람_산책'
  final bool isObtained;        // 획득 여부
  final String dexId;           // DEX_LS_01 등 (도감 ID)
  final int sequenceInDex;      // 도감 내 순서

  const Sticker({
    required this.stickerId,
    required this.stickerName,
    required this.isObtained,
    required this.dexId,
    required this.sequenceInDex,
  });

  /// JSON → Sticker 객체 변환
  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      stickerId: json['stickerId'] ?? '',
      stickerName: json['stickerName'] ?? '',
      isObtained: json['isObtained'] ?? false,
      dexId: json['dexId'] ?? '',
      sequenceInDex: json['sequenceInDex'] ?? 0,
    );
  }

}
