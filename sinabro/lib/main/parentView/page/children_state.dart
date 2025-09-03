// lib/main/parentView/page/children_state.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 자녀 1명 정보
class ChildModel {
  final String id; // childId
  final String name; // childName
  final String nickname; // childNickname
  final int age; // childAge
  final String? phone;

  ChildModel({
    required this.id,
    required this.name,
    required this.nickname,
    required this.age,
    this.phone,
  });

  factory ChildModel.fromJson(Map<String, dynamic> j) => ChildModel(
        id: j['id'] as String,
        name: j['name'] as String,
        nickname: j['nickname'] as String,
        age: j['age'] as int,
        phone: j['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'age': age,
        'phone': phone,
      };
}

/// 자녀 리스트 전역 상태(싱글턴)
class ChildrenState extends ChangeNotifier {
  ChildrenState._internal();
  static final ChildrenState instance = ChildrenState._internal();

  static const _storageKey = 'children_state_v1';

  final List<ChildModel> _items = [];
  List<ChildModel> get items => List.unmodifiable(_items);

  bool _loaded = false;

  /// 앱 시작 후 1회만 로드
  Future<void> loadOnce() async {
    if (_loaded) return;
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List)
          .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _items
        ..clear()
        ..addAll(list);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _storageKey,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> add(ChildModel c) async {
    _items.add(c);
    await _persist();
    notifyListeners();
  }

  Future<void> removeById(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }
}
