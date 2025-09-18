/**
 * @file lib/common/auth_client.dart
 * @author 문채영
 *
 * JWT 자동 부착 HTTP 클라이언트.
 * - http.BaseClient를 상속하여 모든 요청에 Authorization: Bearer <token> 헤더를 자동 추가
 * - 로그인/회원가입/토큰재발급 등 토큰 불필요 API는 자동 스킵
 * - ChildrenState.instance.accessToken 에서 토큰을 읽음
 *
 * 사용법(예):
 *   final client = AuthClient();
 *   final res = await client.get(Uri.parse('$baseUrl/api/children')); // 자녀목록 api
 */
///

import 'package:flutter/foundation.dart';               // kDebugMode, debugPrint
import 'package:http/http.dart' as http;               // HTTP 클라이언트 기본 패키지
import 'package:sinabro/main/parentView/page/children_state.dart'; // 토큰 보관소

/// 모든 HTTP 요청에 JWT를 자동으로 달아주는 클라이언트
class AuthClient extends http.BaseClient {
  /// 실제 전송을 담당하는 내부 클라이언트
  final http.Client _inner;

  /// 토큰을 읽어오는 함수 (기본: ChildrenState에서 읽음)
  final String? Function()? _tokenProvider;

  /// 인증 스킵할 경로 패턴 목록 (로그인/회원가입/토큰재발급 등)
  final List<Pattern> _skipAuthPatterns;

  /// 생성자
  /// - [inner]: 필요하면 외부에서 http.Client 주입
  /// - [tokenProvider]: 커스텀 토큰 리더 주입 가능
  /// - [skipAuthPatterns]: 토큰 생략할 경로 패턴 확장 가능
  AuthClient({
    http.Client? inner,
    String? Function()? tokenProvider,
    List<Pattern>? skipAuthPatterns,
  })  : _inner = inner ?? http.Client(),
        _tokenProvider =
            tokenProvider ?? (() => ChildrenState.instance.accessToken),
        _skipAuthPatterns = skipAuthPatterns ??
            <Pattern>[
              // ------------------------------
              // 🔐 인증 불필요/붙이면 안 되는 API 경로들
              // ------------------------------
              RegExp(r'/api/users/login$'),            // 로그인 API
              RegExp(r'/api/users/social-register$'),  // 소셜 회원가입/로그인 API
              RegExp(r'/api/token/(refresh|reissue)$') // 토큰 재발급 API
            ];

  /// 실제 요청을 보내기 전 Authorization 헤더를 자동으로 부착한다.
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // [로그] 어떤 요청이 나가는지
    if (kDebugMode) {
      debugPrint('[AuthClient] 요청 → ${request.method} ${request.url}');
    }

    // {} 토큰 읽기: ChildrenState 또는 커스텀 tokenProvider에서 읽어온다.
    final token = _tokenProvider?.call();

    // {} 이 요청이 인증 스킵 대상인지 확인
    final skipAuth = _shouldSkipAuth(request.url);

    // {} Authorization 헤더 자동 추가
    if (!skipAuth && token != null && token.isNotEmpty) {
      // 이미 헤더가 있다면 덮어쓰지 않고 유지. 없을 때만 추가.
      request.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      if (kDebugMode) {
        debugPrint('[AuthClient] Authorization 헤더 자동 추가됨');
      }
    } else {
      if (kDebugMode) {
        debugPrint('[AuthClient] Authorization 스킵됨 → '
            '${skipAuth ? '스킵 규칙 매칭' : '토큰 없음'}');
      }
    }

    // {} 실제 전송
    final resp = await _inner.send(request);

    // [로그] 응답 상태 코드만 간단히 출력
    if (kDebugMode) {
      debugPrint('[AuthClient] 응답 ← ${resp.statusCode} ${request.url}');
    }

    return resp;
  }

  /// {} 이 URL이 인증 스킵 대상인지 판별
  bool _shouldSkipAuth(Uri url) {
    final path = url.path; // 예: /api/users/login
    for (final p in _skipAuthPatterns) {
      if (p is RegExp) {
        if (p.hasMatch(path)) return true;
      } else {
        if (path.contains(p.toString())) return true;
      }
    }
    return false;
  }

  /// {} 내부 클라이언트 자원 정리
  @override
  void close() {
    _inner.close();
  }
}
