// lib/main/gameView/common/listenGame/page/level1/level1_story.dart
import 'package:flutter/material.dart';
import 'level1_result.dart';

/// 레벨1 스토리 페이지
/// - themeId (1~5)에 따라 다른 스토리/정답 데이터 로딩
class Level1GamePage extends StatefulWidget {
  final int themeId;

  const Level1GamePage({super.key, required this.themeId});

  @override
  State<Level1GamePage> createState() => _Level1GamePageState();
}

class _Level1GamePageState extends State<Level1GamePage> {
  int _step = 0;
  int _correctCount = 0;
  bool _showOX = false;
  bool _isCorrect = false;
  bool _retryUsed = false; // 1회 틀린 기회 제공

  // 전체 스토리 데이터
  late final List<Map<String, dynamic>> _stories;

  @override
  void initState() {
    super.initState();
    _stories = _getStories(widget.themeId);
  }

  List<Map<String, dynamic>> _getStories(int themeId) {
    switch (themeId) {
      case 1: // 테마1 무지개 색깔
        return [
          {
            "dialogue": "무지개 만들기 마법서를 골라주셨네요!",
            "options": ["black", "blue", "yellow"],
            "answer": 0,
          },
          {
            "dialogue": "이렇게 정답을 선택하면 무지개가 채워져요!",
            "options": ["white", "red", "blue"],
            "answer": 1,
          },
          {
            "dialogue": "채워지고 있어요! 벌써 아름다워!!!",
            "options": ["yellow", "white", "red"],
            "answer": 0,
          },
          {
            "dialogue": "거의 다왔어요! 예쁜 무지개가 될 것 같아요",
            "options": ["blue", "yellow", "black"],
            "answer": 0,
          },
          {
            "dialogue": "마지막이에요! 무지개를 완성해요",
            "options": ["red", "black", "yellow"],
            "answer": 2,
          },
        ];
      case 2: // 테마2 색깔 조합
        return [
          {
            "dialogue": "무지개 만들기 마법서를 골라주세요!",
            "options": ["brown", "pink", "yellow"],
            "answer": 0,
          },
          {
            "dialogue": "달콤한 사탕을 만들려면 어떤 색이 필요할까요?",
            "options": ["orange", "purple", "pink"],
            "answer": 2,
          },
          {
            "dialogue": "사탕을 많이 만들려면 어디에 쓰나요?",
            "options": ["white", "black", "purple"],
            "answer": 2,
          },
          {
            "dialogue": "많은 어린이에게 행복을 줄 거예요!",
            "options": ["green", "pink", "yellow"],
            "answer": 0,
          },
          {
            "dialogue": "마지막이에요! 달콤한 사탕이 생겨라~",
            "options": ["red", "brown", "orange"],
            "answer": 2,
          },
        ];
      case 3: // 테마3 동물 1
        return [
          {
            "dialogue": "동물의 하급 마법서를 골라주세요!",
            "options": ["dog", "cat", "chicken"],
            "answer": 0,
          },
          {
            "dialogue": "이 동물은 대체 무엇일까요?",
            "options": ["cat", "chicken", "dog"],
            "answer": 1,
          },
          {
            "dialogue": "동물 친구들은 많이 알수록 좋아요!",
            "options": ["pig", "chicken", "mouse"],
            "answer": 2,
          },
          {
            "dialogue": "제가 자주 보는 친구들도 많아요~",
            "options": ["cat", "chicken", "dog"],
            "answer": 0,
          },
          {
            "dialogue": "마지막이에요! 이 친구 이름만 알면 돼요!",
            "options": ["mouse", "dog", "cat"],
            "answer": 0,
          },
        ];
      case 4: // 테마4 동물 2
        return [
          {
            "dialogue": "동물의 중급 마법서를 골라주세요!",
            "options": ["elephant", "tiger", "monkey"],
            "answer": 0,
          },
          {
            "dialogue": "동물들을 많이 알아야 좋아요!",
            "options": ["sheep", "penguin", "monkey"],
            "answer": 0,
          },
          {
            "dialogue": "세상엔 수많은 동물 친구들이 있답니다~",
            "options": ["penguin", "sheep", "monkey"],
            "answer": 0,
          },
          {
            "dialogue": "그친구 중에서 제가 마법을 가장 잘 써요!",
            "options": ["sheep", "tiger", "monkey"],
            "answer": 1,
          },
          {
            "dialogue": "마지막이에요! 도움 주셔서 정말 감사해요!",
            "options": ["elephant", "sheep", "penguin"],
            "answer": 2,
          },
        ];
      case 5: // 테마5 동물 3
        return [
          {
            "dialogue": "동물의 상급 마법서를 골라주세요!",
            "options": ["chick", "sheep", "frog"],
            "answer": 0,
          },
          {
            "dialogue": "저도 처음 보는 친구들이 많네요!",
            "options": ["turtle", "rabbit", "chick"],
            "answer": 0,
          },
          {
            "dialogue": "세상은 정말 넓은 것 같아요! 처음 들어봐~",
            "options": ["rabbit", "duck", "bird"],
            "answer": 1,
          },
          {
            "dialogue": "어떻게 다 기억하실래요? 대단해요!",
            "options": ["frog", "rabbit", "chick"],
            "answer": 0,
          },
          {
            "dialogue": "저도 더 열심히 공부할게요! 감사해요!",
            "options": ["turtle", "duck", "rabbit"],
            "answer": 2,
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
            // 오답 1회 허용 → 말풍선 변경
            _stories[_step]["dialogue"] = "다시 들어보고 골라볼까요?";
          } else {
            _step++;
          }
        }

        if (_step >= _stories.length) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => Level1ResultPage(
                    themeId: widget.themeId,
                    success: _correctCount >= 3,
                  ),
            ),
          );
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
    final prefix = (widget.themeId <= 2) ? "color_" : "animal_";

    return Scaffold(
      appBar: AppBar(
        title: Text("레벨1 테마${widget.themeId}"),
        backgroundColor: Colors.orange[200],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/img/contents/gameListen/level1/yangji_chat.png",
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        current["dialogue"],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Icon(Icons.volume_up, size: 48),
              const SizedBox(height: 8),
              const Text("누르면 음성이 출력돼요!"), // 추후 오디오 삽입
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
                          "assets/img/contents/gameListen/level1/${prefix}${name}.png",
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
