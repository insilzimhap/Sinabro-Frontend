// 레벨 2 열매 4 모음2 서버 연결 완료
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart'; // ✅ Selvy 캔버스

import 'package:http/http.dart' as http; // ⭐️ 1. http 패키지
import 'dart:convert'; // ⭐️ 2. json 변환용
import 'package:sinabro/config.dart'; // ⭐️ 3. baseUrl 사용

import 'package:audioplayers/audioplayers.dart'; // 오디오 패키지

/// ─────────────────────────────────────────────────────────────────────────
/// 스펙: 모음(2-4) — mask / trace / preview를 자소별로 개별 조정
class VowelLessonSpec4 {
  final String key; // 'ya','yae','yeo','ye','yo','yu','wa','wae','we','ui'
  final String bigChar; // ㅑ …
  final String nameKo; // 야 …
  final String wordLabel; // 양파, 얘기 …
  final String wordIconAsset; // 아이콘

  // Mask
  final String maskAsset;
  final double maskScale; // 기본 1.0
  final Offset maskOffset; // 기본 Offset.zero

  // Trace(획)
  final List<String> traceAssets;
  final List<double> traceScales; // 각 획별 스케일 (생략 시 1.0)
  final List<Offset> traceOffsets; // 각 획별 오프셋 (생략 시 Offset(0,-2))

  // Preview
  final String previewAsset;
  final double previewScale; // 기본 1.0
  final Offset previewOffset; // 기본 Offset.zero

  const VowelLessonSpec4({
    required this.key,
    required this.bigChar,
    required this.nameKo,
    required this.wordLabel,
    required this.wordIconAsset,
    required this.maskAsset,
    this.maskScale = 1.0,
    this.maskOffset = Offset.zero,
    required this.traceAssets,
    this.traceScales = const [],
    this.traceOffsets = const [],
    required this.previewAsset,
    this.previewScale = 1.0,
    this.previewOffset = Offset.zero,
  });
}

// 공통 경로
const String _base = 'assets/img/contents/studyWrite/';
const String _introImg = '${_base}twin4.png'; // ✅ 인트로 이미지

// 오디오 경로 및 파일명 매핑
const _audioDir = 'assets/audio/contents/studyWrite/level2/';
const _audioIntroVowel2 = '${_audioDir}write4_study_intro_04.mp3'; // 모음 쌍둥이 인트로
const _audioRepeat = '${_audioDir}write4_repeat.mp3'; // 따라 써봐요!

// 레슨 키 → 오디오 파일명 베이스
const Map<String, String> _audioKeyMapVowel4 = {
  'ya': 'ya',
  'yae': 'yae',
  'yeo': 'yeo',
  'ye': 'ye',
  'yo': 'yo',
  'yu': 'yu',
  'wa': 'wa',
  'wae': 'wae',
  'we': 'we',
  'ui': 'ui',
};

// 오디오 파일 헬퍼
String _audioBase(String k) => _audioKeyMapVowel4[k] ?? k;
String _letterAudio(String k) => '${_audioDir}write4_${_audioBase(k)}_00.mp3';
String _wordAudio(String k) => '${_audioDir}write4_${_audioBase(k)}_01.mp3';
String _doneAudio(String k) => '${_audioDir}write4_${_audioBase(k)}_02.mp3';

