// lib/main/gameView/writeGame/page/level3/write_game_3_1.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main3.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

// ✅ API/매핑
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart';
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

// 5세 쓰기 학습 동물 단어 에셋
// 중복되는 단어는 기존 맵을 재사용하고, 신규 단어만 추가
const Map<String, String> kLevel5AnimalAssets = {
  '강아지': kStudyWriteAudioDir + 'animal_dog.mp3',
  '고양이': kStudyWriteAudioDir + 'animal_cat.mp3',
  '닭': kStudyWriteAudioDir + 'animal_chicken.mp3',
  '돼지': kStudyWriteAudioDir + 'animal_pig.mp3',
  '쥐': kStudyWriteAudioDir + 'animal_mouse.mp3',
  '호랑이': kStudyWriteAudioDir + 'animal_tiger.mp3',
  '코끼리': kStudyWriteAudioDir + 'animal_elephant.mp3',
  '원숭이': kStudyWriteAudioDir + 'animal_monkey.mp3',
  '양': kStudyWriteAudioDir + 'animal_sheep.mp3',
  '펭귄': kStudyWriteAudioDir + 'animal_penguin.mp3',
  '오리': kStudyWriteAudioDir + 'animal_duck.mp3',
  '새': kStudyWriteAudioDir + 'animal_bird.mp3',
  '개구리': kStudyWriteAudioDir + 'animal_frog.mp3',
  '거북이': kStudyWriteAudioDir + 'animal_turtle.mp3',
  '토끼': kStudyWriteAudioDir + 'animal_rabbit.mp3',
};
// ⬆️ AUDIO ASSET DEFINITIONS

const _IMG_DIR = 'assets/img/contents/gameWrite/';
const _OUTRO_SUCCESS_BG = '${_IMG_DIR}outro_success.png';
const _OUTRO_FAIL_BG = '${_IMG_DIR}outro_fail.png';
const _CLAP = '${_IMG_DIR}clap.png';
const _PROF_HEAD = '${_IMG_DIR}write_game_professor_head.png';
const _BALLOON = '${_IMG_DIR}text_balloon1.png';

class _AnimalItem {
  final String key;
  final String nameKo;
  final String image;
  final List<String> syllables;
  // final String? audio; // (혼란 방지를 위해 주석 처리됨)
  const _AnimalItem({
    required this.key,
    required this.nameKo,
    required this.image,
    required this.syllables,
    // this.audio, // (혼란 방지를 위해 주석 처리됨)
  });
  String get word => syllables.join();
}

/// 문제 풀
const List<_AnimalItem> _POOL = [
  _AnimalItem(
    key: 'dog',
    nameKo: '강아지',
    image: '${_IMG_DIR}dog.png',
    syllables: ['강', '아', '지'],
  ),
  _AnimalItem(
    key: 'cat',
    nameKo: '고양이',
    image: '${_IMG_DIR}cat.png',
    syllables: ['고', '양', '이'],
  ),
  _AnimalItem(
    key: 'rabbit',
    nameKo: '토끼',
    image: '${_IMG_DIR}rabbit.png',
    syllables: ['토', '끼'],
  ),
  _AnimalItem(
    key: 'duck',
    nameKo: '오리',
    image: '${_IMG_DIR}duck.png',
    syllables: ['오', '리'],
  ),
  _AnimalItem(
    key: 'turtle',
    nameKo: '거북이',
    image: '${_IMG_DIR}turtle.png',
    syllables: ['거', '북', '이'],
  ),
  _AnimalItem(
    key: 'frog',
    nameKo: '개구리',
    image: '${_IMG_DIR}frog.png',
    syllables: ['개', '구', '리'],
  ),
];

class WriteGameLevel3_1Page extends StatefulWidget {
  const WriteGameLevel3_1Page({
    super.key,
    required this.childId,
    this.resultId,
  });
  final String childId;
  final String? resultId;
  static const routeName = '/write/game/3/1';

  @override
  State<WriteGameLevel3_1Page> createState() => _WriteGameLevel3_1PageState();
}

class _WriteGameLevel3_1PageState extends State<WriteGameLevel3_1Page> {
  final _sw = Stopwatch();
  final _canvasKey = GlobalKey<WritingCanvasState>();
  late List<_AnimalItem> _problems;
  int _index = 0;
  final List<bool> _results = [];

  String? _resultId;
  bool _booting = true;

  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();

  _AnimalItem get current => _problems[_index];
  String get _targetWord => current.word;

