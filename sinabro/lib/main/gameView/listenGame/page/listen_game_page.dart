// lib/main/studyView/listenGame/page/listen_game_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/listen_game_content.dart';
import '../data/level1_data.dart';
import '../data/level2_data.dart';
import '../data/level3_data.dart';

class ListenGamePage extends StatefulWidget {
  final List<ListenGameContent> gameData;
  final VoidCallback onFinished;

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

  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path.replaceFirst('assets/audio/', '')));
  }

  void _checkAnswer(int index) async {
    if (_answered) return;

    final current = widget.gameData[_currentIndex];
    setState(() {
      _selected = index;
      _answered = true;
      _isCorrect = (index == current.correctIndex);
    });

    // 정답 음성 재생 (정답폴더 기준)
    final answerAudio = current.audioPath
        .replaceFirst(RegExp(r't\d+_q\d+\.mp3$'), 'answer/correct.mp3');
    await _playAudio(answerAudio);

    // 2초 후 다음 문제로 이동 or 종료
    await Future.delayed(const Duration(seconds: 2));

    if (_currentIndex < widget.gameData.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selected = null;
      });
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.gameData[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔙 상단 바
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.brown),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    '문제 ${_currentIndex + 1} / ${widget.gameData.length}',
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // 🐑 캐릭터 및 대화
              Column(
                children: [
                  Image.asset(
                    data.characterImagePath,
                    width: MediaQuery.of(context).size.width * 0.35,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEED6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          data.characterName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB05E2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.dialogueText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5A3E1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 🔊 음성 재생 버튼
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 56),
                    color: Colors.brown,
                    onPressed: () => _playAudio(data.audioPath),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '누르면 음성이 출력돼요!',
                    style: TextStyle(color: Colors.brown),
                  ),
                ],
              ),

              // 🔘 보기 3개
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) {
                  final isSelected = (_selected == i);
                  final isCorrect =
                      _answered && (i == data.correctIndex);
                  final isWrong = _answered && isSelected && !isCorrect;

                  Color borderColor = Colors.brown.shade200;
                  if (isCorrect) borderColor = Colors.green;
                  if (isWrong) borderColor = Colors.red;

                  return GestureDetector(
                    onTap: () => _checkAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/img/contents/listenGame/level1/${data.optionImages[i]}',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
