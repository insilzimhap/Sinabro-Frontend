import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// ⚠️ 참고: audioplayers 패키지를 pubspec.yaml에 추가하고 flutter pub get을 실행했는지 확인해주세요.

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  // TTS 파일명 매핑을 위한 도우미 함수 (파일명에서 확장자(.mp3)를 제외합니다)
  static String getTtsFileName(String key) {
    switch (key) {
      // ----------------- 인트로 TTS -----------------
      case 'intro_1':
        return 'listen_game_practice_intro_01'; // 양지: 안녕하세요! 저는 양지라고 해요
      case 'intro_2':
        return 'listen_game_practice_intro_02'; // 양지: 내일 마법 시험이 있는데 성공을 못해요
      case 'intro_3':
        return 'listen_game_practice_intro_03'; // 양지: 저를 좀 도와주세요!

      // ----------------- 튜토리얼 (연습) TTS -----------------
      case 'guide_1':
        return 'listen_game_practice_guide_01'; // 양지: 알쏭달쏭 연습실에 도착했어요!
      case 'guide_2':
        return 'listen_game_practice_guide_02'; // 양지: 여기서 올바른 답을 고르면...
      case 'guide_3':
        return 'listen_game_practice_guide_03'; // 양지: 무언가 만들어진다고 해요!
      case 'guide_4':
        return 'listen_game_practice_guide_04'; // 양지: 무엇인지 들어볼까요? (🔊 버튼 클릭 유도)
      case 'guide_5':
        return 'listen_game_practice_guide_05'; // 양지: 빨간색을 찾고 있네요! 보기를 눌러주세요! (🔴 카드 클릭 유도)
      case 'guide_6':
        return 'listen_game_practice_guide_06'; // 양지: 이런식으로 하다보면 연습이 될 것 같아요!
      case 'guide_7':
        return 'listen_game_practice_guide_07'; // 양지: 바로 해볼까요? 잘 부탁드려요!
      case 'question_red':
        return 'listen_game_practice_question_red'; // (🔊 버튼 클릭 시) 빨간색

      // ----------------- 로딩/전환 TTS -----------------
      case 'loading':
        return 'listen_game_loading'; // 게임으로 이동 중입니다. 잠시만 기다려주세요!

      // ----------------- ✅ 레벨 1 인트로 (Theme Intro) & 진행 TTS (추가) -----------------
      // Theme 1
      case 'intro_t1':
        return 'listen3_game_1_intro';
      case 'progress_t1_1':
        return 'listen3_game_1_progress1';
      case 'progress_t1_2':
        return 'listen3_game_1_progress2';
      case 'progress_t1_3':
        return 'listen3_game_1_progress3';
      case 'progress_t1_4':
        return 'listen3_game_1_progress4';
      case 'success_t1':
        return 'listen3_game_1_success';

      // Theme 2
      case 'intro_t2':
        return 'listen3_game_2_intro';
      case 'progress_t2_1':
        return 'listen3_game_2_progress1';
      case 'progress_t2_2':
        return 'listen3_game_2_progress2';
      case 'progress_t2_3':
        return 'listen3_game_2_progress3';
      case 'progress_t2_4':
        return 'listen3_game_2_progress4';
      case 'success_t2':
        return 'listen3_game_2_success';

      // Theme 3
      case 'intro_t3':
        return 'listen3_game_3_intro';
      case 'progress_t3_1':
        return 'listen3_game_3_progress1';
      case 'progress_t3_2':
        return 'listen3_game_3_progress2';
      case 'progress_t3_3':
        return 'listen3_game_3_progress3';
      case 'progress_t3_4':
        return 'listen3_game_3_progress4';
      case 'success_t3':
        return 'listen3_game_3_success';

      // Theme 4
      case 'intro_t4':
        return 'listen3_game_4_intro'; // 👈 누락된 키 추가
      case 'progress_t4_1':
        return 'listen3_game_4_progress1';
      case 'progress_t4_2':
        return 'listen3_game_4_progress2';
      case 'progress_t4_3':
        return 'listen3_game_4_progress3';
      case 'progress_t4_4':
        return 'listen3_game_4_progress4';
      case 'success_t4':
        return 'listen3_game_4_success';

      // Theme 5
      case 'intro_t5':
        return 'listen3_game_5_intro';
      case 'progress_t5_1':
        return 'listen3_game_5_progress1';
      case 'progress_t5_2':
        return 'listen3_game_5_progress2';
      case 'progress_t5_3':
        return 'listen3_game_5_progress3';
      case 'progress_t5_4':
        return 'listen3_game_5_progress4';
      case 'success_t5':
        return 'listen3_game_5_success';

      // 공통 실패
      case 'fail':
        return 'listen3_game_fail';
      // ----------------- ✅ 레벨 1 TTS 끝 -----------------

      // ----------------- ✅ 정답 이름 오디오 (answer_X) 추가 -----------------
      // 색깔
      case 'answer_black':
        return 'color_black';
      case 'answer_blue':
        return 'color_blue';
      case 'answer_yellow':
        return 'color_yellow';
      case 'answer_white':
        return 'color_white';
      case 'answer_red':
        return 'color_red';
      case 'answer_brown':
        return 'color_brown';
      case 'answer_orange':
        return 'color_orange';
      case 'answer_purple':
        return 'color_purple';
      case 'answer_green':
        return 'color_green';
      case 'answer_pink':
        return 'color_pink';
      // 동물
      case 'answer_dog':
        return 'animal_dog';
      case 'answer_cat':
        return 'animal_cat';
      case 'answer_chicken':
        return 'animal_chicken';
      case 'answer_pig':
        return 'animal_pig';
      case 'answer_mouse':
        return 'animal_mouse';
      case 'answer_elephant':
        return 'animal_elephant';
      case 'answer_sheep':
        return 'animal_sheep';
      case 'answer_monkey':
        return 'animal_monkey';
      case 'answer_tiger':
        return 'animal_tiger';
      case 'answer_penguin':
        return 'animal_penguin';
      case 'answer_chick':
        return 'animal_chick';
      case 'answer_turtle':
        return 'animal_turtle';
      case 'answer_rabbit':
        return 'animal_rabbit';
      case 'answer_frog':
        return 'animal_frog';
      case 'answer_duck':
        return 'animal_duck';
      // ----------------- ✅ 정답 이름 오디오 끝 -----------------

      default:
        debugPrint('⚠️ AudioHelper: 알 수 없는 TTS 키: $key');
        return ''; // 키를 못 찾으면 빈 문자열 반환 (경로 오류의 원인)
    }
  }

  // 오디오 재생 함수 (TTS/일반 오디오 경로 처리)
  static Future<void> playAudio(String audioKeyOrPath,
      {bool isTts = false, int themeId = 0}) async {
    // 💡 TTS 재생이 아닐 경우 (일반 오디오), 기존 로직 유지 및 단일 플레이어 중지
    if (!isTts) {
      await _player.stop();
    }

    // 💡 TTS 전용 플레이어 변수 선언 및 초기화 (null 허용)
    AudioPlayer? ttsPlayer;

    String fullPath = '';

    // 1. 경로 생성
    if (isTts) {
      final fileName = getTtsFileName(audioKeyOrPath);
      String folder = 'practice'; // 기본은 practice

      // 💡 TTS 재생 시, 새로운 플레이어 인스턴스 생성
      ttsPlayer = AudioPlayer();

      // 💡 안전 장치: TTS 키 매핑에 실패하면 재생 중단
      if (fileName.isEmpty) {
        debugPrint('❌ 오디오 재생 실패: TTS 키 매핑 오류 (파일 이름이 비어있음)');
        ttsPlayer?.dispose();
        return;
      }

      // themeId를 사용하여 레벨 폴더를 구분 (level1은 themeId 1~5를 사용)
      // ✅ 'listen3_'로 시작하거나, 정답 오디오('answer_') 키인 경우 level1 폴더 사용
      if (fileName.startsWith('listen3_') ||
          audioKeyOrPath.startsWith('answer_')) {
        folder = 'level1';
      }

      // 💡 listen_game_loading.mp3 파일이 'assets/audio/tts/gameListen/' 바로 아래 있다고 가정
      // 💡 튜토리얼/로딩 TTS 경로
      if (fileName == 'listen_game_loading') {
        fullPath = 'assets/audio/tts/gameListen/$fileName.mp3';
      } else if (fileName.startsWith('listen_game_practice')) {
        // ✅ 튜토리얼 오디오 (practice 폴더 사용)
        fullPath = 'assets/audio/tts/gameListen/practice/$fileName.mp3';
      } else {
        // 💡 레벨 1 테마별 TTS 및 정답 오디오 경로
        fullPath = 'assets/audio/tts/gameListen/$folder/$fileName.mp3';
      }
    } else {
      // Level1GamePage의 `data.audioPath`와 같은 일반 게임 문제 오디오

      // ✅ 일반 오디오 경로를 TTS 폴더로 리디렉션
      // ListenGamePage에서 'assets/audio/gameListen/...' 형태로 넘어온 경로를
      // 실제 파일 위치인 'assets/audio/tts/gameListen/...'으로 수정합니다.
      fullPath = audioKeyOrPath.replaceFirst('assets/audio/gameListen/',
          'assets/audio/tts/gameListen/' // 👈 "tts/"를 추가하여 리디렉션
          );
    }

    // 2. 오디오 재생
    if (fullPath.isNotEmpty) {
      // AssetSource는 'assets/' 접두사를 요구하지 않음
      // AudioPlayer의 AssetSource는 자동으로 'assets/' 폴더를 찾습니다.
      final assetPath =
          fullPath.startsWith('assets/') ? fullPath.substring(7) : fullPath;

      try {
        if (isTts) {
          // 💡 TTS는 새로 만든 플레이어로 재생하고, 완료 후 해제 로직 추가
          await ttsPlayer!.play(AssetSource(assetPath));
          ttsPlayer.onPlayerComplete.listen((event) {
            ttsPlayer?.dispose();
            debugPrint('🧹 TTS 플레이어 해제 완료');
          });
        } else {
          // 💡 일반 오디오는 기존의 _player를 사용
          await _player.play(AssetSource(assetPath));
        }

        debugPrint('🔊 오디오 재생 성공: $fullPath');
      } catch (e) {
        debugPrint('❌ 오디오 재생 실패: $e (경로: $fullPath)');
        // 💡 오류 발생 시에도 TTS 플레이어 해제
        if (isTts) {
          ttsPlayer?.dispose();
        }
      }
    }
  }

  static Future<void> stopAudio() async {
    await _player.stop();
  }

  static void dispose() {
    _player.dispose();
  }
}
