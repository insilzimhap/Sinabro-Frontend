// lib/main/childView/page/level_test_page.dart
// 레벨 테스트 관련은 permitall 이라 수정 안했음 (그대로 http로 연결)

import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart';
import 'package:sinabro/main/childView/page/select_character.dart';
import 'package:sinabro/model/level_test_model.dart';

class LevelTestPage extends StatefulWidget {
  final String childId;
  const LevelTestPage({Key? key, required this.childId}) : super(key: key);

  @override
  State<LevelTestPage> createState() => _LevelTestPageState();
}

class _LevelTestPageState extends State<LevelTestPage> {
  late Future<LevelTestResponse> futureData;
  int stepIndex =
      0; // 0 = 부모 안내(img1), 1..N = 부모문항(이미지 매핑), 그 다음 = 자녀 안내(img7) → 자녀문항 → 결과(img8)

  final List<Map<String, dynamic>> parentChoices = [];
  final List<Map<String, dynamic>> levelChoices = [];

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureData = fetchLevelTestData(widget.childId);
  }

  void _next() => setState(() => stepIndex++);

  Future<void> _submitParentChoices() async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/parent-choice/submit?childId=${widget.childId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parentChoices),
    );
    if (res.statusCode != 200) {
      debugPrint('❌ 부모 응답 저장 실패: ${res.body}');
    }
  }

  Future<void> _submitLevelChoices() async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/level-test/submit?childId=${widget.childId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(levelChoices),
    );
    if (res.statusCode != 200) {
      debugPrint('❌ 자녀 응답 저장 실패: ${res.body}');
    }
  }

  Widget _progressBar(double ratio) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LinearProgressIndicator(
          value: ratio.clamp(0, 1),
          minHeight: 14,
          color: const Color(0xFFCBC3F2),
          backgroundColor: const Color(0xFFEFEFEF),
        ),
      ),
    );
  }

  Widget _parentIntro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _progressBar(0),
        const SizedBox(height: 24),
        Image.asset('assets/img/leveltest/img1.png', height: 220),
        const SizedBox(height: 20),
        const Text(
          '부모 영역',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '지금부터 레벨테스트를 시작하겠습니다\n\n'
            '다음부터 있을 문제는 부모님들을 대상으로 하는 문제들입니다.\n'
            '반드시 부모님이 선택할 수 있도록 하며, 아이가 선택하지 않도록 주의해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDAD2FF),
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '지금 레벨테스트를 진행하는 사람은 부모입니다',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _parentQuestion(ParentQuestion q, String imgPath, double ratio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _progressBar(ratio),
          const SizedBox(height: 8),
          Image.asset(imgPath, height: 210),
          const SizedBox(height: 20),
          Text(
            q.questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          ...q.options.map(
            (opt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () {
                  parentChoices.add({'questionId': q.id, 'optionId': opt.id});
                  _next();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E3ED)),
                  ),
                  child: Text(
                    opt.optionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childIntro(double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _progressBar(ratio),
        const SizedBox(height: 24),
        Image.asset('assets/img/leveltest/img7.png', height: 220),
        const SizedBox(height: 20),
        const Text(
          '자녀 영역',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '지금부터 자녀의 레벨테스트를 시작하겠습니다\n\n'
            '아이에게 문항을 보여주고 읽어주어\n'
            '아이가 문제를 파악할 수 있도록 도와주신 후 다음으로 넘어가주세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () async {
              await _submitParentChoices();
              _next();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDAD2FF),
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '아이를 도와 레벨테스트를 진행하겠습니다',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // --- 옵션 카드 (한 줄 배치용) ---
  Widget _optionCard(LevelTestOption opt) {
    return GestureDetector(
      onTap: () {
        levelChoices.add({
          'questionId': _currentQuestionId,
          'optionId': opt.id,
          'isCorrect': false, // 서버 판정
        });
        _next();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E2EE), width: 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (opt.imageUrl != null && opt.imageUrl!.isNotEmpty)
              Image.network('$baseUrl${opt.imageUrl!}', height: 64),
            if (opt.optionText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                opt.optionText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 내부에서 현재 문제 id 접근용 (onTap에서 필요)
  int _currentQuestionId = -1;

  // --- 자녀 문항: 보기 "무조건 한 줄" 배치 ---
  Widget _childQuestion(LevelTestQuestion q, double ratio) {
    _currentQuestionId = q.id;

    return Column(
      children: [
        _progressBar(ratio),
        const SizedBox(height: 8),
        Text(
          q.type,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            q.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        if (q.audioUrl != null && q.audioUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () async {
                await _player.play(UrlSource('$baseUrl${q.audioUrl!}'));
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE6E4EE),
                ),
                child: const Icon(Icons.volume_up, size: 48),
              ),
            ),
          ),
        if (q.questionImageUrl != null && q.questionImageUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Image.network('$baseUrl${q.questionImageUrl!}', height: 160),
          ),
        const SizedBox(height: 16),

        // 👉 여기서 한 줄로 모두 배치 (옵션 수만큼 동등분할)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 140, // 타일 높이
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = q.options.length.clamp(1, 6);
                const spacing = 12.0;
                final totalSpacing = spacing * (count - 1);
                final itemWidth = (constraints.maxWidth - totalSpacing) / count;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(q.options.length, (i) {
                    final opt = q.options[i];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i < q.options.length - 1 ? spacing : 0,
                      ),
                      child: SizedBox(
                        width: itemWidth,
                        child: _optionCard(opt),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _result(double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _progressBar(ratio),
        const SizedBox(height: 24),
        Image.asset('assets/img/leveltest/img8.png', height: 240),
        const SizedBox(height: 20),
        const Text(
          '레벨 테스트 종료',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text('이제 아이와 함께 즐거운 학습을 시작해보세요!', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () async {
              await _submitLevelChoices();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectCharacterPage(childId: widget.childId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDAD2FF),
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '다음으로 넘어가기',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: FutureBuilder<LevelTestResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final allParents = List<ParentQuestion>.from(
            snapshot.data!.parentQuestions,
          );
          allParents.sort(
            (a, b) => (a.questionOrder).compareTo(b.questionOrder),
          );

          List<ParentQuestion> parentQs = allParents;
          if (allParents.isNotEmpty &&
              (allParents.first.questionOrder == 1 ||
                  (allParents.first.questionText).contains('부모님이 풉니다'))) {
            parentQs = allParents.sublist(1); // 실제 부모 선택 5문항
          }

          final levelQs = snapshot.data!.levelTestQuestions;

          // 단계 계산: 부모 안내(1) + 부모문항(5) + 자녀 안내(1) + 자녀문항(M) + 결과(1)
          final totalSteps = 1 + parentQs.length + 1 + levelQs.length + 1;
          final ratio = stepIndex / (totalSteps - 1);

          if (stepIndex == 0) return _parentIntro();

          if (stepIndex >= 1 && stepIndex <= parentQs.length) {
            final q = parentQs[stepIndex - 1];
            final imgNumber = stepIndex + 1; // 1→img2, 5→img6
            return _parentQuestion(
              q,
              'assets/img/leveltest/img$imgNumber.png',
              ratio,
            );
          }

          if (stepIndex == parentQs.length + 1) {
            return _childIntro(ratio);
          }

          final childStart = parentQs.length + 2;
          final childEnd = parentQs.length + 1 + levelQs.length;
          if (stepIndex >= childStart && stepIndex <= childEnd) {
            final idx = stepIndex - childStart;
            return _childQuestion(levelQs[idx], ratio);
          }

          return _result(ratio);
        },
      ),
    );
  }
}

// ---------------- API 호출 ----------------
Future<LevelTestResponse> fetchLevelTestData(String childId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/level-test/questions?childId=$childId'),
  );
  if (response.statusCode == 200) {
    return LevelTestResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('레벨 테스트 데이터를 불러오지 못했습니다.');
  }
}
