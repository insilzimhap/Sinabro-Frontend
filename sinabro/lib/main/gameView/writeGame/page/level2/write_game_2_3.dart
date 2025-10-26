// lib/main/gameView/writeGame/page/level2/write_game_2_3.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/selvy_example_view/selvy_service.dart'
    show SelvyRecognizer;

// ▼ 추가: 매핑/API
import 'package:sinabro/main/gameView/writeGame/data/wg_question_map.dart'
    as WG;
import 'package:sinabro/main/gameView/writeGame/api/write_game_api.dart';
// ⬇️ AUDIO IMPORT
import 'package:audioplayers/audioplayers.dart';

// ⬇️ AUDIO ASSET DEFINITIONS
// 오디오 플레이어 사용 시 위치: 공통 오디오 에셋 경로
const String kGameWriteAudioDir = 'audio/tts/gameWrite/level2/';
// 오디오 플레이어 사용 시 위치: 자음/모음 학습 오디오 에셋 경로 (studyWrite로 분리)
const String kStudyWriteAudioDir = 'audio/tts/studyWrite/level2/';

// 4세 쓰기 게임 공통 대사 에셋
const Map<String, String> kLevel4CommonAssets = {
  // 구분: 공통 | 대사: 이미지를 누르면 소리가 들려요! 잘 듣고 적어보세요
  'COMMON_1': kGameWriteAudioDir + 'write4_game_common_1.mp3',
  // 구분: 공통 | 대사: 쿠키가 맛있게 구워졌어요!
  'SUCCESS_1': kGameWriteAudioDir + 'write4_game_success_1.mp3',
  // 구분: 공통 | 대사: 쿠키 모양을 잘못 잡았나봐요... 다시 해볼까요?
  'FAIL_1': kGameWriteAudioDir + 'write4_game_fail_1.mp3',
};

