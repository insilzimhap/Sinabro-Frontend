/*
 * 듣기게임 테마=열매 활성화/비활성화 별 UI 사진
 * 활성화 시: 제대로 된 테마 이미지 (active)
 * 비활성화 시: 어두운 테마 이미지 (inactive)
 */

class FruitImageEntry {
  final String active;
  final String inactive;

  const FruitImageEntry({ 
    required this.active,
    required this.inactive,
  });
}

final Map<String, FruitImageEntry> fruitImageMap = {
  // 듣기 게임 레벨 1
  'FR_LG_001': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level1/theme/theme_1.png',
    inactive: 'assets/img/contents/gameListen/level1/theme/theme_1_deactivation.png',
  ),
  'FR_LG_002': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level1/theme/theme_2.png',
    inactive: 'assets/img/contents/gameListen/level1/theme/theme_2_deactivation.png',
  ),
  'FR_LG_003': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level1/theme/theme_3.png',
    inactive: 'assets/img/contents/gameListen/level1/theme/theme_3_deactivation.png',
  ),
  'FR_LG_004': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level1/theme/theme_4.png',
    inactive: 'assets/img/contents/gameListen/level1/theme/theme_4_deactivation.png',
  ),
  'FR_LG_005': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level1/theme/theme_5.png',
    inactive: 'assets/img/contents/gameListen/level1/theme/theme_5_deactivation.png',
  ),

  // 듣기 게임 레벨 2
  'FR_LG_006': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level2/theme/theme_1.png',
    inactive: 'assets/img/contents/gameListen/level2/theme/theme_1_deactivation.png',
  ),
  'FR_LG_007': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level2/theme/theme_2.png',
    inactive: 'assets/img/contents/gameListen/level2/theme/theme_2_deactivation.png',
  ),
  'FR_LG_008': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level2/theme/theme_3.png',
    inactive: 'assets/img/contents/gameListen/level2/theme/theme_3_deactivation.png',
  ),

    // 듣기 게임 레벨 3
  'FR_LG_009': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level3/theme/theme_1.png',
    inactive: 'assets/img/contents/gameListen/level3/theme/theme_1_deactivation.png',
  ),
  'FR_LG_010': const FruitImageEntry(
    active: 'assets/img/contents/gameListen/level3/theme/theme_2.png',
    inactive: 'assets/img/contents/gameListen/level3/theme/theme_2_deactivation.png',
  ),

  // 쓰기 게임 레벨 1
  'FR_WG_001': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_1_1.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_1_1_deactivation.png',
  ),
  'FR_WG_002': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_1_2.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_1_2_deactivation.png',
  ),
  'FR_WG_003': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_1_3.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_1_3_deactivation.png',
  ),
  'FR_WG_004': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_1_4.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_1_4_deactivation.png',
  ),

  // 쓰기 게임 레벨 2
  'FR_WG_005': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/bag_left.png',
    inactive: 'assets/img/contents/gameWrite/theme/bag_left_deactivation.png',
  ),
  'FR_WG_006': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/bag_right_top.png',
    inactive: 'assets/img/contents/gameWrite/theme/bag_right_top__deactivation.png',
  ),
  'FR_WG_007': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/bag_right_bottom.png',
    inactive: 'assets/img/contents/gameWrite/theme/bag_right_bottom_deactivation.png',
  ),

    // 쓰기 게임 레벨 3
  'FR_WG_008': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_3_cup_red.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_3_cup_deactivation.png',
  ),
  'FR_WG_009': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_3_cup_blue.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_3_cup_deactivation.png',
  ),
  'FR_WG_010': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_3_cup_yellow.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_3_cup_deactivation.png',
  ),
  'FR_WG_011': const FruitImageEntry(
    active: 'assets/img/contents/gameWrite/write_game_3_cup_green.png',
    inactive: 'assets/img/contents/gameWrite/theme/write_game_3_cup_deactivation.png',
  ),
};
