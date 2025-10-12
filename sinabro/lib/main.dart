import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

// 듣기학습 테스트용
// import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart';

// 듣기게임 테스트용
import 'main/gameView/listenGame/chapter_page.dart';

void main() {
  
  // ✅ 네이티브 앱 키로 초기화 (Kakao Developers 콘솔의 "네이티브 앱 키")
  KakaoSdk.init(
    nativeAppKey: 'ca5d66d22c4255e3dced6bc1a2d4fdcd', 
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시나브로',
      debugShowCheckedModeBanner: false, // 앱 화면 오른쪽 위 debug 배너 제거!
      //home: CloudAnimationScreen(),
      //home: const HandwritingScreen(),
      //home: ListenStudyPage(),
      //home: WriteStudyPage(),
      // home: const ListenAppleSelect(childId: "test_child"), ✔️ 듣기학습용
      home: ListenGameChapterPage(),
    );
  }
}
