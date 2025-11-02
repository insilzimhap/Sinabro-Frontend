// lib/main/gameView/writeGame/page/level2/write_game_2_2.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

// ▼ 추가: 매핑/API
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart'
    as WG;

// ▼ 추가: 매핑/API
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart' as WG; //changed: consonant → vowel 매핑 사용
import 'package:sinabro/main/gameView/common/api/child_game_api.dart'; //changed: ChildGameApi 사용
import 'package:sinabro/main/gameView/common/api/fruit_state.dart'; //changed: resultId 공유



// ⬇️ AUDIO IMPORT
import 'package:audioplayers/audioplayers.dart';


// ---------------------------------------------------------------------------
// 🔊 오디오 관련 설정
// ---------------------------------------------------------------------------

// ⬇️ AUDIO ASSET DEFINITIONS
// 오디오 플레이어 사용 시 위치: 공통 오디오 에셋 경로
const String kGameWriteAudioDir = 'audio/tts/gameWrite/level2/';
// 오디오 플레이어 사용 시 위치: 자음/모음 학습 오디오 에셋 경로 (studyWrite로 분리)
const String kStudyWriteAudioDir = 'audio/tts/studyWrite/level2/';

// 4세 쓰기 게임 공통 대사 에셋
const Map<String, String> kLevel4CommonAssets = {
  // 구분: 공통 | 대사: 과연 이것도 쓸 수 있을까? 글글글...
  'COMMON_1': kGameWriteAudioDir + 'write4_game_common_1.mp3',
  // 구분: 공통 | 대사: 쿠키가 맛있게 구워졌어요!
  'SUCCESS_1': kGameWriteAudioDir + 'write4_game_success_1.mp3',
  // 구분: 공통 | 대사: 쿠키 모양을 잘못 잡았나봐요... 다시 해볼까요?
  'FAIL_1': kGameWriteAudioDir + 'write4_game_fail_1.mp3',
};

// 4세 쓰기 학습 모음 에셋
const Map<String, String> kLevel4VowelAssets = {
  'A': kStudyWriteAudioDir + 'write4_a_00.mp3',
  'AE': kStudyWriteAudioDir + 'write4_ae_00.mp3',
  'EO': kStudyWriteAudioDir + 'write4_eo_00.mp3',
  'E': kStudyWriteAudioDir + 'write4_e_00.mp3',
  'O': kStudyWriteAudioDir + 'write4_o_00.mp3',
  'U': kStudyWriteAudioDir + 'write4_u_00.mp3',
  'EU': kStudyWriteAudioDir + 'write4_eu_00.mp3',
  'I': kStudyWriteAudioDir + 'write4_i_00.mp3',
  'WI': kStudyWriteAudioDir + 'write4_wi_00.mp3',
  'OE': kStudyWriteAudioDir + 'write4_oe_00.mp3',
  'YA': kStudyWriteAudioDir + 'write4_ya_00.mp3',
  'YAE': kStudyWriteAudioDir + 'write4_yae_00.mp3',
  'YEO': kStudyWriteAudioDir + 'write4_yeo_00.mp3',
  'YE': kStudyWriteAudioDir + 'write4_ye_00.mp3',
  'YO': kStudyWriteAudioDir + 'write4_yo_00.mp3',
  'YU': kStudyWriteAudioDir + 'write4_yu_00.mp3',
  'WA': kStudyWriteAudioDir + 'write4_wa_00.mp3',
  'WAE': kStudyWriteAudioDir + 'write4_wae_00.mp3',
  'WE': kStudyWriteAudioDir + 'write4_we_00.mp3',
  'UI': kStudyWriteAudioDir + 'write4_ui_00.mp3',
};

// 모음(Char)을 오디오 맵(Key)으로 변환하기 위한 유틸리티 맵
const Map<String, String> kVowelCharToKey = {
  'ㅏ': 'A',
  'ㅐ': 'AE',
  'ㅓ': 'EO',
  'ㅔ': 'E',
  'ㅗ': 'O',
  'ㅜ': 'U',
  'ㅡ': 'EU',
  'ㅣ': 'I',
  'ㅟ': 'WI',
  'ㅚ': 'OE',
  'ㅑ': 'YA',
  'ㅒ': 'YAE',
  'ㅕ': 'YEO',
  'ㅖ': 'YE',
  'ㅛ': 'YO',
  'ㅠ': 'YU',
  'ㅘ': 'WA',
  'ㅙ': 'WAE',
  'ㅞ': 'WE',
  'ㅢ': 'UI',
};
// ⬆️ AUDIO ASSET DEFINITIONS

