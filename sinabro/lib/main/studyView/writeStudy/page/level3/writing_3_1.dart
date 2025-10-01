// lib/main/studyView/writeStudy/page/writing_3_1.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';

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
// 공용 이동 유틸
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
  } catch (_) {
    if (fallback != null) {
      nav.push(MaterialPageRoute(builder: (_) => fallback));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Route not found: $routeName')));
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
  } catch (_) {
    if (fallback != null) {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => fallback));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Route not found: $routeName')));
    }
  }
}

// 라우트 문자열 → 페이지 위젯( childId 포함 ) 매퍼
Widget? _routeFallbackWithChild(String name, String childId) {
  switch (name) {
    case Writing3_IntroPage.routeName:
      return Writing3_IntroPage(childId: childId);
    case Writing3_1Page.routeName:
      return Writing3_1Page(childId: childId);
    case Writing3_2Page.routeName:
      return Writing3_2Page(childId: childId);
    case Writing3_3Page.routeName:
      return Writing3_3Page(childId: childId);
    case Writing3_4Page.routeName:
      return Writing3_4Page(childId: childId);
    case Writing3_5Page.routeName:
      return Writing3_5Page(childId: childId);
    case Writing3_6Page.routeName:
      return Writing3_6Page(childId: childId);
    case Writing3_DonePage.routeName:
      return Writing3_DonePage(childId: childId);
    default:
      return null;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 인트로 페이지
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_IntroPage extends StatefulWidget {
  const Writing3_IntroPage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_1_intro';
  final String childId;

  @override
  State<Writing3_IntroPage> createState() => _Writing3_IntroPageState();
}

class _Writing3_IntroPageState extends State<Writing3_IntroPage> {
  static const _cardMixed = 'assets/img/contents/studyWrite/card_mixed.png';

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _replaceNamedOrFallback(
        context,
        Writing3_1Page.routeName,
        arguments: {'childId': widget.childId},
        fallback: Writing3_1Page(childId: widget.childId),
      );
    });
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
              Column(
                children: [
                  const SizedBox(height: 48),
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final w = c.maxWidth;
                          final imgW = (w * 0.45).clamp(260.0, 560.0);
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
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
                  ),
                ],
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
// 재사용 페이지(일러스트, 왼쪽 프리뷰, 오른쪽 트레이스+쓰기+판별)
// ──────────────────────────────────────────────────────────────────────────────
class _WritingAnimalPage extends StatefulWidget {
  const _WritingAnimalPage({
    super.key,
    required this.childId,
    required this.illustPath,
    required this.previewPath,
    required this.tracePath,
    required this.nextRouteName,
    required this.columns,
    required this.expectedWord, // 예: '강아지'
    required this.acceptedWords, // 예: ['강아지','강이지',...]
    this.titleColor = const Color(0xFFFEF5F6),
  });

  final String childId;
  final String illustPath;
  final String previewPath;
  final String tracePath;
  final String nextRouteName;
  final int columns; // 2 or 3
  final Color titleColor;

  final String expectedWord;
  final List<String> acceptedWords;

  @override
  State<_WritingAnimalPage> createState() => _WritingAnimalPageState();
}

class _WritingAnimalPageState extends State<_WritingAnimalPage> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  /// 셀비식 정답 판별: 1) 첫 줄만, 2) 한글만, 3) 후보 일치
  bool _isCorrect(String raw) {
    final top1Line = raw.split('\n').first;
    final buf = StringBuffer();
    for (final r in top1Line.runes) {
      final ch = String.fromCharCode(r);
      if (RegExp(r'[가-힣]').hasMatch(ch)) buf.write(ch);
    }
    final cleaned = buf.toString().trim();
    debugPrint('✅ 정제된 top1 = $cleaned');
    return widget.acceptedWords.contains(cleaned);
  }

  void _goNext(BuildContext context) {
    _pushNamedOrFallback(
      context,
      widget.nextRouteName,
      arguments: {'childId': widget.childId},
      fallback: _routeFallbackWithChild(widget.nextRouteName, widget.childId),
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
                        // 오른쪽: 트레이스 + 쓰기 + (아래) 채점 버튼
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TileStrip(
                                columns: cols,
                                child: LayoutBuilder(
                                  builder: (_, __) {
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
                                        // 위: 쓰기 캔버스 (반드시 터치 받도록 처리)
                                        Positioned.fill(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            child: WritingCanvas(
                                              key: _canvasKey,
                                              penWidth: 15,
                                              targetChar: widget.expectedWord,
                                              candidateSet:
                                                  widget.acceptedWords,
                                              targetType: "word",
                                              autoRecognizeOnEnd:
                                                  false, // 수동 채점
                                              onRecognize: (result) async {
                                                if (_isCorrect(result)) {
                                                  _goNext(context);
                                                } else {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          '다시 써볼까요?',
                                                        ),
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
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 채점하기 버튼(수동 인식 트리거)
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

/// 하단 네모 박스(2칸/3칸) - 2칸이면 전체 박스 폭 2/3만 사용(칸 크기 유지)
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
        final fullW = constraints.maxWidth; // Expanded가 준 폭 (3칸 기준)
        final targetW = fullW * (cols / 3.0); // 2칸이면 2/3 사용
        final targetH = fullW / 3.6; // 높이는 3칸 기준 유지

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
// 실제 페이지들(강아지→고양이→토끼→오리→거북이→개구리→완료)
// ──────────────────────────────────────────────────────────────────────────────

// 강아지
class Writing3_1Page extends StatelessWidget {
  const Writing3_1Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_1';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingAnimalPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/dog.png',
      previewPath: 'assets/img/contents/studyWrite/dog_preview.png',
      tracePath: 'assets/img/contents/studyWrite/dog_trace.png',
      nextRouteName: Writing3_2Page.routeName,
      columns: 3,
      expectedWord: '강아지',
      acceptedWords: const ['강아지', '강이지', '깅이지', '강야지'],
    );
  }
}

// 고양이
class Writing3_2Page extends StatelessWidget {
  const Writing3_2Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_2';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingAnimalPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/cat.png',
      previewPath: 'assets/img/contents/studyWrite/cat_preview.png',
      tracePath: 'assets/img/contents/studyWrite/cat_trace.png',
      nextRouteName: Writing3_3Page.routeName,
      columns: 3,
      expectedWord: '고양이',
      acceptedWords: const ['고양이', '고얭이', '고야이', '고양니'],
    );
  }
}

// 토끼
class Writing3_3Page extends StatelessWidget {
  const Writing3_3Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingAnimalPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/rabbit.png',
      previewPath: 'assets/img/contents/studyWrite/rabbit_preview.png',
      tracePath: 'assets/img/contents/studyWrite/rabbit_trace.png',
      nextRouteName: Writing3_4Page.routeName,
      columns: 2,
      expectedWord: '토끼',
      acceptedWords: const ['토끼', '토키', '톡끼', '도끼'],
    );
  }
}

// 오리
class Writing3_4Page extends StatelessWidget {
  const Writing3_4Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingAnimalPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/duck.png',
      previewPath: 'assets/img/contents/studyWrite/duck_preview.png',
      tracePath: 'assets/img/contents/studyWrite/duck_trace.png',
      nextRouteName: Writing3_5Page.routeName,
      columns: 2,
      expectedWord: '오리',
      acceptedWords: const ['오리', '오니', '오이', '오릐'],
    );
  }
}

// 거북이
class Writing3_5Page extends StatelessWidget {
  const Writing3_5Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_5';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingAnimalPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/turtle.png',
      previewPath: 'assets/img/contents/studyWrite/turtle_preview.png',
      tracePath: 'assets/img/contents/studyWrite/turtle_trace.png',
      nextRouteName: Writing3_6Page.routeName,
      columns: 3,
      expectedWord: '거북이',
      acceptedWords: const ['거북이', '거부기', '거북ㅣ', '거북니'],
    );
  }
}

// 개구리
class Writing3_6Page extends StatelessWidget {
  const Writing3_6Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_6';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingAnimalPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/frog.png',
      previewPath: 'assets/img/contents/studyWrite/frog_preview.png',
      tracePath: 'assets/img/contents/studyWrite/frog_trace.png',
      nextRouteName: Writing3_DonePage.routeName,
      columns: 3,
      expectedWord: '개구리',
      acceptedWords: const ['개구리', '개굴이', '개구니', '개구뤼'],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 완료 화면
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_DonePage extends StatefulWidget {
  const Writing3_DonePage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_done';
  final String childId;

  @override
  State<Writing3_DonePage> createState() => _Writing3_DonePageState();
}

class _Writing3_DonePageState extends State<Writing3_DonePage> {
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
          return const _AppleRewardDialog();
        },
      );

      if (!mounted) return;

      final nav = Navigator.of(context, rootNavigator: true);
      try {
        nav.pushNamedAndRemoveUntil(
          kMainAppleTreeRoute,
          (_) => false,
          arguments: {'childId': widget.childId},
        );
      } catch (_) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AppleGarden(childId: widget.childId),
          ),
          (route) => false,
        );
      }
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
                '쓰기 1단계(동물)를 전부 학습했어요!',
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
}
