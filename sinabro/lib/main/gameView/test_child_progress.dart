import 'package:sinabro/main/gameView/tree_progress.dart';

final testChildProgress = TreeProgress.fromJson({
  "childId": "test_child_id",
  "stages": [
    {
      "stageId": "ST007", // 듣기게임 레벨1 (초급)
      "category": "listening_game",
      "level": "초급",
      "fruits": [
        {"fruitId": "FR_LG_001", "active": true},
        {"fruitId": "FR_LG_002", "active": true},
        {"fruitId": "FR_LG_003", "active": false},
        {"fruitId": "FR_LG_004", "active": false},
        {"fruitId": "FR_LG_005", "active": false},
      ]
    },
    {
      "stageId": "ST008", // 듣기게임 레벨2 (중급)
      "category": "listening_game",
      "level": "중급",
      "fruits": [
        {"fruitId": "FR_LG_006", "active": false},
        {"fruitId": "FR_LG_007", "active": false},
        {"fruitId": "FR_LG_008", "active": false},
      ]
    },
    {
      "stageId": "ST009", // 듣기게임 레벨3 (고급)
      "category": "listening_game",
      "level": "고급",
      "fruits": [
        {"fruitId": "FR_LG_009", "active": false},
        {"fruitId": "FR_LG_010", "active": false},
      ]
    },
  ]
});
