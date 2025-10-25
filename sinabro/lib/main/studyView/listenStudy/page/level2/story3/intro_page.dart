// lib/main/studyView/listenStudy/page/level2/story3/intro_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/data/routine_data_1.dart'
    as story3Data1;
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/data/routine_data_2.dart'
    as story3Data2;

class Story3IntroPage extends StatefulWidget {
  final int routineIndex; // 0: 데이터1, 1: 데이터2
  final VoidCallback onNext;
  final String childId;

  const Story3IntroPage({
    super.key,
    required this.routineIndex,
    required this.onNext,
    required this.childId,
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

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;
  bool _canNavigate = false;

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
        tween:
            Tween(begin: const Offset(-1.2, -0.5), end: const Offset(0.8, -0.3))
                .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: const Offset(0.8, -0.3), end: const Offset(0.0, 0.0))
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

    // 오디오 재생 완료 시 _canNavigate = true로 설정
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted && !_showPlane) {
        // 숫자 화면일 때만
        setState(() => _canNavigate = true);
      }
    });

    // ✈️ 비행기 애니메이션 후 숫자 장면으로 전환
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // ✨ [수정] 애니메이션과 오디오가 '진짜로' 끝날 때까지 기다리는 로직

      // 1. 애니메이션이 끝나면 완료되는 Future
      final animationFuture = _planeController.forward();

      // 2. 오디오가 끝나면 완료되는 Future를 수동으로 생성
      final audioCompleter = Completer<void>();
      StreamSubscription? audioSub;
      audioSub = _audioPlayer.onPlayerComplete.listen((_) {
        audioCompleter.complete();
        audioSub?.cancel(); // 리스너 정리
      });

      // 3. 오디오 재생 시작
      _audioPlayer.play(
          AssetSource('audio/tts/studyListen/level2/numbers/num_intro1.mp3'));

      // 4. 애니메이션과 오디오가 '둘 다' 끝나기를 기다림
      await Future.wait([animationFuture, audioCompleter.future]);

      // 5. (선택사항) 자연스러운 전환을 위한 추가 딜레이
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() => _showPlane = false);
        // 🔢 2. 숫자 화면으로 전환되며 두 번째 TTS 재생
        _audioPlayer.play(
            AssetSource('audio/tts/studyListen/level2/numbers/num_intro2.mp3'));
        _numberController.forward();
      }
    });
  }

  @override
  void dispose() {
    _planeController.dispose();
    _numberController.dispose();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
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
          "어라? 우리한테 무언가 날아왔어요\n이게 뭔지 열어볼까?",
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
      scale:
          CurvedAnimation(parent: _numberController, curve: Curves.elasticOut),
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
          //  _canNavigate가 true일 때만 시작하기 버튼이 활성화되고 보이도록
          AnimatedOpacity(
            opacity: _canNavigate ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: _canNavigate ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC5C),
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 3,
              ),
              child: const Text(
                "시작하기",
                style: TextStyle(
                    color: Colors.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
