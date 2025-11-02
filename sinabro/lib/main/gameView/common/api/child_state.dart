import 'package:flutter/foundation.dart';

/// 🎮 자녀 전역 상태 (게임용)
class ChildState extends ChangeNotifier {
  static final ChildState instance = ChildState._internal();
  ChildState._internal();

  String? _childId;
  String? get childId => _childId;

  void setChild(String id) {
    _childId = id;
    debugPrint('[ChildState] 현재 로그인한 자녀 ID: $id');
    notifyListeners();
  }

  void clear() {
    debugPrint('[ChildState] clear');
    _childId = null;
    notifyListeners();
  }
}