/// 에셋 경로
const _SOUND_IMG = 'assets/img/contents/gameWrite/sound.png';
// const _AUD_DIR = 'assets/audio/gameWrite2/vowels/'; // (혼란 방지를 위한 주석처리)

/// 엔딩 이미지(전체 화면)
const _IMG_DIR = 'assets/img/contents/gameWrite/';
const _END_INTRO = '${_IMG_DIR}end_intro.png'; // 1번
const _END_SUCCESS = '${_IMG_DIR}end_success.png'; // 2번
const _END_FAIL = '${_IMG_DIR}end_fail.png'; // 3번

class _VowelItem {
  final String key; // 식별 키
  final String char; // ㅏ, ㅓ, ...
  final String nameKo;
  // final String audio; // (혼란 방지를 위한 주석처리)


  // ---------------------------------------------------------------------------
  // [VO] 모음 데이터 모델
  // ---------------------------------------------------------------------------
  const _VowelItem({
    required this.key,
    required this.char,
    required this.nameKo,
    // required this.audio, // (혼란 방지를 위한 주석처리)
  });
}


/// 모음 풀
const List<_VowelItem> _POOL = [
  _VowelItem(
    key: 'a',
    char: 'ㅏ',
    nameKo: '아', /* audio: '...' */
  ),
  _VowelItem(
    key: 'eo',
    char: 'ㅓ',
    nameKo: '어', /* audio: '...' */
  ),
  _VowelItem(
    key: 'o',
    char: 'ㅗ',
    nameKo: '오', /* audio: '...' */
  ),
  _VowelItem(
    key: 'u',
    char: 'ㅜ',
    nameKo: '우', /* audio: '...' */
  ),
  _VowelItem(
    key: 'eu',
    char: 'ㅡ',
    nameKo: '으', /* audio: '...' */
  ),
  _VowelItem(
    key: 'i',
    char: 'ㅣ',
    nameKo: '이', /* audio: '...' */
  ),
  _VowelItem(
    key: 'wi',
    char: 'ㅟ',
    nameKo: '위', /* audio: '...' */
  ),
  _VowelItem(
    key: 'ya',
    char: 'ㅑ',
    nameKo: '야', /* audio: '...' */
  ),
  _VowelItem(
    key: 'yeo',
    char: 'ㅕ',
    nameKo: '여', /* audio: '...' */
  ),
  _VowelItem(
    key: 'wa',
    char: 'ㅘ',
    nameKo: '와', /* audio: '...' */
  ),
  _VowelItem(
    key: 'yo',
    char: 'ㅛ',
    nameKo: '요', /* audio: '...' */
  ),
  _VowelItem(
    key: 'yu',
    char: 'ㅠ',
    nameKo: '유', /* audio: '...' */
  ),
  _VowelItem(
    key: 'ui',
    char: 'ㅢ',
    nameKo: '의', /* audio: '...' */
  ),
];

// ---------------------------------------------------------------------------
// [Widget] 쓰기게임 2-2 (모음 랜덤)
// ---------------------------------------------------------------------------
class WriteGameLevel2_2Page extends StatefulWidget {
  const WriteGameLevel2_2Page({
    super.key,
    required this.childId,
    this.resultId, // 상위에서 이미 생성했다면 전달
  });

  final String childId;
  final String? resultId;

  static const routeName = '/write/game/2/2';

  @override
  State<WriteGameLevel2_2Page> createState() => _WriteGameLevel2_2PageState();
}

