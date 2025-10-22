// lib/main/studyView/writeStudy/page/writing_3_4.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';

import 'package:http/http.dart' as http; // http 패키지
import 'dart:convert';                   // json 변환용
import 'package:sinabro/config.dart';    // baseUrl 사용

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
  final safeFruitId = fruitId ?? 'unknown_fruit_3_4'; // 기본값 설정
  final safeStartTime = startTime ?? DateTime.now(); // Intro 페이지 경우 startTime null 가능

  switch (name) {
    case Writing3_4_IntroPage.routeName:
      return Writing3_4_IntroPage(childId: childId, fruitId: safeFruitId);
    case Writing3_4_1Page.routeName: // 첫 페이지는 startTime 필요 없음
      return Writing3_4_1Page(childId: childId, fruitId: safeFruitId);
    case Writing3_4_2Page.routeName:
      return Writing3_4_2Page(childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_4_3Page.routeName:
      return Writing3_4_3Page(childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_4_4Page.routeName:
      return Writing3_4_4Page(childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_4_5Page.routeName:
      return Writing3_4_5Page(childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_4_6Page.routeName: // 마지막 페이지
      return Writing3_4_6Page(childId: childId, fruitId: safeFruitId, startTime: safeStartTime);
    case Writing3_4_DonePage.routeName:
      return Writing3_4_DonePage(childId: childId);
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
      final fallbackWidget = _routeFallbackWithChild(routeName, childId, fruitId, startTime);

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
    debugPrint('pushReplacementNamed failed for $routeName: $e. Trying fallback...');
    if (fallback != null) {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => fallback));
    } else {
      final argsMap = arguments as Map<String, dynamic>?;
      final childId = argsMap?['childId'] as String? ?? 'unknown_child';
      final fruitId = argsMap?['fruitId'] as String?;
      final startTime = argsMap?['startTime'] as DateTime?;
      final fallbackWidget = _routeFallbackWithChild(routeName, childId, fruitId, startTime);

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
// 인트로 화면 (⭐️ 수정됨: fruitId 받고 넘기기)
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_4_IntroPage extends StatefulWidget {
  const Writing3_4_IntroPage({
    super.key,
    required this.childId,
    required this.fruitId, // ⭐️ 받기
  });
  static const routeName = '/study/write/writing_3_4_intro';
  final String childId;
  final String fruitId; // ⭐️ 필드 추가

  @override
  State<Writing3_4_IntroPage> createState() => _Writing3_4_IntroPageState();
}

class _Writing3_4_IntroPageState extends State<Writing3_4_IntroPage> {
  static const _cardMixed = 'assets/img/contents/studyWrite/card_mixed.png';

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      // ⭐️ fallback 호출 시에도 fruitId 전달하도록 수정
      _replaceNamedOrFallback( // Intro -> Page1은 pushNamed 대신 replaceNamed 사용 가능
        context,
        Writing3_4_1Page.routeName,
        arguments: {'childId': widget.childId, 'fruitId': widget.fruitId}, // ⭐️ fruitId 넘기기
        fallback: Writing3_4_1Page(childId: widget.childId, fruitId: widget.fruitId), // ⭐️ fallback에도 넘기기
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI 코드는 수정 없음
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFEF5F6),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final imgW = (w * 0.45).clamp(220.0, 380.0);
                  return Center(
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
                        Text(
                          '으라차차 카드가 뒤섞여버렸어요...',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF6B4F4F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '그림은 어떤 카드인지 적어주세요!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B4F4F),
                          ),
                          textAlign: TextAlign.center,
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
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 재사용 카드 위젯 (⭐️ 수정됨: fruitId, startTime, isFirstPage, isLastPage 추가 + API 호출 로직)
// ──────────────────────────────────────────────────────────────────────────────
class _WritingItemPage extends StatefulWidget {
  const _WritingItemPage({
    super.key,
    required this.childId,
    required this.fruitId,       // ⭐️ 추가!
    this.startTime,       // ⭐️ 추가! (첫 페이지 제외하고 받음)
    this.isFirstPage = false, // ⭐️ 추가!
    this.isLastPage = false,  // ⭐️ 추가!
    required this.illustPath,
    required this.previewPath,
    required this.tracePath,
    required this.nextRouteName,
    required this.columns,
    required this.expectedWord,
    required this.acceptedWords,
    this.titleColor = const Color(0xFFFEF5F6),
  });

  final String childId;
  final String fruitId;      // ⭐️ 추가!
  final DateTime? startTime; // ⭐️ 추가!
  final bool isFirstPage;    // ⭐️ 추가!
  final bool isLastPage;     // ⭐️ 추가!
  final String illustPath;
  final String previewPath;
  final String tracePath;
  final String nextRouteName;
  final int columns;
  final String expectedWord;
  final List<String> acceptedWords;
  final Color titleColor;

  @override
  State<_WritingItemPage> createState() => _WritingItemPageState();
}

class _WritingItemPageState extends State<_WritingItemPage> {
  final _canvasKey = GlobalKey<WritingCanvasState>();
  late DateTime _startTime; // ⭐️ API용 시작 시간 기록
  bool _apiCallSent = false; // ⭐️ API 중복 호출 방지

  @override
  void initState() {
    super.initState();
    _startTime = widget.isFirstPage ? DateTime.now() : widget.startTime!;
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
        debugPrint('[Writing3_4] API 연동 성공: fruitId ${widget.fruitId} 완료!');
      } else {
        debugPrint('[Writing3_4] API 연동 실패: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('[Writing3_4] API 연동 중 예외 발생: $e');
    }
  }

  /// 정답 판별 함수
  bool _isCorrect(String raw) {
    final top1Line = raw.split('\n').first;
    final buffer = StringBuffer();
    for (final rune in top1Line.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[가-힣]').hasMatch(ch)) buffer.write(ch);
    }
    final cleaned = buffer.toString().trim();
    debugPrint('✅ 정제된 top1 = $cleaned');
    return widget.acceptedWords.contains(cleaned);
  }

  /// ⭐️ (수정됨) 다음 페이지 이동 + 마지막 페이지면 API 호출!
  void _goNext(BuildContext context) {
    if (widget.isLastPage && !_apiCallSent) {
      _apiCallSent = true;
      _uploadStudyResult(); // API 호출!
    }

    // 다음 페이지로 교체하며 이동 (뒤로가기 방지)
    _replaceNamedOrFallback(
      context,
      widget.nextRouteName,
      // arguments에 startTime도 포함해서 전달
      arguments: {'childId': widget.childId, 'fruitId': widget.fruitId, 'startTime': _startTime},
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
    final cols = widget.columns.clamp(1, 3);

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
                      child: Image.asset(
                        widget.illustPath,
                        width: 260,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 프리뷰
                        Expanded(
                          child: _TileStrip(
                            columns: cols,
                            child: Image.asset(
                              widget.previewPath,
                              height: 120,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 트레이스 + 쓰기 + 채점
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                            height: 120,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.high,
                                          ),
                                        ),
                                        // 위: 쓰기 캔버스
                                        Positioned.fill(
                                          child: WritingCanvas(
                                            key: _canvasKey,
                                            penWidth: 15,
                                            targetChar: widget.expectedWord,
                                            candidateSet: widget.acceptedWords,
                                            targetType: 'word',
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
              // 뒤로 → 항상 나무로
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
// _TileStrip, _GridSplitPainter
// ──────────────────────────────────────────────────────────────────────────────
class _TileStrip extends StatelessWidget {
  const _TileStrip({required this.child, this.columns = 3});
  final Widget child;
  final int columns;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE1E1E1);
    final cols = columns.clamp(1, 3);

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
    final p =
        Paint()
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
// 실제 페이지들 정의 (⭐️ 생성자 수정 완료)
// ──────────────────────────────────────────────────────────────────────────────

// 눈 (3-4-1)
class Writing3_4_1Page extends StatelessWidget {
  const Writing3_4_1Page({
    super.key,
    required this.childId,
    required this.fruitId, // ⭐️ 받기
  });
  static const routeName = '/study/write/writing_3_4_1';
  final String childId;
  final String fruitId; // ⭐️ 필드 추가

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,     // ⭐️ 넘기기
      isFirstPage: true, // ⭐️ 첫 페이지임을 표시
      illustPath: 'assets/img/contents/studyWrite/eye.png',
      previewPath: 'assets/img/contents/studyWrite/eye_preview.png',
      tracePath: 'assets/img/contents/studyWrite/eye_trace.png',
      nextRouteName: Writing3_4_2Page.routeName,
      columns: 1,
      expectedWord: '눈',
      acceptedWords: const ['눈', '뉸'],
    );
  }
}

// 코 (3-4-2)
class Writing3_4_2Page extends StatelessWidget {
  const Writing3_4_2Page({
    super.key,
    required this.childId,
    required this.fruitId,   // ⭐️ 받기
    required this.startTime, // ⭐️ 받기
  });
  static const routeName = '/study/write/writing_3_4_2';
  final String childId;
  final String fruitId;   // ⭐️ 필드 추가
  final DateTime startTime; // ⭐️ 필드 추가

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,     // ⭐️ 넘기기
      startTime: start, // ⭐️ 넘기기
      illustPath: 'assets/img/contents/studyWrite/nose.png',
      previewPath: 'assets/img/contents/studyWrite/nose_preview.png',
      tracePath: 'assets/img/contents/studyWrite/nose_trace.png',
      nextRouteName: Writing3_4_3Page.routeName,
      columns: 1,
      expectedWord: '코',
      acceptedWords: const ['코', '꼬'],
    );
  }
}

// 입 (3-4-3)
class Writing3_4_3Page extends StatelessWidget {
  const Writing3_4_3Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_4_3';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      illustPath: 'assets/img/contents/studyWrite/mouth.png',
      previewPath: 'assets/img/contents/studyWrite/mouth_preview.png',
      tracePath: 'assets/img/contents/studyWrite/mouth_trace.png',
      nextRouteName: Writing3_4_4Page.routeName,
      columns: 1,
      expectedWord: '입',
      acceptedWords: const ['입', '잎'],
    );
  }
}

// 귀 (3-4-4)
class Writing3_4_4Page extends StatelessWidget {
  const Writing3_4_4Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_4_4';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      illustPath: 'assets/img/contents/studyWrite/ear.png',
      previewPath: 'assets/img/contents/studyWrite/ear_preview.png',
      tracePath: 'assets/img/contents/studyWrite/ear_trace.png',
      nextRouteName: Writing3_4_5Page.routeName,
      columns: 1,
      expectedWord: '귀',
      acceptedWords: const ['귀', '뀌'],
    );
  }
}

// 손 (3-4-5)
class Writing3_4_5Page extends StatelessWidget {
  const Writing3_4_5Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_4_5';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      illustPath: 'assets/img/contents/studyWrite/hand.png',
      previewPath: 'assets/img/contents/studyWrite/hand_preview.png',
      tracePath: 'assets/img/contents/studyWrite/hand_trace.png',
      nextRouteName: Writing3_4_6Page.routeName,
      columns: 1,
      expectedWord: '손',
      acceptedWords: const ['손', '쏜'],
    );
  }
}

// 발 (3-4-6) - 마지막!
class Writing3_4_6Page extends StatelessWidget {
  const Writing3_4_6Page({
    super.key,
    required this.childId,
    required this.fruitId,
    required this.startTime,
  });
  static const routeName = '/study/write/writing_3_4_6';
  final String childId;
  final String fruitId;
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = arguments?['childId'] as String? ?? childId;
    final fId = arguments?['fruitId'] as String? ?? fruitId;
    final start = arguments?['startTime'] as DateTime? ?? startTime;

    return _WritingItemPage(
      childId: id,
      fruitId: fId,
      startTime: start,
      isLastPage: true, // ⭐️ 마지막 페이지임을 표시!
      illustPath: 'assets/img/contents/studyWrite/foot.png',
      previewPath: 'assets/img/contents/studyWrite/foot_preview.png',
      tracePath: 'assets/img/contents/studyWrite/foot_trace.png',
      nextRouteName: Writing3_4_DonePage.routeName, // 다음은 완료 페이지
      columns: 1,
      expectedWord: '발',
      acceptedWords: const ['발', '발 '], // '발 '도 허용?
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 완료 화면 (⭐️ API 호출 없음, UI만 표시 후 나무로 복귀)
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_4_DonePage extends StatefulWidget {
  const Writing3_4_DonePage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_done';
  final String childId;

  @override
  State<Writing3_4_DonePage> createState() => _Writing3_4_DonePageState();
}

class _Writing3_4_DonePageState extends State<Writing3_4_DonePage> {
  static const _clapPath = 'assets/img/contents/studyWrite/clap.png';

  @override
  void initState() {
    super.initState();
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
                '쓰기 4단계(신체)도 전부 학습했어요!',
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

// 리워드 팝업
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
          children: [
            Image.asset(
              'assets/img/contents/studyWrite/gold_apple.png',
              width: 56,
              height: 56,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 12),
            const Text(
              '이번 나무의 사과를 획득했어요!\n이번 나무의 황금사과까지 전부 모았어요!\n다음 나무의 사과도 부탁해~',
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