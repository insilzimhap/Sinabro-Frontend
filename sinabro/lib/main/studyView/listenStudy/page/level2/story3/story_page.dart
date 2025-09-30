import 'package:flutter/material.dart';
import 'model/routine_content.dart';

class StoryPage extends StatefulWidget {
  final List<RoutineContent> stories;
  final VoidCallback onFinished;

  const StoryPage({
    super.key,
    required this.stories,
    required this.onFinished,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int _index = 0;

  void _next() {
    if (_index < widget.stories.length - 1) {
      setState(() => _index++);
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_index];
    return Scaffold(
      body: GestureDetector(
        onTap: _next,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(story.imagePath ?? "", width: 240),
              const SizedBox(height: 16),
              Text(story.text,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
