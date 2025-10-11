import 'package:flutter/material.dart';
import 'models.dart';
import 'parents_page.dart';

class GenderSelectPage extends StatelessWidget {
  const GenderSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("성별 선택")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("(__)는 어떤 모습이야?", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParentsPage(selectedGender: Gender.female),
                  ),
                );
              },
              child: const Text("나는 여자아이야"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParentsPage(selectedGender: Gender.male),
                  ),
                );
              },
              child: const Text("나는 남자아이야"),
            ),
          ],
        ),
      ),
    );
  }
}
