import 'dart:async';
import 'package:flutter/material.dart';

class Level1TutorialPage extends StatefulWidget {
  const Level1TutorialPage({super.key});

  @override
  State<Level1TutorialPage> createState() => _Level1TutorialPageState();
}

class _Level1TutorialPageState extends State<Level1TutorialPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _visibleText = "";
  Timer? _timer;
  bool _finished = false;

  late AnimationController _arrowController;

  final List<_TutorialStep> steps = [
    _TutorialStep("알쏭달쏭 연습실에 도착했어요!"),
    _TutorialStep("여기서 올바른 답을 고르면..."),
    _TutorialStep("무언가 만들어진다고 해요!"),
    _TutorialStep("무엇인지 들어볼까요?", highlight: "audio"),
    _TutorialStep("빨간색을 찾겠네요! 보기를 눌러주세요!", highlight: "red"),
    _TutorialStep("이런식으로 하다보면 연습이 될 것 같아요!"),
    _TutorialStep("바로 해볼까요? 잘 부탁드려요!"),
  ];

  @override
  void initState() {
    super.initState();
    _arrowController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
          ..repeat(reverse: true);
    _startTyping();
  }

  void _startTyping() {
    _visibleText = "";
    _finished = false;
    final dialogue = steps[_currentIndex].dialogue;
    int i = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (i < dialogue.length) {
        setState(() {
          _visibleText += dialogue[i];
          i++;
        });
      } else {
        timer.cancel();
        setState(() => _finished = true);
      }
    });
  }

  void _nextDialogue() {
    if (!_finished) return; // 타이핑 끝나야 넘어감
    if (_currentIndex < steps.length - 1) {
      setState(() => _currentIndex++);
      _startTyping();
    } else {
      Navigator.pop(context); // 튜토리얼 종료
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _nextDialogue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 캐릭터 + 말풍선
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/img/contents/gameListen/yangji_chat.png",
                    width: 120,
                    height: 120,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12, right: 24, top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEED7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEC186)),
                      ),
                      child: Stack(
                        children: [
                          Text(
                            _visibleText,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (_finished)
                            Positioned(
                              right: 0,
                              bottom: -8,
                              child: FadeTransition(
                                opacity: _arrowController,
                                child: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 28,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // 오디오 버튼
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.volume_up, size: 48, color: Colors.black87),
                  if (step.highlight == "audio")
                    Positioned(
                      right: -50,
                      bottom: -30,
                      child: FadeTransition(
                        opacity: _arrowController,
                        child: Image.asset(
                          "assets/img/contents/gameListen/level1/hand_pointer.png",
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // 보기 3개
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOption("①", Colors.red,
                        highlight: step.highlight == "red"),
                    _buildOption("②", Colors.green),
                    _buildOption("③", Colors.yellow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String label, Color color, {bool highlight = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black26),
              ),
            ),
          ],
        ),
        if (highlight)
          Positioned(
            bottom: -30,
            child: FadeTransition(
              opacity: _arrowController,
              child: Image.asset(
                "assets/img/contents/gameListen/level1/hand_pointer.png",
                width: 48,
                height: 48,
              ),
            ),
          ),
      ],
    );
  }
}

class _TutorialStep {
  final String dialogue;
  final String? highlight; // "audio", "red" 등 강조 포인트
  const _TutorialStep(this.dialogue, {this.highlight});
}
