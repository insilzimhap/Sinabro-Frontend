import 'package:flutter/material.dart';
import 'models.dart';

class GenderSelectPage extends StatelessWidget {
  final ValueChanged<Gender> onSelected;
  const GenderSelectPage({super.key, required this.onSelected});

  void _choose(BuildContext context, Gender gender) {
    // 먼저 현재 페이지를 닫고,
    Navigator.pop(context);
    // pop 이후에 콜백을 호출(네비게이션 충돌 방지)
    Future.microtask(() => onSelected(gender));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("성별 선택")),
      backgroundColor: const Color(0xFFFDF7F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "(__)는 어떤 모습이야?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.brown),
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderCard(
                  context,
                  imagePath: "assets/img/contents/studyListen/level2/girl.png",
                  label: "나는 여자아이야",
                  onTap: () => _choose(context, Gender.female),
                ),
                const SizedBox(width: 20),
                _genderCard(
                  context,
                  imagePath: "assets/img/contents/studyListen/level2/boy.png",
                  label: "나는 남자아이야",
                  onTap: () => _choose(context, Gender.male),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderCard(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.brown.withOpacity(0.2), offset: const Offset(2, 3), blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 120),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.brown, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