/// ★ 여기 숫자들만 수정하면 글자별로 개별 조정됩니다.
const Map<String, VowelLessonSpec4> VOWEL_LESSONS4 = {
  'ya': VowelLessonSpec4(
    key: 'ya',
    bigChar: 'ㅑ',
    nameKo: '야',
    wordLabel: '양파',
    wordIconAsset: '${_base}onion.png',
    maskAsset: '${_base}ya_mask.png',
    maskScale: 0.4,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}ya_trace1.png'],
    traceScales: [0.7],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}ya_preview.png',
    previewScale: 0.3,
    previewOffset: Offset(0, 30),
  ),
  'yae': VowelLessonSpec4(
    key: 'yae',
    bigChar: 'ㅒ',
    nameKo: '얘',
    wordLabel: '얘기',
    wordIconAsset: '${_base}talk.png',
    maskAsset: '${_base}yae_mask.png',
    maskScale: 0.4,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}yae_trace1.png'],
    traceScales: [0.8],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}yae_preview.png',
    previewScale: 0.3,
    previewOffset: Offset(0, 30),
  ),
  'yeo': VowelLessonSpec4(
    key: 'yeo',
    bigChar: 'ㅕ',
    nameKo: '여',
    wordLabel: '여우',
    wordIconAsset: '${_base}fox.png',
    maskAsset: '${_base}yeo_mask.png',
    maskScale: 0.4,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}yeo_trace1.png'],
    traceScales: [0.8],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}yeo_preview.png',
    previewScale: 0.3,
    previewOffset: Offset(0, 30),
  ),
  'ye': VowelLessonSpec4(
    key: 'ye',
    bigChar: 'ㅖ',
    nameKo: '예',
    wordLabel: '계단',
    wordIconAsset: '${_base}stairs.png',
    maskAsset: '${_base}ye_mask.png',
    maskScale: 0.3,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}ye_trace1.png'],
    traceScales: [2],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}ye_preview.png',
    previewScale: 0.4,
    previewOffset: Offset(0, 30),
  ),
  'yo': VowelLessonSpec4(
    key: 'yo',
    bigChar: 'ㅛ',
    nameKo: '요',
    wordLabel: '요리',
    wordIconAsset: '${_base}cooking.png',
    maskAsset: '${_base}yo_mask.png',
    maskScale: 0.6,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}yo_trace1.png'],
    traceScales: [1.8],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}yo_preview.png',
    previewScale: 1.0,
    previewOffset: Offset(0, 30),
  ),
  'yu': VowelLessonSpec4(
    key: 'yu',
    bigChar: 'ㅠ',
    nameKo: '유',
    wordLabel: '휴지',
    wordIconAsset: '${_base}tissue.png',
    maskAsset: '${_base}yu_mask.png',
    maskScale: 0.6,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}yu_trace1.png'],
    traceScales: [1.9],
    traceOffsets: [Offset(0, 4)],
    previewAsset: '${_base}yu_preview.png',
    previewScale: 1.0,
    previewOffset: Offset(0, 30),
  ),
  'wa': VowelLessonSpec4(
    key: 'wa',
    bigChar: 'ㅘ',
    nameKo: '와',
    wordLabel: '과일',
    wordIconAsset: '${_base}fruit.png',
    maskAsset: '${_base}wa_mask.png',
    maskScale: 0.8,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}wa_trace1.png'],
    traceScales: [1.0],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}wa_preview.png',
    previewScale: 0.8,
    previewOffset: Offset(0, 30),
  ),
  'wae': VowelLessonSpec4(
    key: 'wae',
    bigChar: 'ㅙ',
    nameKo: '왜',
    wordLabel: '돼지',
    wordIconAsset: '${_base}pig.png',
    maskAsset: '${_base}wae_mask.png',
    maskScale: 0.8,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}wae_trace1.png'],
    traceScales: [1.0],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}wae_preview.png',
    previewScale: 0.8,
    previewOffset: Offset(0, 30),
  ),
  'we': VowelLessonSpec4(
    key: 'we',
    bigChar: 'ㅞ',
    nameKo: '웨',
    wordLabel: '스웨터',
    wordIconAsset: '${_base}sweater.png',
    maskAsset: '${_base}we_mask.png',
    maskScale: 0.8,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}we_trace1.png'],
    traceScales: [1.0],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}we_preview.png',
    previewScale: 0.8,
    previewOffset: Offset(0, 30),
  ),
  'ui': VowelLessonSpec4(
    key: 'ui',
    bigChar: 'ㅢ',
    nameKo: '의',
    wordLabel: '의자',
    wordIconAsset: '${_base}chair.png',
    maskAsset: '${_base}ui_mask.png',
    maskScale: 0.7,
    maskOffset: Offset.zero,
    traceAssets: ['${_base}ui_trace1.png'],
    traceScales: [1.0],
    traceOffsets: [Offset(0, -2)],
    previewAsset: '${_base}ui_preview.png',
    previewScale: 0.7,
    previewOffset: Offset(0, 30),
  ),
};

