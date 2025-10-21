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
    required this.isGold, // 마지막 사과 황금 사과인지 확인하기 위한
  });

  final String fruitId;
  final bool isGold; //

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

  void _loadGroupData() {
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
        Navigator.of(context).pop();
        return;
    }
    setState(() => _isLoading = false);
  }

  void _onIntroCompleted() =>
      setState(() => _currentPhase = _AnimalStudyPhase.reveal);
  void _onRevealCompleted() =>
      setState(() => _currentPhase = _AnimalStudyPhase.story);
  void _onStoryCompleted() =>
      setState(() => _currentPhase = _AnimalStudyPhase.outro);

  void _onOutroCompleted() {
    if (_currentAnimalIndex < _groupData.animals.length - 1) {
      setState(() {
        _currentAnimalIndex++;
        _currentPhase = _AnimalStudyPhase.reveal;
      });
    } else {
      // 모든 학습이 끝나면 Navigator.pop() 대신 팝업 호출
      showApplePopup(context, isGold: widget.isGold);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudyBackLayout(
      onBack: () => Navigator.of(context).pop(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentPhaseWidget(),
    );
  }

  Widget _buildCurrentPhaseWidget() {
    final currentAnimal = _groupData.animals[_currentAnimalIndex];
    final isFinalAnimal = _currentAnimalIndex == _groupData.animals.length - 1;

    switch (_currentPhase) {
      case _AnimalStudyPhase.intro:
        return AnimalIntroPage(
          groupData: _groupData,
          onIntroCompleted: _onIntroCompleted,
        );
      case _AnimalStudyPhase.reveal:
        return AnimalRevealPage(
          animalData: currentAnimal,
          onRevealCompleted: _onRevealCompleted,
        );
      case _AnimalStudyPhase.story:
        return AnimalStoryPage(
          animalData: currentAnimal,
          onStoryCompleted: _onStoryCompleted,
        );
      case _AnimalStudyPhase.outro:
        return AnimalOutroPage(
          groupData: _groupData,
          animalData: currentAnimal,
          isFinalAnimalInGroup: isFinalAnimal,
          onOutroCompleted: _onOutroCompleted,
        );
    }
  }
}
