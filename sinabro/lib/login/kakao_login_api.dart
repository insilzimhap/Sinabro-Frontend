// lib/auth/kakao_login_api.dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/services.dart';

class KakaoLoginApi {
  static Future<Map<String, dynamic>?> kakaoLogin() async {
    try {
      OAuthToken token;

      // 1) 토크 우선
      try {
        final installed = await isKakaoTalkInstalled();
        if (!installed) throw PlatformException(code: 'NotInstalled');

        token = await UserApi.instance.loginWithKakaoTalk();
      } on PlatformException catch (e) {
        // 토크 미설치/미연결/취소 등 → 계정 로그인으로 폴백
        // e.code 예: NotSupportedError, NotAvailableError, CANCELED 등
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final user = await UserApi.instance.me();

      return {
        'id': user.id.toString(),
        'nickname': user.kakaoAccount?.profile?.nickname ?? '',
        'email': user.kakaoAccount?.email ?? '',
        'accessToken': token.accessToken,
      };
    } catch (e) {
      // 디버그용 로그만 남기고 null 리턴
      print('❌ 카카오 로그인 오류: $e');
      return null;
    }
  }
}
