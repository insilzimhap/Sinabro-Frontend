// NEXT TODO : 잼 바르고 완료 됐을 때 효과음

// 쓰기 학습 - 레벨1 <나무1(ST004)> / 열매 2(FR_WR_002) 잼 그리기(곡선) 서버 연결 완료
// lib/main/studyView/writeStudy/page/level1/jam_write.dart
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert'; // http 사용을 위해 추가
import 'package:http/http.dart' as http; // http 사용을 위해 추가
import 'package:sinabro/config.dart'; // baseUrl 사용을 위해 추가

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart'; // 오디오 패키지 import

import 'package:sinabro/main/studyView/common/mixin/sticker_reward_handler.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';

/* ───────── assets ───────── */
const _dir = 'assets/img/contents/studyWrite/';
const _bread = '${_dir}bread.png';
const _guides = <String>[
  '${_dir}jam1.png', // 딸기 가이드
  '${_dir}jam2.png', // 포도 가이드
  '${_dir}jam3.png', // 키위 가이드
];
const _jammedImgs = <String>[
  '${_dir}strawberry_bread.png', // 딸기 완성
  '${_dir}grape_bread.png', // 포도 완성
  '${_dir}kiwi_bread.png', // 키위 완성
];
const _jamChild = '${_dir}jam_child.png';
const _rewardApple = '${_dir}apple.png';
const _jamIntroJar = '${_dir}jam.png'; // 인트로 잼 이미지

/* 빵이 차지하는 영역(화면 정규화 좌표) + 가이드 5% 인세트 */
const Rect _kBreadRectNorm = Rect.fromLTWH(0.14, 0.16, 0.72, 0.60);
const double _kGuideInsetPct = 0.05;

// 오디오 에셋 경로 (경로 수정됨)
const _audioDir = 'audio/tts/studyWrite/level1/';
const _audioIntro = '${_audioDir}write3_jam_intro.mp3';
// ❗ 'write3_jam_press.mp3'는 현재 UI 흐름(onPanStart)에 넣으면
// ❗ 그릴 때마다 재생되어 부자연스러울 수 있어 제외하기로 함..
const _audioDraw = '${_audioDir}write3_jam_draw.mp3';
const _audioDone = '${_audioDir}write3_jam_done.mp3';
const _audioFinish = '${_audioDir}write3_jam_finish.mp3';

/* 스텝/페이즈 */
enum _Phase {
  intro,
  draw,
  reveal,
  revealText1,
  revealText2,
  child,
  reward,
  done,
}

class JamSpreadFlowPage extends StatefulWidget {
  final String childId;
  const JamSpreadFlowPage({super.key, required this.childId});

  @override
  State<JamSpreadFlowPage> createState() => _JamSpreadFlowPageState();
}

