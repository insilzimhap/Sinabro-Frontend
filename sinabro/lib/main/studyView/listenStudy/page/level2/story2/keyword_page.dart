// lib/main/studyView/listenStudy/level2/story2/keyword_page.dart
import 'package:flutter/material.dart';
import 'model/routine_content.dart';

class KeywordPage extends StatelessWidget {
  final RoutineContent keyword;
  final RoutineContent self;
  final VoidCallback onNext;

  const KeywordPage({
    super.key,
    required this.keyword,
    required this.self,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onNext,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: Image.asset(keyword.imagePath ?? "", width: 200),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: Image.asset(self.imagePath ?? "", width: 200),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(self.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
