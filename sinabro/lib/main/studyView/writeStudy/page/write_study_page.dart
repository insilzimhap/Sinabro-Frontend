import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/main/studyView/writeStudy/controller/write_study_controller.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/write_study_widget.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/feedback_dialog.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart'; // ✅ 로비 페이지

class WriteStudyPage extends StatelessWidget {
  final String childId;
  const WriteStudyPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WriteStudyController(),
      child: _WriteStudyView(childId: childId),
    );
  }
}

class _WriteStudyView extends StatefulWidget {
  final String childId;
  const _WriteStudyView({super.key, required this.childId});

  @override
  State<_WriteStudyView> createState() => _WriteStudyViewState();
}

class _WriteStudyViewState extends State<_WriteStudyView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _lastPlayedStep = -1;

  final List<String> ttsPaths = [
    'audio/tts/studyWrite/test/leeul.mp3',
    'audio/tts/studyWrite/test/apple.mp3',
    'audio/tts/studyWrite/test/hello.mp3',
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCurrentStepTTS(BuildContext context) async {
    final controller = Provider.of<WriteStudyController>(
      context,
      listen: false,
    );
    final step = controller.currentStep;

    if (_lastPlayedStep != step) {
      _lastPlayedStep = step;
      try {
        await _audioPlayer.play(AssetSource(ttsPaths[step]));
      } catch (e) {
        debugPrint('🔊 TTS 재생 실패: $e');
      }
    }
  }

  Future<void> _checkAnswer(BuildContext context) async {
    final controller = Provider.of<WriteStudyController>(
      context,
      listen: false,
    );

    try {
      controller.updateRecognizedText(controller.currentAnswer);

      if (controller.checkAnswer()) {
        await _audioPlayer.play(
          AssetSource('audio/tts/studyWrite/correct.mp3'),
        );

        final isLast = controller.currentStep == 2;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => FeedbackDialog(isCorrect: true, isLastStep: isLast),
        ).then((_) {
          if (isLast) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LobbyChildScreen(childId: widget.childId),
              ),
            );
          } else {
            controller.nextStepOrRetry();
          }
        });
      } else {
        await _audioPlayer.play(
          AssetSource('audio/tts/studyWrite/Incorrect.mp3'),
        );

        if (controller.attempt == 0) {
          controller.nextStepOrRetry();
        } else {
          final isLast = controller.currentStep == 2;
          if (isLast) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const FeedbackDialog(isCorrect: false, isLastStep: true),
            ).then((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LobbyChildScreen(childId: widget.childId),
                ),
              );
            });
          } else {
            controller.nextStepOrRetry();
          }
        }
      }
    } catch (e) {
      debugPrint('채점 오류: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ 위젯이 빌드된 후 단 한 번만 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentStepTTS(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<WriteStudyController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        title: Text('쓰기 학습 (${controller.currentStep + 1}/3)'),
        backgroundColor: Colors.orange[100],
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          WriteStudyWidget(childId: widget.childId), // ✅ childId 넘기기!
          WritingCanvas(
            onRecognize: (String text) {
              controller.updateRecognizedText(text);
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _checkAnswer(context),
                child: const Text('인식하기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.reset();
                },
                child: const Text('지우기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
