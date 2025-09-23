import 'package:flutter/material.dart';
import 'level1_result.dart';

/// 문제 목업 데이터 모델
class GameQuestion {
  final String dialogue;
  final String audioPath;
  final List<String> options; // 보기 이미지 경로
  final int answerIndex; // 정답 인덱스 (0,1,2)

  GameQuestion({
    required this.dialogue,
    required this.audioPath,
    required this.options,
    required this.answerIndex,
  });
}

class Level1GamePage extends StatefulWidget {
  final int themeId;
  const Level1GamePage({super.key, required this.themeId});

  @override
  State<Level1GamePage> createState() => _Level1GamePageState();
}

class _Level1GamePageState extends State<Level1GamePage> {
  int _currentIndex = 0;
  int _correctCount = 0;

  late List<GameQuestion> _questions;

  @override
  void initState() {
    super.initState();

    // 🔹 테마별 목업 데이터
    _questions = List.generate(5, (i) {
      return GameQuestion(
        dialogue: "테마 ${widget.themeId}의 문제 ${i + 1} 입니다!",
        audioPath: "assets/audio/mock_question${i + 1}.mp3", // 목업 오디오
        options: [
          "assets/img/contents/gameListen/level1/mock_option_red.png",
          "assets/img/contents/gameListen/level1/mock_option_green.png",
          "assets/img/contents/gameListen/level1/mock_option_yellow.png",
        ],
        answerIndex: 1, // 지금은 항상 2번(초록색)이 정답
      );
    });
  }

  void _answerQuestion(int index) {
    if (index == _questions[_currentIndex].answerIndex) {
      _correctCount++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // 결과 페이지로 이동
      final isClear = _correctCount >= 3;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Level1ResultPage(
            themeId: widget.themeId,
            isClear: isClear,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("레벨1 - 테마 ${widget.themeId}"),
        backgroundColor: Colors.orange[200],
      ),
      body: Column(
        children: [
          // 캐릭터 대사
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEED7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEC186)),
            ),
            child: Text(
              q.dialogue,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          // 오디오 버튼 (목업)
          IconButton(
            icon: const Icon(Icons.volume_up, size: 40),
            onPressed: () {
              debugPrint("오디오 재생: ${q.audioPath}");
            },
          ),
          const SizedBox(height: 16),

          // 보기 선택
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: q.options.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _answerQuestion(index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(q.options[index], fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),

          // 진행 상황
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "정답: $_correctCount / ${_questions.length}  "
              "현재 문제: ${_currentIndex + 1} / ${_questions.length}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
