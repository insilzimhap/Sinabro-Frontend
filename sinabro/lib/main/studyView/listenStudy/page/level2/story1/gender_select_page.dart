import 'package:flutter/material.dart';
import 'models.dart';

class GenderSelectPage extends StatefulWidget {
  final ValueChanged<Gender> onSelected; // ✅ 콜백 기반
  const GenderSelectPage({super.key, required this.onSelected});

  @override
  State<GenderSelectPage> createState() => _GenderSelectPageState();
}

class _GenderSelectPageState extends State<GenderSelectPage> {
  Gender? _selected;

  void _selectGender(Gender gender) {
    setState(() => _selected = gender);
    Future.delayed(const Duration(milliseconds: 400), () {
      widget.onSelected(gender); // ✅ Navigator 제거, 콜백 전달
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "(  )는 어떤 모습이야?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GenderButton(
                  imagePath:
                      'assets/img/contents/studyListen/level2/story/girl.png',
                  label: "나는 여자아이야",
                  selected: _selected == Gender.female,
                  onTap: () => _selectGender(Gender.female),
                  imageSize: imageSize,
                ),
                const SizedBox(width: 30),
                _GenderButton(
                  imagePath:
                      'assets/img/contents/studyListen/level2/story/boy.png',
                  label: "나는 남자아이야",
                  selected: _selected == Gender.male,
                  onTap: () => _selectGender(Gender.male),
                  imageSize: imageSize,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderButton extends StatefulWidget {
  final String imagePath;
  final String label;
  final bool selected;
  final double imageSize;
  final VoidCallback onTap;

  const _GenderButton({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.imageSize,
  });

  @override
  State<_GenderButton> createState() => _GenderButtonState();
}

class _GenderButtonState extends State<_GenderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale =
        widget.selected
            ? 1.05
            : _pressed
            ? 0.95
            : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: scale,
        child: Container(
          width: widget.imageSize + 60,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9EEDB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected ? Colors.orange : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              if (widget.selected)
                const BoxShadow(
                  color: Colors.orangeAccent,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                widget.imagePath,
                width: widget.imageSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      widget.selected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.selected ? Colors.deepOrange : Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
