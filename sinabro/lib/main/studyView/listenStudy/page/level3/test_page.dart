import 'package:flutter/material.dart';
import 'data/routine_data.dart';
import 'model/routine_content.dart';
import 'intro_topic_page.dart';
import 'main_topic_page.dart';
import 'main_keyword_page.dart';
import 'story_page.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  void _startRoutine(BuildContext context, int routineIndex) {
    final routine = routineContents
        .where((r) => r.id.startsWith("${routineIndex + 1}-"))
        .toList();

    if (routine.isEmpty) return;

    // Intro → MainTopicPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntroTopicPage(
          title: "째깍째깍... 지금 뭐하는 시간이지?",
          imagePath: "assets/img/contents/studyListen/level3/clock.png",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainTopicPage(
                  topicImagePath: routine.first.topicImagePath, // ✅ 토픽 이미지 사용
                  title: routine.first.topic,
                  onTap: () {
                    // 루틴 전체 실행 시작
                    _startRoutineFlow(context, routine, 0);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 루틴 전체 실행 (스토리 자동 진행 포함)
  void _startRoutineFlow(
      BuildContext context, List<RoutineContent> routine, int keywordIndex) {
    if (keywordIndex >= routine.length) return;

    final keyword = routine[keywordIndex];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainKeywordPage(
          imagePath: keyword.imagePath, // ✅ 키워드 이미지는 여기서
          title: keyword.title,
          onTap: () {
            _startStoryFlow(context, routine, keywordIndex, 0);
          },
        ),
      ),
    );
  }

  // 스토리 자동 진행 (20초마다)
  void _startStoryFlow(BuildContext context, List<RoutineContent> routine,
      int keywordIndex, int storyIndex) {
    final keyword = routine[keywordIndex];
    if (storyIndex >= keyword.stories.length) {
      // 다음 키워드로 이동
      _startRoutineFlow(context, routine, keywordIndex + 1);
      return;
    }

    final story = keyword.stories[storyIndex];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPage(
          imagePath: story.imagePath,
          text: story.text,
          onFinished: () {
            // 20초 뒤 다음 스토리 실행
            Future.delayed(const Duration(seconds: 20), () {
              _startStoryFlow(context, routine, keywordIndex, storyIndex + 1);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3E5),
        elevation: 0,
        title: const Text(
          "Level 3 Test",
          style: TextStyle(color: Color(0xFF7C685F)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startRoutine(context, 0),
              child: const Text("1번 루틴 (아침시간)"),
            ),
            ElevatedButton(
              onPressed: () => _startRoutine(context, 1),
              child: const Text("2번 루틴 (점심시간)"),
            ),
            ElevatedButton(
              onPressed: () => _startRoutine(context, 2),
              child: const Text("3번 루틴 (놀이시간)"),
            ),
            ElevatedButton(
              onPressed: () => _startRoutine(context, 3),
              child: const Text("4번 루틴 (저녁시간)"),
            ),
          ],
        ),
      ),
    );
  }
}
