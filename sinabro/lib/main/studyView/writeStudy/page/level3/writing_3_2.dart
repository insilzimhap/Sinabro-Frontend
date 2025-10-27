// lib/main/studyView/writeStudy/page/writing_3_2.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart'; // AppleGarden(childId: ...)
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';

import 'package:http/http.dart' as http; // ⭐️ 1. http 패키지
import 'dart:convert'; // ⭐️ 2. json 변환용
import 'package:sinabro/config.dart'; // ⭐️ 3. baseUrl 사용
import 'package:audioplayers/audioplayers.dart'; // 오디오 패키지 import

// 루트에서 등록한 나무 화면 라우트 이름(프로젝트에 맞게)
const String kMainAppleTreeRoute = '/apple_garden';

/// 항상 나무 화면으로 복귀
void _goToGarden(BuildContext context, String childId) {
  final nav = Navigator.of(context, rootNavigator: true);
  try {
    nav.pushNamedAndRemoveUntil(
      kMainAppleTreeRoute,
      (_) => false,
      arguments: {'childId': childId},
    );
  } catch (_) {
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AppleGarden(childId: childId)),
      (route) => false,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 라우트 문자열 → 페이지 위젯( childId, fruitId, startTime 포함 ) 매퍼 (⭐️ 수정됨)
// ──────────────────────────────────────────────────────────────────────────────
Widget? _routeFallbackWithChild(
  String name,
  String childId,
  String? fruitId,
  DateTime? startTime,
) {
  final safeFruitId = fruitId ?? 'unknown_fruit_3_2'; // 기본값 또는 에러 처리 필요
  final safeStartTime =
      startTime ?? DateTime.now(); // Intro 페이지 경우 startTime null 가능

  switch (name) {
    case Writing3_2_IntroPage.routeName:
      return Writing3_2_IntroPage(childId: childId, fruitId: safeFruitId);
    case Writing3_2_1Page.routeName: // 첫 페이지는 startTime 필요 없음
      return Writing3_2_1Page(childId: childId, fruitId: safeFruitId);
    case Writing3_2_2Page.routeName:
      return Writing3_2_2Page(
          childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_2_3Page.routeName:
      return Writing3_2_3Page(
          childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_2_4Page.routeName:
      return Writing3_2_4Page(
          childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_2_5Page.routeName:
      return Writing3_2_5Page(
          childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_2_6Page.routeName: // 마지막 페이지
      return Writing3_2_6Page(
          childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_2_DonePage.routeName:
      return Writing3_2_DonePage(childId: childId);
    default:
      debugPrint('Fallback route not found for: $name');
      return null;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 공용 이동 유틸: 네임드 라우트 시도 → 실패하면 fallback 위젯으로 이동 (⭐️ 수정됨)
// ──────────────────────────────────────────────────────────────────────────────
void _pushNamedOrFallback(
  BuildContext context,
  String routeName, {
  Object? arguments,
  Widget? fallback,
}) {
  final nav = Navigator.of(context, rootNavigator: true);
  try {
    nav.pushNamed(routeName, arguments: arguments);
  } catch (e) {
    debugPrint('pushNamed failed for $routeName: $e. Trying fallback...');
    if (fallback != null) {
      nav.push(MaterialPageRoute(builder: (_) => fallback));
    } else {
      final argsMap = arguments as Map<String, dynamic>?;
      final childId = argsMap?['childId'] as String? ?? 'unknown_child';
      final fruitId = argsMap?['fruitId'] as String?;
      final startTime = argsMap?['startTime'] as DateTime?;
      final fallbackWidget =
          _routeFallbackWithChild(routeName, childId, fruitId, startTime);

      if (fallbackWidget != null) {
        nav.push(MaterialPageRoute(builder: (_) => fallbackWidget));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fallback Route not found: $routeName')),
        );
      }
    }
  }
}

void _replaceNamedOrFallback(
  BuildContext context,
  String routeName, {
  Object? arguments,
  Widget? fallback,
}) {
  final nav = Navigator.of(context, rootNavigator: true);
  try {
    nav.pushReplacementNamed(routeName, arguments: arguments);
  } catch (e) {
    debugPrint(
        'pushReplacementNamed failed for $routeName: $e. Trying fallback...');
    if (fallback != null) {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => fallback));
    } else {
      final argsMap = arguments as Map<String, dynamic>?;
      final childId = argsMap?['childId'] as String? ?? 'unknown_child';
      final fruitId = argsMap?['fruitId'] as String?;
      final startTime = argsMap?['startTime'] as DateTime?;
      final fallbackWidget =
          _routeFallbackWithChild(routeName, childId, fruitId, startTime);

      if (fallbackWidget != null) {
        nav.pushReplacement(MaterialPageRoute(builder: (_) => fallbackWidget));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fallback Route not found: $routeName')),
        );
      }
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 오디오 정의
// ──────────────────────────────────────────────────────────────────────────────
const _audioDir = 'audio/tts/studyWrite/level3/';
const _audioIntro2 =
    '${_audioDir}write5_study_intro_2.mp3'; // ✅ 2단계 인트로 (달콤한 카드)
const _audioFinish2 = '${_audioDir}write5_study_finish_2.mp3'; // ✅ 2단계 완료

// ✅ 과일 단어 오디오 파일명 헬퍼
String _getFruitWordAudio(String wordKey) {
  // wordKey 예시: 'apple', 'banana', ...
  return '${_audioDir}fruit_$wordKey.mp3';
}

// ──────────────────────────────────────────────────────────────────────────────
// 인트로 화면 (⭐️ 수정됨: fruitId 받고 넘기기, 오디오 추가)
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_2_IntroPage extends StatefulWidget {
  const Writing3_2_IntroPage({
    super.key,
    required this.childId,
    required this.fruitId, // ⭐️ 받기
  });
  static const routeName = '/study/write/writing_3_2_intro';
  final String childId;
  final String fruitId; // ⭐️ 필드 추가

  @override
  State<Writing3_2_IntroPage> createState() => _Writing3_2_IntroPageState();
}

class _Writing3_2_IntroPageState extends State<Writing3_2_IntroPage> {
  static const _cardMixed = 'assets/img/contents/studyWrite/card_mixed.png';

  // 오디오 플레이어
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 오디오 재생 헬퍼 함수
  void _playAudio(String assetPath) {
    if (!mounted) return;
    _audioPlayer.stop();
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    _audioPlayer.play(AssetSource(assetPath));
  }

  @override
  void initState() {
    super.initState();

    // 인트로 오디오 자동 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio(_audioIntro2); // 2단계 인트로 재생
    });

    Future<void>(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      // ⭐️ fallback 호출 시에도 fruitId 전달하도록 수정
      _replaceNamedOrFallback(
        context,
        Writing3_2_1Page.routeName,
        arguments: {
          'childId': widget.childId,
          'fruitId': widget.fruitId
        }, // ⭐️ fruitId 넘기기
        fallback: Writing3_2_1Page(
            childId: widget.childId,
            fruitId: widget.fruitId), // ⭐️ fallback에도 넘기기
      );
    });
  }

  // 오디오 리소스 해제
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        _goToGarden(context, widget.childId);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFEF5F6),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final imgW = (w * 0.45).clamp(260.0, 560.0);
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            _cardMixed,
                            width: imgW,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                          const SizedBox(height: 24),
                          // ✅ 텍스트 수정 (2단계 과일)
                          Text(
                            '달콤한 카드가 뒤섞여버렸어요...',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6B4F4F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '그림은 어떤 카드인지 적어주세요!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6B4F4F),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  onPressed: () => _goToGarden(context, widget.childId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 재사용 카드 위젯 (⭐️ 수정됨: fruitId, startTime, isFirstPage, isLastPage 추가 + API 호출 로직 + 오디오 추가)
// ──────────────────────────────────────────────────────────────────────────────
class _WritingItemPage extends StatefulWidget {
  const _WritingItemPage({
    super.key,
    required this.childId,
    required this.fruitId, // ⭐️ 추가!
    this.startTime, // ⭐️ 추가! (첫 페이지 제외하고 받음)
    this.isFirstPage = false, // ⭐️ 추가!
    this.isLastPage = false, // ⭐️ 추가!
    required this.illustPath,
    required this.previewPath,
    required this.tracePath,
    required this.nextRouteName,
    required this.columns,
    required this.expectedWord, // 예: '사과'
    required this.acceptedWords, // 예: ['사과','사괴',...]
    required this.wordAudioKey, // 단어 오디오 키
    this.prevRouteName = '/study/write/entry',
    this.titleColor = const Color(0xFFFEF5F6),
  });

  final String childId;
  final String fruitId; // ⭐️ 추가!
  final DateTime? startTime; // ⭐️ 추가!
  final bool isFirstPage; // ⭐️ 추가!
  final bool isLastPage; // ⭐️ 추가!
  final String illustPath;
  final String previewPath;
  final String tracePath;
  final String nextRouteName;
  final int columns;
  final String prevRouteName;
  final Color titleColor;
  final String expectedWord;
  final List<String> acceptedWords;
  final String wordAudioKey; // 필드 추가

  @override
  State<_WritingItemPage> createState() => _WritingItemPageState();
}

class _WritingItemPageState extends State<_WritingItemPage> {
  final _canvasKey = GlobalKey<WritingCanvasState>();
  late DateTime _startTime; // ⭐️ API용 시작 시간 기록
  bool _apiCallSent = false; // ⭐️ API 중복 호출 방지

  // 오디오 플레이어
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 오디오 재생 헬퍼 함수
  void _playAudio(String assetPath) {
    if (!mounted) return;
    _audioPlayer.stop();
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    _audioPlayer.play(AssetSource(assetPath));
  }

  @override
  void initState() {
    super.initState();
    // ⭐️ 첫 페이지면 지금 시간 기록, 아니면 전달받은 시간 사용
    _startTime = widget.isFirstPage ? DateTime.now() : widget.startTime!;

    // 단어 오디오 자동 재생 (첫 페이지 + 이후 페이지 모두)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio(_getFruitWordAudio(widget.wordAudioKey));
    });
  }

  // 오디오 리소스 해제 추가
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// ⭐️ (신규) 학습 완료 API 호출 함수 - JWT 없이
  Future<void> _uploadStudyResult() async {
    final timeSpentSecs = DateTime.now().difference(_startTime).inSeconds;
    final url = Uri.parse('$baseUrl/api/study/writing/complete');
    final body = json.encode({
      'childId': widget.childId,
      'fruitId': widget.fruitId,
      'isCompleted': true,
      'timeSpentSecs': timeSpentSecs,
    });
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[Writing3_2] API 연동 성공: fruitId ${widget.fruitId} 완료!');
      } else {
        debugPrint(
            '[Writing3_2] API 연동 실패: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('[Writing3_2] API 연동 중 예외 발생: $e');
    }
  }

  /// 정답 판별 함수
  bool _isCorrect(String raw) {
    final top1Line = raw.split('\n').first;
    final buffer = StringBuffer();
    for (final rune in top1Line.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[가-힣]').hasMatch(ch)) {
        buffer.write(ch);
      }
    }
    final cleaned = buffer.toString().trim();
    debugPrint("✅ 정제된 top1 = $cleaned");
    return widget.acceptedWords.contains(cleaned);
  }

  /// ⭐️ (수정됨) 다음 페이지 이동 + 마지막 페이지면 API 호출!
  void _goNext(BuildContext context) {
    if (widget.isLastPage && !_apiCallSent) {
      _apiCallSent = true;
      _uploadStudyResult(); // API 호출!
    }

    _replaceNamedOrFallback(
      // 페이지 교체 사용 (뒤로가기 막기)
      context,
      widget.nextRouteName,
      // arguments에 startTime도 포함해서 전달
      arguments: {
        'childId': widget.childId,
        'fruitId': widget.fruitId,
        'startTime': _startTime
      },
      // fallback 호출 시에도 모든 파라미터 전달!
      fallback: _routeFallbackWithChild(
        widget.nextRouteName,
        widget.childId,
        widget.fruitId,
        _startTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cols = widget.columns.clamp(2, 3);

    return WillPopScope(
      onWillPop: () async {
        _goToGarden(context, widget.childId);
        return false;
      },
      child: Scaffold(
        backgroundColor: widget.titleColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 48),
                  Expanded(
                    child: Center(
                      // 일러스트 이미지 탭 -> 단어 오디오 재생
                      child: GestureDetector(
                        onTap: () =>
                            _playAudio(_getFruitWordAudio(widget.wordAudioKey)),
                        child: Image.asset(
                          widget.illustPath,
                          width: 260,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // 왼쪽: 프리뷰
                        Expanded(
                          child: _TileStrip(
                            columns: cols,
                            child: Image.asset(
                              widget.previewPath,
                              height: 150,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 오른쪽: 트레이스 + 쓰기 + 채점
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TileStrip(
                                columns: cols,
                                child: LayoutBuilder(
                                  builder: (context, cons) {
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // 밑: 트레이스 이미지
                                        Center(
                                          child: Image.asset(
                                            widget.tracePath,
                                            height: 150,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.high,
                                          ),
                                        ),
                                        // 위: 쓰기 캔버스
                                        Positioned.fill(
                                          child: WritingCanvas(
                                            // ✅ GestureDetector 불필요 (캔버스 자체가 터치됨)
                                            key: _canvasKey,
                                            penWidth: 15,
                                            targetChar: widget.expectedWord,
                                            candidateSet: widget.acceptedWords,
                                            targetType: "word",
                                            autoRecognizeOnEnd: false, // 수동 채점
                                            // ⭐️ onRecognize 콜백 수정!
                                            onRecognize: (result) async {
                                              if (_isCorrect(result)) {
                                                // ✅ 정답이면 _goNext 호출!
                                                _goNext(context);
                                              } else {
                                                // ❌ 오답 처리
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('다시 써볼까요?'),
                                                      duration: Duration(
                                                        milliseconds: 800,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                await _canvasKey.currentState
                                                    ?.clearCanvas();
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 채점 버튼 (수동 인식 트리거)
                              SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _canvasKey.currentState
                                        ?.recognizeAndCheckText();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD9CCFF),
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    '채점하기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 좌상단: 뒤로 → 항상 나무로
              Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  onPressed: () => _goToGarden(context, widget.childId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _TileStrip, _GridSplitPainter (기존과 동일)
// ──────────────────────────────────────────────────────────────────────────────
class _TileStrip extends StatelessWidget {
  const _TileStrip({required this.child, this.columns = 3});
  final Widget child;
  final int columns;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE1E1E1);
    final cols = columns.clamp(2, 3);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullW = constraints.maxWidth;
        final targetW = fullW * (cols / 3.0);
        final targetH = fullW / 3.6;

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: targetW,
            height: targetH,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    color: Color(0x1A000000),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _GridSplitPainter(
                      color: borderColor,
                      columns: cols,
                    ),
                  ),
                  Center(child: child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridSplitPainter extends CustomPainter {
  const _GridSplitPainter({required this.color, required this.columns});
  final Color color;
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    if (columns <= 1) return;
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    final cellW = size.width / columns;
    for (int i = 1; i < columns; i++) {
      final x = cellW * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// 실제 페이지들 정의 (⭐️ 생성자 수정 완료, ✅ 오디오 키 추가)
// ──────────────────────────────────────────────────────────────────────────────

// 사과 (3-2-1)
class Writing3_2_1Page extends StatelessWidget {
  const Writing3_2_1Page({
    super.key,
    required this.childId,
    required this.fruitId, // ⭐️ 받기
  });
  static const routeName = '/study/write/writing_3_2_1';
  final String childId;
  final String fruitId; // ⭐️ 필드 추가

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;

    return _WritingItemPage(
      childId: id,
      fruitId: fId, // ⭐️ 넘기기
      isFirstPage: true, // ⭐️ 첫 페이지임을 표시
      illustPath: 'assets/img/contents/studyWrite/apple1.png',
      previewPath: 'assets/img/contents/studyWrite/apple_preview.png',
      tracePath: 'assets/img/contents/studyWrite/apple_trace.png',
      nextRouteName: Writing3_2_2Page.routeName,
      columns: 2,
      expectedWord: '사과',
      acceptedWords: const ['사과', '사가', '샤과', '사괘'],
      wordAudioKey: 'apple', // ✅ 단어 오디오 키 추가
    );
  }
}

// 바나나 (3-2-2)
class Writing3_2_2Page extends StatelessWidget {
  const Writing3_2_2Page({
    super.key,
    required this.childId,
    required this.fruitId, // ⭐️ 받기
    required this.startTime, // ⭐️ 받기
  });
  static const routeName = '/study/write/writing_3_2_2';
  final String childId;
  final String fruitId; // ⭐️ 필드 추가
  final DateTime startTime; // ⭐️ 필드 추가

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId, // ⭐️ 넘기기
      startTime: start, // ⭐️ 넘기기
      illustPath: 'assets/img/contents/studyWrite/banana1.png',
      previewPath: 'assets/img/contents/studyWrite/banana_preview.png',
      tracePath: 'assets/img/contents/studyWrite/banana_trace.png',
      nextRouteName: Writing3_2_3Page.routeName,
      columns: 3,
      expectedWord: '바나나',
      acceptedWords: const ['바나나'],
      wordAudioKey: 'banana', // ✅ 단어 오디오 키 추가
    );
  }
}

// 딸기 (3-2-3)
class Writing3_2_3Page extends StatelessWidget {
  const Writing3_2_3Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_2_3';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      illustPath: 'assets/img/contents/studyWrite/strawberry.png',
      previewPath: 'assets/img/contents/studyWrite/strawberry_preview.png',
      tracePath: 'assets/img/contents/studyWrite/strawberry_trace.png',
      nextRouteName: Writing3_2_4Page.routeName,
      columns: 2,
      expectedWord: '딸기',
      acceptedWords: const ['딸기', '딸긔', '딸귀'],
      wordAudioKey: 'strawberry', // ✅ 단어 오디오 키 추가
    );
  }
}

// 포도 (3-2-4)
class Writing3_2_4Page extends StatelessWidget {
  const Writing3_2_4Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_2_4';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      illustPath: 'assets/img/contents/studyWrite/grape.png',
      previewPath: 'assets/img/contents/studyWrite/grape_preview.png',
      tracePath: 'assets/img/contents/studyWrite/grape_trace.png',
      nextRouteName: Writing3_2_5Page.routeName,
      columns: 2,
      expectedWord: '포도',
      acceptedWords: const ['포도', '보도'],
      wordAudioKey: 'grape', // ✅ 단어 오디오 키 추가
    );
  }
}

// 수박 (3-2-5)
class Writing3_2_5Page extends StatelessWidget {
  const Writing3_2_5Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_2_5';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      illustPath: 'assets/img/contents/studyWrite/watermelon.png',
      previewPath: 'assets/img/contents/studyWrite/watermelon_preview.png',
      tracePath: 'assets/img/contents/studyWrite/watermelon_trace.png',
      nextRouteName: Writing3_2_6Page.routeName,
      columns: 2,
      expectedWord: '수박',
      acceptedWords: const ['수박', '슈박'],
      wordAudioKey: 'watermelon', // ✅ 단어 오디오 키 추가
    );
  }
}

// 복숭아 (3-2-6) - 마지막!
class Writing3_2_6Page extends StatelessWidget {
  const Writing3_2_6Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_2_6';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      isLastPage: true, // ⭐️ 마지막 페이지임을 표시!
      illustPath: 'assets/img/contents/studyWrite/peach.png',
      previewPath: 'assets/img/contents/studyWrite/peach_preview.png',
      tracePath: 'assets/img/contents/studyWrite/peach_trace.png',
      nextRouteName: Writing3_2_DonePage.routeName, // 다음은 완료 페이지
      columns: 3,
      expectedWord: '복숭아',
      acceptedWords: const ['복숭아', '복숭와', '복숭ㅇ'],
      wordAudioKey: 'peach', // ✅ 단어 오디오 키 추가
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 완료 화면 (⭐️ API 호출 없음, UI만 표시 후 나무로 복귀, ✅ 오디오 추가)
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_2_DonePage extends StatefulWidget {
  const Writing3_2_DonePage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_2_done';
  final String childId;

  @override
  State<Writing3_2_DonePage> createState() => _Writing3_2_DonePageState();
}

class _Writing3_2_DonePageState extends State<Writing3_2_DonePage> {
  static const _clapPath = 'assets/img/contents/studyWrite/clap.png';

  // ✅ 오디오 플레이어 추가
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ✅ 오디오 재생 헬퍼 함수 추가
  void _playAudio(String assetPath) {
    if (!mounted) return;
    _audioPlayer.stop();
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    _audioPlayer.play(AssetSource(assetPath));
  }

  @override
  void initState() {
    super.initState();

    // ✅ 단계 완료 오디오 자동 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio(_audioFinish2); // 2단계 완료 오디오 재생
    });

    Future<void>(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          Future.delayed(const Duration(seconds: 3), () {
            if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
          });
          return const _AppleRewardDialog(); // 리워드 팝업
        },
      );

      if (!mounted) return;
      _goToGarden(context, widget.childId); // 나무로 복귀
    });
  }

  // ✅ 오디오 리소스 해제 추가
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFEF5F6),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                _clapPath,
                width: 160,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 24),
              Text(
                '쓰기 2단계(과일)도 전부 학습했어요!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6B4F4F),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 리워드 팝업 (기존과 동일)
class _AppleRewardDialog extends StatelessWidget {
  const _AppleRewardDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🍎', style: TextStyle(fontSize: 56)),
            SizedBox(height: 12),
            Text(
              '이번 나무의 사과를 획득했어요!\n잠시 후 나무로 돌아가요~',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF5B534A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} // End of file