class _WriteGameLevel2_2PageState extends State<WriteGameLevel2_2Page> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  late List<_VowelItem> _problems; // 길이 4
  int _index = 0; // 현재 문제
  final List<bool> _results = [];
  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();

  _VowelItem get current => _problems[_index];

  late DateTime _startTime; //changed
  int _elapsedSecs = 0; //changed

  // ▼ API 상태
  String? _resultId;
  bool _booting = true;

  // ⬇️ AUDIO HELPER FUNCTION
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (2-2): $assetPath');
  }

  // ---------------------------------------------------------------------------
  // 초기화 및 오디오
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _initAndStart();
    // ⬇️ 공통 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final commonAudio = kLevel4CommonAssets['COMMON_1'];
      if (commonAudio != null) {
        await _playAssetAudio(commonAudio);
      }
    });
  }

  @override
  void dispose() {
    // ⬇️ AUDIO PLAYER DISPOSE
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAndStart() async {
    try {
      _resultId = widget.resultId ?? FruitState.instance.resultId; //changed
      if (_resultId == null) throw Exception('resultId 없음'); //changed
      _resetGame();
      _startTime = DateTime.now(); //changed
      debugPrint('[2-2] 🕒 시작 시각: $_startTime'); //changed
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류. 잠시 후 다시 시도하세요.')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _booting = false);
    }
  }

  // 랜덤 출제 로직
  void _resetGame() {
    final rnd = Random();
    _problems = [..._POOL]..shuffle(rnd);
    _problems = _problems.take(4).toList();
    _index = 0;
    _results.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
      if (mounted) setState(() {});
    });
  }

  /// Selvy 후보셋을 현재 모음 하나로 고정
  Future<void> _applyCandidate() async {
    try {
      await SelvyRecognizer.setCandidateSet([current.char]);
    } catch (_) {}
  }

  /// 소리 아이콘 탭 → 현재 문제 모음 오디오 재생
  Future<void> _playPronounce() async {
    // ⬇️ 기존 로직 수정: 실제 오디오 에셋을 찾아 재생
    final audioKey = kVowelCharToKey[current.char];
    if (audioKey != null) {
      final audioPath = kLevel4VowelAssets[audioKey];
      if (audioPath != null) {
        await _playAssetAudio(audioPath);
      }
    } else {
      debugPrint('[2-2] Error: Audio key not found for vowel ${current.char}');
    }
  }

  /// 인식 문자열 정규화(첫 줄만, [n] 제거) — 모음은 그대로 비교
  String _normalize(String raw) {
    final top =
        raw.split('\n').first.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();
    return top;
    // 필요 시 호환자모 맵 추가 가능
  }


  // ---------------------------------------------------------------------------
  // [2] 개별 문제 결과 서버 전송 (_sendChoice)
  // ---------------------------------------------------------------------------
  Future<bool> _sendChoice({
    required String shownChar,  //자녀가 쓴 글씨를 셀비가 인식한 결과값(후보 1순위)
    required String correctChar, // 정답 기준 (랜덤 문제의 자음)
    required bool isCorrect,    // 프론트에서 판정한 결과 그대로 전달
  }) async {
    if (_resultId == null) return false; // 방어

    // 문제ID 매핑
    final questionId = WG.requireWgQuestionId(
      WG.vowelQuestionMap,
      correctChar,
      ctx: 'Stage2-2',
    );

    // ✅ 실제 API 호출
    final success = await ChildGameApi.recordWritingChoice(
      resultId: _resultId!,
      questionId: questionId,
      childWrittenText: shownChar,
      isCorrect: isCorrect,
    );

    if (success) {
      debugPrint('[2-2][_sendChoice] ✅ 서버 기록 성공');
    } else {
      debugPrint('[2-2][_sendChoice] ⚠️ 서버 기록 실패');
    }

    return success;

  }

  // ---------------------------------------------------------------------------
  // [3] 게임 완료 후 성공/실패 판정 (_completeAndGetSuccess)
  // ---------------------------------------------------------------------------
  Future<bool> _completeAndGetSuccess({required int timeSpentSecs}) async { //changed
    if (_resultId == null) return false; //changed

    final data = await ChildGameApi.completeWritingGame( //changed
      resultId: _resultId!, //changed
      timeSpentSecs: timeSpentSecs, //changed
    );

    if (data == null) {
      debugPrint('[2-2][_completeAndGetSuccess] ⚠️ 서버 응답 없음'); //changed
      return false;
    }

    final success = data['success'] == true;
    final score = data['score'];
    final total = data['totalQuestions'];
    debugPrint('[2-2][_completeAndGetSuccess] ✅ 서버 success=$success '
        '(score=$score / total=$total)'); //changed
    return success; //changed
  }

  // ---------------------------------------------------------------------------
  // [1] 글씨 인식 결과 수신 → 채점 로직 시작 (_onRecognize)
  // ---------------------------------------------------------------------------
  /// Selvy 콜백
  void _onRecognize(String recognized) async {
    final mine = _normalize(recognized);
    final isCorrect = mine == current.char;

    final choiceSaved =
        await _sendChoice(
          shownChar: mine, 
          correctChar: current.char, 
          isCorrect: isCorrect
        ); //changed
    if (!mounted) return;
    if (choiceSaved) {
      _results.add(isCorrect);
    } else {
      debugPrint('[2-2][_onRecognize] ⚠️ choice 저장 실패 → 로컬 반영 제외'); //changed
    }

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
    } else {
      debugPrint('[2-2][_onRecognize] 모든 문제 완료 → 서버에 complete 요청 시작'); //changed

      final endTime = DateTime.now(); //changed
      _elapsedSecs = endTime.difference(_startTime).inSeconds; //changed
      debugPrint('[2-2] 🕒 플레이 시간: $_elapsedSecs초'); //changed

      final correctCount = _results.where((e) => e).length;
      final frontSuccess = correctCount >= 3;
      debugPrint('[2-2] 🎯 프론트 success=$frontSuccess (정답 $correctCount/4)'); //changed

      final serverSuccess =
          await _completeAndGetSuccess(timeSpentSecs: _elapsedSecs); //changed
      if (!mounted) return;

      final isConsistent = (frontSuccess == serverSuccess);
      final finalSuccess = frontSuccess && serverSuccess && isConsistent;

      debugPrint('[2-2] ✅ 최종 success=$finalSuccess '
          '(front=$frontSuccess / server=$serverSuccess / 일치=$isConsistent)'); //changed

      await _showEndSequence(finalSuccess: frontSuccess); //changed
    }
  }

  // ---------------------------------------------------------------------------
  // [4] 엔딩 시퀀스 (성공 / 실패 UI)
  // ---------------------------------------------------------------------------
  /// 엔딩 시퀀스: 1) 인트로 → 2/3) 성공/실패
  Future<void> _showEndSequence({required bool finalSuccess}) async {
    // 1) 인트로
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FullImageDialog(imageAsset: _END_INTRO),
    );

    // 2) 3초 뒤 인트로 닫기
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // 3) 성공/실패
    if (finalSuccess) {
      // 3-1) 성공 다이얼로그 띄우기
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => _FullImageDialog(
          imageAsset: _END_SUCCESS,
          onTap: () => Navigator.of(context).pop(),
        ),
      );

      // ⬇️ 오디오 재생 시점 수정 : 다이얼로그 표시 후 재생
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100)); // 다이얼로그 표시 지연
        final successAudio = kLevel4CommonAssets['SUCCESS_1'];
        if (successAudio != null) {
          await _playAssetAudio(successAudio);
        }
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WriteGameMain2Page(childId: widget.childId),
          ),
        );
      });
    } else {
      // 3-2) 실패 다이얼로그 띄우기
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _FullImageDialog(
          imageAsset: _END_FAIL,
          overlay: Positioned(
            right: 24,
            bottom: 28,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteGameMain2Page(childId: widget.childId),
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
      // ⬇️ 오디오 재생 시점 수정 : 다이얼로그 표시 후 재생
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100)); // 다이얼로그 표시 지연
        final failAudio = kLevel4CommonAssets['FAIL_1'];
        if (failAudio != null) {
          await _playAssetAudio(failAudio);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7EFE6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          '쓰기 게임 2-2 (모음 랜덤)',
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
                        color: done
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
                                    _SOUND_IMG,
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
                                            targetType: "vowel",
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
                                    onPressed: () => _canvasKey.currentState
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

/// 말풍선 위젯
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
      Rect.fromLTWH(0, 0, size.width, size.height - 10),
      const Radius.circular(12),
    );
    final paint = Paint()..color = const Color(0xFFF2E2CF);
    canvas.drawRRect(r, paint);

    // 꼬리
    const double tailBaseX = 40;
    final double tailTopY = size.height - 10;
    final path = Path()
      ..moveTo(tailBaseX, tailTopY)
      ..relativeLineTo(14, 10)
      ..relativeLineTo(6, -10)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 전체 화면 이미지를 꽉 채워 보여주는 다이얼로그
class _FullImageDialog extends StatelessWidget {
  const _FullImageDialog({required this.imageAsset, this.overlay, this.onTap});

  final String imageAsset;
  final Widget? overlay; // 실패 화면의 "다시하기"
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
                width: w,
                height: h,
                child: Image.asset(imageAsset, fit: BoxFit.contain),
              ),
            ),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}
