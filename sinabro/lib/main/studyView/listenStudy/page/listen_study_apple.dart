// lib/main/studyView/listenStudy/page/listen_study_apple.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 학습 콘텐츠 Entry 파일들 import
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_entry_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/data/color_lessons.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_study_entry.dart';
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

// API 연동을 위한 모델
import 'package:sinabro/config.dart';
import 'package:sinabro/common/auth_client.dart';
import 'package:sinabro/main/studyView/common/models/tree_progress.dart';

// 기존 import
import 'level2/routine_flow.dart';
import 'level3/routine_flow.dart';

enum ContentStatus { locked, available, done }

class ListenAppleSelect extends StatefulWidget {
  static const routeName = '/listen-apple-select';
  final String childId;
  const ListenAppleSelect({super.key, required this.childId});

  @override
  State<ListenAppleSelect> createState() => _ListenAppleSelectState();
}

class _ListenAppleSelectState extends State<ListenAppleSelect> {
  TreeProgress? _progressData;
  bool _isLoading = true;

  // ✅ [수정] 하드코딩된 status 리스트 삭제

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    // 테스트용 임시 데이터
    final tempUnlockedData = {
      "ST001": 5,
      "ST002": 5,
      "ST003": 4,
    };

    setState(() {
      _progressData = TreeProgress(unlockedUntilByStage: tempUnlockedData);
      _isLoading = false;
    });
  }

  final List<Offset> spots = const [
    // 첫 번째 나무 (왼쪽) 5개
    Offset(0.12, 0.35),
    Offset(0.21, 0.38),
    Offset(0.07, 0.48),
    Offset(0.16, 0.53),
    Offset(0.25, 0.50),
    // 두 번째 나무 (가운데) 5개
    Offset(0.46, 0.35),
    Offset(0.55, 0.38),
    Offset(0.41, 0.48),
    Offset(0.50, 0.53),
    Offset(0.59, 0.50),
    // 세 번째 나무 (오른쪽) 4개
    Offset(0.82, 0.35),
    Offset(0.91, 0.41),
    Offset(0.79, 0.50),
    Offset(0.89, 0.56),
  ];

  ContentStatus _getAppleStatus(int index) {
    if (_progressData == null) return ContentStatus.locked;
    String stageId;
    int sequenceInStage;
    if (index <= 4) {
      stageId = 'ST001';
      sequenceInStage = index + 1;
    } else if (index <= 9) {
      stageId = 'ST002';
      sequenceInStage = (index - 5) + 1;
    } else {
      stageId = 'ST003';
      sequenceInStage = (index - 10) + 1;
    }
    final unlockedCount = _progressData!.unlockedUntilByStage[stageId] ?? 0;
    return sequenceInStage <= unlockedCount
        ? ContentStatus.available
        : ContentStatus.locked;
  }

  Future<void> _tap(int index) async {
    // ✅ [수정] _getAppleStatus를 함수로 올바르게 호출
    if (_getAppleStatus(index) == ContentStatus.locked) return;

    // ✅ [수정] 황금 사과 위치 올바르게 수정
    final bool isGold = (index == 4 || index == 9 || index == 13);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, ColorEntryPage.routeName,
            arguments: {'lessonsToShow': apple1Lessons, 'isGold': isGold});
        break;
      case 1:
        Navigator.pushNamed(context, ColorEntryPage.routeName,
            arguments: {'lessonsToShow': apple2Lessons, 'isGold': isGold});
        break;
      case 2:
        Navigator.pushNamed(context, AnimalStudyEntry.routeName,
            arguments: {'fruitId': 'FR_LS_003', 'isGold': isGold});
        break;
      case 3:
        Navigator.pushNamed(context, AnimalStudyEntry.routeName,
            arguments: {'fruitId': 'FR_LS_004', 'isGold': isGold});
        break;
      case 4:
        Navigator.pushNamed(context, AnimalStudyEntry.routeName,
            arguments: {'fruitId': 'FR_LS_005', 'isGold': isGold});
        break;
      case 5:
        startLevel2Routine(context, isGold: isGold);
        break;
      case 6:
        startLevel2Routine2(context, 0, isGold: isGold);
        break;
      case 7:
        startLevel2Routine2(context, 1, isGold: isGold);
        break;
      case 8:
        startLevel2Routine3(context, 2, isGold: isGold);
        break;
      case 9:
        startLevel2Routine3(context, 3, isGold: isGold);
        break;
      case 10:
        startLevel3Routine(context, 0, isGold: isGold);
        break;
      case 11:
        startLevel3Routine(context, 1, isGold: isGold);
        break;
      case 12:
        startLevel3Routine(context, 2, isGold: isGold);
        break;
      case 13:
        startLevel3Routine(context, 3, isGold: isGold);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final size = Size(c.maxWidth, c.maxHeight);
          final appleSize = size.width * 0.06;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/img/contents/studyListen/apple_tree.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              for (int i = 0; i < spots.length; i++)
                Positioned(
                  left: spots[i].dx * size.width - appleSize / 2,
                  top: spots[i].dy * size.height - appleSize / 2,
                  child: _Apple(
                    index: i,
                    size: appleSize,
                    // ✅ [수정] _getAppleStatus 함수를 통해 동적으로 상태 전달
                    status: _getAppleStatus(i),
                    onTap: () => _tap(i),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Apple extends StatefulWidget {
  final int index;
  final double size;
  final ContentStatus status;
  final VoidCallback onTap;

  const _Apple({
    required this.index,
    required this.size,
    required this.status,
    required this.onTap,
    super.key,
  });

  @override
  State<_Apple> createState() => _AppleState();
}

class _AppleState extends State<_Apple> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // ✅ [추가] 잠금 상태일 때 사과를 숨기는 로직
    if (widget.status == ContentStatus.locked) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    // ✅ [수정] 황금 사과 위치를 올바르게 수정
    final isGold =
        (widget.index == 4 || widget.index == 9 || widget.index == 13);
    final asset = isGold
        ? 'assets/img/contents/studyListen/gold_apple.png'
        : 'assets/img/contents/studyListen/apple.png';

    int number;
    if (widget.index <= 4) {
      number = widget.index + 1;
    } else if (widget.index <= 9) {
      number = widget.index - 4;
    } else {
      number = widget.index - 9;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.95 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              asset,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
            Text(
              '$number',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: widget.size * 0.45,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
