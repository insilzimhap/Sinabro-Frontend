// lib/main/studyView/listenStudy/level2/story2/story_page.dart
import 'package:flutter/material.dart';
import 'model/routine_content.dart';

class Story2StoryPage extends StatefulWidget {
  final List<RoutineContent> data;
  final VoidCallback onFinished;

  const Story2StoryPage({
    super.key,
    required this.data,
    required this.onFinished,
  });

  @override
  State<Story2StoryPage> createState() => _Story2StoryPageState();
}

class _Story2StoryPageState extends State<Story2StoryPage> {
  int _index = 0;

  void _next() {
    if (_index < widget.data.length - 1) {
      setState(() => _index++);
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.data[_index];
    return Scaffold(
      body: GestureDetector(
        onTap: _next,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(story.imagePath ?? "", width: 220),
              const SizedBox(height: 16),
              Text(story.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
