import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'data/routine_data_1.dart' as story3Data1;
import 'data/routine_data_2.dart' as story3Data2;

class Story3IntroPage extends StatefulWidget {
  final int routineIndex; // 0: 데이터1, 1: 데이터2
  final VoidCallback onNext;

  const Story3IntroPage({
    super.key,
    required this.routineIndex,
    required this.onNext,
  });

  @override
  State<Story3IntroPage> createState() => _Story3IntroPageState();
}

class _Story3IntroPageState extends State<Story3IntroPage>
    with TickerProviderStateMixin {
  late AnimationController _planeController;
  late Animation<Offset> _planeOffset;
  late Animation<double> _planeRotation;

  late AnimationController _numberController;
  bool _showPlane = true;

  late String _introImage;
  late String _introText;

  @override
  void initState() {
    super.initState();

    // ✅ routineIndex에 따라 데이터 분리
    final data = widget.routineIndex == 0
        ? story3Data1.introData
        : story3Data2.introData;

    _introImage = data.imagePath ?? "";
    _introText = data.text;

    // ✈️ 종이비행기 애니메이션 세팅
    _planeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _planeOffset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-1.2, -0.5), end: const Offset(0.8, -0.3))
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.8, -0.3), end: const Offset(0.0, 0.0))
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
    ]).animate(_planeController);

    _planeRotation = Tween<double>(begin: -0.4, end: 0.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_planeController);

    // 🔢 숫자 친구 등장 애니메이션 세팅
    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // ✈️ 비행기 애니메이션 후 숫자 장면으로 전환
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _planeController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showPlane = false;
        });
        _numberController.forward();
      }
    });
  }

  @override
  void dispose() {
    _planeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _showPlane ? Colors.white : const Color(0xFFFFF7EE),
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _showPlane
                ? _buildPaperPlaneScene()
                : _buildNumberScene(context),
          ),
        ),
      ),
    );
  }

/// ✈️ 종이비행기 장면 (텍스트는 고정, 비행기만 부드럽게 회전하며 이동)
Widget _buildPaperPlaneScene() {
  return Column(
    key: const ValueKey(1),
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SlideTransition(
            position: _planeOffset,
            child: RotationTransition(
              turns: _planeRotation,
              child: Image.asset(
                "assets/img/contents/studyListen/level2/paper_airplane.png",
                width: 180,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 40),
      const Text(
        "어라? (____)에게 무언가 날아왔어요\n이게 뭔지 열어볼까?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          color: Color(0xFF6B4E36),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}


  /// 🔢 숫자 친구 등장 장면 (버튼은 애니메이션 종료 후 자연스럽게 등장)
Widget _buildNumberScene(BuildContext context) {
  return ScaleTransition(
    scale: CurvedAnimation(parent: _numberController, curve: Curves.elasticOut),
    child: Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🧩 숫자 이미지
        Image.asset(
          _introImage,
          width: MediaQuery.of(context).size.width * 0.4,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),

        // ✨ 텍스트
        Text(
          _introText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFF6B4E36),
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 50),

        // 🎬 버튼 애니메이션 (숫자 애니 끝난 후 등장)
        AnimatedBuilder(
          animation: _numberController,
          builder: (context, child) {
            // 숫자 애니 끝나면 (progress 1.0 근처)
            final showButton = _numberController.value > 0.8;
            return AnimatedOpacity(
              opacity: showButton ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: showButton
                  ? ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC5C),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "시작하기",
                        style: TextStyle(
                          color: Colors.brown,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    ),
  );
}
    }