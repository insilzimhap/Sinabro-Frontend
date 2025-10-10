import 'package:flutter/material.dart';
import 'models.dart';

/// 레벨2 스토리 (가족 구성원별 단일 페이지)
/// - index: 1~6 (엄마~동생)
/// - gender: 성별에 따라 이미지 및 텍스트 분기
/// - onFinished: 다음 단계로 넘어가는 콜백
class StoryPage extends StatelessWidget {
  final int index;
  final Gender gender;
  final VoidCallback onFinished;

  const StoryPage({
    super.key,
    required this.index,
    required this.gender,
    required this.onFinished,
  });

  String get _imagePath {
    final base = "assets/img/contents/studyListen/level2/story";
    final genderLabel = gender == Gender.male ? "boy" : "girl";

    // 5는 성별 버전 나눠짐
    switch (index) {
      case 1:
        return "$base/1-1-1.png";
      case 2:
        return "$base/1-2-1.png";
      case 3:
        return "$base/1-3-${gender == Gender.male ? 1 : 2}.png";
      case 4:
        return "$base/1-4-${gender == Gender.male ? 1 : 2}.png";
      case 5:
        return "$base/1-5(${genderLabel}).png";
      case 6:
        return "$base/1-6-${gender == Gender.male ? 1 : 2}.png";
      default:
        return "";
    }
  }

  String get _text {
    switch (index) {
      case 1:
        return "엄마는 나와 함께 놀아줘요";
      case 2:
        return "아빠는 나에게 책을 읽어줘요";
      case 3:
        return gender == Gender.male ? "누나는 나랑 그림을 그려요" : "언니는 나랑 그림을 그려요";
      case 4:
        return gender == Gender.male ? "형은 나랑 놀아요" : "오빠는 나랑 놀아요";
      case 5:
        return "나는 가족을 사랑해요";
      case 6:
        return "동생은 나랑 장난감을 나눠요";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: GestureDetector(
        onTap: onFinished, // 👈 탭 시 다음 단계로 이동
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _imagePath,
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "화면을 터치하면 다음으로 넘어갑니다",
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
