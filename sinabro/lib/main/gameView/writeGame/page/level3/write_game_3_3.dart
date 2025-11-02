// lib/main/gameView/writeGame/page/level3/write_game_3_3.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main3.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

// 매핑
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart';
// 추가
import 'package:sinabro/main/gameView/writeGame/api/fruit_state.dart';   // ✅ resultId 공유용
import 'package:sinabro/main/gameView/writeGame/api/child_game_api.dart'; // ✅ 서버 통신용

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

// 5세 쓰기 학습 채소 단어 에셋
const Map<String, String> kLevel5VegetableAssets = {
  '감자': kStudyWriteAudioDir + 'vege_potato.mp3',
  '고구마': kStudyWriteAudioDir + 'vege_sweetpotato.mp3',
  '오이': kStudyWriteAudioDir + 'vege_cucumber.mp3',
  '배추': kStudyWriteAudioDir + 'vege_cabbage.mp3',
  '옥수수': kStudyWriteAudioDir + 'vege_corn.mp3',
  '버섯': kStudyWriteAudioDir + 'vege_mushroom.mp3',
};
// ⬆️ AUDIO ASSET DEFINITIONS

const _IMG_DIR = 'assets/img/contents/gameWrite/';

// ✅ 아웃트로 리소스
const _OUTRO_SUCCESS_BG = '${_IMG_DIR}outro_success.png';
const _OUTRO_FAIL_BG = '${_IMG_DIR}outro_fail.png';
const _CLAP = '${_IMG_DIR}clap.png';

// 상단 얼굴/말풍선
const _PROF_HEAD = '${_IMG_DIR}write_game_professor_head.png';
const _BALLOON = '${_IMG_DIR}text_balloon1.png';

class _VegItem {
  final String key;
  final String nameKo;
  final String image;
  final List<String> syllables;
  // final String? audio; // (혼란 방지를 위해 주석 처리됨)

  const _VegItem({
    required this.key,
    required this.nameKo,
    required this.image,
    required this.syllables,
    // this.audio, // (혼란 방지를 위해 주석 처리됨)
  });

  String get word => syllables.join();
}

/// 채소 6종
const List<_VegItem> _POOL = [
  _VegItem(
    key: 'potato',
    nameKo: '감자',
    image: '${_IMG_DIR}potato.png',
    syllables: ['감', '자'],
  ),
  _VegItem(
    key: 'sweetpotato',
    nameKo: '고구마',
    image: '${_IMG_DIR}sweetpotato.png',
    syllables: ['고', '구', '마'],
  ),
  _VegItem(
    key: 'cucumber',
    nameKo: '오이',
    image: '${_IMG_DIR}cucumber.png',
    syllables: ['오', '이'],
  ),
  _VegItem(
    key: 'cabbage',
    nameKo: '배추',
    image: '${_IMG_DIR}cabbage.png',
    syllables: ['배', '추'],
  ),
  _VegItem(
    key: 'corn',
    nameKo: '옥수수',
    image: '${_IMG_DIR}corn.png',
    syllables: ['옥', '수', '수'],
  ),
  _VegItem(
    key: 'mushroom',
    nameKo: '버섯',
    image: '${_IMG_DIR}mushroom.png',
    syllables: ['버', '섯'],
  ),
];

class WriteGameLevel3_3Page extends StatefulWidget {
  const WriteGameLevel3_3Page({
    super.key, 
    required this.childId,
    required this.resultId,
    });
  final String childId;
  final String? resultId;

  static const routeName = '/write/game/3/3';

  @override
  State<WriteGameLevel3_3Page> createState() => _WriteGameLevel3_3PageState();
}

class _WriteGameLevel3_3PageState extends State<WriteGameLevel3_3Page> {
  final _canvasKey = GlobalKey<WritingCanvasState>();
  late List<_VegItem> _problems;
  int _index = 0;
  final List<bool> _results = [];
  String? _resultId;
  final _sw = Stopwatch(); // ✅ 실제 플레이 시간 측정
  bool _booting = true;

  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();

  _VegItem get current => _problems[_index];
  String get _targetWord => current.word;

