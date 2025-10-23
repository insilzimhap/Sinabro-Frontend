// lib/main/studyView/listenStudy/page/level1/animals/animal_study_entry.dart

import 'package:flutter/material.dart';
import 'package:sinabro/main/studyView/common/layout/study_back_layout.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';
import 'data/animal_study_data.dart';
import 'data/animal_study_models.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_intro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_outro_page.dart';

enum _AnimalStudyPhase { intro, reveal, story, outro }

class AnimalStudyEntry extends StatefulWidget {
  static const routeName = '/study/listen/animal-entry';

  const AnimalStudyEntry({
    super.key,
    required this.fruitId,
    required this.isGold,
    required this.childId, // ✅ childId 받기
  });

  final String fruitId;
  final bool isGold;
  final String childId; // ✅ childId 멤버 변수

  @override
  State<AnimalStudyEntry> createState() => _AnimalStudyEntryState();
}

class _AnimalStudyEntryState extends State<AnimalStudyEntry> {
  late final AnimalGroupData _groupData;
  _AnimalStudyPhase _currentPhase = _AnimalStudyPhase.intro;
  int _currentAnimalIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupData();
    });
  }

  // fruitId에 따라 동물 그룹 데이터 로드
  void _loadGroupData() {
    // ... (switch 문 로직 동일)
    switch (widget.fruitId) {
      case 'FR_LS_003':
        _groupData = animalGroup1;
        break;
      case 'FR_LS_004':
        _groupData = animalGroup2;
        break;
      case 'FR_LS_005':
        _groupData = animalGroup3;
        break;
      default:
        debugPrint("Error: Invalid fruitId '${widget.fruitId}'");
        if (mounted) Navigator.of(context).pop();
        return;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- 페이지 전환 콜백 함수들 ---
  void _onIntroCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _AnimalStudyPhase.reveal);
  }

  void _onRevealCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _AnimalStudyPhase.story);
  }

  void _onStoryCompleted() {
    if (!mounted) return;
    setState(() => _currentPhase = _AnimalStudyPhase.outro);
  }

  // ✅ [수정] _onOutroCompleted 함수 시그니처 변경 (파라미터 제거)
  void _onOutroCompleted() {
    if (!mounted) return;
    // 다음 동물이 있으면 다음 동물로, 없으면 완료 팝업
    if (_currentAnimalIndex < _groupData.animals.length - 1) {
      setState(() {
        _currentAnimalIndex++;
        _currentPhase = _AnimalStudyPhase.reveal; // 다음 동물 Reveal부터 시작
      });
    } else {
      // 모든 동물 학습 완료 -> 팝업 호출
      // ✅ [수정] 파라미터 대신 widget.childId 사용
      showApplePopup(context, isGold: widget.isGold, childId: widget.childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // StudyBackLayout으로 감싸서 뒤로가기 버튼 제공
    return StudyBackLayout(
      onBack: () => Navigator.of(context).pop(), // 뒤로가기 시 현재 학습 종료
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : _buildCurrentPhaseWidget(), // 현재 단계에 맞는 위젯 표시
    );
  }

  /// 현재 학습 단계(_currentPhase)에 맞는 위젯을 생성하고 반환
  Widget _buildCurrentPhaseWidget() {
    // 현재 보여줄 동물 데이터
    final currentAnimal = _groupData.animals[_currentAnimalIndex];
    // 현재 동물이 그룹의 마지막 동물인지 여부
    final isFinalAnimal = _currentAnimalIndex == _groupData.animals.length - 1;

    // 현재 단계(_currentPhase)에 따라 다른 페이지 위젯 반환
    switch (_currentPhase) {
      case _AnimalStudyPhase.intro:
        return AnimalIntroPage(
          childId: widget.childId, // ✅ childId 전달
          groupData: _groupData,
          onIntroCompleted: _onIntroCompleted,
        );
      case _AnimalStudyPhase.reveal:
        return AnimalRevealPage(
          childId: widget.childId, // ✅ childId 전달
          animalData: currentAnimal,
          onRevealCompleted: _onRevealCompleted,
        );
      case _AnimalStudyPhase.story:
        return AnimalStoryPage(
          childId: widget.childId, // ✅ childId 전달
          animalData: currentAnimal,
          onStoryCompleted: _onStoryCompleted,
        );
      case _AnimalStudyPhase.outro:
        return AnimalOutroPage(
          childId: widget.childId, // ✅ childId 전달
          groupData: _groupData,
          animalData: currentAnimal,
          isFinalAnimalInGroup: isFinalAnimal,
          // ✅ [수정] onOutroCompleted 콜백 전달 (파라미터 없는 VoidCallback)
          onOutroCompleted: _onOutroCompleted,
        );
    }
  }
}
