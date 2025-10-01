// lib/main/studyView/writeStudy/page/writing_3_4.dart
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
// 공용 이동 유틸: 네임드 라우트 시도 → 실패하면 fallback 위젯으로 이동
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

// 라우트 문자열 → 위젯( childId 포함 ) 매퍼
Widget? _routeFallbackWithChild(String name, String childId) {
  switch (name) {
    case Writing3_4_IntroPage.routeName:
      return Writing3_4_IntroPage(childId: childId);
    case Writing3_4_1Page.routeName:
      return Writing3_4_1Page(childId: childId);
    case Writing3_4_2Page.routeName:
      return Writing3_4_2Page(childId: childId);
    case Writing3_4_3Page.routeName:
      return Writing3_4_3Page(childId: childId);
    case Writing3_4_4Page.routeName:
      return Writing3_4_4Page(childId: childId);
    case Writing3_4_5Page.routeName:
      return Writing3_4_5Page(childId: childId);
    case Writing3_4_6Page.routeName:
      return Writing3_4_6Page(childId: childId);
    case Writing3_4_DonePage.routeName:
      return Writing3_4_DonePage(childId: childId);
    default:
      return null;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 인트로: 카드 섞인 이미지 + 안내 텍스트 → 3초 뒤 1번(눈)으로 자동 이동
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_4_IntroPage extends StatefulWidget {
  const Writing3_4_IntroPage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_intro';
  final String childId;

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
      _pushNamedOrFallback(
        context,
        Writing3_4_1Page.routeName,
        arguments: {'childId': widget.childId},
        fallback: _routeFallbackWithChild(
          Writing3_4_1Page.routeName,
          widget.childId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
/* 재사용 카드(일러스트 + 하단 프리뷰/트레이스 + 쓰기/판별)
   columns: 1/2/3 (1칸이면 전체 폭 1/3만 사용해서 칸 크기 유지)
   - requiredStrokes/타이머 제거
   - 수동 ‘채점하기’ 버튼으로 인식 */
// ──────────────────────────────────────────────────────────────────────────────
class _WritingItemPage extends StatefulWidget {
  const _WritingItemPage({
    required this.childId,
    required this.illustPath,
    required this.previewPath,
    required this.tracePath,
    required this.nextRouteName,
    required this.columns,
    required this.expectedWord, // 예: '눈'
    required this.acceptedWords, // 예: ['눈','뉸'...]
    this.titleColor = const Color(0xFFFEF5F6),
    super.key,
  });

  final String childId;
  final String illustPath;
  final String previewPath;
  final String tracePath;
  final String nextRouteName;
  final int columns; // 1~3
  final String expectedWord;
  final List<String> acceptedWords;
  final Color titleColor;

  @override
  State<_WritingItemPage> createState() => _WritingItemPageState();
}

class _WritingItemPageState extends State<_WritingItemPage> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  bool _isCorrect(String raw) {
    // 1) 첫 줄만 취득 → 2) 한글만 이어붙여 비교
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
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // ✨ 이 줄을 추가했습니다.
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
                            mainAxisAlignment:
                                MainAxisAlignment.center, // ✨ 이 줄을 추가했습니다.
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
                                            onRecognize: (result) async {
                                              if (_isCorrect(result)) {
                                                _goNext(context);
                                              } else {
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

/// 하단 네모 박스(1/2/3칸) — 칸 수에 따라 전체 폭을 1/3, 2/3, 3/3로 조절(칸 크기 유지)
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
        final fullW = constraints.maxWidth; // 3칸 기준 가용폭
        final targetW = fullW * (cols / 3.0); // 1칸 → 1/3만 사용
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
    if (columns <= 1) return; // 1칸이면 분할선 없음
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
// 실제 페이지들(눈→코→입→귀→손→발→완료)
// ──────────────────────────────────────────────────────────────────────────────

// 눈
class Writing3_4_1Page extends StatelessWidget {
  const Writing3_4_1Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_1';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingItemPage(
      childId: id,
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

// 코
class Writing3_4_2Page extends StatelessWidget {
  const Writing3_4_2Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_2';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingItemPage(
      childId: id,
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

// 입
class Writing3_4_3Page extends StatelessWidget {
  const Writing3_4_3Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_3';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingItemPage(
      childId: id,
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

// 귀
class Writing3_4_4Page extends StatelessWidget {
  const Writing3_4_4Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_4';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingItemPage(
      childId: id,
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

// 손
class Writing3_4_5Page extends StatelessWidget {
  const Writing3_4_5Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_5';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingItemPage(
      childId: id,
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

// 발
class Writing3_4_6Page extends StatelessWidget {
  const Writing3_4_6Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_4_6';
  final String childId;

  @override
  Widget build(BuildContext context) {
    final argId =
        (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['childId']
            as String?;
    final id = argId ?? childId;

    return _WritingItemPage(
      childId: id,
      illustPath: 'assets/img/contents/studyWrite/foot.png',
      previewPath: 'assets/img/contents/studyWrite/foot_preview.png',
      tracePath: 'assets/img/contents/studyWrite/foot_trace.png',
      nextRouteName: Writing3_4_DonePage.routeName,
      columns: 1,
      expectedWord: '발',
      acceptedWords: const ['발', '발 '],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 완료 화면: 박수 → 3초 팝업(황금사과) → 나무로 이동
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
}
