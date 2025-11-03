// lib/main/studyView/listenGame/page/listen_game_page.dart

/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 게임 진행 화면]
 *  - 듣기 학습 게임의 실제 문제 풀이 화면
 *  - 문제별 오디오 재생 및 정답 선택 기능 포함
 *  - 구성 요소
 *      1. 캐릭터 대화 및 음성 듣기 버튼
 *      2. 보기(이미지 3개) 중 정답 선택
 *      3. 정답 확인 후 다음 문제로 자동 이동
 *      4. 모든 문제 완료 시 onFinished 콜백으로 결과 전달
 * 
 *  - 전달 데이터
 *    - [gameData] : 문제 세트(List<ListenGameContent>)
 *    - [onFinished] : 전체 게임 종료 시 상위 Flow로 정답 개수 전달
 * ----------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/gameView/listenGame/controller/audio_helper.dart';
import 'package:sinabro/main/gameView/listenGame/model/listen_game_content.dart';

import 'package:sinabro/main/gameView/writeGame/api/child_game_api.dart';
import 'package:sinabro/main/gameView/writeGame/api/fruit_state.dart';

class ListenGamePage extends StatefulWidget {
  final List<ListenGameContent>
      gameData; // 🔹 문제 세트 (각 문제: 오디오 + 보기 이미지 + 정답 인덱스)
  final void Function(int correctCount) onFinished; // 🔹 모든 문제 완료 후 상위로 결과 전달

  const ListenGamePage({
    super.key,
    required this.gameData,
    required this.onFinished,
  });

  @override
  State<ListenGamePage> createState() => _ListenGamePageState();
}

class _ListenGamePageState extends State<ListenGamePage> {
  int _currentIndex = 0; // 현재 문제 인덱스

  // 선택 및 정답 처리 상태
  bool _answered = false;
  int? _selected;
  bool _isCorrect = false;

  // 정답/오답 카운트
  int _correctCount = 0;
  int _wrongCount = 0;

  //changed-start
  DateTime? _startTime; // 게임 시작 시각
  //changed-end

