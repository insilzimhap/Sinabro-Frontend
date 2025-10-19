// lib/main/studyView/writeStudy/page/writing_3_3.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart'; // AppleGarden(childId: ...)
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';

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
    case Writing3_3_IntroPage.routeName:
      return Writing3_3_IntroPage(childId: childId);
    case Writing3_3_1Page.routeName:
      return Writing3_3_1Page(childId: childId);
    case Writing3_3_2Page.routeName:
      return Writing3_3_2Page(childId: childId);
    case Writing3_3_3Page.routeName:
      return Writing3_3_3Page(childId: childId);
    case Writing3_3_4Page.routeName:
      return Writing3_3_4Page(childId: childId);
    case Writing3_3_5Page.routeName:
      return Writing3_3_5Page(childId: childId);
    case Writing3_3_6Page.routeName:
      return Writing3_3_6Page(childId: childId);
    case Writing3_3_DonePage.routeName:
      return Writing3_3_DonePage(childId: childId);
    default:
      return null;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 인트로 화면: 카드 섞인 이미지 → 3초 뒤 1번 페이지로 자동 이동
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_3_IntroPage extends StatefulWidget {
  const Writing3_3_IntroPage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_intro';
  final String childId;

  @override
  State<Writing3_3_IntroPage> createState() => _Writing3_3_IntroPageState();
}

class _Writing3_3_IntroPageState extends State<Writing3_3_IntroPage> {
  static const _cardMixed = 'assets/img/contents/studyWrite/card_mixed.png';

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _replaceNamedOrFallback(
        context,
        Writing3_3_1Page.routeName,
        arguments: {'childId': widget.childId},
        fallback: Writing3_3_1Page(childId: widget.childId),
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
                          Text(
                            '으라차차 카드가 뒤섞여버렸어요...',
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
// 재사용 카드(일러스트 + 하단 프리뷰/트레이스 + 쓰기/판별)
//  - requiredStrokes/무반응 타이머 제거
//  - “채점하기” 버튼으로 수동 인식
// ──────────────────────────────────────────────────────────────────────────────
class _WritingItemPage extends StatefulWidget {
  const _WritingItemPage({
    super.key,
    required this.childId,
    required this.illustPath,
    required this.previewPath,
    required this.tracePath,
    required this.nextRouteName,
    required this.columns,
    required this.expectedWord, // 예: '감자'
    required this.acceptedWords, // 예: ['감자','감쟈'...]
    this.titleColor = const Color(0xFFFEF5F6),
  });

  final String childId;
  final String illustPath;
  final String previewPath;
  final String tracePath;
  final String nextRouteName;
  final int columns;
  final Color titleColor;

  final String expectedWord;
  final List<String> acceptedWords;

  @override
  State<_WritingItemPage> createState() => _WritingItemPageState();
}

class _WritingItemPageState extends State<_WritingItemPage> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  bool _isCorrect(String raw) {
    // 후보의 첫 줄만 취득 → 한글만 이어붙여 비교
    final top1Line = raw.split('\n').first;
    final buffer = StringBuffer();
    for (final rune in top1Line.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[가-힣]').hasMatch(ch)) buffer.write(ch);
    }
    final cleaned = buffer.toString().trim();
    debugPrint("✅ 정제된 top1 = $cleaned");
    return widget.acceptedWords.contains(cleaned);
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
                                            key: _canvasKey,
                                            penWidth: 15,
                                            targetChar: widget.expectedWord,
                                            candidateSet: widget.acceptedWords,
                                            targetType: "word",
                                            autoRecognizeOnEnd: false, // 수동 채점
                                            onRecognize: (result) async {
                                              if (_isCorrect(result)) {
                                                _replaceNamedOrFallback(
                                                  context,
                                                  widget.nextRouteName,
                                                  arguments: {
                                                    'childId': widget.childId,
                                                  },
                                                  fallback:
                                                      _routeFallbackWithChild(
                                                        widget.nextRouteName,
                                                        widget.childId,
                                                      ),
                                                );
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

/// 하단 네모 박스(2칸/3칸) — 2칸이면 전체 박스 폭 2/3로 축소(칸 크기 유지)
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
        final fullW = constraints.maxWidth; // 3칸 기준 가용폭
        final targetW = fullW * (cols / 3.0); // 2칸이면 2/3 사용
        final targetH = fullW / 3.6; // 3칸 기준 높이(칸 크기 고정)

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
// 실제 페이지들(감자→고구마→오이→배추→옥수수→버섯→완료)
// ──────────────────────────────────────────────────────────────────────────────

// 감자
class Writing3_3_1Page extends StatelessWidget {
  const Writing3_3_1Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_1';
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
      illustPath: 'assets/img/contents/studyWrite/potato.png',
      previewPath: 'assets/img/contents/studyWrite/potato_preview.png',
      tracePath: 'assets/img/contents/studyWrite/potato_trace.png',
      nextRouteName: Writing3_3_2Page.routeName,
      columns: 2,
      expectedWord: '감자',
      acceptedWords: const ['감자', '감쟈', '갑자'],
    );
  }
}

// 고구마
class Writing3_3_2Page extends StatelessWidget {
  const Writing3_3_2Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_2';
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
      illustPath: 'assets/img/contents/studyWrite/sweetpotato.png',
      previewPath: 'assets/img/contents/studyWrite/sweetpotato_preview.png',
      tracePath: 'assets/img/contents/studyWrite/sweetpotato_trace.png',
      nextRouteName: Writing3_3_3Page.routeName,
      columns: 3,
      expectedWord: '고구마',
      acceptedWords: const ['고구마', '고구머', '고구맙'],
    );
  }
}

// 오이
class Writing3_3_3Page extends StatelessWidget {
  const Writing3_3_3Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_3';
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
      illustPath: 'assets/img/contents/studyWrite/cucumber.png',
      previewPath: 'assets/img/contents/studyWrite/cucumber_preview.png',
      tracePath: 'assets/img/contents/studyWrite/cucumber_trace.png',
      nextRouteName: Writing3_3_4Page.routeName,
      columns: 2,
      expectedWord: '오이',
      acceptedWords: const ['오이', '오ㅣ', '요이'],
    );
  }
}

