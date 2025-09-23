import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginApi {
  // ✅ 카카오톡 또는 카카오계정으로 로그인 → 사용자 정보 반환
  static Future<Map<String, dynamic>?> kakaoLogin() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      // 로그인 시도
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // 사용자 정보 요청
      User user = await UserApi.instance.me();

      final kakaoId = user.id.toString();
      final nickname = user.kakaoAccount?.profile?.nickname ?? '';
      final email = user.kakaoAccount?.email ?? '';
      final accessToken = token.accessToken;

      // 반환값을 Map으로 만들어서 제공
      return {
        'id': kakaoId,
        'nickname': nickname,
        'email': email,
        'accessToken': accessToken,
      };
    } catch (e) {
      print('카카오 로그인 오류: $e');
      return null;
    }
  }
}
