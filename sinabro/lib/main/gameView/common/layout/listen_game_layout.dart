import 'package:flutter/material.dart';

/// 듣기 게임 공용 레이아웃
/// - 캐릭터 이미지 / 대사창(말풍선) / 오디오 버튼 / 보기 선택 영역 포함
/// - 모든 실제 데이터는 외부에서 주입받아 사용
class ListenGameLayout extends StatelessWidget {
  final String characterName;
  final String dialogueText; // 여러 줄일 경우 \n 기준으로 분할
  final String characterImagePath;
  final List<String> optionImagePaths; // 보기 이미지 경로 리스트
  final VoidCallback onPlayAudio;
  final Color dialogueColor; // 대사창 색상
  final Color nameTagColor; // 이름 태그 색상

  const ListenGameLayout({
    super.key,
    required this.characterName,
    required this.dialogueText,
    required this.characterImagePath,
    required this.optionImagePaths,
    required this.onPlayAudio,
    this.dialogueColor = const Color(0xFFFFF3E0),
    this.nameTagColor = const Color(0xFFFFCC80),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── 상단 캐릭터 이미지 + 대사창 ───────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  characterImagePath,
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 캐릭터 이름 태그
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: nameTagColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          characterName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 대사창 (슬라이드 + 말풍선)
                      DialogueSlider(
                        lines: dialogueText.split('\n'),
                        color: dialogueColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── 오디오 버튼 ───────────────────────────────
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 48),
                  onPressed: onPlayAudio,
                ),
                const Text("누르면 음성이 출력돼요!"),
              ],
            ),

            const Spacer(),

            // ── 보기 선택 영역 ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(optionImagePaths.length, (index) {
                return Column(
                  children: [
                    Text("보기 ${index + 1}"),
                    const SizedBox(height: 6),
                    Image.asset(
                      optionImagePaths[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── 대사 슬라이더 (한 줄씩 순환 출력) ──────────────────────────────
class DialogueSlider extends StatefulWidget {
  final List<String> lines;
  final Duration duration;
  final Color color;

  const DialogueSlider({
    super.key,
    required this.lines,
    this.duration = const Duration(seconds: 2),
    this.color = const Color(0xFFFFF3E0),
  });

  @override
  State<DialogueSlider> createState() => _DialogueSliderState();
}

class _DialogueSliderState extends State<DialogueSlider> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(widget.duration);
      if (!mounted) return false;
      setState(() => _index = (_index + 1) % widget.lines.length);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: SpeechBubble(
        key: ValueKey(_index),
        text: widget.lines[_index],
        color: widget.color,
      ),
    );
  }
}

/// ── 말풍선 위젯 ───────────────────────────────────────────────
class SpeechBubble extends StatelessWidget {
  final String text;
  final Color color;

  const SpeechBubble({
    super.key,
    required this.text,
    this.color = const Color(0xFFFFF3E0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(color),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

/// ── 말풍선 그리기 (꼬리 왼쪽) ───────────────────────────────
class BubblePainter extends CustomPainter {
  final Color color;
  BubblePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // 본체
    final r = RRect.fromLTRBR(0, 0, size.width, size.height,
        const Radius.circular(12));
    canvas.drawRRect(r, paint);

    // 꼬리 (왼쪽 중간)
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.lineTo(-10, size.height * 0.45);
    path.lineTo(0, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
