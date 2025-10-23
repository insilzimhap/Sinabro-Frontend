import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/models.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/quiz_page.dart';

class SiblingsPage extends StatelessWidget {
  final Gender selectedGender;
  final String childId; // 자녀 아이디

  const SiblingsPage({
    super.key,
    required this.selectedGender,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    final siblings = selectedGender == Gender.female
        ? [
            FamilyMember(
              role: "언니",
              description: "언니는 나랑 그림을 그려",
              imagePath: "assets/img/family/unni.png",
            ),
            FamilyMember(
              role: "오빠",
              description: "오빠는 나랑 놀아줘",
              imagePath: "assets/img/family/oppa.png",
            ),
            FamilyMember(
              role: "동생",
              description: "동생은 나랑 장난감을 나눠줘",
              imagePath: "assets/img/family/dongsaeng.png",
            ),
          ]
        : [
            FamilyMember(
              role: "누나",
              description: "누나는 나랑 그림을 그려",
              imagePath: "assets/img/family/noona.png",
            ),
            FamilyMember(
              role: "형",
              description: "형은 나랑 놀아줘",
              imagePath: "assets/img/family/hyung.png",
            ),
            FamilyMember(
              role: "동생",
              description: "동생은 나랑 장난감을 나눠줘",
              imagePath: "assets/img/family/dongsaeng.png",
            ),
          ];

    return Scaffold(
      appBar: AppBar(title: const Text("우리 형제자매")),
      body: ListView(
        children: siblings
            .map(
              (m) => Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: Image.asset(m.imagePath, height: 50),
                  title: Text(m.role,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text(m.description),
                ),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizPage(childId: childId)),
          );
        },
      ),
    );
  }
}
