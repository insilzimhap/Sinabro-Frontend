// lib/main/gameView/writeGame/page/level3/write_game_3_4.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main3.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

// 매핑
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart';
// API
import 'package:sinabro/main/gameView/writeGame/api/write_game_api.dart';
// ⬇️ AUDIO IMPORT
import 'package:audioplayers/audioplayers.dart';

// ⬇️ AUDIO ASSET DEFINITIONS
// 오디오 플레이어 사용 시 위치: 공통 오디오 에셋 경로
const String kGameWriteAudioDir = 'audio/tts/gameWrite/level3/';
// 오디오 플레이어 사용 시 위치: 학습 단어 오디오 에셋 경로
const String kStudyWriteAudioDir = 'audio/tts/studyWrite/level3/';

// 5세 쓰기 게임 공통 대사 에셋
const Map<String, String> kLevel5CommonAssets = {
  // 구분: 공통 | 대사: 과연 이것도 쓸 수 있을까? 글글글...
  'COMMON_1': kGameWriteAudioDir + 'write5_game_common_1.mp3',
  // 구분: 공통 | 대사: 대단하군...이렇게 잘할 줄이야!
  'SUCCESS_1': kGameWriteAudioDir + 'write5_game_success_1.mp3',
  // 구분: 공통 | 대사: 아쉽게도 퀴즈를 맞추지 못했네
  'FAIL_1': kGameWriteAudioDir + 'write5_game_fail_1.mp3',
};

// 5세 쓰기 학습 신체 단어 에셋
const Map<String, String> kLevel5BodyAssets = {
  '눈': kStudyWriteAudioDir + 'body_eye.mp3',
  '코': kStudyWriteAudioDir + 'body_nose.mp3',
  '입': kStudyWriteAudioDir + 'body_mouth.mp3',
  '귀': kStudyWriteAudioDir + 'body_ear.mp3',
  '손': kStudyWriteAudioDir + 'body_hand.mp3',
  '발': kStudyWriteAudioDir + 'body_foot.mp3',
};
// ⬆️ AUDIO ASSET DEFINITIONS

const _IMG_DIR = 'assets/img/contents/gameWrite/';

// 아웃트로 배경
const _OUTRO_SUCCESS_BG = '${_IMG_DIR}outro_success.png';
const _OUTRO_FAIL_BG = '${_IMG_DIR}outro_fail.png';
const _CLAP = '${_IMG_DIR}clap.png';

// 상단 얼굴/말풍선 이미지
const _PROF_HEAD = '${_IMG_DIR}write_game_professor_head.png';
const _BALLOON = '${_IMG_DIR}text_balloon1.png';

class _BodyItem {
  final String key;
  final String nameKo; // 매핑 key로 사용
  final String image;
  final List<String> syllables;
  // final String? audio; // (혼란 방지를 위해 주석 처리됨)
  const _BodyItem({
    required this.key,
    required this.nameKo,
    required this.image,
    required this.syllables,
    // this.audio, // (혼란 방지를 위해 주석 처리됨)
  });

  String get word => syllables.join();
}

const List<_BodyItem> _POOL = [
  _BodyItem(
    key: 'eye',
    nameKo: '눈',
    image: '${_IMG_DIR}eye.png',
    syllables: ['눈'],
  ),
  _BodyItem(
    key: 'nose',
    nameKo: '코',
    image: '${_IMG_DIR}nose.png',
    syllables: ['코'],
  ),
  _BodyItem(
    key: 'mouth',
    nameKo: '입',
    image: '${_IMG_DIR}mouth.png',
    syllables: ['입'],
  ),
  _BodyItem(
    key: 'ear',
    nameKo: '귀',
    image: '${_IMG_DIR}ear.png',
    syllables: ['귀'],
  ),
  _BodyItem(
    key: 'hand',
    nameKo: '손',
    image: '${_IMG_DIR}hand.png',
    syllables: ['손'],
  ),
  _BodyItem(
    key: 'foot',
    nameKo: '발',
    image: '${_IMG_DIR}foot.png',
    syllables: ['발'],
  ),
];

