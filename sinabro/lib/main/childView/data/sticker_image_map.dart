// lib/mian/childView/data/sticker
/*
 * ---------------------------------------------------------------------------
 * 🧩 Sticker Image Map
 * 도감(스티커북)에서 스티커 활성/비활성 이미지 매핑
 * stickerId 기준으로 관리 (예: ST_LS_001, ST_WR_004 ...)
 * 
 * 분류:
 *  - 듣기 학습 보상 (DEX_LS_01~03)
 *  - 쓰기 학습 보상 (DEX_WR_01~03)
 * ---------------------------------------------------------------------------
 */

class StickerImageEntry {
  final String active;
  final String inactive;

  const StickerImageEntry({
    required this.active,
    required this.inactive,
  });
}

final Map<String, StickerImageEntry> stickerImageMap = {
  // 🎧 듣기 학습 보상 ----------------------------------------------------------------

  // 🏡 DEX_LS_01 — 가족 도감 (레벨 1 / ST001)
  'ST_LS_001': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen11.png', // 남동생
    inactive: 'assets/img/contents/stickerBook/stickers/listen11_deactivation.png',
  ),
  'ST_LS_002': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen12.png', // 여동생
    inactive: 'assets/img/contents/stickerBook/stickers/listen12_deactivation.png',
  ),
  'ST_LS_003': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen13.png', // 오빠
    inactive: 'assets/img/contents/stickerBook/stickers/listen13_deactivation.png',
  ),
  'ST_LS_004': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen14.png', // 엄마
    inactive: 'assets/img/contents/stickerBook/stickers/listen14_deactivation.png',
  ),
  'ST_LS_005': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen15.png', // 아빠
    inactive: 'assets/img/contents/stickerBook/stickers/listen15_deactivation.png',
  ),

  // 🌳 DEX_LS_02 — 공원 도감 (레벨 2 / ST002)
  'ST_LS_006': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen21.png', // 고양이
    inactive: 'assets/img/contents/stickerBook/stickers/listen21_deactivation.png',
  ),
  'ST_LS_007': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen22.png', // 강아지
    inactive: 'assets/img/contents/stickerBook/stickers/listen22_deactivation.png',
  ),
  'ST_LS_008': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen23.png', // 사람_산책
    inactive: 'assets/img/contents/stickerBook/stickers/listen23_deactivation.png',
  ),
  'ST_LS_009': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen24.png', // 새
    inactive: 'assets/img/contents/stickerBook/stickers/listen24_deactivation.png',
  ),
  'ST_LS_010': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen25.png', // 사람_의자
    inactive: 'assets/img/contents/stickerBook/stickers/listen25_deactivation.png',
  ),

  // 🌼 DEX_LS_03 — 정원 도감 (레벨 3 / ST003)
  'ST_LS_011': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen31.png', // 빨간 꽃
    inactive: 'assets/img/contents/stickerBook/stickers/listen31_deactivation.png',
  ),
  'ST_LS_012': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen33.png', // 파랑 꽃
    inactive: 'assets/img/contents/stickerBook/stickers/listen33_deactivation.png',
  ),
  'ST_LS_013': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen34.png', // 보라 꽃
    inactive: 'assets/img/contents/stickerBook/stickers/listen34_deactivation.png',
  ),
  'ST_LS_014': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/listen32.png', // 노랑 꽃
    inactive: 'assets/img/contents/stickerBook/stickers/listen32_deactivation.png',
  ),

  // ✏️ 쓰기 학습 보상 ----------------------------------------------------------------

  // 🌊 DEX_WR_01 — 바다 도감 (레벨 1 / ST004)
  'ST_WR_001': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write11.png', // 불가사리
    inactive: 'assets/img/contents/stickerBook/stickers/write11_deactivation.png',
  ),
  'ST_WR_002': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write12.png', // 빨간 물고기
    inactive: 'assets/img/contents/stickerBook/stickers/write12_deactivation.png',
  ),
  'ST_WR_003': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write13.png', // 조개
    inactive: 'assets/img/contents/stickerBook/stickers/write13_deactivation.png',
  ),
  'ST_WR_004': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write14.png', // 초록 물고기
    inactive: 'assets/img/contents/stickerBook/stickers/write14_deactivation.png',
  ),

  // 🍦 DEX_WR_02 — 아이스크림 도감 (레벨 2 / ST005)
  'ST_WR_005': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write21.png', // 바닐라
    inactive: 'assets/img/contents/stickerBook/stickers/write21_deactivation.png',
  ),
  'ST_WR_006': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write22.png', // 딸기
    inactive: 'assets/img/contents/stickerBook/stickers/write22_deactivation.png',
  ),
  'ST_WR_007': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write23.png', // 초코
    inactive: 'assets/img/contents/stickerBook/stickers/write23_deactivation.png',
  ),
  'ST_WR_008': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write24.png', // 녹차
    inactive: 'assets/img/contents/stickerBook/stickers/write24_deactivation.png',
  ),

  // 🏫 DEX_WR_03 — 학교 도감 (레벨 3 / ST006)
  'ST_WR_009': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write31.png', // 흰색옷 학생
    inactive: 'assets/img/contents/stickerBook/stickers/write31_deactivation.png',
  ),
  'ST_WR_010': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write33.png', // 노란옷 학생
    inactive: 'assets/img/contents/stickerBook/stickers/write33_deactivation.png',
  ),
  'ST_WR_011': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write32.png', // 파란옷 학생
    inactive: 'assets/img/contents/stickerBook/stickers/write32_deactivation.png',
  ),
  'ST_WR_012': StickerImageEntry(
    active: 'assets/img/contents/stickerBook/stickers/write34.png', // 분홍옷 학생
    inactive: 'assets/img/contents/stickerBook/stickers/write34_deactivation.png',
  ),
};
