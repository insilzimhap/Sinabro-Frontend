import 'package:flutter/material.dart';
import 'gender_select_page.dart';

class Level2IntroPage extends StatefulWidget {
  const Level2IntroPage({super.key});

  @override
  State<Level2IntroPage> createState() => _Level2IntroPageState();
}

class _Level2IntroPageState extends State<Level2IntroPage> {
  final List<bool> _dustVisible = [true, true, true];

  void _clearDust(int index) {
    setState(() => _dustVisible[index] = false);

    if (_dustVisible.every((v) => v == false)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GenderSelectPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "어라? 먼지 쌓인 무언가를 발견했어요\n먼지를 털어서 확인해볼까?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/img/family/photo_frame.png", height: 250),
                if (_dustVisible[0])
                  Positioned(
                    top: 40,
                    left: 60,
                    child: GestureDetector(
                      onTap: () => _clearDust(0),
                      child: Image.asset("assets/img/family/dust.png", height: 80),
                    ),
                  ),
                if (_dustVisible[1])
                  Positioned(
                    top: 100,
                    right: 70,
                    child: GestureDetector(
                      onTap: () => _clearDust(1),
                      child: Image.asset("assets/img/family/dust.png", height: 90),
                    ),
                  ),
                if (_dustVisible[2])
                  Positioned(
                    bottom: 50,
                    left: 100,
                    child: GestureDetector(
                      onTap: () => _clearDust(2),
                      child: Image.asset("assets/img/family/dust.png", height: 70),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
