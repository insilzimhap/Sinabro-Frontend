// lib/main/studyView/writeStud/page/level2/writing_2_1.dart
// 레벨 2 열매 1 자음/쌍자음 서버 연결 완료

import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:http/http.dart' as http; // ⭐️ http 패키지
import 'dart:convert'; // ⭐️ json 변환용
import 'package:sinabro/config.dart'; // ⭐️ baseUrl 사용
import 'package:audioplayers/audioplayers.dart'; // 오디오 패키지 import

// 인트로 이미지
const _twin1 = 'assets/img/contents/studyWrite/twin1.png';

// 오디오 경로 및 파일명 정의
const _audioDir = 'audio/tts/studyWrite/level2/';
const _audioIntro = '${_audioDir}write4_study_intro_01.mp3'; // 자음 쌍둥이 인트로
const _audioRepeat = '${_audioDir}write4_repeat.mp3'; // 따라 써봐요!

// ✅ 레슨 키 -> 오디오 파일명 중간 부분 매핑
const Map<String, String> _audioKeyMap = {
  // 4세 1번째 열매 자음 내용
  'giyeok': 'giyeok',
  'giyeokssang': 'ssang_giyeok',
  'digeut': 'digeut',
  'digeutssang': 'ssang_digeut',
  'siot': 'siot',
  'siotssang': 'ssang_siot',
  'jieut': 'jieut',
  'jieutssang': 'ssang_jieut',
  'bieup': 'bieup',
  'bieupssang': 'ssang_bieup',
};

// ✅ 오디오 파일명 가져오는 헬퍼 함수들
String _getAudioBaseName(String lessonKey) =>
    _audioKeyMap[lessonKey] ?? lessonKey;
String _getLetterNameAudio(String key) =>
    '${_audioDir}write4_${_getAudioBaseName(key)}_00.mp3'; // 자음 발음(기역)
String _getWordAudio(String key) =>
    '${_audioDir}write4_${_getAudioBaseName(key)}_01.mp3'; // 자음 연상 단어
String _getCompletionAudio(String key) =>
    '${_audioDir}write4_${_getAudioBaseName(key)}_02.mp3'; // 자음 완료 (~를 학습했어요!)

/// ---------------------------------------------------------------------------
/// 레슨 스펙
class LessonSpec {
  final String key;
  final String bigChar;
  final String nameKo;
  final String wordLabel;
  final String wordIconAsset;
  final String maskAsset;
  final List<String> traceAssets;
  final List<Offset> traceOffsets;
  final List<double> traceScales;
  final String previewAsset;

  const LessonSpec({
    required this.key,
    required this.bigChar,
    required this.nameKo,
    required this.wordLabel,
    required this.wordIconAsset,
    required this.maskAsset,
    required this.traceAssets,
    this.traceOffsets = const [],
    this.traceScales = const [],
    required this.previewAsset,
  });
}

