// 각 스테이지(stageId)에 연결된 열매(fruitId) 리스트 정의
// 예: ST007 = 듣기 게임 레벨 1, ST008 = 듣기 게임 레벨 2

final Map<String, List<String>> stageFruitMap = {
  // 듣기 게임
  'ST007': [
    'FR_LG_001',
    'FR_LG_002',
    'FR_LG_003',
    'FR_LG_004',
    'FR_LG_005',
  ],
  'ST008': [
    'FR_LG_006',
    'FR_LG_007',
    'FR_LG_008',
  ],

  // 쓰기 게임
  'ST001': [
    'FR_WS_001',
    'FR_WS_002',
    'FR_WS_003',
    'FR_WS_004',
    'FR_WS_005',
  ],
  'ST002': [
    'FR_WS_001',
    'FR_WS_002',
    'FR_WS_003',
    'FR_WS_004',
    'FR_WS_005',
  ],
};