/// 이동 순서
const List<String> VOWEL_ORDER4 = [
  'ya',
  'yae',
  'yeo',
  'ye',
  'yo',
  'yu',
  'wa',
  'wae',
  'we',
  'ui',
];

/// ─────────────────────────────────────────────────────────────────────────
/// 페이지 (writing_2_4.dart)
class Writing24Page extends StatefulWidget {
  final String childId;
  final String lesson; // 시작키(기본: ya)
  final String fruitId; // ⭐️ fruitId 변수 추가!

  final bool showIntro; // ✅ 인트로 표시 여부

  const Writing24Page({
    super.key,
    required this.childId,
    this.lesson = 'ya',
    this.showIntro = true,
    required this.fruitId,
  });

  @override
  State<Writing24Page> createState() => _Writing24PageState();
}

class _Writing24PageState extends State<Writing24Page> {
  int step = 0; // 0: 따라쓰기, 1: 완료
  late bool _showIntro; // ✅ 인트로 상태
  final _canvasKey = GlobalKey<WritingCanvasState>(); // ✅ 캔버스 제어용

  // ✅ 마지막 레슨 자동 팝업 예약/중복 방지
  bool get _isFinalLesson => widget.lesson == VOWEL_ORDER4.last;
  bool _rewardShowing = false;
  bool _finalPopupScheduled = false;
  Timer? _finalPopupTimer;

  // ⭐️ API 연동 변수 추가
  late DateTime _startTime; // 학습 시작 시간
  bool _apiCallSent = false; // API 중복 호출 방지 플래그

  // 오디오 플레이어/구독
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSub;

