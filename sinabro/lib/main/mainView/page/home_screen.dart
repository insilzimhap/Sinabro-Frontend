import 'package:flutter/material.dart';

import 'package:sinabro/main/mainView/widget/moving_cloud.dart';
import 'package:sinabro/main/mainView/widget/main_to_userSelect_btn.dart';

class CloudAnimationScreen extends StatefulWidget {
  @override
  _CloudAnimationScreenState createState() => _CloudAnimationScreenState();
}

class _CloudAnimationScreenState extends State<CloudAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    // 구름 1 컨트롤러 (빠르게)
    _controller1 = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // 구름 2 컨트롤러 (느리게)
    _controller2 = AnimationController(
      duration: Duration(seconds: 18),
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: -1.0, end: 0.0).animate(_controller1);
    _animation2 = Tween<double>(begin: -1.0, end: 0.0).animate(_controller2);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ 배경
          Positioned.fill(
            child: Image.asset(
              'assets/img/pageMain/main_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ 구름 1
          MovingCloud(
            animation: _animation1,
            topPosition: 0,
            screenWidth: screenWidth,
            imagePath: 'assets/img/pageMain/cloud1.png',
            width: 1000,
          ),

          // ✅ 구름 2
          MovingCloud(
            animation: _animation2,
            topPosition: 200,
            screenWidth: screenWidth,
            imagePath: 'assets/img/pageMain/cloud2.png',
            width: 1000,
          ),

          // ✅ main > user Select 버튼
          const MainToUserSelectBtn(),
        ],
      ),
    );
  }
}
