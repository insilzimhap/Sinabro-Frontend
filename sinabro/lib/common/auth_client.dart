/**
 * @file lib/common/auth_client.dart
 * @author 문채영
 * JWT 자동 부착 HTTP 클라이언트 (부팅 시 토큰 복구 포함).
 * 
 *  * ## 역할
 * - `http.BaseClient`를 상속한 래퍼로, 보호된 API 호출 시 자동으로
 *   `Authorization: Bearer <JWT>` 헤더를 붙여줍니다.
 * - 로그인/회원가입 등 인증이 불필요한(permitAll) 엔드포인트는 자동으로 제외합니다.
 * - 앱 재실행 시 SharedPreferences에 저장된 토큰을 메모리로 복구(hydrate)할 수 있습니다.
 * 
 *  * ## 주의사항
 * - 요청에 Authorization 헤더가 이미 있다면 덮어쓰지 않습니다(존중).
 * - `AuthClient.instance`는 토큰 주입/삭제(hydrate, setAuthToken, clearAuth)용 싱글턴입니다.
 *   실제 요청은 `AuthClient()` 새 인스턴스를 만들어도 전역 토큰(static) 덕분에 동일하게 동작합니다.
 */
///


import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinabro/main/parentView/page/children_state.dart';

class AuthClient extends http.BaseClient {
  /// 전역에서 쓰기 위한 싱글턴 (setAuthToken, hydrate 전용)
  static final AuthClient instance = AuthClient();

  final http.Client _inner;
  final String? Function()? _tokenProvider;
  final List<Pattern> _skipAuthPatterns;

  // 전역 오버라이드 토큰(있으면 최우선)
  static String? _globalTokenOverride;

  AuthClient({
    http.Client? inner,
    String? Function()? tokenProvider,
    List<Pattern>? skipAuthPatterns,
  })  : _inner = inner ?? http.Client(),
        _tokenProvider =
            tokenProvider ?? (() => ChildrenState.instance.accessToken),
        _skipAuthPatterns = skipAuthPatterns ??
            <Pattern>[
              RegExp(r'/api/users/login$'),
              RegExp(r'/api/users/register$'),
              RegExp(r'/api/users/social-register$'),
              RegExp(r'/api/users/check-id$'),
              RegExp(r'/api/token/(refresh|reissue)$'),
            ];

  /// 부팅 시(앱 시작 시) 토큰을 SharedPreferences에서 메모리로 복구
  static Future<void> hydrateFromPrefs() async {
    if (_globalTokenOverride != null && _globalTokenOverride!.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _globalTokenOverride ??= prefs.getString('accessToken');
    if (kDebugMode) {
      debugPrint('[AuthClient] hydrated token: ${_globalTokenOverride != null}');
    }
  }

  /// 로그인/소셜가입 성공 후 토큰 저장(전역 오버라이드 + SharedPreferences 동기화)
  Future<void> setAuthToken(String? accessToken, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    _globalTokenOverride = accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      await prefs.remove('accessToken');
    } else {
      await prefs.setString('accessToken', accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString('refreshToken', refreshToken);
    }
  }

  /// 로그아웃 등 토큰 제거
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _globalTokenOverride = null;
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  bool _shouldSkipAuth(Uri url) {
    final path = url.path;
    for (final p in _skipAuthPatterns) {
      if (p is RegExp) {
        if (p.hasMatch(path)) return true;
      } else {
        if (path.contains(p.toString())) return true;
      }
    }
    return false;
  }

  Future<String?> _resolveToken() async {
    // 1) 전역 오버라이드
    if (_globalTokenOverride != null && _globalTokenOverride!.isNotEmpty) {
      return _globalTokenOverride;
    }
    // 2) 외부 제공자(기본: ChildrenState.accessToken)
    final provided = _tokenProvider?.call();
    if (provided != null && provided.isNotEmpty) return provided;
    // 3) 마지막으로 SharedPreferences 조회
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (kDebugMode) {
      debugPrint('[AuthClient] 요청 → ${request.method} ${request.url}');
    }

    final skip = _shouldSkipAuth(request.url);
    final token = await _resolveToken();

    if (!skip && token != null && token.isNotEmpty) {
      request.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      if (kDebugMode) debugPrint('[AuthClient] Authorization 자동 추가됨');
    } else {
      if (kDebugMode) {
        debugPrint('[AuthClient] Authorization 스킵 → ${skip ? 'permitAll' : '토큰없음'}');
      }
    }

    final resp = await _inner.send(request);
    if (kDebugMode) {
      debugPrint('[AuthClient] 응답 ← ${resp.statusCode} ${request.url}');
    }
    return resp;
  }

  @override
  void close() => _inner.close();
}