class WriteGameLevel3_4Page extends StatefulWidget {
  const WriteGameLevel3_4Page({super.key, required this.childId});
  final String childId;

  static const routeName = '/write/game/3/4';

  @override
  State<WriteGameLevel3_4Page> createState() => _WriteGameLevel3_4PageState();
}

class _WriteGameLevel3_4PageState extends State<WriteGameLevel3_4Page> {
  final List<GlobalKey<WritingCanvasState>> _canvasKeys = [];
  List<Completer<String>> _recognizeWaiters = [];

  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<_BodyItem> _problems;
  int _index = 0;
  final List<bool> _results = [];
  String? _resultId;
  final _sw = Stopwatch();

  _BodyItem get current => _problems[_index];

  // ⬇️ AUDIO HELPER FUNCTION
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (3-4): $assetPath');
  }

  @override
  void initState() {
    super.initState();
    _startGame();
    // ⬇️ 공통 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final commonAudio = kLevel5CommonAssets['COMMON_1'];
      if (commonAudio != null) {
        await _playAssetAudio(commonAudio);
      }
    });
  }

  @override
  void dispose() {
    _sw.stop();
    // ⬇️ AUDIO PLAYER DISPOSE
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    try {
      _resultId = await WriteGameApi.start(
        childId: widget.childId,
        stageCode: 'FR_WG_011', // 몸 랜덤 스테이지 코드
      );
      _sw.start();
    } catch (e) {
      debugPrint('[3-4] start error: $e');
      _resultId = null;
    }
    _resetGame();
  }

  void _resetGame() {
    final rnd = Random();
    _problems = [..._POOL]..shuffle(rnd);
    _problems = _problems.take(4).toList();
    _index = 0;
    _results.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prepareProblem();
      if (mounted) setState(() {});
    });
  }

  Future<void> _prepareProblem() async {
    _canvasKeys
      ..clear()
      ..addAll(
        List.generate(
          current.syllables.length,
          (_) => GlobalKey<WritingCanvasState>(),
        ),
      );
    try {
      await SelvyRecognizer.setCandidateSet(current.syllables);
    } catch (_) {}
    for (final k in _canvasKeys) {
      await k.currentState?.clearCanvas();
    }
  }

  Future<void> _playPronounce() async {
    // ⬇️ 기존 로직 수정: 실제 오디오 에셋을 찾아 재생
    final audioPath = kLevel5BodyAssets[current.nameKo];
    if (audioPath != null) {
      await _playAssetAudio(audioPath);
    } else {
      debugPrint(
        '[3-4] audio: ${current.nameKo} (Audio not mapped)',
      );
    }
    // ⬆️ 기존 로직 수정
  }

  Future<void> _onCheckAndNext() async {
    _recognizeWaiters = List.generate(
      _canvasKeys.length,
      (_) => Completer<String>(),
    );
    for (final key in _canvasKeys) {
      key.currentState?.recognizeAndCheckText();
    }

    final List<String> results = [];
    for (final waiter in _recognizeWaiters) {
      try {
        final s = await waiter.future.timeout(const Duration(seconds: 3));
        results.add(_normalize(s));
      } catch (_) {
        results.add('');
      }
    }

    bool isCorrect = true;
    for (int i = 0; i < current.syllables.length; i++) {
      final mine = (i < results.length) ? results[i] : '';
      if (mine != current.syllables[i]) {
        isCorrect = false;
        break;
      }
    }

    // wg_question_id 조회
    String questionId;
    try {
      questionId = requireWgQuestionId(
        bodyQuestionMap,
        current.nameKo,
        ctx: 'Stage3-4',
      );
    } catch (e) {
      debugPrint('[3-4] mapping not found for "${current.nameKo}": $e');
      questionId = 'UNKNOWN';
    }

    // 서버로 정답 전송
    try {
      if (_resultId != null && questionId != 'UNKNOWN') {
        await WriteGameApi.sendChoice(
          resultId: _resultId!,
          questionId: questionId,
          childWrittenText: results.join(),
          isCorrect: isCorrect,
        );
      }
    } catch (e) {
      debugPrint('[3-4] sendChoice error: $e');
    }

    _results.add(isCorrect);
    if (!mounted) return;

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _prepareProblem();
    } else {
      // 완료
      bool apiSuccess = false;
      try {
        if (_resultId != null) {
          final res = await WriteGameApi.complete(
            resultId: _resultId!,
            totalQuestions: _problems.length,
            timeSpentSecs: _sw.elapsed.inSeconds,
          );
          apiSuccess = res.success;
        }
      } catch (e) {
        debugPrint('[3-4] complete error: $e');
      }

      final localSuccess = _results.where((e) => e).length >= 3;
      await _showEndSequence(apiSuccess || localSuccess); // bool 전달
    }
  }

  void _onRecognizeAt(int slotIndex, String recognized) {
    if (slotIndex >= 0 && slotIndex < _recognizeWaiters.length) {
      if (!_recognizeWaiters[slotIndex].isCompleted) {
        _recognizeWaiters[slotIndex].complete(recognized);
      }
    }
  }

  String _normalize(String raw) {
    final top =
        raw.split('\n').first.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();
    return top;
  }

  // ✅ 시그니처를 bool로 변경
  Future<void> _showEndSequence(bool success) async {
    // 1) 인트로 다이얼로그
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FullImageDialog(imageAsset: _OUTRO_SUCCESS_BG),
    );
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      // 2) 팝업
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _FullImageDialog(
          imageAsset: _OUTRO_SUCCESS_BG,
          overlay: _ClearPopup(),
        ),
      );

      // ⬇️ 성공 오디오 재생 시점: 다이얼로그 표시 후 재생
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100)); // 다이얼로그 표시 지연
        final successAudio = kLevel5CommonAssets['SUCCESS_1'];
        if (successAudio != null) {
          await _playAssetAudio(successAudio);
        }
      });
      // ⬆️ 성공 오디오 재생 시점

      // 3) 2.5초 후 메인3 이동
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WriteGameMain3Page(childId: widget.childId),
        ),
      );
    } else {
      // 실패
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _FullImageDialog(
          imageAsset: _OUTRO_FAIL_BG,
          overlay: Positioned(
            right: 24,
            bottom: 28,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => WriteGameMain3Page(childId: widget.childId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE7D3A6),
                foregroundColor: const Color(0xFF5B3D20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '다시하기',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      );

      // ⬇️ 실패 오디오 재생 시점: 다이얼로그 표시 후 재생
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100)); // 다이얼로그 표시 지연
        final failAudio = kLevel5CommonAssets['FAIL_1'];
        if (failAudio != null) {
          await _playAssetAudio(failAudio);
        }
      });
      // ⬆️ 실패 오디오 재생 시점
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기 한 프레임 방어: 캔버스 키 아직 생성 전일 수 있음
    final hasCanvas = _canvasKeys.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.brown,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '쓰기 게임 3-4 (몸 랜덤)',
          style: TextStyle(color: Colors.brown),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment(0, -0.9),
                child: _ProfessorHeader(
                  text: '과연 이것도 쓸 수 있을까? 글글글…',
                  faceSize: 134,
                  balloonWidth: 420,
                  balloonHeight: 120,
                  textSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_problems.length, (i) {
                  final done = i < _results.length;
                  final now = i == _index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? (_results[i]
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935))
                            : (now
                                ? const Color(0xFF795548)
                                : const Color(0xFFBCAAA4)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final side = (c.biggest.shortestSide * 0.72).clamp(
                            180.0,
                            280.0,
                          );
                          return Stack(
                            children: [
                              const Positioned(
                                left: 150,
                                top: 38,
                                child: _SpeechHint(text: '누르면 음성이 출력돼요!'),
                              ),
                              Align(
                                alignment: const Alignment(0.6, -0.1),
                                child: GestureDetector(
                                  onTap: _playPronounce,
                                  child: Image.asset(
                                    current.image,
                                    width: side,
                                    height: side,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final canvasW = (c.maxWidth * 0.86).clamp(
                            320.0,
                            c.maxWidth,
                          );
                          final canvasH = (c.maxHeight * 0.62).clamp(
                            240.0,
                            c.maxHeight,
                          );
                          final tileSize = Size(canvasW, canvasH);

                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 캔버스가 단일 타일로 표시되는 로직
                                if (hasCanvas)
                                  _CanvasTile(
                                    size: tileSize,
                                    canvasKey: _canvasKeys.first,
                                    childId: widget.childId,
                                    target: current.syllables.first,
                                    onRecognize: (s) => _onRecognizeAt(0, s),
                                  )
                                else
                                  SizedBox(
                                    width: canvasW,
                                    height: canvasH,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: _onCheckAndNext,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD9CCFF),
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      '다음',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* 상단 얼굴 + 말풍선 */
class _ProfessorHeader extends StatelessWidget {
  const _ProfessorHeader({
    required this.text,
    this.faceSize = 44,
    this.balloonWidth = 280,
    this.balloonHeight = 88,
    this.textSize = 18,
  });

  final String text;
  final double faceSize;
  final double balloonWidth;
  final double balloonHeight;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final maxBalloonW = MediaQuery.of(context).size.width - faceSize - 40;
    final bw = balloonWidth.clamp(100, maxBalloonW);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          _PROF_HEAD,
          width: faceSize,
          height: faceSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: bw.toDouble(),
          height: balloonHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(_BALLOON, fit: BoxFit.contain),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5B4634),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* 재사용 위젯들 */
class _CanvasTile extends StatelessWidget {
  const _CanvasTile({
    required this.size,
    required this.canvasKey,
    required this.childId,
    required this.target,
    required this.onRecognize,
  });

  final Size size;
  final GlobalKey<WritingCanvasState> canvasKey;
  final String childId;
  final String target;
  final ValueChanged<String> onRecognize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size.width * 0.98,
            height: size.height * 0.98,
            child: WritingCanvas(
              key: canvasKey,
              childId: childId,
              targetChar: target,
              candidateSet: [target],
              targetType: "syllable",
              autoRecognizeOnEnd: false,
              onRecognize: onRecognize,
              penWidth: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechHint extends StatelessWidget {
  const _SpeechHint({
    this.width = 240,
    this.height = 54,
    this.fontSize = 18,
    this.text = '누르면 음성이 출력돼요!',
  });

  final double width;
  final double height;
  final double fontSize;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BalloonPainter(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0xFF7A614B),
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 10),
      const Radius.circular(12),
    );
    final paint = Paint()..color = const Color(0xFFF2E2CF);
    canvas.drawRRect(r, paint);

    final double tailBaseX = 26, tailTopY = size.height - 10;
    final path = Path()
      ..moveTo(tailBaseX, tailTopY)
      ..relativeLineTo(14, 10)
      ..relativeLineTo(6, -10)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FullImageDialog extends StatelessWidget {
  const _FullImageDialog({required this.imageAsset, this.overlay, this.onTap});

  final String imageAsset;
  final Widget? overlay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: w,
                height: h,
                child: Image.asset(imageAsset, fit: BoxFit.contain),
              ),
            ),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

/// 성공 팝업
class _ClearPopup extends StatelessWidget {
  const _ClearPopup();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = (w * 0.72).clamp(300.0, 520.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: cardW,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF1C8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 64,
                child: Image.asset(
                  _CLAP,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '이번 단계를 클리어했어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5A4032),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '다음 단계도 도전해봐요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6C5244),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
