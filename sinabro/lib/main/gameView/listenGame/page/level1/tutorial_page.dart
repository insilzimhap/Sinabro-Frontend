import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  final VoidCallback onTutorialComplete;

  const TutorialPage({super.key, required this.onTutorialComplete});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _handController;

  @override
  void initState() {
    super.initState();
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    } else {
      widget.onTutorialComplete();
    }
  }

  final List<Map<String, dynamic>> tutorialSteps = [
    {
      "dialogue": "무엇인지 들어볼까요?",
      "showSpeaker": true,
      "showHandSpeaker": true,
      "showHandColor": false,
      "showText": true,
    },
    {
      "dialogue": "빨간색을 찾고 있네요! 보기를 눌러주세요!",
      "showSpeaker": true,
      "showHandSpeaker": false,
      "showHandColor": true,
      "showText": true,
    },
    {
      "dialogue": "이런식으로 하다보면 연습이 될 것 같아요!",
      "showSpeaker": true,
      "showHandSpeaker": false,
      "showHandColor": false,
      "showText": true,
    },
    {
      "dialogue": "바로 해볼까요? 잘 부탁드려요!",
      "showSpeaker": true,
      "showHandSpeaker": false,
      "showHandColor": false,
      "showText": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final step = tutorialSteps[currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/img/contents/gameListen/level1/yangji_chat.png',
                    width: 120,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE2B3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: '양지 ',
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: step["dialogue"],
                              style: const TextStyle(
                                color: Colors.brown,
                                fontSize: 18,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (step["showSpeaker"])
                    Image.asset(
                      'assets/img/contents/gameListen/speaker.png',
                      width: 80,
                      height: 80,
                    ),
                  if (step["showHandSpeaker"])
                    Positioned(
                      right: -60,
                      bottom: -10,
                      child: FadeTransition(
                        opacity:
                            Tween(begin: 0.3, end: 1.0).animate(_handController),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/contents/gameListen/tutorial/hand_pointer.png',
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "눌러보세요!",
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (step["showText"])
                const Text(
                  "누르면 음성이 출력돼요!",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB37A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorBox('red', '①'),
                      const SizedBox(width: 20),
                      _buildColorBox('green', '②'),
                      const SizedBox(width: 20),
                      _buildColorBox('yellow', '③'),
                    ],
                  ),
                  if (step["showHandColor"])
                    Positioned(
                      left: 45,
                      bottom: -10,
                      child: FadeTransition(
                        opacity:
                            Tween(begin: 0.3, end: 1.0).animate(_handController),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/contents/gameListen/tutorial/hand_pointer.png',
                              width: 60,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "눌러보세요!",
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nextStep,
        backgroundColor: const Color(0xFFFFC857),
        label: const Text(
          "다음",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildColorBox(String color, String number) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/img/contents/gameListen/tutorial/$color.png',
            width: 55,
            height: 55,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 6,
            top: 6,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
