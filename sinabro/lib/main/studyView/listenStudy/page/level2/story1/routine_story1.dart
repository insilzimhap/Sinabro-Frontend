import 'package:flutter/material.dart';
import 'intro_page.dart';
import 'gender_select_page.dart';
import 'main_keyword.dart';
import 'story_page.dart';
import 'models.dart';

/// 🎬 레벨2 스토리1 전체 루틴 실행 (가족)
void startLevel2Story1Routine(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const Level2Story1Routine()),
  );
}

class Level2Story1Routine extends StatefulWidget {
  const Level2Story1Routine({super.key});

  @override
  State<Level2Story1Routine> createState() => _Level2Story1RoutineState();
}

class _Level2Story1RoutineState extends State<Level2Story1Routine> {
  Gender? _selectedGender;
  int _currentIndex = 0; // 0~5 (총 6명)

  void _goToGenderSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => GenderSelectPageWrapper(
              onSelected: (gender) {
                setState(() => _selectedGender = gender);
                _startNextStep();
              },
            ),
      ),
    );
  }

  void _startNextStep() {
    // 6명(엄마, 아빠, 언니/누나, 형/오빠, 나, 동생) 순서대로 실행
    if (_currentIndex < 6) {
      final index = _currentIndex + 1;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MainKeywordPage(
                index: index,
                gender: _selectedGender!,
                onNext: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => StoryPage(
                            index: index,
                            gender: _selectedGender!,
                            onFinished: () {
                              setState(() => _currentIndex++);
                              _startNextStep();
                            },
                          ),
                    ),
                  );
                },
              ),
        ),
      );
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("잘했어요!"),
            content: const Text("가족에 대해 모두 배웠어요 🍎"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("완료"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Level2IntroPageWrapper(onNext: _goToGenderSelect);
  }
}

/// ✅ 인트로 페이지 래퍼
class Level2IntroPageWrapper extends StatelessWidget {
  final VoidCallback onNext;
  const Level2IntroPageWrapper({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Level2IntroPage(onFinished: onNext);
  }
}

/// ✅ 성별 선택 페이지 래퍼
class GenderSelectPageWrapper extends StatelessWidget {
  final ValueChanged<Gender> onSelected;
  const GenderSelectPageWrapper({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GenderSelectPage(onSelected: onSelected);
  }
}
