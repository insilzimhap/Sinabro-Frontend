import 'package:flutter/material.dart';
//import 'package:sinabro/main/mainView/page/home_screen.dart';
//import 'package:sinabro/config.dart';  //추가
import 'package:sinabro/login/social_info_page.dart'; // 네 SocialExtraInfoPage 파일 경로 맞게 수정! 테스트용

//듣기학습
//import 'package:sinabro/main/studyView/listenStudy/page/listen_study_page.dart';
//import 'package:sinabro/main/studyView/writeStudy/page/write_study_page.dart';
//import 'package:sinabro/selvy_example_view/handwriting_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '시나브로',
//       debugShowCheckedModeBanner: false, // 앱 화면 오른쪽 위 debug 배너 제거!
//       home: CloudAnimationScreen(),
//       //home: const HandwritingScreen(),
//       //home: ListenStudyPage(),
//       //home: WriteStudyPage(),
//     );
//   }
// }


// 테스트용
void main() {
  runApp(const MyTestApp());
}

class MyTestApp extends StatelessWidget {
  const MyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SocialExtraInfoPage(
        userId: "test123",
        userEmail: "test@example.com",
        userName: "테스트사용자",
        socialType: "google",
        socialId: "social12345",
      ),
    );
  }
}