class _JamSpreadFlowPageState extends State<JamSpreadFlowPage>
    with SingleTickerProviderStateMixin {
  int _stage = 0; // 0:딸기 1:포도 2:키위
  _Phase _phase = _Phase.intro;
  double _progress = 0; // 0..1
  int _nonce = 0; // 레이어 강제 리셋 키
  bool _preloaded = false;

  // 오디오 플레이어 인스턴스
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ✅ 학습 시작 시간 기록 변수
  DateTime? _startTime;

  // 완성 전환(짜라란)
  late final AnimationController _revealCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  // ✅ API 호출 함수 추가
  Future<void> _uploadStudyWritingResult() async {
    // 실제 이 학습에 해당하는 정확한 fruit_id로 바꿔주세요!
    const String fruitIdForThisStudy = 'FR_WR_002';

    // 학습 시간 계산
    int timeSpentSeconds = 0;
    if (_startTime != null) {
      timeSpentSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }

    // 서버에 보낼 데이터 구성
    final body = jsonEncode({
      'childId': widget.childId, // State 위젯의 childId 사용
      'fruitId': fruitIdForThisStudy,
      'timeSpentSecs': timeSpentSeconds, // 계산된 시간 사용
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

  // ------------------ 오디오 ------------------
  @override
  void initState() {
    super.initState();
    // 인트로 오디오 자동 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playAudio(_audioIntro);
      }
    });
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

  /* ───────── precache ───────── */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheOnce();
  }

  Future<void> _precacheOnce() async {
    if (_preloaded) return;
    final size = MediaQuery.of(context).size;
    final dpr = MediaQuery.of(context).devicePixelRatio;

    final breadW = size.width * _kBreadRectNorm.width;
    final breadH = size.height * _kBreadRectNorm.height;
    final guideW = breadW * (1 - _kGuideInsetPct * 2);
    final guideH = breadH * (1 - _kGuideInsetPct * 2);

    final futures = <Future>[
      precacheImage(
        ResizeImage(
          AssetImage(_bread),
          width: (size.width * dpr).toInt(),
          height: (size.height * dpr).toInt(),
        ),
        context,
      ),
      precacheImage(AssetImage(_jamChild), context),
      precacheImage(AssetImage(_rewardApple), context),
      precacheImage(AssetImage(_jamIntroJar), context),
    ];
    for (final j in _jammedImgs) {
      futures.add(
        precacheImage(
          ResizeImage(
            AssetImage(j),
            width: (size.width * dpr).toInt(),
            height: (size.height * dpr).toInt(),
          ),
          context,
        ),
      );
    }
    for (final g in _guides) {
      futures.add(
        precacheImage(
          ResizeImage(
            AssetImage(g),
            width: (guideW * dpr).toInt(),
            height: (guideH * dpr).toInt(),
          ),
          context,
        ),
      );
    }
    await Future.wait(futures);
    _preloaded = true;
  }

  /* ───────── flow helpers ───────── */
  void _startDraw() {
    // "선에 맞춰 잼을 발라주세요" 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playAudio(_audioDraw);
      }
    });

    setState(() {
      _phase = _Phase.draw;
      // ✅ 학습 시작 시간 기록
      _startTime = DateTime.now();
    });
  }

  void _reset() {
    // ✅ (재시도 시) 그리기 오디오 다시 재생
    _playAudio(_audioDraw);
    setState(() {
      _progress = 0;
      _phase = _Phase.draw;
      _nonce++; // 레이어 재생성
    });
  }

  Future<void> _onStageDone() async {
    if (!mounted) return;
    setState(() => _phase = _Phase.reveal);
    _revealCtrl
      ..reset()
      ..forward();
    await _revealCtrl.forward();

    if (_stage == 2) {
      // "맛있게 완성되었어요" 오디오 재생
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _playAudio(_audioDone);
      });
      setState(() => _phase = _Phase.revealText1);
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return;

      // "잘 먹겠습니다" 오디오 재생
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _playAudio(_audioFinish);
        }
      });
      setState(() => _phase = _Phase.revealText2);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() => _phase = _Phase.child);
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      setState(() => _phase = _Phase.reward);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // ✅ [핵심 수정] 보상 시퀀스 시작 (사과 팝업 표시)
      setState(() => _phase = _Phase.reward);
      // 사과 팝업이 2초간 화면에 머무르도록 지연
      await Future.delayed(const Duration(seconds: 2)); 
      if (!mounted) return;


      // ✅ API 호출 추가! (팝업 후, 화면 전환 전)
      await _uploadStudyWritingResult();

      // ✅ StickerRewardHandler로 전환 (보상 페이지)
      if (!mounted) return;
      // FR_WR_002 (열매 2)에 맞는 설정
      const fruitId = 'FR_WR_002';
      const stageKey = 'ST004'; // 쓰기 학습 레벨 1 (가정)
      const newlyUnlockedIndex = 1; // FR_WR_002는 두 번째 열매일 것으로 가정 (인덱스 1)
      
      // 오디오 중지 (화면 전환 전)
      await _audioPlayer.stop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StickerRewardHandler(
            childId: widget.childId,
            fruitId: fruitId,
            stageKey: stageKey,
            newlyUnlockedIndex: newlyUnlockedIndex,
            isAllCleared: false,
            onFinish: () {},
            // ✅ 최종 목적지로 쓰기 학습 나무 페이지 전달
            finalDestination: AppleGarden(childId: widget.childId),
          ),
        ),
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 다음 단계 그리기 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playAudio(_audioDraw);
      }
    });
    setState(() {
      _stage++;
      _progress = 0;
      _phase = _Phase.draw;
      _nonce++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFEEE7DC),
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          final dpr = MediaQuery.of(context).devicePixelRatio;

          ResizeImage _bg(String path) => ResizeImage(
                AssetImage(path),
                width: (size.width * dpr).toInt().clamp(0, 4096),
                height: (size.height * dpr).toInt().clamp(0, 4096),
              );

          return Stack(
            fit: StackFit.expand,
            children: [
              // 0) 배경(빵)
              if (_phase == _Phase.child || _phase == _Phase.reward)
                Image.asset(_jamChild, fit: BoxFit.cover)
              else
                Image(
                  image: _bg(_bread),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),

              // 1) 드로잉 레이어
              if (_phase == _Phase.draw)
                JamImageGuideLayer(
                  key: ValueKey('stage-$_stage-$_nonce'),
                  guideAsset: _guides[_stage],
                  breadRectNorm: _kBreadRectNorm,
                  guideInsetPct: _kGuideInsetPct,
                  onProgress: (p) => setState(() => _progress = p),
                  onDone: _onStageDone,
                  // 인식 세팅(필요 시 외부에서 값 변경)
                  targetCoverage: 0.6,
                  snapRadiusPx: 30,
                  stampRadiusPx: 9,
                  sampleStridePx: 4,
                ),

              // 2) 완성 컷(짜라란) + 텍스트
              if (_phase == _Phase.reveal ||
                  _phase == _Phase.revealText1 ||
                  _phase == _Phase.revealText2)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedBuilder(
                      animation: _revealCtrl,
                      builder: (_, __) {
                        final t = CurvedAnimation(
                          parent: _revealCtrl,
                          curve: Curves.easeInOutCubic,
                        ).value;
                        final scale =
                            0.92 + 0.08 * Curves.easeOutBack.transform(t);
                        return Opacity(
                          opacity: t,
                          child: Transform.scale(
                            scale: scale,
                            child: Image(
                              image: _bg(_jammedImgs[_stage]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_phase == _Phase.revealText1 ||
                        _phase == _Phase.revealText2)
                      _BottomBannerText(
                        text: _phase == _Phase.revealText2
                            ? '잘 먹겠습니다~'
                            : '맛있게 완성되었어요!',
                      ),
                  ],
                ),

              // 3) 아이가 먹는 화면 (깜빡임 방지: jammed 이미지를 바닥에 깔고 그 위에 child)
              if (_phase == _Phase.child)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: ResizeImage(
                        AssetImage(_jammedImgs[_stage]),
                        width: (MediaQuery.of(context).size.width *
                                MediaQuery.of(context).devicePixelRatio)
                            .toInt()
                            .clamp(0, 4096),
                        height: (MediaQuery.of(context).size.height *
                                MediaQuery.of(context).devicePixelRatio)
                            .toInt()
                            .clamp(0, 4096),
                      ),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 200),
                      child: Image.asset(_jamChild, fit: BoxFit.cover),
                    ),
                  ],
                ),

              // 4) 리워드 팝업
              if (_phase == _Phase.reward) const _RewardPopup(),

              // 상단 좌측 버튼 (← 뒤로가기)
              Positioned(
                left: 10,
                top: 10 + padTop,
                child: IconButton.filled(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Navigator.pushReplacementNamed(context, '/apple_garden');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              // 진행도 배지(그리기 중)
              if (_phase == _Phase.draw)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20 + MediaQuery.of(context).padding.bottom,
                  child: Center(
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
                        // ❗ 여기 텍스트는 오디오 파일명과 관계 없습니다.
                        '선에 맞춰 잼을 발라주세요!  ${(min(1.0, _progress) * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

              // 인트로 화면
              if (_phase == _Phase.intro)
                Positioned.fill(
                  child: Material(
                    color: const Color(0xFFFFF2F4),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: _startDraw,
                      child: SafeArea(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final w = c.maxWidth;
                            final imgW = (w * 0.75).clamp(350.0, 750.0);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 36),
                                Image.asset(
                                  _jamIntroJar,
                                  width: imgW,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    '달콤한 잼을 식빵에 발라봐요!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF7A5F57),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFB388EB), // 보라색 박스
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        '화면을 탭하면 시작해요',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/* 하단 배너 텍스트 (박스 처리) */
class _BottomBannerText extends StatelessWidget {
  final String text;
  const _BottomBannerText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 36,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55), // 반투명 박스
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black38,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ──────────────────────────────────────────────
   이미지(투명 PNG) 가이드 기반 드로잉/판정 레이어
   ────────────────────────────────────────────── */
class JamImageGuideLayer extends StatefulWidget {
  final String guideAsset;
  final Rect breadRectNorm; // 0~1
  final double guideInsetPct;
  final ValueChanged<double> onProgress; // 0..1
  final VoidCallback onDone;
  final double targetCoverage; // 예: 0.70
  final double snapRadiusPx;
  final int stampRadiusPx;
  final int sampleStridePx;

  const JamImageGuideLayer({
    super.key,
    required this.guideAsset,
    required this.breadRectNorm,
    required this.guideInsetPct,
    required this.onProgress,
    required this.onDone,
    required this.targetCoverage,
    this.snapRadiusPx = 28,
    this.stampRadiusPx = 8,
    this.sampleStridePx = 4,
  });

  @override
  State<JamImageGuideLayer> createState() => _JamImageGuideLayerState();
}

class _JamImageGuideLayerState extends State<JamImageGuideLayer> {
  ui.Image? _maskImg;
  Uint8List? _rgba;
  int _gw = 0, _gh = 0;

  // 앵커 4개 (그리드 좌표)
  late Offset _leftAnchorGrid;
  late Offset _rightAnchorGrid;
  late Offset _topAnchorGrid;
  late Offset _bottomAnchorGrid;

  // 이번 시도의 목표 앵커(반대편)
  Offset? _targetEndAnchor;

  // 마지막 포인터의 "마스크 픽셀 좌표"
  Offset? _lastMaskPt;

  // 사각/스케일
  late Rect _breadRect;
  late Rect _guideRect;
  late double _mx, _my;

  // 격자 & 커버리지
  late int _gridW, _gridH, _stride;
  late List<bool> _coveredGrid;
  int _totalSamples = 0, _coveredSamples = 0;

  final List<Offset> _stroke = [];

  bool get _ready => _maskImg != null && _rgba != null;
  double get _coverage =>
      _totalSamples == 0 ? 0.0 : _coveredSamples / _totalSamples;

  // 좌/우/상/하 끝 칼럼/행
  int _minGXEdge = 0, _maxGXEdge = 0;
  int _minGYEdge = 0, _maxGYEdge = 0;

  // 주축 감지: true면 가로형(좌↔우), false면 세로형(상↔하)
  bool _useHorizontal = true;

  // 밴드/슬랙/커버리지
  static const double _kEndBandPct = 0.10; // 끝 도달 밴드 폭(주축 기준)
  static const double _kOrthoSlackPct = 0.50; // 직교축 슬랙(비율)
  static const double _kCoverageGrace = 0.90; // 커버리지 그레이스

  void _resetAttempt() {
    _stroke.clear();
    _coveredGrid = List<bool>.filled(_gridW * _gridH, false);
    _coveredSamples = 0;
    _lastMaskPt = null;
    _targetEndAnchor = null;
    widget.onProgress(0.0);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMask();
  }

  Future<void> _loadMask() async {
    final size = MediaQuery.of(context).size;

    _breadRect = Rect.fromLTWH(
      widget.breadRectNorm.left * size.width,
      widget.breadRectNorm.top * size.height,
      widget.breadRectNorm.width * size.width,
      widget.breadRectNorm.height * size.height,
    );

    final insetW = _breadRect.width * widget.guideInsetPct;
    final insetH = _breadRect.height * widget.guideInsetPct;

    _guideRect = Rect.fromLTWH(
      _breadRect.left + insetW,
      _breadRect.top + insetH,
      _breadRect.width - 2 * insetW,
      _breadRect.height - 2 * insetH,
    );

    // guideRect 크기로 가이드 디코딩
    final bytes = await rootBundle.load(widget.guideAsset);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: _guideRect.width.toInt().clamp(1, 4096),
      targetHeight: _guideRect.height.toInt().clamp(1, 4096),
    );
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (!mounted) return;
    _maskImg = img;
    _rgba = byteData!.buffer.asUint8List();
    _gw = img.width;
    _gh = img.height;

    _mx = _gw / _guideRect.width;
    _my = _gh / _guideRect.height;

    // 격자 구축
    _stride = widget.sampleStridePx.clamp(2, 16);
    _gridW = (_gw + _stride - 1) ~/ _stride;
    _gridH = (_gh + _stride - 1) ~/ _stride;
    _coveredGrid = List<bool>.filled(_gridW * _gridH, false);

    // 총 샘플 수 & 엣지 탐색
    _totalSamples = 0;

    int minGX = 1 << 30, maxGX = -1;
    int minGY = 1 << 30, maxGY = -1;

    // 좌/우 앵커 계산용 누적
    int sumGYMin = 0, cntGYMin = 0;
    int sumGYMax = 0, cntGYMax = 0;

    // 상/하 앵커 계산용 누적
    int sumGXMin = 0, cntGXMin = 0;
    int sumGXMax = 0, cntGXMax = 0;

    for (int gy = 0; gy < _gridH; gy++) {
      for (int gx = 0; gx < _gridW; gx++) {
        if (_alphaOnAtGrid(gx, gy)) {
          _totalSamples++;

          // X 엣지
          if (gx < minGX) {
            minGX = gx;
            sumGYMin = gy;
            cntGYMin = 1;
          } else if (gx == minGX) {
            sumGYMin += gy;
            cntGYMin++;
          }
          if (gx > maxGX) {
            maxGX = gx;
            sumGYMax = gy;
            cntGYMax = 1;
          } else if (gx == maxGX) {
            sumGYMax += gy;
            cntGYMax++;
          }

          // Y 엣지
          if (gy < minGY) {
            minGY = gy;
            sumGXMin = gx;
            cntGXMin = 1;
          } else if (gy == minGY) {
            sumGXMin += gx;
            cntGXMin++;
          }
          if (gy > maxGY) {
            maxGY = gy;
            sumGXMax = gx;
            cntGXMax = 1;
          } else if (gy == maxGY) {
            sumGXMax += gx;
            cntGXMax++;
          }
        }
      }
    }

    // 좌/우 앵커(Y는 해당 엣지의 평균)
    final leftGY = cntGYMin == 0 ? _gridH / 2.0 : (sumGYMin / cntGYMin);
    final rightGY = cntGYMax == 0 ? _gridH / 2.0 : (sumGYMax / cntGYMax);
    _leftAnchorGrid = Offset(minGX.toDouble(), leftGY);
    _rightAnchorGrid = Offset(maxGX.toDouble(), rightGY);

    // 상/하 앵커(X는 해당 엣지의 평균)
    final topGX = cntGXMin == 0 ? _gridW / 2.0 : (sumGXMin / cntGXMin);
    final bottomGX = cntGXMax == 0 ? _gridW / 2.0 : (sumGXMax / cntGXMax);
    _topAnchorGrid = Offset(topGX, minGY.toDouble());
    _bottomAnchorGrid = Offset(bottomGX, maxGY.toDouble());

    // 엣지 저장
    _minGXEdge = minGX < 0 ? 0 : minGX;
    _maxGXEdge = maxGX < 0 ? _gridW - 1 : maxGX;
    _minGYEdge = minGY < 0 ? 0 : minGY;
    _maxGYEdge = maxGY < 0 ? _gridH - 1 : maxGY;

    // 주축 결정: 가로 폭 vs 세로 높이
    final spanX = (_maxGXEdge - _minGXEdge).abs();
    final spanY = (_maxGYEdge - _minGYEdge).abs();
    _useHorizontal = spanX >= spanY;

    _coveredSamples = 0;
    _lastMaskPt = null;
    _targetEndAnchor = null;
    _stroke.clear();

    setState(() {});
  }

  /// 알파 존재 여부(격자 좌표 -> 실제 샘플 픽셀)
  bool _alphaOnAtGrid(int gx, int gy) {
    final x = (gx * _stride).clamp(0, _gw - 1);
    final y = (gy * _stride).clamp(0, _gh - 1);
    final a = _rgba![(y * _gw + x) * 4 + 3];
    return a > 32;
  }

  // 화면→마스크/마스크→화면
  Offset _toMask(Offset screenPt) => Offset(
        (screenPt.dx - _guideRect.left) * _mx,
        (screenPt.dy - _guideRect.top) * _my,
      );

  Offset _toScreen(Offset maskPt) => Offset(
        _guideRect.left + maskPt.dx / _mx,
        _guideRect.top + maskPt.dy / _my,
      );

  // 점-사각형 최소거리
  double _distanceToRect(Offset p, Rect r) {
    final dx = (p.dx < r.left)
        ? (r.left - p.dx)
        : (p.dx > r.right)
            ? (p.dx - r.right)
            : 0.0;
    final dy = (p.dy < r.top)
        ? (r.top - p.dy)
        : (p.dy > r.bottom)
            ? (p.dy - r.bottom)
            : 0.0;
    return sqrt(dx * dx + dy * dy);
  }

  // 화면 점을 가이드 선 근처의 가장 가까운 마스크 픽셀로 스냅
  Offset? _nearestMaskPoint(Offset rawScreen) {
    if (_distanceToRect(rawScreen, _guideRect) > widget.snapRadiusPx) {
      return null;
    }

    final local = Offset(
      (rawScreen.dx - _guideRect.left).clamp(0.0, _guideRect.width),
      (rawScreen.dy - _guideRect.top).clamp(0.0, _guideRect.height),
    );
    final m = Offset(local.dx * _mx, local.dy * _my);

    final rMask = max(1, (widget.snapRadiusPx * _mx).ceil());
    double bestD2 = 1e12;
    Offset? best;
    final cx = m.dx.round(), cy = m.dy.round();

    for (int dy = -rMask; dy <= rMask; dy++) {
      final y = cy + dy;
      if (y < 0 || y >= _gh) continue;
      for (int dx = -rMask; dx <= rMask; dx++) {
        final x = cx + dx;
        if (x < 0 || x >= _gw) continue;
        final a = _rgba![(y * _gw + x) * 4 + 3];
        if (a <= 32) continue;
        final d2 = (dx * dx + dy * dy).toDouble();
        if (d2 < bestD2) {
          bestD2 = d2;
          best = Offset(x.toDouble(), y.toDouble());
        }
      }
    }
    if (best == null) return null;
    if (sqrt(bestD2) > widget.snapRadiusPx * _mx) return null;
    return _toScreen(best);
  }

  // 격자에 도장
  void _stampAtMaskGrid(Offset maskPt) {
    final cx = (maskPt.dx / _stride).round();
    final cy = (maskPt.dy / _stride).round();
    final rGrid = max(1, (widget.stampRadiusPx / _stride).ceil());

    for (int gy = cy - rGrid; gy <= cy + rGrid; gy++) {
      if (gy < 0 || gy >= _gridH) continue;
      for (int gx = cx - rGrid; gx <= cx + rGrid; gx++) {
        if (gx < 0 || gx >= _gridW) continue;
        if ((gx - cx) * (gx - cx) + (gy - cy) * (gy - cy) > rGrid * rGrid) {
          continue;
        }

        final idx = gy * _gridW + gx;
        if (!_coveredGrid[idx] && _alphaOnAtGrid(gx, gy)) {
          _coveredGrid[idx] = true;
          _coveredSamples++;
        }
      }
    }
  }

  // 진행 업데이트(성공 호출 없음)
  void _updateProgress(Offset maskPt) {
    final cov = _coverage;
    widget.onProgress(cov);
    _lastMaskPt = maskPt; // 마지막 마스크 좌표 기록
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    return Stack(
      children: [
        // 반투명 가이드
        Positioned.fromRect(
          rect: _guideRect,
          child: Opacity(
            opacity: 0.35,
            child: RawImage(image: _maskImg, fit: BoxFit.fill),
          ),
        ),
        // 제스처 + 스트로크
        Positioned.fill(
          child: GestureDetector(
            onPanStart: (d) {
              _resetAttempt(); // 항상 새 시도
              final snapped = _nearestMaskPoint(d.localPosition);
              if (snapped == null) return;

              // 시작점 그리드 좌표
              final m = _toMask(snapped);
              final gm = Offset(m.dx / _stride, m.dy / _stride);

              // 시작 앵커에 가까운 쪽을 start로 보고, 반대편을 목표 end로
              if (_useHorizontal) {
                final distL = (gm - _leftAnchorGrid).distance;
                final distR = (gm - _rightAnchorGrid).distance;
                _targetEndAnchor =
                    (distL <= distR) ? _rightAnchorGrid : _leftAnchorGrid;
              } else {
                final distT = (gm - _topAnchorGrid).distance;
                final distB = (gm - _bottomAnchorGrid).distance;
                _targetEndAnchor =
                    (distT <= distB) ? _bottomAnchorGrid : _topAnchorGrid;
              }

              _stroke.add(snapped);
              _stampAtMaskGrid(m);
              _updateProgress(m);
              setState(() {});
            },
            onPanUpdate: (d) {
              final snapped = _nearestMaskPoint(d.localPosition);
              if (snapped == null) return;
              if (_stroke.isEmpty || (_stroke.last - snapped).distance >= 2.0) {
                _stroke.add(snapped);
                final m = _toMask(snapped);
                _stampAtMaskGrid(m);
                _updateProgress(m);
                setState(() {});
              }
            },
            onPanEnd: (d) {
              final cov = _coverage;

              bool endReached = false;
              if (_lastMaskPt != null) {
                final gm = Offset(
                  _lastMaskPt!.dx / _stride,
                  _lastMaskPt!.dy / _stride,
                );

                if (_useHorizontal) {
                  // X 밴드 + Y 슬랙
                  final bandGX = (_gridW * _kEndBandPct).ceil().clamp(
                        1,
                        _gridW,
                      );
                  final leftBandMaxX = (_minGXEdge + bandGX).clamp(
                    0,
                    _gridW - 1,
                  );
                  final rightBandMinX = (_maxGXEdge - bandGX).clamp(
                    0,
                    _gridW - 1,
                  );

                  final ySlack = (_gridH * _kOrthoSlackPct * 0.5).ceil();
                  final centerY = _gridH / 2.0;
                  final inYSlack = (gm.dy - centerY).abs() <= ySlack;

                  final inLeftBand = gm.dx <= leftBandMaxX;
                  final inRightBand = gm.dx >= rightBandMinX;

                  endReached = (inLeftBand || inRightBand) && inYSlack;
                } else {
                  // Y 밴드 + X 슬랙  ← 세로형 가이드
                  final bandGY = (_gridH * _kEndBandPct).ceil().clamp(
                        1,
                        _gridH,
                      );
                  final topBandMaxY = (_minGYEdge + bandGY).clamp(
                    0,
                    _gridH - 1,
                  );
                  final bottomBandMinY = (_maxGYEdge - bandGY).clamp(
                    0,
                    _gridH - 1,
                  );

                  final xSlack = (_gridW * _kOrthoSlackPct * 0.5).ceil();
                  final centerX = _gridW / 2.0;
                  final inXSlack = (gm.dx - centerX).abs() <= xSlack;

                  final inTopBand = gm.dy <= topBandMaxY;
                  final inBottomBand = gm.dy >= bottomBandMinY;

                  endReached = (inTopBand || inBottomBand) && inXSlack;
                }
              }

              // 커버리지 그레이스 적용
              final covNeed = (widget.targetCoverage * _kCoverageGrace).clamp(
                0.0,
                1.0,
              );

              final success = endReached && cov >= covNeed;

              if (success) {
                widget.onDone();
              } else {
                // ✅ 실패 시 오디오 다시 재생
                // ❗ State 위젯(_JamSpreadFlowPageState)의 메서드를 호출
                if (mounted) {
                  (context.findAncestorStateOfType<_JamSpreadFlowPageState>())
                      ?._playAudio(_audioDraw);
                }
                _resetAttempt();
              }
            },
            child: CustomPaint(
              painter: _JamStrokePainter(
                stroke: _stroke,
                maskImage: _maskImg!, // _ready일 때만 빌드하므로 안전
                maskSrcRect: Rect.fromLTWH(
                  0,
                  0,
                  _gw.toDouble(),
                  _gh.toDouble(),
                ),
                maskDstRect: _guideRect,
                strokeColor: const ui.Color.fromARGB(255, 0, 47, 255), // 파란 펜
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* 스트로크 렌더러 */
class _JamStrokePainter extends CustomPainter {
  final List<Offset> stroke;

  // 마스킹용 이미지와 Src/Dst 사각형
  final ui.Image maskImage;
  final Rect maskSrcRect;
  final Rect maskDstRect;
  final ui.Color strokeColor;

  _JamStrokePainter({
    required this.stroke,
    required this.maskImage,
    required this.maskSrcRect,
    required this.maskDstRect,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stroke.length < 2) return;

    // 1) 경로 구성
    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }

    // 2) 마스킹 레이어 시작 (가이드 영역만 레이어)
    canvas.saveLayer(maskDstRect, Paint());

    // 3) 스트로크 먼저 그리기 (사용자 펜 컬러)
    final baseWidth = max(20.0, size.shortestSide * 0.028);
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = baseWidth;
    canvas.drawPath(path, strokePaint);

    // 4) 가이드 알파로 "클립"만 — 가이드 색을 보이지 않게(dstIn)
    canvas.drawImageRect(
      maskImage,
      maskSrcRect,
      maskDstRect,
      Paint()..blendMode = BlendMode.dstIn,
    );

    // 5) 레이어 종료
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JamStrokePainter old) =>
      old.stroke != stroke ||
      old.maskImage != maskImage ||
      old.maskSrcRect != maskSrcRect ||
      old.maskDstRect != maskDstRect ||
      old.strokeColor != strokeColor;
}

/* 리워드 팝업 */
class _RewardPopup extends StatelessWidget {
  const _RewardPopup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Container(
        width: 360,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4),
            Image(
              image: AssetImage(_rewardApple),
              height: 72,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 14),
            Text(
              '이번 나무의 사과를 획득했어요!\n잠시 후 나무로 돌아가요~',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5A4032),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
