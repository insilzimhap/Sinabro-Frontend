/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 1 튜토리얼 화면]
 *  - 듣기 게임 시작 전 조작 및 설명 안내 튜토리얼
 *  - 레벨 1의 1번째 테마에서만 실행됨
 *  - 마지막 단계 완료 시 테마 선택 화면으로 이동
 * ----------------------------------------------------------------
 */


// lib/main/gameView/common/listenGame/page/level1/level1_tutorial.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_layout.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_transition.dart';
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_theme_select.dart';

class Level1TutorialPage extends StatefulWidget {
  //(수정) - 콜백 함수를 저장할 변수 추가
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
    "바로 해볼까요? 잘 부탁드려요!", // 자동 진행 후 transition
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
      // 마지막 단계 → 전환 페이지 → 테마 선택
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ListenGameTransition(
            nextPage: Level1ThemeSelectPage(
              onThemeSelected: (index) {
                // 선택된 테마 index 로직 (예: 다음 단계 이동 등)
                debugPrint('선택된 테마: $index');
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        ),
      );
    }
  }

  void _startAutoTimerIfNeeded() {
    _autoTimer?.cancel();

    // 인트로(0~2) + 튜토리얼 후반(5,6) → 7초 후 자동 진행
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
              // 🔊 추후 오디오 재생 코드 삽입
              debugPrint("🔊 오디오 재생 실행 (추후 추가 예정)");
              _nextStep();
            }
          },
        ),

        // ── 손가락 안내 PNG ─────────────────────────────
        if (_isSoundStep) // 스피커 가리킴
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
        if (_isRedCardStep) // 빨강 카드 가리킴
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
