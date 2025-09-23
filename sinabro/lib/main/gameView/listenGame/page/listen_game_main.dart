import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/common/layout/listen_game_layout.dart';
import 'flow_config.dart';

class ListenGameMainPage extends StatefulWidget {
  final int level; // 1, 2, 3

  const ListenGameMainPage({super.key, required this.level});

  @override
  State<ListenGameMainPage> createState() => _ListenGameMainPageState();
}

class _ListenGameMainPageState extends State<ListenGameMainPage> {
  int _step = 0; // 0=스토리, 1=전환, 2=테마선택, 3=게임, 4=결과
  int _themeId = 1;
  int _currentIndex = 0;
  int _correctCount = 0;

  void _nextStep() => setState(() => _step++);

  void _startGame(int themeId) {
    setState(() {
      _themeId = themeId;
      _step = 3;
      _currentIndex = 0;
      _correctCount = 0;
    });
  }

  void _onAnswer(bool isCorrect) {
    if (isCorrect) _correctCount++;
    if (_currentIndex < 4) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _step = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = levelConfigs[widget.level]!;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _buildStep(config),
      ),
    );
  }

  Widget _buildStep(LevelFlowConfig config) {
    switch (_step) {
      case 0: // 스토리
        return _buildStory(config);
      case 1: // 전환
        Future.delayed(const Duration(seconds: 2), _nextStep);
        return Center(child: Text("레벨${widget.level} → 게임으로 이동 중..."));
      case 2: // 테마 선택
        return _buildThemeSelect(config);
      case 3: // 게임
        final data = config.characterData();
        return ListenGameLayout(
          characterName: data.characterName,
          dialogueText: "${data.dialogueText}\n\n문제 ${_currentIndex + 1} / 5",
          characterImagePath: data.characterImagePath,
          optionImagePaths: data.optionImagePaths,
          onPlayAudio: data.onPlayAudio,
          dialogueColor: data.dialogueColor,
          nameTagColor: data.nameTagColor,
        );
      case 4: // 결과
        return _buildResult(config);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 스토리 진행
  Widget _buildStory(LevelFlowConfig config) {
    int storyIndex = 0;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final story = config.story[storyIndex];
        return GestureDetector(
          onTap: story.showButton
              ? null
              : () {
                  if (storyIndex < config.story.length - 1) {
                    setLocalState(() => storyIndex++);
                  }
                },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(story.imagePath, width: 240, height: 240),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: config.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    story.dialogue,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (story.showButton) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    onPressed: _nextStep,
                    child: const Text(
                      "도전하기",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  /// 테마 선택
  Widget _buildThemeSelect(LevelFlowConfig config) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: config.themeCount,
      itemBuilder: (context, index) {
        final id = index + 1;
        return GestureDetector(
          onTap: () => _startGame(id),
          child: Container(
            color: config.color.withOpacity(0.3),
            child: Center(child: Text("테마 $id")),
          ),
        );
      },
    );
  }

  /// 결과 (클리어/실패)
  Widget _buildResult(LevelFlowConfig config) {
    final isClear = _correctCount >= 3;
    final results = isClear ? config.ending : config.fail;
    final result = results[_themeId - 1];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(result.imagePath, width: 240, height: 240),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isClear
                  ? config.color.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isClear
                    ? config.color.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              result.dialogue,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _step = 2),
            child: const Text("테마 선택으로 돌아가기"),
          )
        ],
      ),
    );
  }
}
