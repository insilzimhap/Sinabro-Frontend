// lib/main/parentView/page/children_state.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart';

/// 앱 전역에서 부모 세션 + 자녀목록을 관리하는 경량 스토어
class ChildrenState extends ChangeNotifier {
  ChildrenState._();
  static final ChildrenState instance = ChildrenState._();

  // ---------- 세션(로그인 정보) ----------
  String? _sessionUserId;
  String? _sessionUserName;

  String? get sessionUserId => _sessionUserId;
  String? get sessionUserName => _sessionUserName;

  /// 로그인 성공 시 반드시 호출
  Future<void> setSession({required String userId, String? userName}) async {
    _sessionUserId = userId;
    _sessionUserName = userName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parentUserId', userId);
    if (userName != null) await prefs.setString('parentUserName', userName);

    // 디버그 로그
    // ignore: avoid_print
    print(
      '[ChildrenState.setSession] userId=$userId, userName=${userName ?? ""}',
    );
    notifyListeners();
  }

  // ---------- 화면용 선택된 userId ----------
  String? _activeUserId; // 현재 페이지가 사용 중인 부모 ID
  String? get activeUserId => _activeUserId;

  bool loading = false;
  bool _loadedOnce = false;

  // 서버에서 내려온 자녀 목록
  List<ChildSummary> items = [];

  /// 자녀페이지/공지페이지 등에서 부모ID를 정해준다.
  /// null 또는 빈 문자열이면 세션에서 자동 복구
  Future<void> setParent(String? incomingUserId) async {
    final given = (incomingUserId ?? '').trim();
    if (given.isNotEmpty) {
      _activeUserId = given;
    } else if (_activeUserId == null || _activeUserId!.isEmpty) {
      // 세션 → 저장소 → 최종복구
      if (_sessionUserId == null || _sessionUserId!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _sessionUserId = prefs.getString('parentUserId');
        _sessionUserName = prefs.getString('parentUserName');
      }
      _activeUserId = _sessionUserId;
    }

    // ignore: avoid_print
    print(
      '[ChildrenState.setParent] incoming="$incomingUserId" -> resolved="${_activeUserId ?? ""}"',
    );
    notifyListeners();
  }

  /// 최초 1회 로드 (페이지 진입 시 호출)
  Future<void> loadOnce(String? incomingUserId) async {
    await setParent(incomingUserId);
    if (_loadedOnce) return;
    await refresh();
    _loadedOnce = true;
  }

  /// 서버에서 자녀목록 새로고침
  Future<void> refresh() async {
    final uid = (_activeUserId ?? '').trim();
    if (uid.isEmpty) {
      // ignore: avoid_print
      print('[ChildrenState.refresh] skip: userId is empty (check login)');
      return;
    }

    try {
      loading = true;
      notifyListeners();

      final list = await ParentApi.fetchChildren(uid); // List<ChildSummary>
      items = list;
    } catch (_) {
      // 필요시 에러처리
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 로그아웃 등 세션 정리
  Future<void> clear() async {
    _sessionUserId = null;
    _sessionUserName = null;
    _activeUserId = null;
    items = [];
    _loadedOnce = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parentUserId');
    await prefs.remove('parentUserName');
    notifyListeners();
  }
}
