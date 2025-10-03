import 'package:flutter/material.dart';

/// 레벨2 게임 페이지
/// - themeId (1~3)에 따라 다른 스토리/정답 데이터 로딩
class Level2GamePage extends StatefulWidget {
  final int themeId;

  const Level2GamePage({super.key, required this.themeId});

  @override
  State<Level2GamePage> createState() => _Level2GamePageState();
}

class _Level2GamePageState extends State<Level2GamePage> {
  int _step = 0;
  int _correctCount = 0;
  bool _showOX = false;
  bool _isCorrect = false;
  bool _retryUsed = false; // 1회 틀린 기회 제공

  late final List<Map<String, dynamic>> _stories;

  @override
  void initState() {
    super.initState();
    _stories = _getStories(widget.themeId);
  }

  List<Map<String, dynamic>> _getStories(int themeId) {
    switch (themeId) {
      case 1: // 가족
        return [
          {
            "dialogue": "우선 가족에 대해서 제게 알려주세요!",
            "options": ["brother", "sister", "mother"],
            "answer": 0,
          },
          {
            "dialogue": "계속 알려주면 기억할게요~",
            "options": ["sister", "brother", "mother"],
            "answer": 1,
          },
          {
            "dialogue": "정말 도움이 많이 되고 있어요!",
            "options": ["father", "sister", "child"],
            "answer": 2,
          },
          {
            "dialogue": "가족에 대해서 더 제게 알려주세요!",
            "options": ["father", "mother", "brother"],
            "answer": 0,
          },
          {
            "dialogue": "같은 관계여도 호칭이 여러개라니!",
            "options": ["father", "mother", "mother"],
            "answer": 1,
          },
        ];
      case 2: // 감정
        return [
          {
            "dialogue": "사람들의 표정을 익혀보려고 해요",
            "options": ["happy", "funny", "angry"],
            "answer": 0,
          },
          {
            "dialogue": "이건 무슨 표정일까요?",
            "options": ["surprised", "disgusted", "happy"],
            "answer": 1,
          },
          {
            "dialogue": "새로운 표정들도 많아요 신기해요!",
            "options": ["surprised", "disgusted", "happy"],
            "answer": 1,
          },
          {
            "dialogue": "행복이라는 감정이 더 멀리멀리 퍼지길~",
            "options": ["shy", "calm", "bored"],
            "answer": 0,
          },
          {
            "dialogue": "이건 무슨 표정일까요?",
            "options": ["surprised", "disgusted", "happy"],
            "answer": 1,
          },
        ];
      case 3: // 종합 감정
        return [
          {
            "dialogue": "사람의 표정은 참 다양하네요!",
            "options": ["happy", "funny", "angry"],
            "answer": 0,
          },
          {
            "dialogue": "표정을 따라하다 보면 더 알기 쉬워요",
            "options": ["surprised", "disgusted", "happy"],
            "answer": 1,
          },
          {
            "dialogue": "이건 조금 어려운 것 같아요",
            "options": ["surprised", "disgusted", "happy"],
            "answer": 1,
          },
          {
            "dialogue": "거의 다 끝나가요! 정말 대단해요",
            "options": ["shy", "calm", "bored"],
            "answer": 0,
          },
          {
            "dialogue": "마지막 표정이에요 도와줘서 고마워요!",
            "options": ["surprised", "disgusted", "happy"],
            "answer": 1,
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
          //   MaterialPageRoute(builder: (_) => Level2ResultPage(success: _correctCount >= 2)),
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
      appBar: AppBar(title: Text("레벨2 테마${widget.themeId}")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    "assets/img/contents/gameListen/level2/fairy.png",
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFE0F7FA),
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
                          "assets/img/contents/gameListen/level2/${name}.png",
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
