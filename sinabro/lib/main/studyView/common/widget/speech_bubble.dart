import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.name, required this.text, required this.color});
  final String name;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(name, style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 22)),
        ],
      ),
    );
  }
}
