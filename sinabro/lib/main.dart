import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';
import 'package:sinabro/config.dart';  //추가
import 'package:sinabro/login/social_info_page.dart'; // 네 SocialExtraInfoPage 파일 경로 맞게 수정! 테스트용
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';


//듣기학습
// import 'package:sinabro/main/studyView/listenStudy/page/listen_study_page.dart';
// import 'package:sinabro/main/studyView/writeStudy/page/write_study_page.dart';
// import 'package:sinabro/selvy_example_view/handwriting_screen.dart';


// ✅ JWT 자동부착 클라이언트 (부팅 시 토큰 복구용)
import 'package:sinabro/common/auth_client.dart';


/// 앱 시작점
Future<void> main() async {

  // ✅ 네이티브 앱 키로 초기화 (Kakao Developers 콘솔의 "네이티브 앱 키")
  KakaoSdk.init(
    nativeAppKey: 'ca5d66d22c4255e3dced6bc1a2d4fdcd', 
  );

  
  // 1) 플러터 엔진-플랫폼 채널 준비
  WidgetsFlutterBinding.ensureInitialized();

  // 2) ⬇️ 부팅 시 저장돼 있던 JWT를 메모리로 복구 (AuthClient가 이후 모든 요청에 자동 부착)
  try {
    await AuthClient.hydrateFromPrefs();
    print('[main] 부팅 토큰 복구 완료');
  } catch (e) {
    print('[main][경고] 토큰 복구 중 오류: $e');
  }

  // 3) 앱 실행
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시나브로',
      debugShowCheckedModeBanner: false, // 앱 화면 오른쪽 위 debug 배너 제거!
      home: CloudAnimationScreen(),
      //home: const HandwritingScreen(),
      //home: ListenStudyPage(),
      //home: WriteStudyPage(),
    );
  }
}
