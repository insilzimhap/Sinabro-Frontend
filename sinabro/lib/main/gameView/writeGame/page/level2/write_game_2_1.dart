// lib/main/studyView/writeGame/page/level2/write_game_2_1.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

// ▼ 추가: 매핑/API
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart'
    as WG;
import 'package:sinabro/main/gameView/writeGame/api/write_game_api.dart';

/// 에셋 경로
/// 이미지: assets/img/contents/gameWrite/sound.png (고정)
const _IMG_DIR = 'assets/img/contents/gameWrite/';
const _AUD_DIR = 'assets/audio/gameWrite2/cons/';

/// 엔딩 이미지(전체 화면)
const _END_INTRO = '${_IMG_DIR}end_intro.png'; // 1번
const _END_SUCCESS = '${_IMG_DIR}end_success.png'; // 2번
const _END_FAIL = '${_IMG_DIR}end_fail.png'; // 3번

class _ConsonantItem {
  final String key; // 식별 키
  final String char; // ㄱ, ㄲ, ...
  final String nameKo;
  final String audio; // 오디오 asset 경로

  const _ConsonantItem({
    required this.key,
    required this.char,
    required this.nameKo,
    required this.audio,
  });
}

/// 자음 19개 풀
const List<_ConsonantItem> _POOL = [
  _ConsonantItem(
    key: 'giyeok',
    char: 'ㄱ',
    nameKo: '기역',
    audio: '${_AUD_DIR}giyeok.mp3',
  ),
  _ConsonantItem(
    key: 'ssang_giyeok',
    char: 'ㄲ',
    nameKo: '쌍기역',
    audio: '${_AUD_DIR}ssang_giyeok.mp3',
  ),
  _ConsonantItem(
    key: 'digeut',
    char: 'ㄷ',
    nameKo: '디귿',
    audio: '${_AUD_DIR}digeut.mp3',
  ),
  _ConsonantItem(
    key: 'ssang_digeut',
    char: 'ㄸ',
    nameKo: '쌍디귿',
    audio: '${_AUD_DIR}ssang_digeut.mp3',
  ),
  _ConsonantItem(
    key: 'siot',
    char: 'ㅅ',
    nameKo: '시옷',
    audio: '${_AUD_DIR}siot.mp3',
  ),
  _ConsonantItem(
    key: 'ssang_siot',
    char: 'ㅆ',
    nameKo: '쌍시옷',
    audio: '${_AUD_DIR}ssang_siot.mp3',
  ),
  _ConsonantItem(
    key: 'jieut',
    char: 'ㅈ',
    nameKo: '지읒',
    audio: '${_AUD_DIR}jieut.mp3',
  ),
  _ConsonantItem(
    key: 'ssang_jieut',
    char: 'ㅉ',
    nameKo: '쌍지읒',
    audio: '${_AUD_DIR}ssang_jieut.mp3',
  ),
  _ConsonantItem(
    key: 'bieup',
    char: 'ㅂ',
    nameKo: '비읍',
    audio: '${_AUD_DIR}bieup.mp3',
  ),
  _ConsonantItem(
    key: 'ssang_bieup',
    char: 'ㅃ',
    nameKo: '쌍비읍',
    audio: '${_AUD_DIR}ssang_bieup.mp3',
  ),
  _ConsonantItem(
    key: 'nieun',
    char: 'ㄴ',
    nameKo: '니은',
    audio: '${_AUD_DIR}nieun.mp3',
  ),
  _ConsonantItem(
    key: 'rieul',
    char: 'ㄹ',
    nameKo: '리을',
    audio: '${_AUD_DIR}rieul.mp3',
  ),
  _ConsonantItem(
    key: 'mieum',
    char: 'ㅁ',
    nameKo: '미음',
    audio: '${_AUD_DIR}mieum.mp3',
  ),
  _ConsonantItem(
    key: 'ieung',
    char: 'ㅇ',
    nameKo: '이응',
    audio: '${_AUD_DIR}ieung.mp3',
  ),
  _ConsonantItem(
    key: 'chieut',
    char: 'ㅊ',
    nameKo: '치읓',
    audio: '${_AUD_DIR}chieut.mp3',
  ),
  _ConsonantItem(
    key: 'pieup',
    char: 'ㅍ',
    nameKo: '피읖',
    audio: '${_AUD_DIR}pieup.mp3',
  ),
  _ConsonantItem(
    key: 'hieut',
    char: 'ㅎ',
    nameKo: '히읗',
    audio: '${_AUD_DIR}hieut.mp3',
  ),
  _ConsonantItem(
    key: 'kieuk',
    char: 'ㅋ',
    nameKo: '키읔',
    audio: '${_AUD_DIR}kieuk.mp3',
  ),
  _ConsonantItem(
    key: 'tieut',
    char: 'ㅌ',
    nameKo: '티읕',
    audio: '${_AUD_DIR}tieut.mp3',
  ),
];