  // ⬇️ AUDIO HELPER FUNCTION
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (3-3): $assetPath');
  }

  @override
  void initState() {
    super.initState();
    _initAndStart(); // ✅ 타이머 시작 포함
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
    // ⬇️ AUDIO PLAYER DISPOSE
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAndStart() async {
    try {
      // resultId는 부모 페이지에서 전달됨
      _resultId = widget.resultId ?? FruitState.instance.resultId; //changed

      if (_resultId == null) {
        throw Exception('resultId 없음'); //changed
      }

      _resetGame(); // 문제 셔플 (랜덤 출제 로직)

      _sw.start(); // 타이머 시작
      debugPrint('[3-3] 🎯 게임 시작 시각 기록됨 → ${DateTime.now()}'); //changed
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
    final audioPath = kLevel5VegetableAssets[current.nameKo];
    if (audioPath != null) {
      await _playAssetAudio(audioPath);
    } else {
      debugPrint(
        '[3-3] play audio: ${current.nameKo} (Audio not mapped)',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // [2] 채점 결과 서버 전송 (_sendChoice)
  Future<void> _sendChoice(String word, bool isCorrect) async {
    if (_resultId == null) return;
    final qid = requireWgQuestionId(vegetableQuestionMap, word, ctx: 'Stage3-3'); //changed
    try {
      await ChildGameApi.recordWritingChoice( //changed
        resultId: _resultId!, //changed
        questionId: qid, //changed
        childWrittenText: word, //changed
        isCorrect: isCorrect, //changed
      );
      debugPrint('[3-3][_sendChoice] ✅ 서버 기록 성공');
    } catch (e) {
      debugPrint('[3-3][_sendChoice] ⚠️ 서버 기록 실패: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 게임 완료 후 성공/실패 판정 (_completeAndGetSuccess)
  Future<bool> _completeAndGetSuccess() async {
    if (_resultId == null) return false;
    try {
      final secs = _sw.elapsed.inSeconds; //changed
      final data = await ChildGameApi.completeWritingGame( //changed
        resultId: _resultId!, //changed
        timeSpentSecs: secs, //changed
      );

      if (data == null) {
        debugPrint('[3-3][_completeAndGetSuccess] ⚠️ 서버 응답 없음');
        return false;
      }

      final success = data['success'] == true; //changed
      final score = data['score']; //changed
      final total = data['totalQuestions']; //changed
      debugPrint('[3-3][_completeAndGetSuccess] ✅ 서버 success=$success (score=$score / total=$total)');
      return success;
    } catch (e) {
      debugPrint('[3-3][_completeAndGetSuccess] ⚠️ 예외 발생: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 글씨 인식 결과 수신 (_onRecognizeWord)
  void _onRecognizeWord(String recognized) async {
    final mine = _normalize(recognized);
    final isCorrect = mine == _targetWord;
    await _sendChoice(mine, isCorrect); //changed

    _results.add(isCorrect);
    if (!mounted) return;

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _prepareProblem();
    } else {
      debugPrint('[3-3][_onRecognizeWord] 모든 문제 완료 → 서버 complete 요청 시작');
      final frontCount = _results.where((e) => e).length;
      final frontSuccess = frontCount >= 3;
      debugPrint('[3-3] 🎯 프론트 success=$frontSuccess (정답 $frontCount/${_problems.length})');

      final serverSuccess = await _completeAndGetSuccess(); //changed
      if (!mounted) return;

      final isConsistent = (frontSuccess == serverSuccess);
      final finalSuccess = frontSuccess && serverSuccess && isConsistent;
      debugPrint('[3-3] ✅ 최종 success=$finalSuccess (front=$frontSuccess / server=$serverSuccess / 일치=$isConsistent)');
      await _showEndSequence(finalSuccess);
    }
  }

  // ---------------------------------------------------------------------------
  // 글씨 인식 결과 정규화 (_normalize)
  String _normalize(String raw) {
    final top =
        raw.split('\n').first.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();
    return top;
  }

  /// ✅ 최종본 아웃트로 로직
  // ---------------------------------------------------------------------------
  // 엔딩 시퀀스 (성공 / 실패 UI)
  Future<void> _showEndSequence(bool finalSuccess) async {

    // 1) 성공 배경
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FullImageDialog(imageAsset: _OUTRO_SUCCESS_BG),
    );
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (finalSuccess) {
      // 2) 팝업
      showDialog<void>(
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
          '쓰기 게임 3-3 (채소 랜덤)',
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

              // 진행 점
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

              // 본문
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
                          final caption = (canvasH * 0.12).clamp(18.0, 28.0);

                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: canvasW,
                                  height: canvasH,
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
                                        width: canvasW * 0.98,
                                        height: canvasH * 0.98,
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
                                        bottom: canvasH * 0.06,
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

/* ───────────── 재사용: 상단 한글박사 얼굴 + 말풍선 ───────────── */
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

/* ─────────── 보조 위젯 ─────────── */
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

/// ✅ 전체 화면 다이얼로그
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

/// ✅ 성공 팝업
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
              // 박수 이미지 있으면 사용, 없으면 아이콘 fallback
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
