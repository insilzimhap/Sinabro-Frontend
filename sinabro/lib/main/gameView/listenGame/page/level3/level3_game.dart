import 'package:flutter/material.dart';

/// 레벨3 게임 페이지
/// - themeId (1~2)에 따라 다른 스토리/정답 데이터 로딩
class Level3GamePage extends StatefulWidget {
  final int themeId;

  const Level3GamePage({super.key, required this.themeId});

  @override
  State<Level3GamePage> createState() => _Level3GamePageState();
}

class _Level3GamePageState extends State<Level3GamePage> {
  int _step = 0;
  int _correctCount = 0;
  bool _showOX = false;
  bool _isCorrect = false;
  bool _retryUsed = false;

  late final List<Map<String, dynamic>> _stories;

  @override
  void initState() {
    super.initState();
    _stories = _getStories(widget.themeId);
  }

  List<Map<String, dynamic>> _getStories(int themeId) {
    switch (themeId) {
      case 1: // 숫자 세기
        return [
          {
            "dialogue": "이 그림은 몇 개인지 맞혀보라크!",
            "options": ["6", "7", "8"],
            "answer": 0, // 정답: 6개
          },
          {
            "dialogue": "숫자가 많아서 헷갈리크!",
            "options": ["8", "9", "10"],
            "answer": 2, // 정답: 10개
          },
          {
            "dialogue": "조금 더 어려운 문제다크!",
            "options": ["7", "8", "9"],
            "answer": 1, // 정답: 8개
          },
          {
            "dialogue": "이건 엄청 많다크! 잘 세보라크!",
            "options": ["9", "10", "7"],
            "answer": 0, // 정답: 9개
          },
          {
            "dialogue": "마지막 문제다크! 힘내라크!",
            "options": ["10", "7", "6"],
            "answer": 1, // 정답: 7개
          },
        ];
      default:
        return [];
    }
  }

  void _onAnswerTap(int index) {
    final current = _stories[_step];
    final correct = index == current["answer"];

    setState(() {
      _showOX = true;
      _isCorrect = correct;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showOX = false;
        if (correct) {
          _correctCount++;
          _step++;
        } else {
          if (!_retryUsed) {
            _retryUsed = true;
            _stories[_step]["dialogue"] = "다시 들어보고 골라볼까요?";
          } else {
            _step++;
          }
        }

        if (_step >= _stories.length) {
          // TODO: 결과 페이지 연결
          // Navigator.pushReplacement(context,
          //   MaterialPageRoute(builder: (_) => Level3ResultPage(success: _correctCount >= 3)),
          // );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_step >= _stories.length) {
      return const SizedBox.shrink();
    }

    final current = _stories[_step];
    return Scaffold(
      appBar: AppBar(title: Text("레벨3 테마${widget.themeId}")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    "assets/img/contents/gameListen/level3/kuku.png",
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFFFEBEE),
                      child: Text(current["dialogue"]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Icon(Icons.volume_up, size: 48),
              const Text("누르면 음성이 출력돼요!"),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(current["options"].length, (index) {
                  final name = current["options"][index];
                  return GestureDetector(
                    onTap: () => _onAnswerTap(index),
                    child: Column(
                      children: [
                        Text("보기 ${index + 1}"),
                        const SizedBox(height: 6),
                        Image.asset(
                          "assets/img/contents/gameListen/level3/${name}.png",
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          if (_showOX)
            Container(
              color: Colors.black54,
              child: Center(
                child: Icon(
                  _isCorrect ? Icons.circle_outlined : Icons.close,
                  color: _isCorrect ? Colors.green : Colors.red,
                  size: 200,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
