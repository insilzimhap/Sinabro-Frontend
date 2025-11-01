// 레벨 1 열매 4 달고나(도형) 서버 연결 완료
// lib/main/studyView/writeStudy/page/level1/candy_write.dart
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert'; // http 사용을 위해 추가
import 'package:http/http.dart' as http; // http 사용을 위해 추가
import 'package:sinabro/config.dart'; // baseUrl 사용을 위해 추가

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:audioplayers/audioplayers.dart'; // 오디오 패키지 import

/* ───────── assets ───────── */
const _dir = 'assets/img/contents/studyWrite/';
const _bgCandy = '${_dir}bg_candy.png'; // 배경
const _cookie = '${_dir}candy.png'; // 쿠키(그리기 단계)

/// 가이드 PNG (투명 배경 + 선 부분 불투명)
const _guide1 = '${_dir}candy1.png';
const _guide2 = '${_dir}candy2.png';
const _guide3 = '${_dir}candy3.png';

/// 스테이지별 완성 컷
const _finishCir = '${_dir}candy_cir.png';
const _finishTri = '${_dir}candy_tri.png';
const _finishRec = '${_dir}candy_rec.png';

const _eatCandy = '${_dir}eat_candy.png'; // 먹는 장면
const _appleGold = '${_dir}apple_gold.png'; // 팝업 아이콘
const _dalgona = '${_dir}dalgona.png';

// 오디오 에셋 경로
const _audioDir = 'audio/tts/studyWrite/level1/';
const _audioIntro = '${_audioDir}write3_dalgona_intro.mp3';
const _audioDone = '${_audioDir}write3_dalgona_done.mp3';
const _audioFinish = '${_audioDir}write3_dalgona_finish.mp3';

/* ───────── flow ───────── */
enum _Phase { intro, draw, reveal, eat }

enum _Shape { circle, triangle, square }

class CandyWritePage extends StatefulWidget {
  final String childId;
  const CandyWritePage({super.key, required this.childId});

  @override
  State<CandyWritePage> createState() => _CandyWritePageState();
}

