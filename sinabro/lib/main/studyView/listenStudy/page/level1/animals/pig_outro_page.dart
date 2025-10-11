// lib/main/studyView/listenStudy/animals/pig_outro_page.dart
//
// 마지막 동물(돼지) 엔딩 + 전체 완료 화면을 한 파일에서 순차 진행
// Step 0) 돼지 엔딩 (배경: pig_06.png, 말풍선 텍스트1, 오디오: pig06.mp3)
// Step 1) 전체 완료 (배경: 베이지, 중앙 박수 이모지/이미지 + 텍스트2, 오디오: animals_next1.mp3)
// → 모든 오디오가 끝나면 onFinished 콜백 호출(없으면 pop)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/figma_board.dart';

class PigOutroPage extends StatefulWidget {
  const PigOutroPage({
    super.key,
    this.onFinished,
  });

  static const routeName = '/listen/animals/pig-outro';

  /// 전 구간 재생 완료 후 호출(예: 사과 팝업 띄우기, 트리 화면 복귀 등)
  final VoidCallback? onFinished;

  @override
  State<PigOutroPage> createState() => _PigOutroPageState();
}

class _PigOutroPageState extends State<PigOutroPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;

  /// === 에셋 / 문구 정의 ===
  // Step0: 개구리 엔딩
  static const String _frogBg =
      'assets/img/contents/studyListen/level1/animals/pig_06.png';
  static const String _frogLine = '돼지는 꿀꿀 맛있는 걸 먹으러 갔어요';
  static const String _frogAudio =
      'assets/audio/tts/studyListen/level1/animals/pig06.mp3';

  // Step1: 전체 완료(박수 아이콘 + 텍스트)
  static const String _finalClap =
      'assets/img/contents/studyListen/level1/animals/animal4.png'; // 848x848 (피그마)
  static const String _finalLine = '저 멀리에서 만날 수 있는\n동물 친구들을 모두 만났어요!';
  static const String _finalAudio =
      'assets/audio/tts/studyListen/level1/animals/animals_next3.mp3';

  /// 진행 스텝: 0(개구리 엔딩) → 1(전체 완료)
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _playCurrent(); // 첫 장면부터 재생
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  /// 현재 스텝의 오디오를 재생하고, 완료 시 다음 스텝으로 자동 전환
  Future<void> _playCurrent() async {
    await _sub?.cancel();

    final String asset = _step == 0 ? _frogAudio : _finalAudio;

    try {
      await _player.setAsset(asset);
      await _player.play();
    } catch (e) {
      debugPrint('PigOutro audio error($_step): $e');
      // 오디오 실패해도 UX 흐름은 보장
      Future.delayed(const Duration(milliseconds: 800), _goNextIfAny);
      return;
    }

    _sub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        // 약간의 여유 시간 후 다음 단계
        await Future.delayed(const Duration(milliseconds: 800));
        _goNextIfAny();
      }
    });
  }

  void _goNextIfAny() {
    if (!mounted) return;
    if (_step == 0) {
      setState(() => _step = 1);
      _playCurrent();
    } else {
      // 모든 단계 끝
      widget.onFinished?.call();
      if (widget.onFinished == null && mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudyBackLayout(
      onBack: () => Navigator.of(context).maybePop(),
      body: FigmaBoard(
        baseWidth: 2000,
        baseHeight: 1200,
        builder: (context, scale, dx, dy) {
          final u = FigmaUnits(scale, dx, dy);

          // === STEP별 화면 ===
          if (_step == 0) {
            // -------------------------------
            // STEP 0: 돼지 엔딩 화면 (배경 full + 하단 말풍선)
            // 피그마 레이아웃:
            // - 배경 이미지 cover
            // - 하단 라벨: left 172, top 998, size 1655x133, r=50, border=7
            // -------------------------------
            return Stack(
              children: [
                Positioned.fill(child: Image.asset(_frogBg, fit: BoxFit.cover)),
                Positioned(
                  left: u.sx(172),
                  top: u.sy(998),
                  width: u.sw(1655),
                  height: u.sw(133),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: u.sw(7), color: const Color(0xFFD5D5D5)),
                        borderRadius: BorderRadius.circular(u.sw(50)),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: u.sw(6)),
                        child: Text(
                          _frogLine,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF626262),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: u.sp(80),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // -------------------------------
          // STEP 1: 전체 완료 화면
          // 피그마 레이아웃:
          // - 배경: 베이지(#FFF2E5)
          // - 중앙 상단 박수 아이콘(이미지): left 576, top 0, size 848x848
          // - 중앙 텍스트: left 276, top 753, font 120, center
          // -------------------------------
          return Stack(
            children: [
              Positioned.fill(child: Container(color: const Color(0xFFFFF2E5))),
              Positioned(
                left: u.sx(576),
                top: u.sy(0),
                width: u.sw(848),
                height: u.sw(848),
                child: Image.asset(_finalClap, fit: BoxFit.cover),
              ),
              Positioned(
                left: u.sx(276),
                top: u.sy(753),
                child: Text(
                  _finalLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF7C685F),
                    fontSize: u.sp(120),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
