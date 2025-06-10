import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/main/studyView/writeStudy/controller/write_study_controller.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart';

class WriteStudyWidget extends StatefulWidget {
  final String childId; // ✅ 추가
  const WriteStudyWidget({super.key, required this.childId}); // ✅ required 추가

  @override
  State<WriteStudyWidget> createState() => _WriteStudyWidgetState();
}

class _WriteStudyWidgetState extends State<WriteStudyWidget> {
  final AudioPlayer _player = AudioPlayer();

  final List<String> mainImagePaths = [
    'assets/img/contents/studyWrite/test/leeul.png',
    'assets/img/contents/studyWrite/test/apple.png',
    'assets/img/contents/studyWrite/test/hello.png',
  ];

  final List<String> strokeImagePaths = [
    'assets/img/contents/studyWrite/test/leeulStroke.png',
    'assets/img/contents/studyWrite/test/appleStroke.png',
    'assets/img/contents/studyWrite/test/helloStroke.png',
  ];

  final List<String> ttsPaths = [
    'audio/tts/studyWrite/test/leeul.mp3',
    'audio/tts/studyWrite/test/apple.mp3',
    'audio/tts/studyWrite/test/hello.mp3',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final controller = Provider.of<WriteStudyController>(
        context,
        listen: false,
      );
      _playSound(ttsPaths[controller.currentStep]);
    });
  }

  Future<void> _playSound(String path) async {
    try {
      await _player.play(AssetSource(path));
    } catch (e) {
      debugPrint('음성 재생 실패: $e');
    }
  }

  Widget buildConsonantStage(WriteStudyController controller) {
    final step = controller.currentStep;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => _playSound(ttsPaths[step]),
          child: Image.asset(mainImagePaths[step], width: 300),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(strokeImagePaths[step], width: 250),
            if (controller.isCorrect)
              Image.asset(
                'assets/img/contents/studyWrite/correct.png',
                width: 400,
              ),
          ],
        ),
      ],
    );
  }

  Widget buildWordStage(WriteStudyController controller) {
    final step = controller.currentStep;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _playSound(ttsPaths[step]),
            child: Image.asset(mainImagePaths[step], width: 300),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(strokeImagePaths[step], width: 420),
              if (controller.isCorrect)
                Image.asset(
                  'assets/img/contents/studyWrite/correct.png',
                  width: 350,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSentenceStage(WriteStudyController controller) {
    final step = controller.currentStep;

    if (controller.isCorrect) {
      // 정답이고 마지막 단계이면 2초 후 로비로 이동
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>LobbyChildScreen(childId: widget.childId)),
          );
        }
      });
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _playSound(ttsPaths[step]),
            child: Image.asset(mainImagePaths[step], width: 300),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(strokeImagePaths[step], width: 700),
              if (controller.isCorrect)
                Image.asset(
                  'assets/img/contents/studyWrite/correct.png',
                  width: 380,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<WriteStudyController>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Builder(
        builder: (_) {
          if (controller.currentStep == 0)
            return buildConsonantStage(controller);
          if (controller.currentStep == 1) return buildWordStage(controller);
          return buildSentenceStage(controller);
        },
      ),
    );
  }
}
