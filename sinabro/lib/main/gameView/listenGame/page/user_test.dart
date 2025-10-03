// DB연동 시 해당 파일 수정하면 됨
// lib/main/gameView/common/listenGame/user_data.dart
class UserGameData {
  static final UserGameData _instance = UserGameData._internal();

  factory UserGameData() => _instance;
  UserGameData._internal();

  final Map<int, bool> themeClear = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  void clearTheme(int themeId) {
    themeClear[themeId] = true;
  }

  // 지금은 모든 테마 열림
  bool isThemeOpened(int themeId) {
    return true;
  }
}
