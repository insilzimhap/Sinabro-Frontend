import 'package:flutter/material.dart';
import 'style.dart';

class MainKeywordPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const MainKeywordPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      body: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
            children: [
              // 키워드 이미지
              Image.asset(
                imagePath,
                height: AppStyle.keywordImageHeight(context),
                fit: BoxFit.contain,
              ),

              SizedBox(height: AppStyle.keywordSpacing(context)),

              // 키워드 텍스트
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppStyle.keywordTitle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
