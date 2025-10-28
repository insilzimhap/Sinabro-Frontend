import 'package:flutter/material.dart';

class Level1FailPage extends StatelessWidget {
  final VoidCallback? onRetry; // 실패 후 → 테마선택으로 돌아가기

  const Level1FailPage({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAEBD7), // 따뜻한 베이지톤
      body: SafeArea(
        child: Stack(
          children: [
            // 🐑 실패 이미지
            Center(
              child: Image.asset(
                'assets/img/contents_child_listen_game/fail_sheep.png',
                width: size.width * 0.65,
              ),
            ),

            // 💬 말풍선 (오른쪽 아래)
            Positioned(
              bottom: size.height * 0.13,
              right: size.width * 0.1,
              left: size.width * 0.1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '양지',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A4A00),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '앗! 마법으로 만들어지지 않았어요\n만드는 걸 다시 도와주실래요?',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3E2A1A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔙 뒤로가기 버튼 (테마선택으로)
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.brown, size: 26),
                onPressed: onRetry ??
                    () {
                      Navigator.pop(context);
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
