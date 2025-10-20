// lib/main/studyView/writeGame/page/level2/write_game_2_1.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

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
  const WriteGameLevel2_1Page({super.key, required this.childId});
  final String childId;

  static const routeName = '/write/game/2/1';

  @override
  State<WriteGameLevel2_1Page> createState() => _WriteGameLevel2_1PageState();
}

class _WriteGameLevel2_1PageState extends State<WriteGameLevel2_1Page> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  // 리셋을 위해 final 제거
  late List<_ConsonantItem> _problems; // 길이 4
  int _index = 0; // 현재 문제
  final List<bool> _results = [];

  _ConsonantItem get current => _problems[_index];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    final rnd = Random();
    _problems = [..._POOL]..shuffle(rnd);
    _problems = _problems.take(4).toList();
    _index = 0;
    _results.clear();
    // 캔버스 비우고 후보셋 반영
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
      setState(() {});
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

  void _onRecognize(String recognized) async {
    final mine = _normalize(recognized);
    final isCorrect = mine == current.char;

    _results.add(isCorrect);
    if (!mounted) return;

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
    } else {
      // 끝! → 엔딩 시퀀스
      final correct = _results.where((e) => e).length;
      if (!mounted) return;
      await _showEndSequence(correct);
    }
  }

  /// 엔딩 시퀀스: 1) 인트로 → 2/3) 성공/실패
  Future<void> _showEndSequence(int correctCount) async {
    // 1) 인트로: 기다리지 말고 띄우기
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FullImageDialog(imageAsset: _END_INTRO),
    );

    // 2) 2.5초 뒤 인트로 닫기
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // 인트로 다이얼로그 닫기
    }

    // 3) 성공/실패 분기
    final success = correctCount >= 3;

    if (success) {
      // 성공 화면: 탭하면 닫히지만, 3초 뒤엔 자동으로 메인으로 이동
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder:
            (_) => _FullImageDialog(
              imageAsset: _END_SUCCESS,
              onTap: () => Navigator.of(context).pop(),
            ),
      );

      // 3초 뒤 자동 이동
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
      // 실패 화면: "다시하기" 버튼으로 리셋
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
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pop(); // 실패 다이얼로그 닫기
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
                                alignment: const Alignment(
                                  0.6,
                                  -0.1,
                                ), // (x,y) -1~1
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

/// 말풍선 위젯(사이즈/글자크기 조절 가능)
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
      Rect.fromLTWH(0, 0, size.width, size.height - 10), // 하단 10px은 꼬리 공간
      const Radius.circular(12),
    );
    final paint = Paint()..color = const Color(0xFFF2E2CF);
    canvas.drawRRect(r, paint);

    // 꼬리 (왼쪽 하단 기준)
    final double tailBaseX = 40; // 꼬리 시작 x (위치 조절 지점)
    final double tailTopY = size.height - 10;
    final path =
        Path()
          ..moveTo(tailBaseX, tailTopY)
          ..relativeLineTo(14, 10) // 오른쪽 아래로
          ..relativeLineTo(6, -10) // 다시 위로
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 전체 화면 이미지를 꽉 채워 보여주는 다이얼로그
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
                width: w, // 화면의 85% 너비만 사용
                height: h, // 화면의 85% 높이만 사용
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain, // 비율 유지, 잘림 없음
                ),
              ),
            ),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}