/// ---------------------------------------------------------------------------
/// 레슨 정의 (네가 준 것 그대로)
const Map<String, LessonSpec> LESSONS = {
  'giyeok': LessonSpec(
    key: 'giyeok',
    bigChar: 'ㄱ',
    nameKo: '기역',
    wordLabel: '가위',
    wordIconAsset: 'assets/img/contents/studyWrite/scissors.png',
    maskAsset: 'assets/img/contents/studyWrite/giyeok_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/giyeok_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: 'assets/img/contents/studyWrite/giyeok_preview.png',
  ),
  'giyeokssang': LessonSpec(
    key: 'giyeokssang',
    bigChar: 'ㄲ',
    nameKo: '쌍기역',
    wordLabel: '꿀',
    wordIconAsset: 'assets/img/contents/studyWrite/honey.png',
    maskAsset: 'assets/img/contents/studyWrite/giyeokssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/giyeokssang_trace1.png',
      'assets/img/contents/studyWrite/giyeokssang_trace2.png',
    ],
    traceOffsets: [Offset(-90, -5), Offset(90, -2)],
    traceScales: [0.45, 0.45],
    previewAsset: 'assets/img/contents/studyWrite/giyeokssang_preview.png',
  ),
  'digeut': LessonSpec(
    key: 'digeut',
    bigChar: 'ㄷ',
    nameKo: '디귿',
    wordLabel: '다리미',
    wordIconAsset: 'assets/img/contents/studyWrite/iron.png',
    maskAsset: 'assets/img/contents/studyWrite/digeut_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/digeut_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: 'assets/img/contents/studyWrite/digeut_preview.png',
  ),
  'digeutssang': LessonSpec(
    key: 'digeutssang',
    bigChar: 'ㄸ',
    nameKo: '쌍디귿',
    wordLabel: '떡볶이',
    wordIconAsset: 'assets/img/contents/studyWrite/tteokbokki.png',
    maskAsset: 'assets/img/contents/studyWrite/digeutssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/digeutssang_trace1.png',
      'assets/img/contents/studyWrite/digeutssang_trace2.png',
    ],
    traceOffsets: [Offset(-90, -2), Offset(90, -2)],
    traceScales: [0.4, 0.4],
    previewAsset: 'assets/img/contents/studyWrite/digeutssang_preview.png',
  ),
  'siot': LessonSpec(
    key: 'siot',
    bigChar: 'ㅅ',
    nameKo: '시옷',
    wordLabel: '사과',
    wordIconAsset: 'assets/img/contents/studyWrite/apple1.png',
    maskAsset: 'assets/img/contents/studyWrite/siot_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/siot_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [0.8],
    previewAsset: 'assets/img/contents/studyWrite/siot_preview.png',
  ),
  'siotssang': LessonSpec(
    key: 'siotssang',
    bigChar: 'ㅆ',
    nameKo: '쌍시옷',
    wordLabel: '씨앗',
    wordIconAsset: 'assets/img/contents/studyWrite/seed.png',
    maskAsset: 'assets/img/contents/studyWrite/siotssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/siotssang_trace1.png',
      'assets/img/contents/studyWrite/siotssang_trace2.png',
    ],
    traceOffsets: [Offset(-60, -2), Offset(70, -2)],
    traceScales: [0.53, 0.50],
    previewAsset: 'assets/img/contents/studyWrite/siotssang_preview.png',
  ),
  'jieut': LessonSpec(
    key: 'jieut',
    bigChar: 'ㅈ',
    nameKo: '지읒',
    wordLabel: '자동차',
    wordIconAsset: 'assets/img/contents/studyWrite/car.png',
    maskAsset: 'assets/img/contents/studyWrite/jieut_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/jieut_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [0.87],
    previewAsset: 'assets/img/contents/studyWrite/jieut_preview.png',
  ),
  'jieutssang': LessonSpec(
    key: 'jieutssang',
    bigChar: 'ㅉ',
    nameKo: '쌍지읒',
    wordLabel: '짜장면',
    wordIconAsset: 'assets/img/contents/studyWrite/jajangmyeon.png',
    maskAsset: 'assets/img/contents/studyWrite/jieutssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/jieutssang_trace1.png',
      'assets/img/contents/studyWrite/jieutssang_trace2.png',
    ],
    traceOffsets: [Offset(-60, -10), Offset(80, -10)],
    traceScales: [0.5, 0.47],
    previewAsset: 'assets/img/contents/studyWrite/jieutssang_preview.png',
  ),
  'bieup': LessonSpec(
    key: 'bieup',
    bigChar: 'ㅂ',
    nameKo: '비읍',
    wordLabel: '바나나',
    wordIconAsset: 'assets/img/contents/studyWrite/banana.png',
    maskAsset: 'assets/img/contents/studyWrite/bieup_mask.png',
    traceAssets: ['assets/img/contents/studyWrite/bieup_trace.png'],
    traceOffsets: [Offset(0, -2)],
    traceScales: [1.0],
    previewAsset: 'assets/img/contents/studyWrite/bieup_preview.png',
  ),
  'bieupssang': LessonSpec(
    key: 'bieupssang',
    bigChar: 'ㅃ',
    nameKo: '쌍비읍',
    wordLabel: '빵',
    wordIconAsset: 'assets/img/contents/studyWrite/bread1.png',
    maskAsset: 'assets/img/contents/studyWrite/bieupssang_mask.png',
    traceAssets: [
      'assets/img/contents/studyWrite/bieupssang_trace1.png',
      'assets/img/contents/studyWrite/bieupssang_trace2.png',
    ],
    traceOffsets: [Offset(-90, -2), Offset(90, -2)],
    traceScales: [0.43, 0.43],
    previewAsset: 'assets/img/contents/studyWrite/bieupssang_preview.png',
  ),
};

