import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/main/studyView/writeStudy/controller/write_study_controller.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/write_study_widget.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';

/// 최상위 쓰기 학습 페이지
class WriteStudyPage extends StatelessWidget {
  final String childId;
  const WriteStudyPage({super.key, this.childId = ""});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WriteStudyController(),
      child: _WriteStudyView(childId: childId),
    );
  }
}

/// 내부 위젯: 학습 단계 관리, 채점 로직 포함
class _WriteStudyView extends StatefulWidget {
  final String childId;
  const _WriteStudyView({super.key, this.childId = ""});

  @override
  State<_WriteStudyView> createState() => _WriteStudyViewState();
}

class _WriteStudyViewState extends State<_WriteStudyView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey<WritingCanvasState> canvasKey = GlobalKey(); // ✅ canvas 접근용

  final List<String> ttsPaths = [
    'audio/tts/studyWrite/test/leeul.mp3',
    'audio/tts/studyWrite/test/apple.mp3',
    'audio/tts/studyWrite/test/hello.mp3',
  ];

  int _lastPlayedStep = -1;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// 🎧 현재 단계 TTS 재생
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        children: [WriteStudyWidget(canvasKey: canvasKey, childId: widget.childId,)],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  canvasKey.currentState
                      ?.recognizeAndCheckText(); // ✅ 리팩토링된 채점 호출
                },
                child: const Text('채점하기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.reset();
                  canvasKey.currentState?.clearCanvas(); // ✅ 캔버스 초기화
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
