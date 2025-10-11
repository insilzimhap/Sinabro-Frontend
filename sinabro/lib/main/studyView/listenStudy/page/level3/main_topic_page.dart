import 'package:flutter/material.dart';
import 'style.dart';

class MainTopicPage extends StatelessWidget {
  final String topicImagePath; // 토픽 이미지
  final String title;
  final VoidCallback onTap;

  const MainTopicPage({
    super.key,
    required this.topicImagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppStyle.background,
      body: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 위로 올리기 → flex 비율 조정
            Expanded(
              flex: 7, // 기존보다 조금 줄여서 위쪽 공간 더 확보
              child: Center(
                child: Image.asset(
                  topicImagePath,
                  height: AppStyle.mainTopicImageHeight(context),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: AppStyle.mainTopicSpacing(context)),
            Expanded(
              flex: 2, // 텍스트 부분을 작게
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppStyle.mainTopicTitle(context),
                ),
              ),
            ),
            const Spacer(flex: 1), // 아래쪽 여백 확보
          ],
        ),
      ),
    );
  }
}
