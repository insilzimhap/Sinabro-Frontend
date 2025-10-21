import 'package:flutter/material.dart';
import 'models.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/siblings_page.dart';

class ParentsPage extends StatelessWidget {
  final Gender selectedGender;
  const ParentsPage({super.key, required this.selectedGender});

  @override
  Widget build(BuildContext context) {
    final parents = [
      FamilyMember(
        role: "엄마",
        description: "엄마는 나와 함께 놀아줘",
        imagePath: "assets/img/family/mom.png",
      ),
      FamilyMember(
        role: "아빠",
        description: "아빠는 나에게 책을 읽어줘",
        imagePath: "assets/img/family/dad.png",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("우리 가족")),
      body: ListView(
        children: parents
            .map((m) => Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: Image.asset(m.imagePath, height: 50),
                    title: Text(m.role,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(m.description),
                  ),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SiblingsPage(selectedGender: selectedGender),
            ),
          );
        },
      ),
    );
  }
}
