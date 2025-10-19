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

/// 내부 위젯: 학습 단계 관리 + 채점/초기화 버튼
class _WriteStudyView extends StatefulWidget {
  final String childId;
  const _WriteStudyView({super.key, this.childId = ""});

  @override
  State<_WriteStudyView> createState() => _WriteStudyViewState();
}

class _WriteStudyViewState extends State<_WriteStudyView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  // ✅ WritingCanvas 에 접근하기 위한 GlobalKey (recognize / clear 등)
  final GlobalKey<WritingCanvasState> canvasKey =
      GlobalKey<WritingCanvasState>();

  /// 단계별 TTS(예시)
  final List<String> ttsPaths = <String>[
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

  /// 🎧 현재 단계 TTS 1회 재생
  Future<void> _playCurrentStepTTS(BuildContext context) async {
    final controller = context.read<WriteStudyController>();
    final step = controller.currentStep;

    if (step != _lastPlayedStep && step >= 0 && step < ttsPaths.length) {
      _lastPlayedStep = step;
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(ttsPaths[step]));
      } catch (e) {
        debugPrint('🔊 TTS 재생 실패: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 첫 렌더 후 1회 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentStepTTS(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WriteStudyController>();

    // 단계가 변하면 TTS 갱신
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentStepTTS(context);
    });

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
          // 실제 학습 화면 (내부에서 WritingCanvas를 canvasKey로 생성해야 함)
          WriteStudyWidget(canvasKey: canvasKey, childId: widget.childId),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Row(
          children: [
            // 채점하기: 캔버스의 하위호환 API 호출
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  canvasKey.currentState?.recognizeAndCheckText();
                },
                child: const Text('채점하기'),
              ),
            ),
            const SizedBox(width: 12),
            // 지우기: 컨트롤러 리셋 + 캔버스 초기화
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.reset();
                  canvasKey.currentState?.clearCanvas();
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
