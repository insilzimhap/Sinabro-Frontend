import 'package:flutter/material.dart';
import 'models.dart';

class MainKeywordPage extends StatelessWidget {
  final int index; // 1~6
  final Gender gender;
  final VoidCallback onNext;

  const MainKeywordPage({
    super.key,
    required this.index,
    required this.gender,
    required this.onNext,
  });

  String get _title {
    switch (index) {
      case 1:
        return "엄마";
      case 2:
        return "아빠";
      case 3:
        return gender == Gender.male ? "누나" : "언니";
      case 4:
        return gender == Gender.male ? "형" : "오빠";
      case 5:
        return "나";
      case 6:
        return "동생";
      default:
        return "";
    }
  }

  String get _imagePath {
    const base = "assets/img/contents/studyListen/level2/main_keyword";
    if (index == 5) {
      return "$base/1-5(${gender == Gender.male ? "boy" : "girl"}).png";
    }
    return "$base/1-$index.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: InkWell(
        onTap: onNext,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _imagePath,
                  width: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
