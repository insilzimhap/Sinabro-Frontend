import 'package:flutter/foundation.dart';

/// 🍎 FruitState
/// 현재 선택된 열매(fruitId)를 전역으로 관리
class FruitState extends ChangeNotifier {
  static final FruitState instance = FruitState._internal();
  FruitState._internal();

  String? _fruitId;
  String? get fruitId => _fruitId;

  /// 사과 클릭 시 설정
  void setFruit(String id) {
    _fruitId = id;
    debugPrint('[FruitState] setFruit → $id');
    notifyListeners();
  }

  /// 열매 완료 또는 나무 이동 시 초기화
  void clear() {
    debugPrint('[FruitState] clear');
    _fruitId = null;
    notifyListeners();
  }
}
