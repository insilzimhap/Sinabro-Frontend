/**
 * @file lib/common/auth_client.dart
 * @author 문채영
 * JWT 자동 부착 HTTP 클라이언트 (부팅 시 토큰 복구 포함).
 * * * ## 역할
 * - `http.BaseClient`를 상속한 래퍼로, 보호된 API 호출 시 자동으로
 * `Authorization: Bearer <JWT>` 헤더를 붙여줍니다.
 * - 로그인/회원가입 등 인증이 불필요한(permitAll) 엔드포인트는 자동으로 제외합니다.
 * - 앱 재실행 시 SharedPreferences에 저장된 토큰을 메모리로 복구(hydrate)할 수 있습니다.
 * * * ## 주의사항
 * - 요청에 Authorization 헤더가 이미 있다면 덮어쓰지 않습니다(존중).
 * - `AuthClient.instance`는 토큰 주입/삭제(hydrate, setAuthToken, clearAuth)용 싱글턴입니다.
 * 실제 요청은 `AuthClient()` 새 인스턴스를 만들어도 전역 토큰(static) 덕분에 동일하게 동작합니다.
 */
///

import 'dart:async'; // ⭐️ 타임아웃 쓰려면 이거 import 해야 함
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthClient extends http.BaseClient {
  /// 전역 싱글턴
  static final AuthClient instance = AuthClient._internal();

  /// 외부에서 AuthClient()로 호출해도 동일 인스턴스 반환
  factory AuthClient({
    http.Client? inner,
    String? Function()? tokenProvider,
    List<Pattern>? skipAuthPatterns,
  }) {
    // 인자를 줘도 싱글턴 패턴 유지(필요 시 내부에서만 커스터마이즈)
    return instance;
  }

  // 실제 생성자(내부용)                                     
  AuthClient._internal({
    http.Client? inner,
    String? Function()? tokenProvider,
    List<Pattern>? skipAuthPatterns,
  })  : _inner = inner ?? http.Client(),
        _tokenProvider = tokenProvider,
        _skipAuthPatterns = skipAuthPatterns ?? <Pattern>[];  

  final http.Client _inner;
  final String? Function()? _tokenProvider;
  final List<Pattern> _skipAuthPatterns;

  // 전역 오버라이드 토큰(있으면 최우선)
  static String? _globalTokenOverride;

  // 기본적으로 permitAll 엔드포인트 목록                   
  // 👇 여기 리스트 수정 👇
  static List<Pattern> _defaultSkipPatterns = <Pattern>[
    // ───────── users (permitAll)
    RegExp(r'^/api/users/(login|register|social-register|check-id)$'),
    RegExp(r'^/api/token/(refresh|reissue)$'),

    // ───────── child (permitAll)
    RegExp(r'^/api/child/(login|info|logout)$'),

    // ───────── characters (permitAll)
    RegExp(r'^/api/characters$'),
    RegExp(r'^/api/characters/resolve$'),
    RegExp(r'^/api/character/selection$'),
    RegExp(r'^/api/character/selection/check$'),

    // ───────── notice (permitAll)
    RegExp(r'^/api/app/notices(?:/.*)?$'),

    // ───────── level-test / parent-choice (permitAll)
    RegExp(r'^/api/level-test(?:/.*)?$'),
    RegExp(r'^/api/parent-choice(?:/.*)?$'),

    // ───────── docs / health (permitAll)
    RegExp(r'^/v3/api-docs(?:/.*)?$'),
    RegExp(r'^/swagger-ui(?:/.*)?$'),
    RegExp(r'^/swagger-ui\.html$'),
    RegExp(r'^/actuator/health$'),

    // ⭐️ [추가] Stage UI Current API 경로 (permitAll이니까 추가)
    //    '/api/app/child/' 다음에 아무 childId나 오고 '/stage/ui/current'로 끝나는 경로
    RegExp(r'^/api/app/child/[^/]+/stage/ui/current$'),
    // ⭐️ [추가] Stage All API 경로도 permitAll 이었으니 추가 (선택)
    RegExp(r'^/api/app/child/[^/]+/stage/all$'),

    // ⭐️ [임시 허용] 자녀 리포트 요약 API (progress-summary)
    RegExp(r'^/api/app/child/[^/]+/progress-summary$'),

  ];
  // 👆 여기 리스트 수정 👆


  // 싱글턴 초기화 시 한 번만 기본 skip 패턴 주입               
  static void _initDefaultsIfNeeded() {                        
    if (instance._skipAuthPatterns.isEmpty) {                  
      instance._skipAuthPatterns.addAll(_defaultSkipPatterns); 
    }                                                          
  }  

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
    // 2) 외부 제공자(있으면 사용)
    final provided = _tokenProvider?.call();
    if (provided != null && provided.isNotEmpty) return provided;
    // 3) 마지막으로 SharedPreferences 조회
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _initDefaultsIfNeeded(); 
    debugPrint('[AuthClient] 요청 시작 → ${request.method} ${request.url}');

    final skip = _shouldSkipAuth(request.url);
    String? token; // ⭐️ 토큰 변수 선언

    // ⭐️ 토큰 가져오는 부분도 try-catch로 감싸서 오류 확인
    try {
      token = await _resolveToken(); 
      debugPrint('[AuthClient] 토큰 확인 완료 (값 존재: ${token != null && token.isNotEmpty})');
    } catch (e) {
      debugPrint('[AuthClient] 토큰 가져오는 중 오류 발생!: $e');
      // 토큰 못 가져와도 일단 요청은 보내보자 (permitAll일 수 있으니)
    }

    if (!skip && token != null && token.isNotEmpty) {
      // ⭐️ 헤더 추가 전에 기존 헤더 있는지 확인 (더 안전하게)
      if (!request.headers.containsKey('Authorization')) {
        request.headers['Authorization'] = 'Bearer $token';
        debugPrint('[AuthClient] Authorization 자동 추가됨');
      } else {
        debugPrint('[AuthClient] Authorization 헤더가 이미 존재하여 덮어쓰지 않음');
      }
    } else {
      debugPrint('[AuthClient] Authorization 스킵 → ${skip ? 'permitAll' : '토큰없음'}');
    }

    // ⭐️ 실제 네트워크 요청 부분을 try-catch와 timeout으로 감싸기
    try {
      debugPrint('[AuthClient] 내부 http 클라이언트(_inner.send) 호출 시작...'); // 👈 로그 추가
      
      // ⭐️ 타임아웃 추가 (예: 15초)
      //    _inner.send 자체가 Future를 반환하므로 여기에 timeout 적용 가능
      final resp = await _inner.send(request).timeout(const Duration(seconds: 15)); 
      
      debugPrint('[AuthClient] 응답 받음 ← ${resp.statusCode} ${request.url}'); // 👈 로그 추가
      return resp;

    } on TimeoutException catch (e) { // ⭐️ 타임아웃 에러 잡기
      debugPrint('[AuthClient] 요청 시간 초과! (${request.method} ${request.url}): $e'); 
      // ⭐️ 타임아웃 시 에러를 다시 던져서 ListenAppleSelect에서 잡도록 함

      throw TimeoutException('Request timed out after 15 seconds'); // 👈 아까 고친 부분 
    } catch (e) { // ⭐️ 그 외 모든 네트워크 관련 에러 잡기
      debugPrint('[AuthClient] 네트워크 요청 중 심각한 오류 발생! (${request.method} ${request.url}): $e');
      // ⭐️ 에러를 다시 던짐
      throw http.ClientException('HTTP request failed: $e', request.url); 
    }
  }

  @override
  void close() => _inner.close();
}