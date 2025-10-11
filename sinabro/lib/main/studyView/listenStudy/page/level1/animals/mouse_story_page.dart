import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/mouse_outro_page.dart';

class MouseStoryPage extends StatefulWidget {
  const MouseStoryPage({
    super.key,
    this.onFinished,
  });

  /// 네임드 라우트가 필요하면 등록해서 써도 돼요.
  static const routeName = '/listen/animals/mouse-story';

  /// 마지막 장면 이후 이어서 갈 화면이 있다면 콜백으로 연결
  final VoidCallback? onFinished;

  @override
  State<MouseStoryPage> createState() => _MouseStoryPageState();
}

class _MouseStoryPageState extends State<MouseStoryPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;
  int _index = 0;

  // === 장면 데이터 (이미지 풀스크린 + 오디오 1:1) ===
  static const List<String> _images = [
    'assets/img/contents/studyListen/level1/animals/mouse_01.png',
    'assets/img/contents/studyListen/level1/animals/mouse_02.png',
    'assets/img/contents/studyListen/level1/animals/mouse_03.png',
    'assets/img/contents/studyListen/level1/animals/mouse_04.png',
    'assets/img/contents/studyListen/level1/animals/mouse_05.png',
  ];

  static const List<String> _audios = [
    'assets/audio/tts/studyListen/level1/animals/mouse01.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse02.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse03.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse04.mp3',
    'assets/audio/tts/studyListen/level1/animals/mouse05.mp3',
  ];

  @override
  void initState() {
    super.initState();
    // 첫 장면 이미지 프리캐시(초기 깜빡임 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
          const AssetImage(
              'assets/img/contents/studyListen/level1/animals/mouse_01.png'),
          context);
      _playCurrent();
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playCurrent() async {
    _playerSub?.cancel();

    try {
      await _player.setAsset(_audios[_index]);
      await _player.play();
    } catch (e) {
      // asset 경로 오류나 재생 실패 시에도 진행 가능하도록 무시
      debugPrint('MouseStory audio error: $e');
    }

    // ✅ 다음 이미지 프리캐시(전환 렉 최소화)
    if (mounted && _index + 1 < _images.length) {
      precacheImage(AssetImage(_images[_index + 1]), context);
    }

    // ✅ 오디오 재생 완료 감지
    _playerSub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        // 약간의 여유(연출 템포)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _next();
      }
    });
  }

  void _next() {
    if (_index < _images.length - 1) {
      setState(() => _index++);
      _playCurrent();
    } else {
      // ✅ 모든 장면 종료 후 부드럽게 아웃트로로
      if (widget.onFinished != null) {
        widget.onFinished!();
      } else {
        _goToOutro();
      }
    }
  }

  void _goToOutro() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const MouseOutroPage(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StudyBackLayout(
      onBack: () => Navigator.of(context).maybePop(),
      body: Stack(
        children: [
          // 화면 전체를 이미지로 꽉 채움 + 부드러운 전환
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
                  child: child,
                ),
              ),
              child: Image.asset(
                _images[_index],
                key: ValueKey(_images[_index]), // ← 전환 트리거
                fit: BoxFit.cover,
              ),
            ),
          ),
          // (선택) 탭해서 다음 장면으로 넘기기
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _next,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