// 4세 쓰기 학습 자음 에셋
const Map<String, String> kLevel4ConsonantAssets = {
  'GIYEOK': kStudyWriteAudioDir + 'write4_giyeok_00.mp3',
  'SSANG_GIYEOK': kStudyWriteAudioDir + 'write4_ssang_giyeok_00.mp3',
  'DIGEUT': kStudyWriteAudioDir + 'write4_digeut_00.mp3',
  'SSANG_DIGEUT': kStudyWriteAudioDir + 'write4_ssang_digeut_00.mp3',
  'SIOT': kStudyWriteAudioDir + 'write4_siot_00.mp3',
  'SSANG_SIOT': kStudyWriteAudioDir + 'write4_ssang_siot_00.mp3',
  'JIEUT': kStudyWriteAudioDir + 'write4_jieut_00.mp3',
  'SSANG_JIEUT': kStudyWriteAudioDir + 'write4_ssang_jieut_00.mp3',
  'BIEUP': kStudyWriteAudioDir + 'write4_bieup_00.mp3',
  'SSANG_BIEUP': kStudyWriteAudioDir + 'write4_ssang_bieup_00.mp3',
  'NIEUN': kStudyWriteAudioDir + 'write4_nieun_00.mp3',
  'RIEUL': kStudyWriteAudioDir + 'write4_rieul_00.mp3',
  'MIEUM': kStudyWriteAudioDir + 'write4_mieum_00.mp3',
  'IEUNG': kStudyWriteAudioDir + 'write4_ieung_00.mp3',
  'CHIEUT': kStudyWriteAudioDir + 'write4_chieut_00.mp3',
  'PIEUP': kStudyWriteAudioDir + 'write4_pieup_00.mp3',
  'HIEUT': kStudyWriteAudioDir + 'write4_hieut_00.mp3',
  'KIEUK': kStudyWriteAudioDir + 'write4_kieuk_00.mp3',
  'TIEUT': kStudyWriteAudioDir + 'write4_tieut_00.mp3',
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

// 자음(Char)을 오디오 맵(Key)으로 변환하기 위한 유틸리티 맵
const Map<String, String> kConsonantCharToKey = {
  'ㄱ': 'GIYEOK',
  'ㄲ': 'SSANG_GIYEOK',
  'ㄷ': 'DIGEUT',
  'ㄸ': 'SSANG_DIGEUT',
  'ㅅ': 'SIOT',
  'ㅆ': 'SSANG_SIOT',
  'ㅈ': 'JIEUT',
  'ㅉ': 'SSANG_JIEUT',
  'ㅂ': 'BIEUP',
  'ㅃ': 'SSANG_BIEUP',
  'ㄴ': 'NIEUN',
  'ㄹ': 'RIEUL',
  'ㅁ': 'MIEUM',
  'ㅇ': 'IEUNG',
  'ㅊ': 'CHIEUT',
  'ㅋ': 'KIEUK',
  'ㅌ': 'TIEUT',
  'ㅍ': 'PIEUP',
  'ㅎ': 'HIEUT',
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
// ⬆️ AUDIO ASSET DEFINITIONS (추가 끝)

/// 고정 사운드 아이콘 경로
const _SOUND_IMG = 'assets/img/contents/gameWrite/sound.png';

/// 엔딩(전체 화면) 이미지
const _IMG_DIR = 'assets/img/contents/gameWrite/';
const _END_INTRO = '${_IMG_DIR}end_intro.png'; // 1번
const _END_SUCCESS = '${_IMG_DIR}end_success.png'; // 2번
const _END_FAIL = '${_IMG_DIR}end_fail.png'; // 3번

// ⬇️ 오디오 경로 제거
// const _CONS_AUD = 'assets/audio/gameWrite2/cons/';
// const _VOW_AUD = 'assets/audio/gameWrite2/vowels/';

enum _TargetType { consonant, vowel }

class _Item {
  final String key; // 식별 키
  final String char; // ㄱ/ㅏ 등
  final String nameKo;
  // final String audio; // (혼란 방지를 위해 주석 처리됨)
  final _TargetType type;

  const _Item({
    required this.key,
    required this.char,
    required this.nameKo,
    // required this.audio, // (혼란 방지를 위해 주석 처리됨)
    required this.type,
  });
}

/// 자음 19개
const List<_Item> _CONSONANTS = [
  _Item(
    key: 'giyeok',
    char: 'ㄱ',
    nameKo: '기역',
    // audio: '${_CONS_AUD}giyeok.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'ssang_giyeok',
    char: 'ㄲ',
    nameKo: '쌍기역',
    // audio: '${_CONS_AUD}ssang_giyeok.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'digeut',
    char: 'ㄷ',
    nameKo: '디귿',
    // audio: '${_CONS_AUD}digeut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'ssang_digeut',
    char: 'ㄸ',
    nameKo: '쌍디귿',
    // audio: '${_CONS_AUD}ssang_digeut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'siot',
    char: 'ㅅ',
    nameKo: '시옷',
    // audio: '${_CONS_AUD}siot.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'ssang_siot',
    char: 'ㅆ',
    nameKo: '쌍시옷',
    // audio: '${_CONS_AUD}ssang_siot.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'jieut',
    char: 'ㅈ',
    nameKo: '지읒',
    // audio: '${_CONS_AUD}jieut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'ssang_jieut',
    char: 'ㅉ',
    nameKo: '쌍지읒',
    // audio: '${_CONS_AUD}ssang_jieut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'bieup',
    char: 'ㅂ',
    nameKo: '비읍',
    // audio: '${_CONS_AUD}bieup.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'ssang_bieup',
    char: 'ㅃ',
    nameKo: '쌍비읍',
    // audio: '${_CONS_AUD}ssang_bieup.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'nieun',
    char: 'ㄴ',
    nameKo: '니은',
    // audio: '${_CONS_AUD}nieun.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'rieul',
    char: 'ㄹ',
    nameKo: '리을',
    // audio: '${_CONS_AUD}rieul.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'mieum',
    char: 'ㅁ',
    nameKo: '미음',
    // audio: '${_CONS_AUD}mieum.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'ieung',
    char: 'ㅇ',
    nameKo: '이응',
    // audio: '${_CONS_AUD}ieung.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'chieut',
    char: 'ㅊ',
    nameKo: '치읓',
    // audio: '${_CONS_AUD}chieut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'pieup',
    char: 'ㅍ',
    nameKo: '피읖',
    // audio: '${_CONS_AUD}pieup.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'hieut',
    char: 'ㅎ',
    nameKo: '히읗',
    // audio: '${_CONS_AUD}hieut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'kieuk',
    char: 'ㅋ',
    nameKo: '키읔',
    // audio: '${_CONS_AUD}kieuk.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
  _Item(
    key: 'tieut',
    char: 'ㅌ',
    nameKo: '티읕',
    // audio: '${_CONS_AUD}tieut.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.consonant,
  ),
];

/// 모음(요청 목록)
const List<_Item> _VOWELS = [
  _Item(
    key: 'a',
    char: 'ㅏ',
    nameKo: '아',
    // audio: '${_VOW_AUD}a.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'eo',
    char: 'ㅓ',
    nameKo: '어',
    // audio: '${_VOW_AUD}eo.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'o',
    char: 'ㅗ',
    nameKo: '오',
    // audio: '${_VOW_AUD}o.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'u',
    char: 'ㅜ',
    nameKo: '우',
    // audio: '${_VOW_AUD}u.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'eu',
    char: 'ㅡ',
    nameKo: '으',
    // audio: '${_VOW_AUD}eu.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'i',
    char: 'ㅣ',
    nameKo: '이',
    // audio: '${_VOW_AUD}i.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'wi',
    char: 'ㅟ',
    nameKo: '위',
    // audio: '${_VOW_AUD}wi.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'ya',
    char: 'ㅑ',
    nameKo: '야',
    // audio: '${_VOW_AUD}ya.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'yeo',
    char: 'ㅕ',
    nameKo: '여',
    // audio: '${_VOW_AUD}yeo.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'wa',
    char: 'ㅘ',
    nameKo: '와',
    // audio: '${_VOW_AUD}wa.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'yo',
    char: 'ㅛ',
    nameKo: '요',
    // audio: '${_VOW_AUD}yo.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'yu',
    char: 'ㅠ',
    nameKo: '유',
    // audio: '${_VOW_AUD}yu.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
  _Item(
    key: 'ui',
    char: 'ㅢ',
    nameKo: '의',
    // audio: '${_VOW_AUD}ui.mp3', // (혼란 방지를 위해 주석 처리됨)
    type: _TargetType.vowel,
  ),
];

/// 자모음 혼합 풀
const List<_Item> _MIXED_POOL = [..._CONSONANTS, ..._VOWELS];

class WriteGameLevel2_3Page extends StatefulWidget {
  const WriteGameLevel2_3Page({
    super.key,
    required this.childId,
    this.resultId,
  });
  final String childId;
  final String? resultId;

  static const routeName = '/write/game/2/3';

  @override
  State<WriteGameLevel2_3Page> createState() => _WriteGameLevel2_3PageState();
}

class _WriteGameLevel2_3PageState extends State<WriteGameLevel2_3Page> {
  final _canvasKey = GlobalKey<WritingCanvasState>();

  late List<_Item> _problems; // 길이 4
  int _index = 0;
  final List<bool> _results = [];

  // ⬇️ AUDIO PLAYER INSTANCE
  final AudioPlayer _audioPlayer = AudioPlayer();

  _Item get current => _problems[_index];

  // API 상태
  String? _resultId;
  bool _booting = true;

  // ⬇️ AUDIO HELPER FUNCTION
  Future<void> _playAssetAudio(String assetPath) async {
    if (!mounted) return;
    await _audioPlayer.stop(); // 기존 오디오 중지
    await _audioPlayer.play(AssetSource(assetPath));
    debugPrint('🎶 오디오 재생 시작 (2-3): $assetPath');
  }
  // ⬆️ AUDIO HELPER FUNCTION

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
      _resultId = widget.resultId;
      _resultId ??= await WriteGameApi.start(
        childId: widget.childId,
        stageCode: 'FR_WG_007', // 혼합 스테이지 코드. 백엔드 값에 맞춰 수정.
      );
      _resetGame();
    } catch (_) {
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

  void _resetGame() {
    final rnd = Random();
    _problems = [..._MIXED_POOL]..shuffle(rnd);
    _problems = _problems.take(4).toList();
    _index = 0;
    _results.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
      if (mounted) setState(() {});
    });
  }

  /// Selvy 후보셋을 현재 문자 하나로 제한
  Future<void> _applyCandidate() async {
    try {
      await SelvyRecognizer.setCandidateSet([current.char]);
    } catch (_) {}
  }

  Future<void> _playPronounce() async {
    // ⬇️ 기존 로직 수정: 실제 오디오 에셋을 찾아 재생
    final isConsonant = current.type == _TargetType.consonant;
    final audioKey =
        (isConsonant ? kConsonantCharToKey : kVowelCharToKey)[current.char];

    if (audioKey != null) {
      final audioPath =
          (isConsonant ? kLevel4ConsonantAssets : kLevel4VowelAssets)[audioKey];
      if (audioPath != null) {
        await _playAssetAudio(audioPath);
      }
    } else {
      debugPrint('[2-3] Error: Audio key not found for char ${current.char}');
    }
    // ⬆️ 기존 로직 수정
  }

  /// 라벨 정규화(첫 줄만, [n] 제거, 초/중성 호환자모 → 일반 자모)
  String _normalize(String raw) {
    final top =
        raw.split('\n').first.replaceAll(RegExp(r'\[\d+\]\s*'), '').trim();
    const map = {
      // 자음(초성)
      'ᄀ': 'ㄱ',
      'ᄁ': 'ㄲ',
      'ᄂ': 'ㄴ',
      'ᄃ': 'ㄷ',
      'ᄄ': 'ㄸ',
      'ᄅ': 'ㄹ',
      'ᄆ': 'ㅁ',
      'ᄇ': 'ㅂ',
      'ᄈ': 'ㅃ',
      'ᄉ': 'ㅅ',
      'ᄊ': 'ㅆ',
      'ᄋ': 'ㅇ',
      'ᄌ': 'ㅈ',
      'ᄍ': 'ㅉ',
      'ᄎ': 'ㅊ',
      'ᄏ': 'ㅋ',
      'ᄐ': 'ㅌ',
      'ᄑ': 'ㅍ',
      'ᄒ': 'ㅎ',
      'U+1100': 'ㄱ',
      'U+1101': 'ㄲ',
      'U+1102': 'ㄴ',
      'U+1103': 'ㄷ',
      'U+1104': 'ㄸ',
      'U+1105': 'ㄹ',
      'U+1106': 'ㅁ',
      'U+1107': 'ㅂ',
      'U+1108': 'ㅃ',
      'U+1109': 'ㅅ',
      'U+110A': 'ㅆ',
      'U+110B': 'ㅇ',
      'U+110C': 'ㅈ',
      'U+110D': 'ㅉ',
      'U+110E': 'ㅊ', 'U+110F': 'ㅋ', 'U+1110': 'ㅌ', 'U+1111': 'ㅍ', 'U+1112': 'ㅎ',
      // 모음(중성)
      'ᅡ': 'ㅏ',
      'ᅥ': 'ㅓ',
      'ᅩ': 'ㅗ',
      'ᅮ': 'ㅜ',
      'ᅳ': 'ㅡ',
      'ᅵ': 'ㅣ',
      'ᅱ': 'ㅟ',
      'ᅣ': 'ㅑ',
      'ᅧ': 'ㅕ',
      'ᅪ': 'ㅘ',
      'ᅭ': 'ㅛ',
      'ᅲ': 'ㅠ',
      'ᅴ': 'ㅢ',
      'U+1161': 'ㅏ',
      'U+1165': 'ㅓ',
      'U+1169': 'ㅗ',
      'U+116E': 'ㅜ',
      'U+1173': 'ㅡ',
      'U+1175': 'ㅣ',
      'U+1171': 'ㅟ',
      'U+1163': 'ㅑ',
      'U+1167': 'ㅕ',
      'U+116A': 'ㅘ',
      'U+116D': 'ㅛ',
      'U+1172': 'ㅠ',
      'U+1174': 'ㅢ',
    };
    return map[top] ?? top;
  }

  Future<void> _sendChoice({
    required String shownChar,
    required _TargetType type,
    required bool isCorrect,
  }) async {
    if (_resultId == null) return;
    final map = type == _TargetType.consonant
        ? WG.consonantQuestionMap
        : WG.vowelQuestionMap;
    final qid = WG.requireWgQuestionId(map, shownChar, ctx: 'Stage2-3');

    try {
      await WriteGameApi.sendChoice(
        resultId: _resultId!,
        questionId: qid,
        childWrittenText: shownChar,
        isCorrect: isCorrect,
      );
    } catch (_) {
      // 스텁/네트워크 실패 시 무시. 연결 후 로깅 처리.
    }
  }

  Future<bool> _completeAndGetSuccess() async {
    if (_resultId == null) return false;
    try {
      final res = await WriteGameApi.complete(resultId: _resultId!);
      return res.success == true;
    } catch (_) {
      return false;
    }
  }

  void _onRecognize(String recognized) async {
    final mine = _normalize(recognized);
    final isCorrect = mine == current.char;

    // 서버 기록
    await _sendChoice(
      shownChar: current.char,
      type: current.type,
      isCorrect: isCorrect,
    );

    _results.add(isCorrect);
    if (!mounted) return;

    if (_index < _problems.length - 1) {
      setState(() => _index += 1);
      await _canvasKey.currentState?.clearCanvas();
      await _applyCandidate();
    } else {
      final serverSuccess = await _completeAndGetSuccess();
      if (!mounted) return;
      await _showEndSequence(serverSuccess: serverSuccess);
    }
  }

  /// 엔딩 시퀀스: 1) 인트로 → 2/3) 성공/실패
  Future<void> _showEndSequence({required bool serverSuccess}) async {
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
    if (serverSuccess) {
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
          '쓰기 게임 2-3 (자모음 랜덤)',
          style: TextStyle(color: Colors.brown),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // 상단 안내
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
                    // 왼쪽: 사운드 아이콘 + 말풍선
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
                                alignment: const Alignment(0.6, -0.1),
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
                                        SizedBox(
                                          width: pad * 0.98,
                                          height: pad * 0.98,
                                          child: WritingCanvas(
                                            key: _canvasKey,
                                            childId: widget.childId,
                                            targetChar: current.char,
                                            candidateSet: [current.char],
                                            targetType: current.type ==
                                                    _TargetType.consonant
                                                ? "consonant"
                                                : "vowel",
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
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 10),
      const Radius.circular(12),
    );
    final paint = Paint()..color = const Color(0xFFF2E2CF);
    canvas.drawRRect(r, paint);

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
  final Widget? overlay; // 추가 버튼/위젯(실패 화면의 "다시하기")
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
