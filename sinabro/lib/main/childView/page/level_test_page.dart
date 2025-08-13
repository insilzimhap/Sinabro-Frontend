import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinabro/config.dart';
import 'package:sinabro/model/level_test_model.dart';
import 'package:sinabro/main/childView/page/select_character.dart';

class LevelTestPage extends StatefulWidget {
  final String childId;
  const LevelTestPage({required this.childId});

  @override
  State<LevelTestPage> createState() => _LevelTestPageState();
}

class _LevelTestPageState extends State<LevelTestPage> {
  late Future<LevelTestResponse> futureData;
  int questionIndex = 0;

  // ✅ 부모 응답 저장용 리스트
  List<Map<String, dynamic>> parentChoices = [];

  // ✅ 자녀 응답 저장용 리스트
  List<Map<String, dynamic>> levelChoices = [];

  @override
  void initState() {
    super.initState();
    futureData = fetchLevelTestData(widget.childId);
  }

  void _nextQuestion() {
    setState(() {
      questionIndex++;
    });
  }

  // ✅ 부모 응답 저장 API 호출
  Future<void> _submitParentChoices() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/parent-choice/submit?childId=${widget.childId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parentChoices),
    );
    if (response.statusCode != 200) {
      print('❌ 부모 응답 저장 실패: ${response.body}');
    }
  }

  // ✅ 자녀 응답 저장 및 점수 반영 API 호출
  Future<void> _submitLevelChoices() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/level-test/submit?childId=${widget.childId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(levelChoices),
    );
    if (response.statusCode != 200) {
      print('❌ 자녀 응답 저장 실패: ${response.body}');
    }
  }

  Widget _buildParentQuestion(ParentQuestion q) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            q.questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
          ),
          const SizedBox(height: 30),
          ...q.options.map((option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                parentChoices.add({
                  'questionId': q.id,
                  'optionId': option.id,
                });
                _nextQuestion();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0D9B8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(option.optionText, textAlign: TextAlign.center),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLevelQuestion(LevelTestQuestion q) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            q.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
          ),
          const SizedBox(height: 20),
          if (q.questionImageUrl != null)
            Image.network('$baseUrl${q.questionImageUrl!}', height: 150),
          const SizedBox(height: 20),
          ...q.options.map((opt) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                // ✅ 자녀 응답 리스트에 추가
                levelChoices.add({
                  'questionId': q.id,
                  'optionId': opt.id ?? 0,
                  'isCorrect': opt.correct,
                });
                _nextQuestion();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0D9B8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (opt.imageUrl != null)
                      Image.network('$baseUrl${opt.imageUrl!}', height: 100),
                    const SizedBox(height: 8),
                    Text(opt.optionText, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInstructionPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '한글 인지 영역 - 5문항\n\n아이에게 문항을 읽어주며\n아이가 문제를 파악하도록 도와주신 후 체크해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.black87),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: () async {
                // 🟤 부모 응답 저장은 여기서 딱 한 번만 호출
                await _submitParentChoices();
                _nextQuestion();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD966),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '네. 아이가 풀도록 도와준 후 체크하겠습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: FutureBuilder<LevelTestResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final parentQuestions = snapshot.data!.parentQuestions;
          final levelQuestions = snapshot.data!.levelTestQuestions;

          final instructionPageIndex = parentQuestions.length;
          final totalQuestions = parentQuestions.length + levelQuestions.length + 1;

          if (questionIndex < parentQuestions.length) {
            return _buildParentQuestion(parentQuestions[questionIndex]);
          } else if (questionIndex == instructionPageIndex) {
            return _buildInstructionPage();
          } else if (questionIndex < totalQuestions) {
            final levelIndex = questionIndex - parentQuestions.length - 1;
            return _buildLevelQuestion(levelQuestions[levelIndex]);
          } else {
            // 🟤 마지막에는 자녀 응답만 전송
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _submitLevelChoices();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectCharacterPage(childId: widget.childId),
                ),
              );
            });
            return const Center(child: Text('레벨테스트 완료!'));
          }
        },
      ),
    );
  }
}

// ✅ API에서 문제 리스트 가져오기
Future<LevelTestResponse> fetchLevelTestData(String childId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/level-test/questions?childId=$childId'),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return LevelTestResponse.fromJson(jsonData);
  } else {
    throw Exception('레벨 테스트 데이터를 불러오지 못했습니다.');
  }
}