// 배추
class Writing3_3_4Page extends StatelessWidget {
  const Writing3_3_4Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_4';
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
      illustPath: 'assets/img/contents/studyWrite/cabbage.png',
      previewPath: 'assets/img/contents/studyWrite/cabbage_preview.png',
      tracePath: 'assets/img/contents/studyWrite/cabbage_trace.png',
      nextRouteName: Writing3_3_5Page.routeName,
      columns: 2,
      expectedWord: '배추',
      acceptedWords: const ['배추', '베추', '배츄'],
    );
  }
}

// 옥수수
class Writing3_3_5Page extends StatelessWidget {
  const Writing3_3_5Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_5';
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
      illustPath: 'assets/img/contents/studyWrite/corn.png',
      previewPath: 'assets/img/contents/studyWrite/corn_preview.png',
      tracePath: 'assets/img/contents/studyWrite/corn_trace.png',
      nextRouteName: Writing3_3_6Page.routeName,
      columns: 3,
      expectedWord: '옥수수',
      acceptedWords: const ['옥수수', '옥슈슈', '옥수슈'],
    );
  }
}

// 버섯
class Writing3_3_6Page extends StatelessWidget {
  const Writing3_3_6Page({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_6';
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
      illustPath: 'assets/img/contents/studyWrite/mushroom.png',
      previewPath: 'assets/img/contents/studyWrite/mushroom_preview.png',
      tracePath: 'assets/img/contents/studyWrite/mushroom_trace.png',
      nextRouteName: Writing3_3_DonePage.routeName, // 마지막 → 완료
      columns: 2,
      expectedWord: '버섯',
      acceptedWords: const ['버섯', '버셧', '버섯ㅅ'],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 완료 화면: 박수 → 3초 팝업 → 3초 뒤 나무로 이동
// ──────────────────────────────────────────────────────────────────────────────
class Writing3_3_DonePage extends StatefulWidget {
  const Writing3_3_DonePage({super.key, required this.childId});
  static const routeName = '/study/write/writing_3_3_done';
  final String childId;

  @override
  State<Writing3_3_DonePage> createState() => _Writing3_3_DonePageState();
}

class _Writing3_3_DonePageState extends State<Writing3_3_DonePage> {
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
                '쓰기 3단계(채소)도 전부 학습했어요!',
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
