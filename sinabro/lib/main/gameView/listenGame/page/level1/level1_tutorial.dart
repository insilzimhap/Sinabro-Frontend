/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1 튜토리얼 화면]
 *  - 듣기 게임 시작 전 조작 및 설명 안내 튜토리얼
 *  - 레벨 1의 1번째 테마에서만 실행됨
 *  - 마지막 단계 완료 시 onTutorialEnd 콜백 실행 (게임으로 이동)
 * ----------------------------------------------------------------
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_layout.dart';

class Level1TutorialPage extends StatefulWidget {
  final VoidCallback? onTutorialEnd;

  const Level1TutorialPage({super.key, this.onTutorialEnd});

  @override
  State<Level1TutorialPage> createState() => _Level1TutorialPageState();
}

class _Level1TutorialPageState extends State<Level1TutorialPage>
    with SingleTickerProviderStateMixin {
  int step = 0;
  late AnimationController _blinkController;
  Timer? _autoTimer;

  final List<String> dialogues = [
    "알쏭달쏭 연습실에 도착했어요!",
    "여기서 올바른 답을 고르면...",
    "무언가 만들어진다고 해요!",
    "무엇인지 들어볼까요?", // 🔊 사운드 버튼만 동작
    "빨간색을 찾고있네요! 보기를 눌러주세요!", // 🔴 카드만 동작
    "이런식으로 하다보면 연습이 될 것 같아요!", // 자동 진행
    "바로 해볼까요? 잘 부탁드려요!", // 자동 진행 후 게임으로 이동
  ];

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startAutoTimerIfNeeded();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  void _nextStep() {
    if (step < dialogues.length - 1) {
      setState(() {
        step++;
      });
      _startAutoTimerIfNeeded();
    } else {
      // ✅ 마지막 단계 → onTutorialEnd 콜백 실행 (게임 화면으로 전환)
      if (widget.onTutorialEnd != null) {
        widget.onTutorialEnd!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _startAutoTimerIfNeeded() {
    _autoTimer?.cancel();

    if (step <= 2 || step == 5 || step == 6) {
      _autoTimer = Timer(const Duration(seconds: 7), () {
        if (mounted) _nextStep();
      });
    }
  }

  bool get _isSoundStep => step == 3;
  bool get _isRedCardStep => step == 4;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenGameLayout(
          characterName: "양지",
          dialogueText: dialogues[step],
          characterImagePath:
              "assets/img/contents/gameListen/level1/yangji_chat.png",
          optionWidgets: [
            _OptionCard(
              number: "①",
              child: _ColorCircle(color: Colors.red),
              onTap: () {
                if (_isRedCardStep) _nextStep();
              },
            ),
            _OptionCard(
              number: "②",
              child: _ColorCircle(color: Colors.green),
              onTap: () {},
            ),
            _OptionCard(
              number: "③",
              child: _ColorCircle(color: Colors.yellow),
              onTap: () {},
            ),
          ],
          onPlayAudio: () {
            if (_isSoundStep) {
              debugPrint("🔊 오디오 재생 실행 (추후 추가 예정)");
              _nextStep();
            }
          },
        ),
        if (_isSoundStep)
          Positioned(
            top: 280,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: FadeTransition(
              opacity: _blinkController,
              child: Transform.rotate(
                angle: -0.28,
                child: Image.asset(
                  "assets/img/contents/gameListen/level1/hand_pointer.png",
                  width: 80,
                ),
              ),
            ),
          ),
        if (_isRedCardStep)
          Positioned(
            bottom: 120,
            left: 40,
            child: FadeTransition(
              opacity: _blinkController,
              child: Transform.rotate(
                angle: -2.42,
                child: Image.asset(
                  "assets/img/contents/gameListen/level1/hand_pointer.png",
                  width: 80,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String number;
  final Widget child;
  final VoidCallback onTap;

  const _OptionCard({
    required this.number,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;

  const _ColorCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