class WriteGameLevel2_1Page extends StatefulWidget {
  const WriteGameLevel2_1Page({
    super.key,
    required this.childId,
    this.resultId, // 상위에서 이미 생성했으면 주입
  });

  final String childId;
  final String? resultId;

  static const routeName = '/write/game/2/1';

  @override
  State<WriteGameLevel2_1Page> createState() => _WriteGameLevel2_1PageState();
}

class _WriteGameLevel2_1PageState extends State<WriteGameLevel2_1Page> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  late List<_ConsonantItem> _problems; // 길이 4
  int _index = 0; // 현재 문제
  final List<bool> _results = [];

  _ConsonantItem get current => _problems[_index];

  // ▼ API 연동 상태
  String? _resultId; // 게임 세션 식별자
  bool _booting = true; // 초기화 중 표시용

  @override
  void initState() {
    super.initState();
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    try {
      // resultId 확보
      _resultId = widget.resultId;
      _resultId ??= await WriteGameApi.start(
        childId: widget.childId,
        stageCode: 'FR_WG_005', // 자음 스테이지 코드(백엔드 합의값)
      );

      // 문제 셔플
      _resetGame();
    } catch (e) {
      // 치명적 실패시 단순 팝
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류. 잠시 후 다시 시도하세요.')),
        );
        Navigator.of(context).pop();
      }
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
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
      if (mounted) setState(() {});
    });
  }

  /// Selvy 후보셋을 현재 자음 하나로 고정
  Future<void> _applyCandidate() async {
    try {
      await SelvyRecognizer.setCandidateSet([current.char]);
    } catch (_) {}
  }

  /// 소리 아이콘 탭 → 현재 문제 자음 오디오 재생 (플레이어는 프로젝트에 맞춰 교체)
  Future<void> _playPronounce() async {
    // 예: context.read<AudioService>().playAsset(current.audio);
    debugPrint('[2-1] play audio: ${current.audio}');
  }

  /// 인식 문자열 정규화(첫 줄만, [n] 제거, 호환 자모 통일)
  String _normalize(String raw) {
    final top =
        raw.split('\n').first.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();
    const map = {
      'ᄀ': 'ㄱ',
      'ᄁ': 'ㄲ',
      'ᄂ': 'ㄴ',
      'ᄃ': 'ㄷ',
      'ᄄ': 'ㄸ',
      'ᄅ': 'ㄹ',
      'ᄆ': 'ㅁ',
      'ᄇ': 'ㅂ',
      'ᄈ': 'ㅃ',
      'ᄉ': 'ㅅ',
      'ᄊ': 'ㅆ',
      'ᄋ': 'ㅇ',
      'ᄌ': 'ㅈ',
      'ᄍ': 'ㅉ',
      'ᄎ': 'ㅊ',
      'ᄏ': 'ㅋ',
      'ᄐ': 'ㅌ',
      'ᄑ': 'ㅍ',
      'ᄒ': 'ㅎ',
      'U+1100': 'ㄱ',
      'U+1101': 'ㄲ',
      'U+1102': 'ㄴ',
      'U+1103': 'ㄷ',
      'U+1104': 'ㄸ',
      'U+1105': 'ㄹ',
      'U+1106': 'ㅁ',
      'U+1107': 'ㅂ',
      'U+1108': 'ㅃ',
      'U+1109': 'ㅅ',
      'U+110A': 'ㅆ',
      'U+110B': 'ㅇ',
      'U+110C': 'ㅈ',
      'U+110D': 'ㅉ',
      'U+110E': 'ㅊ',
      'U+110F': 'ㅋ',
      'U+1110': 'ㅌ',
      'U+1111': 'ㅍ',
      'U+1112': 'ㅎ',
    };
    return map[top] ?? top;
  }

  Future<void> _sendChoice({
    required String shownChar,
    required bool isCorrect,
  }) async {
    if (_resultId == null) return; // 방어
    final questionId = WG.requireWgQuestionId(
      WG.consonantQuestionMap,
      shownChar,
      ctx: 'Stage2-1',
    );

    await WriteGameApi.sendChoice(
      resultId: _resultId!,
      questionId: questionId,
      childWrittenText: shownChar,
      isCorrect: isCorrect,
    );
  }

  Future<bool> _completeAndGetSuccess() async {
    if (_resultId == null) return false;
    final res = await WriteGameApi.complete(resultId: _resultId!);
    // 백엔드 응답 형식에 맞춰 success 필드 접근
    return res.success == true;
  }

  void _onRecognize(String recognized) async {
    final mine = _normalize(recognized);
    final isCorrect = mine == current.char;

    // 서버에 choice 먼저 기록
    await _sendChoice(shownChar: current.char, isCorrect: isCorrect);

    _results.add(isCorrect);
    if (!mounted) return;

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
    } else {
      // 끝 → 서버 기준으로 성공/실패 판단
      final serverSuccess = await _completeAndGetSuccess();
      if (!mounted) return;
      await _showEndSequence(serverSuccess: serverSuccess);
    }
  }

  /// 엔딩 시퀀스: 1) 인트로 → 2/3) 성공/실패
  Future<void> _showEndSequence({required bool serverSuccess}) async {
    // 1) 인트로
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FullImageDialog(imageAsset: _END_INTRO),
    );

    // 2) 3초 뒤 인트로 닫기
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // 인트로 닫기
    }

    // 3) 성공/실패 분기(서버 기준)
    if (serverSuccess) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder:
            (_) => _FullImageDialog(
              imageAsset: _END_SUCCESS,
              onTap: () => Navigator.of(context).pop(),
            ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // 성공 다이얼로그 닫기
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WriteGameMain2Page(childId: widget.childId),
          ),
        );
      });
    } else {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => _FullImageDialog(
              imageAsset: _END_FAIL,
              overlay: Positioned(
                right: 24,
                bottom: 28,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(); // 실패 닫기
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => WriteGameMain2Page(childId: widget.childId),
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
          '쓰기 게임 2-1 (자음 랜덤)',
          style: TextStyle(color: Colors.brown),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // 상단 안내 배너
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '이미지를 누르면 소리가 들려요! 잘 듣고 적어보세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5B4634),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 진행 인디케이터
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
                        color:
                            done
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

              // 본문
              Expanded(
                child: Row(
                  children: [
                    // 왼쪽: “소리” 아이콘(고정) + 말풍선
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
                                child: _SpeechHint(),
                              ),
                              Align(
                                alignment: const Alignment(0.6, -0.1),
                                child: GestureDetector(
                                  onTap: _playPronounce,
                                  child: Image.asset(
                                    '${_IMG_DIR}sound.png',
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

                    // 오른쪽: 빈 보드 + WritingCanvas
                    Expanded(
                      flex: 6,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final pad = (c.maxWidth * 0.94).clamp(
                            280.0,
                            c.maxHeight * 0.8,
                          );
                          final caption = (pad * 0.085).clamp(18.0, 28.0);
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: pad,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // 보드 배경
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
                                        // 실제 쓰기 캔버스
                                        SizedBox(
                                          width: pad * 0.98,
                                          height: pad * 0.98,
                                          child: WritingCanvas(
                                            key: _canvasKey,
                                            childId: widget.childId,
                                            targetChar: current.char,
                                            candidateSet: [current.char],
                                            targetType: "consonant",
                                            autoRecognizeOnEnd: false,
                                            onRecognize: _onRecognize,
                                            penWidth: 40,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: pad * 0.06,
                                          child: Text(
                                            '적고 다음 버튼을 눌러요!',
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
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed:
                                        () =>
                                            _canvasKey.currentState
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

/// 말풍선 위젯
class _SpeechHint extends StatelessWidget {
  const _SpeechHint({
    this.width = 300,
    this.height = 62,
    this.fontSize = 22,
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
    // 본체
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 10),
      const Radius.circular(12),
    );
    final paint = Paint()..color = const Color(0xFFF2E2CF);
    canvas.drawRRect(r, paint);

    // 꼬리
    final double tailBaseX = 40;
    final double tailTopY = size.height - 10;
    final path =
        Path()
          ..moveTo(tailBaseX, tailTopY)
          ..relativeLineTo(14, 10)
          ..relativeLineTo(6, -10)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 전체 화면 이미지를 꽉 채워 보여주는 다이얼로그
class _FullImageDialog extends StatelessWidget {
  const _FullImageDialog({required this.imageAsset, this.overlay, this.onTap});

  final String imageAsset;
  final Widget? overlay; // 추가 버튼/위젯(실패 화면의 "다시하기")
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
