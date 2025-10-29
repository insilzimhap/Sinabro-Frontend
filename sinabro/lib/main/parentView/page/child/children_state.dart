/**
 * @file lib/main/parentView/page/child/children_state.dart
 *
 * 역할: 앱 전역에서 부모 세션, 자녀 목록, JWT 토큰을 관리하는 경량 스토어.
 * - 로그인 성공 시 세션/토큰을 메모리와 SharedPreferences에 저장
 * - 페이지 진입 시 부모 ID 및 토큰을 복구
 * - ParentApi를 통해 자녀 목록을 로드/갱신
 * @ 채영: auth_client, parent_api 손 보면서 코드 수정봤습니다
 */
///

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart';
import 'package:sinabro/common/auth_client.dart'; // ★ CHANGED: AuthClient 연동

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
    // ✅ 변경
    Future.microtask(() => notifyListeners());
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
    // notifyListeners();
    Future.microtask(() => notifyListeners()); // 수정된 값 다시 불로오기 위해 빌드 후 실행

    // ✅ (세션 복구 직후) 토큰 자동 복구
    // - 앱 재시작 등으로 메모리에 토큰이 없을 수 있음
    // - SharedPreferences에서 읽어 _accessToken/_refreshToken 에 로드(메모리 복원)한다.
    if (_accessToken == null || _accessToken!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('accessToken');
      _refreshToken = prefs.getString('refreshToken');
      // ignore: avoid_print
      print('[ChildrenState.setParent] 토큰 복구됨: ${_accessToken != null}');
      // ★ CHANGED: AuthClient에도 동기화(이후 요청에 자동 부착)
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        await AuthClient.instance
            .setAuthToken(_accessToken, refreshToken: _refreshToken);
      }
    }
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
      // ❌ 즉시 notify → 빌드 중 충돌
      // notifyListeners();
      Future.microtask(() => notifyListeners()); // 빌드 이후 실행

      final list = await ParentApi.fetchChildren(uid); // List<ChildSummary>
      items = list;
    } catch (_) {
      // 필요시 에러처리
    } finally {
      loading = false;
      // ❌ 즉시 notify → 또 충돌 가능
      // notifyListeners();
      Future.microtask(() => notifyListeners()); // 안전하게 빌드 후 반영
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
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    notifyListeners();
  }

  // ---------- JWT 토큰 ----------
  // 메모리에 보관되는 현재 액세스/리프레시 토큰.
  // null 또는 빈 문자열이면 미로그인 상태로 간주.
  String? _accessToken;
  String? _refreshToken;

  /// 현재 메모리에 적재된 액세스 토큰
  String? get accessToken => _accessToken;

  /// 현재 메모리에 적재된 리프레시 토큰
  String? get refreshToken => _refreshToken;

  /// 로그인/소셜 로그인 성공 시 토큰 저장
  /// - 서버 응답의 accessToken 은 필수, refreshToken 은 있을 때만 저장
  /// - SharedPreferences 키: 'accessToken', 'refreshToken'
  Future<void> setToken({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    if (refreshToken != null) {
      await prefs.setString('refreshToken', refreshToken);
    }
    // ★ CHANGED: refreshToken 유무와 상관 없이 항상 AuthClient에 주입
    await AuthClient.instance
        .setAuthToken(accessToken, refreshToken: refreshToken);

    // ignore: avoid_print
    print(
      '[ChildrenState.setToken] accessToken 저장됨 (length=${accessToken.length})',
    );
    notifyListeners();
  }

  // ★ CHANGED: 과거 코드 호환용(부팅 시 토큰 복구 필요할 때 사용)
  Future<void> _hydrateTokensIfNeeded() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }

  /// ★ CHANGED: getAccessToken() 레거시 호환
  Future<String?> getAccessToken() async {
    await _hydrateTokensIfNeeded();
    return _accessToken;
  }

  /// ★ CHANGED: getRefreshToken() 레거시 호환
  Future<String?> getRefreshToken() async {
    await _hydrateTokensIfNeeded();
    return _refreshToken;
  }
}