/// 이동 순서
const List<String> LESSON_ORDER = [
  'giyeok',
  'giyeokssang',
  'digeut',
  'digeutssang',
  'siot',
  'siotssang',
  'jieut',
  'jieutssang',
  'bieup',
  'bieupssang',
];

/// (참고용) 레슨별 획 수 — 현재 캔버스에 직접 쓰진 않지만 남겨둠
const Map<String, int> REQUIRED_STROKES = {
  'giyeok': 1,
  'giyeokssang': 2,
  'digeut': 2,
  'digeutssang': 4,
  'siot': 2,
  'siotssang': 4,
  'jieut': 3,
  'jieutssang': 6,
  'bieup': 4,
  'bieupssang': 8,
};

/// ---------------------------------------------------------------------------
/// 페이지
class Writing21Page extends StatefulWidget {
  final String childId;
  final String lesson;
  final bool showIntro;
  final String fruitId; // ⭐️ fruitId 변수 추가됨

  const Writing21Page({
    super.key,
    required this.childId,
    this.lesson = 'giyeok',
    this.showIntro = true,
    required this.fruitId, // ⭐️ 생성자에 fruitId 추가됨
  });

  @override
  State<Writing21Page> createState() => _Writing21PageState();
}

class _Writing21PageState extends State<Writing21Page> {
  late bool _showIntro;
  int step = 0; // 0: 따라쓰기, 1: 학습완료

  final _canvasKey = GlobalKey<WritingCanvasState>();
  bool _rewardShown = false;
  bool get _isFinalLesson => widget.lesson == LESSON_ORDER.last;
  Timer? _finalPopupTimer;
  bool _finalPopupScheduled = false;

  // ⭐️ API 연동을 위한 변수 2개 추가
  late DateTime _startTime; // 학습 시작 시간
  bool _apiCallSent = false; // API 중복 호출 방지 플래그

  // 오디오 플레이어 추가
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription; // 순차 재생용 구독

  LessonSpec get spec => LESSONS[widget.lesson] ?? LESSONS['giyeok']!;