  // ⬇️ AUDIO HELPER FUNCTION
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (3-1): $assetPath');
  }

  @override
  void initState() {
    super.initState();
    _initAndStart();
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

  Future<void> _initAndStart() async {
    try {
      _resultId = widget.resultId;
      _resultId ??= await WriteGameApi.start(
        childId: widget.childId,
        stageCode: 'FR_WG_008',
      );
      _sw.start();
      _resetGame();
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _booting = false);
    }
  }

  void _resetGame() {
    final rnd = Random();
    _problems = [..._POOL]..shuffle(rnd);
    _problems = _problems.take(4).toList();
    _index = 0;
    _results.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prepareProblem();
      setState(() {});
    });
  }

  Future<void> _prepareProblem() async {
    try {
      await SelvyRecognizer.setCandidateSet([_targetWord]);
    } catch (_) {}
    await _canvasKey.currentState?.clearCanvas();
  }

  Future<void> _playPronounce() async {
    // ⬇️ 기존 로직 수정: 실제 오디오 에셋을 찾아 재생
    final audioPath = kLevel5AnimalAssets[current.nameKo];
    if (audioPath != null) {
      await _playAssetAudio(audioPath);
    } else {
      debugPrint('[3-1] Error: Audio key not found for word ${current.nameKo}');
    }
  }

  String _normalize(String raw) =>
      raw.split('\n').first.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();

  Future<void> _sendChoice(String word, bool isCorrect) async {
    if (_resultId == null) return;
    final qid = requireWgQuestionId(animalQuestionMap, word, ctx: 'Stage3-1');
    try {
      await WriteGameApi.sendChoice(
        resultId: _resultId!,
        questionId: qid,
        childWrittenText: word,
        isCorrect: isCorrect,
      );
    } catch (_) {}
  }

  Future<bool> _completeAndGetSuccess() async {
    if (_resultId == null) return false;
    try {
      final secs = _sw.elapsed.inSeconds; // ✅ 경과시간
      final res = await WriteGameApi.complete(
        resultId: _resultId!,
        totalQuestions: _problems.length, // ✅ 4 문항
        timeSpentSecs: secs, // ✅ 소요시간
      );
      return res.success == true;
    } catch (_) {
      return false;
    }
  }

  void _onRecognizeWord(String recognized) async {
    final mine = _normalize(recognized);
    final isCorrect = mine == _targetWord;
    await _sendChoice(_targetWord, isCorrect);

    _results.add(isCorrect);
    if (!mounted) return;

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _prepareProblem();
    } else {
      final success = await _completeAndGetSuccess();
      await _showEndSequence(success);
    }
  }

  Future<void> _showEndSequence(bool success) async {
    // 1) 인트로 다이얼로그 (기존 로직 유지)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FullImageDialog(imageAsset: _OUTRO_SUCCESS_BG),
    );

    // 2) 3초 뒤 인트로 닫기 (기존 로직 유지)
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (success || _results.where((e) => e).length >= 3) {
      // 3-1) 성공 다이얼로그 띄우기
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _FullImageDialog(
          imageAsset: _OUTRO_SUCCESS_BG,
          overlay: _ClearPopup(),
        ),
      );

      // ⬇️ 성공 오디오 재생 시점 : 다이얼로그 표시 후 재생
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100)); // 다이얼로그 표시 지연
        final successAudio = kLevel5CommonAssets['SUCCESS_1'];
        if (successAudio != null) {
          await _playAssetAudio(successAudio);
        }
      });
      // ⬆️ 성공 오디오 재생 시점

      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WriteGameMain3Page(childId: widget.childId),
        ),
      );
    } else {
      // 3-2) 실패 다이얼로그 띄우기
      await showDialog(
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

      // ⬇️ 실패 오디오 재생 시점 : 다이얼로그 표시 후 재생
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
    if (_booting) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7EFE6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          '쓰기 게임 3-1 (동물 랜덤)',
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
                  balloonWidth: 400,
                  balloonHeight: 120,
                  textSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final done = i < _results.length;
                  final now = i == _index;
                  final ok = done ? _results[i] : false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? (ok
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
                          final cw = (c.maxWidth * 0.86).clamp(
                            320.0,
                            c.maxWidth,
                          );
                          final ch = (c.maxHeight * 0.62).clamp(
                            240.0,
                            c.maxHeight,
                          );
                          final caption = (ch * 0.12).clamp(18.0, 28.0);
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: cw,
                                  height: ch,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                        width: cw * 0.98,
                                        height: ch * 0.98,
                                        child: WritingCanvas(
                                          key: _canvasKey,
                                          childId: widget.childId,
                                          targetChar: _targetWord,
                                          candidateSet: [_targetWord],
                                          targetType: "word",
                                          autoRecognizeOnEnd: false,
                                          onRecognize: _onRecognizeWord,
                                          penWidth: 20,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: ch * 0.06,
                                        child: Text(
                                          '단어를 한 번에 써보세요!',
                                          style: TextStyle(
                                            fontSize: caption,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF8D6E63),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () => _canvasKey.currentState
                                        ?.recognizeAndCheckText(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD9CCFF),
                                      foregroundColor: Colors.black87,
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

/* ───────────── 재사용 위젯 ───────────── */
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
        Image.asset(_PROF_HEAD, width: faceSize, height: faceSize),
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
    final tailBaseX = 26.0, tailTopY = size.height - 10;
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
