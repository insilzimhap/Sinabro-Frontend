import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';
//import 'package:sinabro/selvy_example_view/handwriting_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시나브로',
      debugShowCheckedModeBanner: false, // 앱 화면 오른쪽 위 debug 배너 제거!
      home: CloudAnimationScreen(),
      //home: const HandwritingScreen(),
    );
  }
}