  @override
  void initState() {
    super.initState();
    _showIntro = widget.showIntro;

    _startTime = DateTime.now(); // ⭐️ 시간 측정 시작!

    // 인트로 또는 학습 시퀀스 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showIntro) {
        _playAudio(_audioIntroVowel2);
      } else {
        _playWriteScreenSequence();
      }
    });
  }

  @override
  void dispose() {
    _finalPopupTimer?.cancel();
    // 오디오 리소스 정리
    _playerCompleteSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  VowelLessonSpec4 get spec =>
      VOWEL_LESSONS4[widget.lesson] ?? VOWEL_LESSONS4['ya']!;

  int _requiredStrokes(String key) {
    switch (key) {
      case 'ya':
        return 3;
      case 'yae':
        return 4;
      case 'yeo':
        return 3;
      case 'ye':
        return 4;
      case 'yo':
        return 3;
      case 'yu':
        return 3;
      case 'wa':
        return 4;
      case 'wae':
        return 5;
      case 'we':
        return 5;
      case 'ui':
        return 2;
      default:
        return 1;
    }
  }

  /// ⭐️ (신규) 학습 완료 API 호출 함수 - JWT 없이
  Future<void> _uploadStudyResult() async {
    // 1. 걸린 시간 계산
    final timeSpentSecs = DateTime.now().difference(_startTime).inSeconds;

    // 2. API 엔드포인트
    final url = Uri.parse('$baseUrl/api/study/writing/complete');

    // 3. 전송할 데이터
    final body = json.encode({
      'childId': widget.childId,
      'fruitId': widget.fruitId, // ⭐️ 생성자로 받은 fruitId 사용!
      'isCompleted': true,
      'timeSpentSecs': timeSpentSecs,
    });

    // 4. 헤더 (Content-Type만)
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      // 5. API 호출
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[Writing22] API 연동 성공: fruitId ${widget.fruitId} 완료!');
      } else {
        debugPrint(
            '[Writing22] API 연동 실패: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('[Writing22] API 연동 중 예외 발생: $e');
    }
  }

  String? _nextKey() {
    final i = VOWEL_ORDER4.indexOf(widget.lesson);
    if (i == -1 || i + 1 >= VOWEL_ORDER4.length) return null;
    return VOWEL_ORDER4[i + 1];
  }

  void _backToLobby() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
    );
  }

  // 오디오 재생 유틸
  void _playAudio(String assetPath, {bool loop = false}) {
    if (!mounted) return;
    _audioPlayer.stop();
    _playerCompleteSub?.cancel();
    _audioPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    _audioPlayer.play(AssetSource(assetPath));
  }

  // 순차 재생용 대기
  Future<void> _playAudioAndWait(String assetPath) {
    if (!mounted) return Future.value();
    final c = Completer<void>();
    _playerCompleteSub?.cancel();
    _playAudio(assetPath);
    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (!c.isCompleted) c.complete();
      _playerCompleteSub?.cancel();
    });
    // 안전 타임아웃
    Future.delayed(const Duration(seconds: 5), () {
      if (!c.isCompleted) {
        _playerCompleteSub?.cancel();
        if (mounted) {
          debugPrint('Audio playback timed out: $assetPath');
          c.complete();
        }
      }
    });
    return c.future;
  }

  // 학습 화면 오디오 시퀀스: 글자→단어→(첫 레슨이면)따라써봐요
  Future<void> _playWriteScreenSequence() async {
    if (!mounted) return;
    final lessonKey = widget.lesson;
    final isFirst = VOWEL_ORDER4.first == lessonKey;
    try {
      await _playAudioAndWait(_letterAudio(lessonKey));
      if (!mounted) return;
      await _playAudioAndWait(_wordAudio(lessonKey));
      if (!mounted) return;
      if (isFirst) {
        await _playAudioAndWait(_audioRepeat);
      }
    } catch (e) {
      debugPrint('Write screen sequence error: $e');
    } finally {
      if (mounted) _playerCompleteSub?.cancel();
    }
  }

  String _norm(String s) {
    const map = {
      'ᅣ': 'ㅑ',
      'U+1163': 'ㅑ',
      'ᅤ': 'ㅒ',
      'U+1164': 'ㅒ',
      'ᅧ': 'ㅕ',
      'U+1167': 'ㅕ',
      'ᅨ': 'ㅖ',
      'U+1168': 'ㅖ',
      'ᅭ': 'ㅛ',
      'U+116D': 'ㅛ',
      'ᅲ': 'ㅠ',
      'U+1172': 'ㅠ',
      'ᅪ': 'ㅘ',
      'U+116A': 'ㅘ',
      'ᅫ': 'ㅙ',
      'U+116B': 'ㅙ',
      'ᅰ': 'ㅞ',
      'U+1170': 'ㅞ',
      'ᅴ': 'ㅢ',
      'U+1174': 'ㅢ',
    };
    final t = s.trim();
    return map[t] ?? t;
  }

  void _handleRecognize(String r) {
    final top1Line = r.split('\n').first;
    final cleaned = top1Line.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();
    final got = _norm(cleaned);
    final target = _norm(spec.bigChar);

    if (got.isNotEmpty && got == target) {
      // 완료 오디오 재생
      _playAudio(_doneAudio(widget.lesson));

      // 1. 인식 성공! 완료 단계로 UI 변경
      setState(() => step = 1);

      // ⭐️⭐️⭐️ 2. 여기가 핵심! ⭐️⭐️⭐️
      // 마지막 레슨('ui')이고, API를 아직 안 보냈다면 호출!
      if (_isFinalLesson && !_apiCallSent) {
        _apiCallSent = true; // 중복 호출 방지 플래그 설정
        _uploadStudyResult(); // API 호출 함수 실행!
      }
      // ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️

      // 3. (기존 로직) 마지막 레슨이면 팝업 예약
      if (_isFinalLesson && !_rewardShowing && !_finalPopupScheduled) {
        _finalPopupScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _finalPopupTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) _showRewardPopup(); // 팝업 표시
          });
        });
      }
    } else {
      _canvasKey.currentState?.clearCanvas();
    }
  }

  Future<void> _showRewardPopup() async {
    if (_rewardShowing) return;
    _rewardShowing = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
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
                Image.asset(
                  '${_base}apple_gold.png',
                  height: 56,
                  fit: BoxFit.contain,
                ),
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
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
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
      ),
    );

    _rewardShowing = false;
    if (!mounted) return;
    _backToLobby();
  }

  Future<void> _next() async {
    if (step == 0) {
      setState(() => step = 1);
    } else {
      final k = _nextKey();
      if (k == null) {
        await _showRewardPopup();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Writing24Page(
              childId: widget.childId,
              fruitId: widget.fruitId,
              lesson: k,
              showIntro: false, // ✅ 다음 레슨은 인트로 없이
            ),
          ),
        );
      }
    }
  }

  /// 인트로 화면
  Widget _buildIntro(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 탭 시 학습 시퀀스 오디오 시작
      onTap: () {
        setState(() => _showIntro = false);
        _playWriteScreenSequence();
      },
      child: Container(
        color: const Color(0xFFFFF4F3),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final shortest =
                  (c.maxWidth < c.maxHeight) ? c.maxWidth : c.maxHeight;
              final imgW = shortest * 0.55;

              final double lift = c.maxHeight * 0.16; // 이미지+제목 위로
              final double hintBottom = 120.0; // 하단 문구 여백

              return Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, -lift),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              _introImg,
                              width: imgW,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '모음 친구들이 찾아왔어요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5A4032),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: hintBottom + MediaQuery.of(context).padding.bottom,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3D6).withOpacity(0.95),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4E3B00),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 완료 화면에서만, 마지막 레슨은 숨김
    final showNextFab = !_showIntro && step == 1 && !_isFinalLesson;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: _backToLobby,
        ),
      ),
      body: _showIntro
          ? _buildIntro(context)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: step == 0 ? _buildWrite() : _buildComplete(),
              ),
            ),
      // ✅ FAB은 항상 깔고 보임만 제어(페이드)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: IgnorePointer(
            ignoring: !showNextFab,
            child: AnimatedOpacity(
              opacity: showNextFab ? 1 : 0,
              duration: const Duration(milliseconds: 140),
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: const Color(0xFFD9CCFF),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    _nextKey() == null ? '확인' : '다음',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  /// 1) 따라쓰기 화면 — 보드 축소 + 버튼 위로 띄우기(분리)
  Widget _buildWrite() {
    return LayoutBuilder(
      builder: (context, c) {
        return Row(
          children: [
            // 왼쪽 정보 패널
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, l) {
                  final colW = l.maxWidth;
                  final glyphSize = (colW * 0.65).clamp(160.0, 260.0);
                  final wordSize = (colW * 0.12).clamp(36.0, 52.0);
                  final iconSize = (colW * 0.40).clamp(90.0, 140.0);
                  final labelSize = (colW * 0.11).clamp(28.0, 38.0);
                  final hintW = (colW * 0.56).clamp(170.0, 300.0);

                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ 큰 글자 탭 → 글자 이름 오디오
                            GestureDetector(
                              onTap: () => _playAudio(_letterAudio(spec.key)),
                              child: Text(
                                spec.bigChar,
                                style: TextStyle(
                                  fontSize: glyphSize,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            SizedBox(height: glyphSize * 0.06),
                            // ✅ 글자 이름 탭 → 글자 이름 오디오
                            GestureDetector(
                              onTap: () => _playAudio(_letterAudio(spec.key)),
                              child: Text(
                                spec.nameKo,
                                style: TextStyle(
                                  fontSize: wordSize,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: glyphSize * 0.14),
                            // ✅ 단어 아이콘+라벨 탭 → 단어 오디오
                            GestureDetector(
                              onTap: () => _playAudio(_wordAudio(spec.key)),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    spec.wordIconAsset,
                                    width: iconSize,
                                    height: iconSize,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    spec.wordLabel,
                                    style: TextStyle(
                                      fontSize: labelSize,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 250,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Image.asset(
                              '${_base}hint_tailleft.png',
                              width: 180,
                              fit: BoxFit.contain,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 13, bottom: 8),
                              child: Text(
                                '누르면 들어볼 수 있어요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFDB7C7C),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 오른쪽: 노트패드 + mask/trace + ✍️ WritingCanvas(전체 덮기)
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, box) {
                  // ■ 노트패드 전체 크기 축소
                  final padW = (box.maxWidth * 0.80).clamp(
                    260.0,
                    box.maxHeight * 0.76,
                  );

                  // ■ 내부 마스크/트레이스도 함께 축소
                  const baseMaskScale = 0.74; // 기존 0.80 근처 → 0.74
                  const baseTraceScale = 0.70; // 기존 0.75 근처 → 0.70

                  final maskW = padW * baseMaskScale * spec.maskScale;
                  final traceBaseW = maskW * baseTraceScale;
                  final captionSize = (padW * 0.095).clamp(18.0, 30.0);

                  // 버튼을 보드와 완전히 분리해서 자유 위치에 띄우기 위해 Stack 사용
                  return Stack(
                    children: [
                      // 노트패드(중앙)
                      Positioned.fill(
                        child: Center(
                          child: SizedBox(
                            width: padW,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    '${_base}notepad_frame.png',
                                    fit: BoxFit.contain,
                                  ),
                                  // MASK
                                  SizedBox(
                                    width: maskW,
                                    child: Transform.translate(
                                      offset: spec.maskOffset,
                                      child: Image.asset(
                                        spec.maskAsset,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  // TRACE
                                  ...List.generate(spec.traceAssets.length, (
                                    i,
                                  ) {
                                    final s = (i < spec.traceScales.length)
                                        ? spec.traceScales[i]
                                        : 1.0;
                                    final o = (i < spec.traceOffsets.length)
                                        ? spec.traceOffsets[i]
                                        : const Offset(0, -2);
                                    return SizedBox(
                                      width: traceBaseW * s,
                                      child: Transform.translate(
                                        offset: o,
                                        child: Image.asset(
                                          spec.traceAssets[i],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  }),
                                  // ✍️ WritingCanvas: padW 전체 덮기
                                  SizedBox(
                                    width: padW,
                                    height: padW,
                                    child: WritingCanvas(
                                      key: _canvasKey,
                                      targetChar: spec.bigChar,
                                      candidateSet: [spec.bigChar], // ✅ 최소 후보셋
                                      targetType: "vowel", // ✅ 모음 모드
                                      // 필요 시: requiredStrokes: _requiredStrokes(widget.lesson),
                                      onRecognize: _handleRecognize,
                                    ),
                                  ),
                                  // 안내 문구
                                  Positioned(
                                    bottom: padW * 0.06,
                                    child: Text(
                                      '따라 써봐요!',
                                      style: TextStyle(
                                        fontSize: captionSize,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFFF6B6B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ✅ 채점하기 버튼: 보드와 완전히 분리된 ‘떠 있는’ 버튼
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 24, // 더 올리고 싶으면 더 작은 값으로
                        child: Center(
                          child: SizedBox(
                            width: 200, // 버튼 폭 고정
                            height: 42, // 버튼 높이 고정
                            child: ElevatedButton(
                              onPressed: () => _canvasKey.currentState
                                  ?.recognizeAndCheckText(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD966),
                                foregroundColor: Colors.black87,
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 2) 완료 화면
  Widget _buildComplete() {
    return LayoutBuilder(
      builder: (context, c) {
        final padW = (c.maxWidth * 0.60).clamp(320.0, c.maxHeight * 0.80);
        final basePreviewW = padW * 0.62;
        final previewW = basePreviewW * spec.previewScale;
        final labelSize = (padW * 0.13).clamp(30.0, 42.0);
        final titleSize = (padW * 0.12).clamp(24.0, 34.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: padW,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        '${_base}notepad_frame.png',
                        fit: BoxFit.contain,
                      ),
                      Transform.translate(
                        offset: spec.previewOffset,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              spec.previewAsset,
                              width: previewW,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              spec.nameKo,
                              style: TextStyle(
                                fontSize: labelSize,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '‘${spec.bigChar}’를 학습했어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF7A5C51),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