  @override
  void initState() {
    super.initState();
    _showIntro = widget.showIntro;
    _setLessonCandidate(spec.bigChar); // ✅ 네이티브 후보셋 제한

    _startTime = DateTime.now(); // ⭐️ 페이지 시작과 동시에 시간 측정 시작!

    // 오디오 재생 시작 (인트로 또는 바로 학습)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showIntro) {
        _playAudio(_audioIntro);
      } else {
        _playWriteScreenSequence(); // 인트로 없으면 바로 글자 학습 오디오 시작
      }
    });
  }

  @override
  void dispose() {
    _finalPopupTimer?.cancel();
    _playerCompleteSubscription?.cancel(); // 구독 취소
    _audioPlayer.dispose(); // 오디오 플레이어 해제
    super.dispose();
  }

  // ------------------ 오디오 재생 로직 ------------------

  /// 오디오 재생 (기존 재생 중단)
  void _playAudio(String assetPath, {bool isLooping = false}) {
    if (!mounted) return;
    _audioPlayer.stop();
    _playerCompleteSubscription?.cancel(); // 이전 구독 취소
    _audioPlayer
        .setReleaseMode(isLooping ? ReleaseMode.loop : ReleaseMode.release);
    _audioPlayer.play(AssetSource(assetPath));
  }

  /// 오디오 재생하고 끝나기를 기다림 (순차 재생용)
  Future<void> _playAudioAndWait(String assetPath) {
    if (!mounted) return Future.value(); // 위젯 종료 시 즉시 반환

    final completer = Completer<void>();
    _playerCompleteSubscription?.cancel(); // 이전 구독 취소

    _playAudio(assetPath); // 재생 시작

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _playerCompleteSubscription?.cancel(); // 완료 후 구독 취소
    });

    // 타임아웃 추가 (예: 5초 후 완료 안되면 에러 처리)
    Future.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        _playerCompleteSubscription?.cancel();
        if (mounted) {
          // mounted 체크 추가
          debugPrint('Audio playback timed out: $assetPath');
          completer.complete(); // 타임아웃 시에도 완료 처리 (다음으로 넘어가게)
        }
      }
    });

    return completer.future;
  }

  /// 글자 학습 화면 오디오 순차 재생
  Future<void> _playWriteScreenSequence() async {
    if (!mounted) return; // ✅ 시작 전 체크

    final lessonKey = widget.lesson;
    final bool isFirstLesson = LESSON_ORDER.first == lessonKey;

    try {
      // 1. 글자 이름 재생
      await _playAudioAndWait(_getLetterNameAudio(lessonKey));
      if (!mounted) return; // ✅ 재생 후 체크

      // 2. 단어 재생
      await _playAudioAndWait(_getWordAudio(lessonKey));
      if (!mounted) return; // ✅ 재생 후 체크

      // 3. 첫 글자일 때만 "따라 써봐요!" 재생
      if (isFirstLesson) {
        await _playAudioAndWait(_audioRepeat);
      }
    } catch (e) {
      debugPrint("Error playing write screen sequence: $e");
    } finally {
      if (mounted) {
        _playerCompleteSubscription?.cancel(); // 혹시 모를 구독 정리
      }
    }
  }
  // --------------------------------------------------------

  String? _nextLessonKey() {
    final i = LESSON_ORDER.indexOf(widget.lesson);
    if (i == -1 || i + 1 >= LESSON_ORDER.length) return null;
    return LESSON_ORDER[i + 1];
  }

  String _normalizeKoreanLabel(String s) {
    final t = s.trim();
    const map = {
      'ᄀ': 'ㄱ',
      'U+1100': 'ㄱ',
      'ᄁ': 'ㄲ',
      'U+1101': 'ㄲ',
      'ᄃ': 'ㄷ',
      'U+1103': 'ㄷ',
      'ᄄ': 'ㄸ',
      'U+1104': 'ㄸ',
      'ᄉ': 'ㅅ',
      'U+1109': 'ㅅ',
      'ᄊ': 'ㅆ',
      'U+110A': 'ㅆ',
      'ᄌ': 'ㅈ',
      'U+110C': 'ㅈ',
      'ᄍ': 'ㅉ',
      'U+110D': 'ㅉ',
      'ᄇ': 'ㅂ',
      'U+1107': 'ㅂ',
      'ᄈ': 'ㅃ',
      'U+1108': 'ㅃ',
    };
    return map[t] ?? t;
  }

  /// ⭐️ (수정됨) 학습 완료 API 호출 함수 - JWT 토큰 처리 제거
  Future<void> _uploadStudyResult() async {
    // 1. 걸린 시간 계산
    final timeSpentSecs = DateTime.now().difference(_startTime).inSeconds;

    // 2. API 엔드포인트
    final url = Uri.parse('$baseUrl/api/study/writing/complete');

    // 3. 전송할 데이터 (StudyCompletionDto)
    final body = json.encode({
      'childId': widget.childId,
      'fruitId': widget.fruitId, // ⭐️ 생성자로 받은 fruitId 사용!
      'isCompleted': true,
      'timeSpentSecs': timeSpentSecs,
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[Writing21] API 연동 성공: fruitId ${widget.fruitId} 완료!');
      } else {
        debugPrint(
            '[Writing21] API 연동 실패: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('[Writing21] API 연동 중 예외 발생: $e');
    }
  }

  /// 🔁 인식 콜백: top1 줄만 쓰고 [n] 토큰 제거 후 정규화 비교
  void _onRecognizeFromSelvy(String recognized) {
    final top1Line = recognized.split('\n').first;
    final cleaned = top1Line.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();

    final norm = _normalizeKoreanLabel(cleaned);
    final target = _normalizeKoreanLabel(spec.bigChar);

    if (norm.isNotEmpty && norm == target) {
      // 1. 완료 오디오 재생
      _playAudio(_getCompletionAudio(widget.lesson));

      // 2. 인식 성공! 완료 단계(step 1)로 UI 변경
      setState(() => step = 1);

      // ⭐️ 3. (핵심!) 이게 마지막 레슨인지, API를 아직 안 보냈는지 확인!
      if (_isFinalLesson && !_apiCallSent) {
        _apiCallSent = true; // ⭐️ 중복 호출 방지!
        _uploadStudyResult(); // ⭐️ API 호출 함수 실행!
      }

      // 4. (기존 로직) 마지막 레슨이면 리워드 팝업 예약
      if (_isFinalLesson && !_rewardShown && !_finalPopupScheduled) {
        _finalPopupScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _finalPopupTimer = Timer(const Duration(seconds: 3), () {
            if (!mounted || step != 1 || _rewardShown) return;
            _showRewardPopup();
          });
        });
      }
    } else {
      _canvasKey.currentState?.clearCanvas();
      // Next? : 실패 시 오디오 재생? 요구사항에는 없었지만 필요하면 추가
      // _playAudio(_audioRepeat); // 예: "따라 써봐요!" 다시 재생
    }
  }

  Future<void> _setLessonCandidate(String targetChar) async {
    try {
      await SelvyRecognizer.setCandidateSet([targetChar]);
      // 언어 타입은 WritingCanvas가 targetType에 맞춰 setLanguage() 해줌
      debugPrint('[Writing21] setCandidateSet([$targetChar])');
    } catch (e) {
      debugPrint('[Writing21] setCandidateSet 실패: $e');
    }
  }

  void _goBackToAppleTree() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
    );
  }

  // 다음 레슨 이동 시 오디오 재생 추가
  void _goNext() {
    final nextKey = _nextLessonKey();
    if (nextKey == null) {
      _goBackToAppleTree();
    } else {
      // 다음 레슨 오디오 재생 예약 (페이지 전환 후 재생되도록)
      // 중요: 다음 페이지 initState에서 오디오가 재생되므로 여기서는 제거
      // Future.delayed(Duration(milliseconds: 100), () {
      //   _playWriteScreenSequenceFor(nextKey); // 다음 키로 오디오 재생
      // });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Writing21Page(
            childId: widget.childId,
            lesson: nextKey,
            showIntro: false,
            fruitId: widget.fruitId, // ⭐️ fruitId 계속 넘겨주기
          ),
        ),
      );
    }
  }

  Widget _buildIntro(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 인트로 화면 탭 시 글자 학습 오디오 시작
        _playWriteScreenSequence();
        setState(() => _showIntro = false);
      },
      child: Container(
        color: const Color(0xFFFFF4F3),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final shortest =
                  (c.maxWidth < c.maxHeight) ? c.maxWidth : c.maxHeight;
              final imgW = shortest * 0.55;
              final double lift = c.maxHeight * 0.16;
              final double hintBottom = 120.0;

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
                              _twin1,
                              width: imgW,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '자음 쌍둥이들이 찾아왔어요!',
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
    final showNextFab = !_showIntro && step == 1 && !_isFinalLesson;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: _goBackToAppleTree,
        ),
      ),
      body: _showIntro
          ? _buildIntro(context)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: step == 0
                    ? _buildWriteStep(context)
                    : _buildCompleteStep(context),
              ),
            ),

      // FAB은 고정 두고 가시성만 토글
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
                  onPressed: _goNext,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    _nextLessonKey() == null ? '확인' : '다음',
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

  /// 1) 따라쓰기 화면(@ 연수 : 해당 영역 누를 때 tts 재생을 위해 전체적으롣 코드 수정함)
  Widget _buildWriteStep(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Row(
          children: [
            // 왼쪽 패널
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
                            // ✅ 큰 글자 탭 -> 글자 이름 오디오 재생
                            GestureDetector(
                              onTap: () =>
                                  _playAudio(_getLetterNameAudio(spec.key)),
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
                            // ✅ 글자 이름 탭 -> 글자 이름 오디오 재생
                            GestureDetector(
                              onTap: () =>
                                  _playAudio(_getLetterNameAudio(spec.key)),
                              child: Text(
                                spec.nameKo,
                                style: TextStyle(
                                  fontSize: wordSize,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: glyphSize * 0.14),
                            // ✅ 단어 아이콘 + 이름 Row 탭 -> 단어 오디오 재생
                            GestureDetector(
                              onTap: () => _playAudio(_getWordAudio(spec.key)),
                              behavior:
                                  HitTestBehavior.opaque, // Row 빈 공간도 탭 되도록
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
                      // NEXT TODO : 힌트 말풍선 위치 조정 (상대적 위치 사용 고려)
                      Positioned(
                        top: 5,
                        // ⭐ left: 250 은 화면 크기에 따라 밀릴 수 있으니
                        // ⭐ right: 10 또는 alignment 사용을 고려하세요.
                        left: 250,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Image.asset(
                              'assets/img/contents/studyWrite/hint_tailleft.png',
                              width: 180,
                              fit: BoxFit.contain,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 13, bottom: 6),
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

            // 오른쪽 패널
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, box) {
                  // ── 버튼/여백 예약치 정의 ───────────────────────────────────────────────
                  const double buttonH = 42; // 버튼 높이
                  const double buttonLift = 56; // 하단에서 띄울 거리(↑로 올림)
                  final double safeBottom =
                      MediaQuery.of(context).padding.bottom;
                  final double reservedBottom =
                      buttonH + buttonLift + safeBottom;

                  // ── 보드 최대 크기 계산 (버튼이 차지하는 영역 제외) ─────────────────────
                  final double maxBoardHeight = (box.maxHeight - reservedBottom)
                      .clamp(240.0, box.maxHeight);

                  final double padW = math
                      .min(
                        box.maxWidth * 0.86, // 가로 기준 너비 제한
                        maxBoardHeight * 0.88, // 세로 기준(예약 높이 제외)
                      )
                      .clamp(280.0, 900.0);

                  const innerScale = 0.80;
                  const baseTraceScale = 0.75;

                  final maskW = padW * innerScale;
                  final traceW = maskW * baseTraceScale;
                  final captionSize = (padW * 0.10).clamp(18.0, 32.0);

                  // ── 버튼을 하단에서 띄워서 고정하기 위해 Stack 사용 ────────────────────
                  return Stack(
                    children: [
                      // 보드(노트패드) 영역: 가운데에 배치
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
                                    'assets/img/contents/studyWrite/notepad_frame.png',
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(
                                    width: maskW,
                                    child: Image.asset(
                                      spec.maskAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  ...List.generate(spec.traceAssets.length, (
                                    i,
                                  ) {
                                    final offs = (i < spec.traceOffsets.length)
                                        ? spec.traceOffsets[i]
                                        : const Offset(0, -2);
                                    final scale = (i < spec.traceScales.length)
                                        ? spec.traceScales[i]
                                        : 1.0;
                                    return SizedBox(
                                      width: traceW * scale,
                                      child: Transform.translate(
                                        offset: offs,
                                        child: Image.asset(
                                          spec.traceAssets[i],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(
                                    width: maskW * 0.98,
                                    height: maskW * 0.98,
                                    child: WritingCanvas(
                                      key: _canvasKey,
                                      childId: widget.childId,
                                      targetChar: spec.bigChar,
                                      candidateSet: [spec.bigChar],
                                      targetType: "consonant",
                                      onRecognize: _onRecognizeFromSelvy,
                                    ),
                                  ),
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

                      // 채점하기 버튼: 하단에서 buttonLift 만큼 띄워 고정
                      // 채점하기 버튼: 하단에서 buttonLift 만큼 띄워 고정
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 30,
                        child: Center(
                          child: SizedBox(
                            width: 200, // ✅ 버튼 폭 직접 지정
                            height: buttonH,
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

  /// 리워드 팝업
  void _showRewardPopup() {
    if (_rewardShown || !mounted) return;
    _rewardShown = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'reward',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        final size = MediaQuery.of(context).size;
        final cardW = size.width * 0.72 > 520 ? 520.0 : size.width * 0.72;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: cardW,
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
                  Image(
                    // ⭐ 사과 이미지 경로 확인 필요 (apple1.png?)
                    image: AssetImage(
                      'assets/img/contents/studyWrite/apple1.png',
                    ),
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
          ),
        );
      },
    );

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppleGarden(childId: widget.childId)),
      );
    });
  }

  /// 2) 학습 완료 화면
  Widget _buildCompleteStep(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final padW = (c.maxWidth * 0.60).clamp(320.0, c.maxHeight * 0.80);
        final previewW = padW * 0.62;
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
                        'assets/img/contents/studyWrite/notepad_frame.png',
                        fit: BoxFit.contain,
                      ),
                      Column(
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '‘${spec.bigChar}’을 학습했어요!',
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