  // 오디오 플레이어 (문제별 음성 재생)
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    //changed-start
    _startTime = DateTime.now(); // 시작 시점 기록
    //changed-end
    _playAudio(widget.gameData[_currentIndex].audioPath); // ✅ 첫 문제 오디오 재생
  }

  @override
  void dispose() {
    AudioHelper.stopAudio(); // ✅ dispose 시 오디오 중지
    super.dispose();
  }

  // ───────────────────── 오디오/이미지 관련 ─────────────────────
  // 오디오 경로 정규화 (assets/ 접두어 제거)
  String _normalizeAudioAsset(String path) {
    if (path.startsWith('assets/')) {
      return path.split('assets/').last;
    }
    return path;
  }

  // 이미지 경로 정규화 (폴더 경로 자동 보정)
  String _normalizeImageAsset(String path) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('img/') || path.startsWith('images/')) {
      return 'assets/$path';
    }
    if (path.contains('/')) return 'assets/$path';
    return 'assets/img/contents/gameListen/level1/$path';
  }

  // 오디오 재생 함수
  Future<void> _playAudio(String path) async {
    await _player.stop();
    final assetPath = _normalizeAudioAsset(path);
    await _player.play(AssetSource(assetPath));
  }

  // ───────────────────────────────────────────────────
  // 🔹 보기 선택 시 정답 판별 + 다음 문제 이동
  void _checkAnswer(int index) async {
    if (_answered) return; // 이미 답한 문제면 무시

    final current = widget.gameData[_currentIndex];
    final correct = index == current.correctIndex; // ✅ 정답인지 확인

    // 정답 여부 반영
    setState(() {
      _selected = index;
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _correctCount++; // 정답 수 증가
      } else {
        _wrongCount++; // 오답 수 증가
      }
    });

    //changed-start
    // ✅ 서버에 선택 결과 기록 (recordListeningChoice)
    final resultId = FruitState.instance.resultId;
    if (resultId != null) {
      try {
        final questionId = current.questionId;
        final optionId = current.optionIds[index];
        await ChildGameApi.recordListeningChoice(
          resultId: resultId,
          questionId: questionId,
          optionId: optionId,
        );
        debugPrint('[ListenGamePage] ✅ 선택 기록 완료 → $questionId / $optionId');
      } catch (e) {
        debugPrint('[ListenGamePage] ⚠️ 선택 기록 실패: $e');
      }
    } else {
      debugPrint('[ListenGamePage] ⚠️ resultId 없음 (recordListeningChoice 생략)');
    }

    // 2초간 정답 피드백 후 다음 문제로 이동
    await Future.delayed(const Duration(seconds: 2));

    // 모든 문제 다 풀면 onFinished() 호출
    if (_currentIndex < widget.gameData.length - 1) {
      // 다음 문제로 이동
      setState(() {
        _currentIndex++;
        _answered = false;
        _selected = null;
      });
      _playAudio(widget.gameData[_currentIndex].audioPath); // ✅ 다음 문제 오디오 자동 재생
    } else {
      //changed-start
      // ✅ 게임 완료 처리 (completeListeningGame)
      final endTime = DateTime.now();
      final elapsedSecs =
          _startTime != null ? endTime.difference(_startTime!).inSeconds : 0;

      final resultId = FruitState.instance.resultId;
      if (resultId != null) {
        final data = await ChildGameApi.completeListeningGame(
          resultId: resultId,
          timeSpentSecs: elapsedSecs,
        );

        final success = data?['success'] == true;
        debugPrint('[ListenGamePage] ✅ complete 호출 완료 success=$success');
      } else {
        debugPrint('[ListenGamePage] ⚠️ resultId 없음 (complete 생략)');
      }
      AudioHelper.stopAudio(); // ✅ 게임 종료 전 오디오 중지
      widget.onFinished(_correctCount); // ✅ 모든 문제 완료 → 상위 Flow로 결과(정답 개수) 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.gameData[_currentIndex]; // 현재 문제 데이터
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 700;

    final optionBoxSize = isTablet ? 180.0 : size.width * 0.28;
    final leftCharWidth = isTablet ? size.width * 0.20 : size.width * 0.22;
    final dialogueMaxWidth = size.width - leftCharWidth - 64;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        // 🔹 상단 영역: 뒤로가기 + 진행 상태 표시
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFFB05E2E),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              '문제 ${_currentIndex + 1} / ${widget.gameData.length}',
                              style: const TextStyle(
                                color: Color(0xFF8D4A1E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 🔹 대화 + 캐릭터 이미지 영역
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 왼쪽: 캐릭터 이미지
                            Container(
                              width: leftCharWidth,
                              height: leftCharWidth,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  _normalizeImageAsset(data.characterImagePath),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 오른쪽: 캐릭터 대사
                            ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: dialogueMaxWidth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 캐릭터 이름 말풍선
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFCC80),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      data.characterName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5C3B1E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 대사 텍스트
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      data.dialogueText,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A2E16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // 🔹 오디오 재생 버튼 영역
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: isTablet ? 110 : 90,
                                height: isTablet ? 110 : 90,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.volume_up, size: 48),
                                  color: const Color(0xFF4A2E16),
                                  onPressed: () => _playAudio(data.audioPath),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '누르면 음성이 출력돼요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF5C3B1E),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // 🔹 보기(선택지 3개) 영역
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(3, (i) {
                              final isSelected = (_selected == i);
                              final isCorrect =
                                  _answered && (i == data.correctIndex);
                              final isWrong =
                                  _answered && isSelected && !isCorrect;

                              // 선택지 테두리 색상
                              Color borderColor = Colors.grey.shade400;
                              if (isCorrect) borderColor = Colors.green;
                              if (isWrong) borderColor = Colors.red;

                              return Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () => _checkAnswer(i),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      width: optionBoxSize,
                                      height: optionBoxSize * 0.75,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: borderColor, width: 3),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // 보기 번호
                                          Positioned(
                                            left: 8,
                                            top: 8,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.white,
                                              child: Text(
                                                '${i + 1}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // 보기 이미지
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Image.asset(
                                                _normalizeImageAsset(
                                                    data.optionImages[i]),
                                                fit: BoxFit.contain,
                                                width: optionBoxSize * 0.5,
                                                height: optionBoxSize * 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
