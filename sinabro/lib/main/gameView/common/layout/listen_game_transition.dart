import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/listenGame/controller/audio_helper.dart'; // ✅ 추가

/// 듣기 게임 화면 전환 페이지
/// - 귀여운 일러스트 + 안내 텍스트
/// - 2~3초 대기 후 nextPage로 이동
class ListenGameTransition extends StatefulWidget {
  final Widget nextPage;
  final Duration duration;

  const ListenGameTransition({
    super.key,
    required this.nextPage,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ListenGameTransition> createState() => _ListenGameTransitionState();
}

class _ListenGameTransitionState extends State<ListenGameTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // 귀여운 살짝 튀는 스케일 애니메이션
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 💡 로딩 TTS 재생
    AudioHelper.playAudio('loading', isTts: true);

    // 일정 시간 뒤 다음 페이지로 이동
    Future.delayed(widget.duration, () {
      if (mounted) {
        AudioHelper.stopAudio(); // ✅ 페이지 전환 전 오디오 중지
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.nextPage),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    AudioHelper.stopAudio(); // ✅ dispose 시 오디오 중지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Image.asset(
                "assets/img/contents/gameListen/transition.png",
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "게임으로 이동 중입니다\n잠시만 기다려주세요!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
