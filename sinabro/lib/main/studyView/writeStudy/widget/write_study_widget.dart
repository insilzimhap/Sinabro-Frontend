import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/main/studyView/writeStudy/controller/write_study_controller.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/writing_canvas.dart';
import 'package:sinabro/main/childView/page/lobby_child.dart';
import 'package:sinabro/main/studyView/writeStudy/widget/feedback_dialog.dart';

/// 각 학습 단계에 따라 이미지를 구성하고 피드백을 보여주는 위젯
class WriteStudyWidget extends StatefulWidget {
  final GlobalKey<WritingCanvasState> canvasKey;
  final String childId;

  const WriteStudyWidget({
    super.key,
    required this.canvasKey,
    this.childId = "",
  });

  @override
  State<WriteStudyWidget> createState() => _WriteStudyWidgetState();
}

class _WriteStudyWidgetState extends State<WriteStudyWidget> {
  final AudioPlayer _player = AudioPlayer();

  // --- 이번 "열매" 세트 ---
  static const List<String> _candidateSet = [
    'ㄱ',
    'ㄲ',
    'ㄷ',
    'ㄸ',
    'ㅅ',
    'ㅆ',
    'ㅈ',
    'ㅉ',
    'ㅂ',
    'ㅃ',
  ];

  // Step -> 타겟 문자 (예시 매핑; 필요에 맞게 바꿔도 됨)
  static const Map<int, String> _stepTarget = {
    0: 'ㄱ', // 자음 학습
    1: '가', // 단어(또는 글자) 단계 예시
    2: '가위', // 문장/단어 단계 예시
  };

  // 자산 경로(임시 예시)
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
    // 화면 진입 시 현재 단계 TTS 1회 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<WriteStudyController>();
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

  // ---------------- 단계별 UI ----------------

  /// 1단계: 자모/기본 쓰기
  Widget _buildConsonantStage(WriteStudyController controller) {
    final step = controller.currentStep;
    final target = _stepTarget[step] ?? 'ㄱ';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 좌측 정보 패널(이미지/단어/말풍선 등은 필요에 맞게 교체)
        GestureDetector(
          onTap: () => _playSound(ttsPaths[step]),
          child: Image.asset(mainImagePaths[step], width: 300),
        ),

        // 우측: 안내 이미지 + 캔버스
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(strokeImagePaths[step], width: 250),
            if (controller.isCorrect)
              Image.asset(
                'assets/img/contents/studyWrite/correct.png',
                width: 400,
              ),
            SizedBox(
              width: 250,
              height: 250,
              child: WritingCanvas(
                key: widget.canvasKey,
                targetChar: target, // ★ 타겟 전달
                candidateSet: _candidateSet, // ★ 세트 제한 전달
                onRecognize:
                    (String text) => _handleRecognize(text, controller),
                childId: widget.childId,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2단계: 단어 쓰기(또는 글자 학습 2라운드)
  Widget _buildWordStage(WriteStudyController controller) {
    final step = controller.currentStep;
    final target = _stepTarget[step] ?? '가';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _playSound(ttsPaths[step]),
            child: Image.asset(mainImagePaths[step], width: 280),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(strokeImagePaths[step], width: 280),
              if (controller.isCorrect)
                Image.asset(
                  'assets/img/contents/studyWrite/correct.png',
                  width: 200,
                ),
              SizedBox(
                width: 280,
                height: 200,
                child: WritingCanvas(
                  key: widget.canvasKey,
                  targetChar: target,
                  candidateSet: _candidateSet,
                  onRecognize:
                      (String text) => _handleRecognize(text, controller),
                  childId: widget.childId,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3단계: 문장/자유 쓰기(완료 시 로비 이동)
  Widget _buildSentenceStage(WriteStudyController controller) {
    final step = controller.currentStep;
    final target = _stepTarget[step] ?? '가위';

    if (controller.isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LobbyChildScreen(childId: widget.childId),
            ),
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
            child: Image.asset(mainImagePaths[step], width: 250),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(strokeImagePaths[step], width: 600, height: 200),
              if (controller.isCorrect)
                Image.asset(
                  'assets/img/contents/studyWrite/correct.png',
                  width: 200,
                ),
              SizedBox(
                width: 600,
                height: 200,
                child: WritingCanvas(
                  key: widget.canvasKey,
                  targetChar: target,
                  candidateSet: _candidateSet,
                  onRecognize:
                      (String text) => _handleRecognize(text, controller),
                  childId: widget.childId,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- 인식 결과 처리 ----------------

  /// 셀비 인식 결과를 받아 컨트롤러/다이얼로그/다음 단계까지 처리
  void _handleRecognize(String recognized, WriteStudyController controller) {
    controller.updateRecognizedText(recognized);

    final step = controller.currentStep;
    final target = _stepTarget[step] ?? '';
    final isCorrect = recognized == target;

    controller.setCorrect(isCorrect);

    showDialog(
      context: context,
      builder:
          (_) => FeedbackDialog(
            isCorrect: isCorrect,
            isLastStep: controller.isLastStep,
          ),
    ).then((_) {
      if (isCorrect) {
        // 다음 단계로 이동 + 캔버스 초기화
        controller.nextStep();
        widget.canvasKey.currentState?.clearCanvas();
        // 다음 단계 TTS
        final nextStep = controller.currentStep;
        if (nextStep < ttsPaths.length) {
          _playSound(ttsPaths[nextStep]);
        }
      } else {
        // 오답: 캔버스만 비워서 재도전
        widget.canvasKey.currentState?.clearCanvas();
      }
      setState(() {});
    });
  }

  // ---------------- 빌드 ----------------

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WriteStudyController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Builder(
        builder: (_) {
          if (controller.currentStep == 0)
            return _buildConsonantStage(controller);
          if (controller.currentStep == 1) return _buildWordStage(controller);
          return _buildSentenceStage(controller);
        },
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
