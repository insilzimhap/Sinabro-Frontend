/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 게임 진행 화면]
 *  - 문제별 음성 듣기 후 올바른 그림(선택지)을 선택하는 단계
 *  - 캐릭터 대사, 오디오 재생, 정오답 판정 및 진행 흐름 포함
 *  - 모든 문제 완료 시 정답 개수를 콜백(onFinished)으로 전달
 * ----------------------------------------------------------------
 */


// lib/main/studyView/listenGame/page/listen_game_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sinabro/main/gameView/listenGame/model/listen_game_content.dart';

import 'package:sinabro/main/gameView/common/api/child_game_api.dart';
import 'package:sinabro/main/gameView/common/api/fruit_state.dart';

class ListenGamePage extends StatefulWidget {
  final List<ListenGameContent> gameData;
  final void Function(int correctCount) onFinished;


  const ListenGamePage({
    super.key,
    required this.gameData,
    required this.onFinished,
  });

  @override
  State<ListenGamePage> createState() => _ListenGamePageState();
}

class _ListenGamePageState extends State<ListenGamePage> {
  int _currentIndex = 0;
  bool _answered = false;
  int? _selected;
  bool _isCorrect = false;

  int _correctCount = 0;
  int _wrongCount = 0;

  final AudioPlayer _player = AudioPlayer();

  DateTime? _startTime; // 게임 시작 시점 기록

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // 시작 시간 저장
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ───────────────────── 오디오/이미지 관련 ─────────────────────
  String _normalizeAudioAsset(String path) {
    if (path.startsWith('assets/')) {
      return path.split('assets/').last;
    }
    return path;
  }

  String _normalizeImageAsset(String path) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('img/') || path.startsWith('images/')) {
      return 'assets/$path';
    }
    if (path.contains('/')) return 'assets/$path';
    return 'assets/img/contents/gameListen/level2/answer/$path';
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    final assetPath = _normalizeAudioAsset(path);
    await _player.play(AssetSource(assetPath));
  }

  // ───────────────────────── 정답 선택 로직 ─────────────────────────
  void _checkAnswer(int index) async {
    if (_answered) return;

    final current = widget.gameData[_currentIndex];
    final correct = index == current.correctIndex;

    setState(() {
      _selected = index;
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });

    // ✅ 서버에 선택 결과 기록
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
        debugPrint('[Level2Game] ✅ 선택 기록 완료: $questionId / $optionId');
      } catch (e) {
        debugPrint('[Level2Game] ⚠️ 선택 기록 실패: $e');
      }
    } else {
      debugPrint('[Level2Game] ⚠️ resultId 없음 (record 생략)');
    }


    await Future.delayed(const Duration(seconds: 2));

    if (_currentIndex < widget.gameData.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selected = null;
      });
    } else {
      // ✅ 모든 문제 완료 시 /complete 호출
      final endTime = DateTime.now();
      final elapsedSecs =
          _startTime != null ? endTime.difference(_startTime!).inSeconds : 0;

      if (resultId != null) {
        try {
          final data = await ChildGameApi.completeListeningGame(
            resultId: resultId,
            timeSpentSecs: elapsedSecs,
          );
          debugPrint('[Level2Game] ✅ completeListeningGame 성공: $data');
        } catch (e) {
          debugPrint('[Level2Game] ⚠️ completeListeningGame 실패: $e');
        }
      } else {
        debugPrint('[Level2Game] ⚠️ resultId 없음 (complete 생략)');
      }


      widget.onFinished(_correctCount); // ✅ 정답 개수 전달
    }

  }

  // ───────────────────────── UI 구성 ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final data = widget.gameData[_currentIndex];
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: dialogueMaxWidth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(3, (i) {
                              final isSelected = (_selected == i);
                              final isCorrect = _answered && (i == data.correctIndex);
                              final isWrong = _answered && isSelected && !isCorrect;

                              Color borderColor = Colors.grey.shade400;
                              if (isCorrect) borderColor = Colors.green;
                              if (isWrong) borderColor = Colors.red;

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () => _checkAnswer(i),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: optionBoxSize,
                                      height: optionBoxSize * 0.75,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor, width: 3),
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
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Image.asset(
                                                _normalizeImageAsset(data.optionImages[i]),
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