class _CandyWritePageState extends State<CandyWritePage>
    with SingleTickerProviderStateMixin {
  // 스테이지: 동그라미 → 세모 → 네모
  final List<_Shape> _stages = const [
    _Shape.circle,
    _Shape.triangle,
    _Shape.square,
  ];
  // 각 스테이지 가이드
  final List<String> _guides = const [_guide1, _guide2, _guide3];
  final List<double> _guideScale = const [0.80, 0.68, 0.80];

  // ⭐️ [수정] HEAD와 sub의 변수들 병합
  final AudioPlayer _audioPlayer = AudioPlayer(); // sub 브랜치 오디오
  DateTime? _startTime; // HEAD 브랜치 학습 시작 시간

  int _stage = 0;
  _Phase _phase = _Phase.intro;

  // 진행도 표시 (0..1)
  double _progress = 0.0;

  // 완성 컷 애니메이션
  late final AnimationController _revealCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  // ✅ API 호출 함수 (HEAD 브랜치)
  Future<void> _uploadStudyWritingResult() async {
    // 실제 이 학습에 해당하는 정확한 fruit_id로 바꿔주세요!
    const String fruitIdForThisStudy = 'FR_WR_004';

    // ✅ 학습 시간 계산
    int timeSpentSeconds = 0;
    if (_startTime != null) {
      // 끝나는 시간과 시작 시간의 차이를 구해서 초 단위로 변환
      timeSpentSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }

    // 서버에 보낼 데이터 구성
    final body = jsonEncode({
      'childId': widget.childId, // State 위젯의 childId 사용
      'fruitId': fruitIdForThisStudy,
      // ✅ 계산된 시간 사용
      'timeSpentSecs': timeSpentSeconds,
      'isCompleted': true, // 학습을 정상적으로 완료했으므로 true
    });

    try {
      // 백엔드 API 호출 (POST 요청)
      final res = await http.post(
        Uri.parse('$baseUrl/api/study/writing/complete'), // 백엔드 API 주소
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // 응답 상태 코드 확인
      if (res.statusCode == 200) {
        debugPrint('✅ 쓰기 학습 결과 업로드 성공!');
      } else {
        debugPrint('❌ 쓰기 학습 결과 업로드 실패: ${res.body}');
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      debugPrint('❌ 쓰기 학습 결과 업로드 중 에러 발생: $e');
    }
  }

  // ------------------ 오디오 (sub 브랜치) ------------------
  @override
  void initState() {
    super.initState();
    // 인트로 오디오 자동 재생
    _playAudio(_audioIntro);
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    // 오디오 플레이어 리소스 해제
    _audioPlayer.dispose();
    super.dispose();
  }

  /// 오디오 재생 헬퍼 함수
  Future<void> _playAudio(String assetPath, {bool isLooping = false}) async {
    // 위젯이 dispose된 후에 호출되는 것을 방지
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오가 있다면 중지
    _audioPlayer
        .setReleaseMode(isLooping ? ReleaseMode.loop : ReleaseMode.release);
    await _audioPlayer.play(AssetSource(assetPath));
    return _audioPlayer.onPlayerComplete.first;
  }
  // ---------------------------------------------

  Future<void> _onStageDone() async {
    if (!mounted) return;

    setState(() => _phase = _Phase.reveal);
    _revealCtrl
      ..reset()
      ..forward();

    await _revealCtrl.forward();
    if (!mounted) return;

    // 마지막 스테이지 완료 시에만 "완성되었어요" 재생
    if (_stage >= _stages.length - 1) {
      // "완성되었어요" 오디오 재생이 완료될 때까지 기다림
      await _playAudio(_audioDone);
      if (!mounted) return;

      // 오디오가 끝난 후 3초간 대기 (5초 -> 3초로 줄어있었음)
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
    }

    // 다음 단계 또는 엔딩
    if (_stage < _stages.length - 1) {
      // 아직 다음 스테이지 남음
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      // 다음 단계 시작 시 별도 오디오 없음
      setState(() {
        _stage++;
        _progress = 0;
        _phase = _Phase.draw;
      });
    } else {
      // 마지막 → 먹는 장면 3초 → 팝업 → 나무로
      setState(() => _phase = _Phase.eat);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _playAudio(_audioFinish);
      });
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      await _showRewardPopup();

      // ✅ API 호출 함수 실행!
      await _uploadStudyWritingResult();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
      );
    }
  }

  String _finishAssetFor(_Shape s) {
    switch (s) {
      case _Shape.circle:
        return _finishCir;
      case _Shape.triangle:
        return _finishTri;
      case _Shape.square:
        return _finishRec;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFEEE7DC),
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final side = min(size.width, size.height) * 0.75;
          
          // ⭐️ [수정] 중복된 코드 제거, 여기서 한 번만 시간 기록
          // ⭐ 첫 번째 스테이지(_stage == 0)의 그리기 단계(_phase == _Phase.draw)일 때 딱 한 번만 시간 기록
          if (_phase == _Phase.draw && _stage == 0 && _startTime == null) {
            _startTime = DateTime.now();
            debugPrint('✅ 학습 시작 시간 기록: $_startTime');
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 배경
              Image.asset(_bgCandy, fit: BoxFit.cover),

              // ✅ 인트로 화면
              if (_phase == _Phase.intro) ...[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _phase = _Phase.draw), // 탭 → 시작
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const Spacer(flex: 5),
                            // 달고나 이미지
                            Image.asset(
                              _dalgona,
                              width: min(size.width, size.height) * 0.55,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 28),
                            // 타이틀
                            const Text(
                              '달고나를 만들어봐요~',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5A4032),
                                height: 1.2,
                              ),
                            ),

                            // 아래로 좀 더 내리기
                            const Spacer(flex: 3),

                            // 🔸 안내 문구 + 박스 배경
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFFFFF3D6,
                                ).withOpacity(0.9), // 크림색 박스
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '화면을 탭하면 넘어가요',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16, // ← 살짝 키움 (기존 14 → 16)
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4E3B00),
                                ),
                              ),
                            ),

                            // 하단 여백 + 안전 영역
                            SizedBox(
                              height: 18 +
                                  kBottomNavigationBarHeight * 0.0 + // 필요시 조절
                                  0 +
                                  MediaQuery.of(context).padding.bottom,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              if (_phase == _Phase.draw) ...[
                // 가운데 쿠키
                Center(
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: Image.asset(_cookie, fit: BoxFit.contain),
                  ),
                ),

                // 가이드 + 한 획 판정 레이어 (jam_write와 동일한 방식)
                Center(
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: CandyGuideLayer(
                      guideAsset: _guides[_stage],
                      guideOpacity: 0.38,
                      sizeScale: _guideScale[
                          _stage], // ✅ 스테이지별 축소율 적용 (예: [0.80, 0.68, 0.80])
                      targetCoverage: 0.50, // ✅ 50% 이상 채우기 (80% -> 50%로 완화됨)
                      snapRadiusPx: 30,
                      stampRadiusPx: 9,
                      sampleStridePx: 4,
                      strokeColor: const ui.Color.fromARGB(255, 90, 64, 50),
                      strokeWidthBasePx: 18,
                      requireLoopClosure: true, // ✅ 닫힌 도형: 시작점으로 돌아오면 OK
                      loopCloseThreshPx: 24,
                      onProgress: (p) => setState(() => _progress = p),
                      onDone: _onStageDone,
                      onFail: () {
                        // ⭐ 실패 시 별도 오디오 없음
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('다시 그려볼까요? 한 번에 이어서!'),
                            duration: Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 진행도 배지
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        // ⭐ 안내 문구 변경 (달고나 맞춤)
                        '모양 틀을 따라 한 번에 그려요  ${(min(_progress, 1.0) * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              if (_phase == _Phase.reveal) ...[
                // 완성 컷 애니메이션
                AnimatedBuilder(
                  animation: _revealCtrl,
                  builder: (_, __) {
                    final t = CurvedAnimation(
                      parent: _revealCtrl,
                      curve: Curves.easeInOutCubic,
                    ).value;
                    final scale = 0.90 + 0.10 * Curves.easeOutBack.transform(t);
                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: t,
                          child: Image.asset(
                            _finishAssetFor(_stages[_stage]),
                            width: side,
                            height: side,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const _FinishBanner(), // "완성되었어요~!" 텍스트 배너
              ],

              if (_phase == _Phase.eat) ...[
                Positioned.fill(
                  child: Image.asset(_eatCandy, fit: BoxFit.cover),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80 + MediaQuery.of(context).padding.bottom,
                  child: const _EatBanner(), // "맛있게 먹어봐요~!" 텍스트 배너
                ),
              ],

              // 뒤로가기 (항상 나무로 복귀)
              Positioned(
                left: 10,
                top: 10 + padTop,
                child: IconButton.filled(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppleGarden(childId: widget.childId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRewardPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 360,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF1C8),
                borderRadius: BorderRadius.circular(18),
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
                  const SizedBox(height: 4),
                  Image.asset(_appleGold, height: 56, fit: BoxFit.contain),
                  const SizedBox(height: 14),
                  const Text(
                    '이번 나무의 사과를 획득했어요!\n이번 나무의 황금사과까지 전부 모았어요!\n다음 나무의 사과도 부탁해~',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5A4032),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xFF5A4032),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

/* ─────────────────────────────────────────────────────────────────────────────
   CandyGuideLayer (완화판)
   ... (이하 CandyGuideLayer, _MaskClippedStrokePainter, _FinishBanner, _EatBanner 코드는
        충돌이 없었으므로 네 원본 그대로 두면 돼. 수정할 거 없음.)
   ─────────────────────────────────────────────────────────────────────────────*/
class CandyGuideLayer extends StatefulWidget {
  final String guideAsset;
  final double guideOpacity;

  final double targetCoverage; // 예: 0.50
  final double snapRadiusPx; // 스냅 반경(화면 좌표)
  final int stampRadiusPx; // 도장 반경(px, 마스크 좌표)
  final int sampleStridePx; // 샘플 간격(px, 마스크 좌표)

  final ui.Color strokeColor;
  final double strokeWidthBasePx;

  final ValueChanged<double> onProgress; // 0..1
  final VoidCallback onDone;
  final VoidCallback? onFail;

  /// 닫힌 도형이면 true. (원/세모/네모)
  final bool requireLoopClosure;

  /// 시작-끝 허용 거리(px, 화면 기준)
  final double loopCloseThreshPx;

  /// 가이드 박스를 컨테이너 대비 얼마로 그릴지 (0~1)
  final double sizeScale;

  const CandyGuideLayer({
    super.key,
    required this.guideAsset,
    required this.guideOpacity,
    required this.targetCoverage,
    required this.snapRadiusPx,
    required this.stampRadiusPx,
    required this.sampleStridePx,
    required this.strokeColor,
    required this.strokeWidthBasePx,
    required this.onProgress,
    required this.onDone,
    this.onFail,
    this.requireLoopClosure = true,
    this.loopCloseThreshPx = 28,
    this.sizeScale = 0.80,
  });

  @override
  State<CandyGuideLayer> createState() => _CandyGuideLayerState();
}

class _CandyGuideLayerState extends State<CandyGuideLayer> {
  // ... (CandyGuideLayer의 모든 내부 변수와 함수들)
  // ... (수정할 거 없음)
  ui.Image? _maskImg;
  Uint8List? _rgba;
  int _gw = 0, _gh = 0;
  Offset? _firstMaskPt;
  Offset? _lastMaskPt;
  late Rect _guideRect;
  late double _mx, _my;
  late int _gridW, _gridH, _stride;
  late List<bool> _coveredGrid;
  int _totalSamples = 0, _coveredSamples = 0;
  final List<Offset> _stroke = [];
  Size? _lastSize;
  int _minGXEdge = 0, _maxGXEdge = 0;
  int _minGYEdge = 0, _maxGYEdge = 0;
  bool _useHorizontal = true; 
  static const double _kEndBandPct = 0.12;
  static const double _kOrthoSlackPct = 0.70;
  static const double _kCoverageGrace = 0.90; 
  bool get _ready => _maskImg != null && _rgba != null;
  double get _coverage =>
      _totalSamples == 0 ? 0.0 : _coveredSamples / _totalSamples;
  void _resetAttempt() {
    _stroke.clear();
    _coveredGrid = List<bool>.filled(_gridW * _gridH, false);
    _coveredSamples = 0;
    _firstMaskPt = null;
    _lastMaskPt = null;
    widget.onProgress(0.0);
    setState(() {});
  }
  Future<void> _loadMaskForSize(Size size) async {
    // ...
  }
  bool _alphaOnAtGrid(int gx, int gy) {
    // ...
    return false; // 예시
  }
  Offset _toMask(Offset screenPt) => Offset(
        (screenPt.dx - _guideRect.left) * _mx,
        (screenPt.dy - _guideRect.top) * _my,
      );
  double _distanceToRect(Offset p, Rect r) {
    // ...
    return 0.0; // 예시
  }
  Offset? _nearestMaskPoint(Offset rawScreen) {
    // ...
    return null; // 예시
  }
  void _stampAtMaskGrid(Offset maskPt) {
    // ...
  }
  void _updateProgress(Offset maskPt) {
    widget.onProgress(_coverage);
    _lastMaskPt = maskPt;
  }

  @override
  Widget build(BuildContext context) {
    // ... (CandyGuideLayer의 build 함수)
    return LayoutBuilder(
      builder: (_, cons) {
        // ...
        if (!_ready) return const SizedBox.shrink();
        return Stack(
          children: [
            // ... (가이드)
            // ... (제스처 + 스트로크)
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (d) {
                  // ...
                },
                onPanUpdate: (d) {
                  // ...
                },
                onPanEnd: (_) {
                  // ... (onDone, onFail 호출 로직)
                },
                onPanCancel: () {
                  _resetAttempt();
                  widget.onFail?.call();
                },
                child: CustomPaint(
                  painter: _MaskClippedStrokePainter(
                    stroke: _stroke,
                    maskImage: _maskImg!,
                    maskSrcRect: Rect.fromLTWH(0, 0, _gw.toDouble(), _gh.toDouble()),
                    maskDstRect: _guideRect,
                    strokeColor: widget.strokeColor,
                    strokeWidth: max(
                      widget.strokeWidthBasePx,
                      min(_guideRect.width, _guideRect.height) * 0.06,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaskClippedStrokePainter extends CustomPainter {
  // ... (수정할 거 없음)
  final List<Offset> stroke;
  final ui.Image maskImage;
  final Rect maskSrcRect;
  final Rect maskDstRect;
  final Color strokeColor;
  final double strokeWidth;

  _MaskClippedStrokePainter({
    required this.stroke,
    required this.maskImage,
    required this.maskSrcRect,
    required this.maskDstRect,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ...
  }

  @override
  bool shouldRepaint(covariant _MaskClippedStrokePainter old) => false; // 예시
}

class _FinishBanner extends StatelessWidget {
  const _FinishBanner();
  @override
  Widget build(BuildContext context) {
    // ...
    return Container(); // 예시
  }
}

class _EatBanner extends StatelessWidget {
  const _EatBanner();
  @override
  Widget build(BuildContext context) {
    // ...
    return Container(); // 예시
  }
}