// lib/main/studyView/listenStudy/page/level2/story1/routine_host.dart
// (Or keep the filename as routine_flow.dart if preferred)

/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 레벨 2, Story 1 (가족) 학습 흐름 호스트]
 *
 * 이 파일은 레벨 2의 '가족' 주제(FR_LS_006) 학습 흐름 전체를 관리하는
 * StatefulWidget (`Level2Story1Routine`)을 포함합니다.
 * `listen_study_router`의 `startLevel2Routine` 함수에서 이 위젯을 호출하여 시작됩니다.
 *
 * - 진행 순서: Intro -> 성별 선택 -> (키워드 -> 스토리) * 6 -> 완료 팝업
 * - 내부 상태(`_selectedGender`, `_currentIndex`)를 사용하여 현재 단계를 관리합니다.
 * - 각 단계 페이지 완료 시 콜백(onFinished, onSelected, onNext)을 통해
 * 다음 단계(`_startNextStep`)를 트리거합니다.
 * - `childId`를 받아서 모든 하위 페이지 및 완료 팝업에 전달합니다.
 * ----------------------------------------------------------------
 */
import 'package:flutter/material.dart';

// 공통 위젯 import (절대 경로)
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';

// 레벨 2 Story 1 (가족) 관련 페이지 및 모델 import (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/intro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/gender_select_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/main_keyword.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/story_page.dart'; // StoryPage (Stroy1 용)
import 'package:sinabro/main/studyView/listenStudy/page/level2/story1/models.dart'; // Gender enum

// ✅ [추가] 라우트 이름 상수 (임시 정의, 나중에 AppConstants로 옮기세요)
const routeNameListenAppleSelect =
    '/listen-apple-select'; // ApplePopup 완료 후 돌아갈 경로

/// 🎬 레벨 2 Story 1 (가족) 전체 루틴을 관리하는 StatefulWidget
///   - `startLevel2Routine` 함수 대신 이 위젯을 직접 `MaterialPageRoute`로 호출합니다.
class Level2Story1Routine extends StatefulWidget {
  final bool isGold; // 현재 학습이 황금 사과인지 여부
  final String childId; // 현재 학습 중인 자녀 ID

  const Level2Story1Routine({
    super.key,
    required this.isGold,
    required this.childId, // ✅ 생성자에서 childId 받기
  });

  @override
  State<Level2Story1Routine> createState() => _Level2Story1RoutineState();
}

class _Level2Story1RoutineState extends State<Level2Story1Routine> {
  // --- 상태 변수 ---
  Gender? _selectedGender; // 사용자가 선택한 성별 (null이면 아직 선택 전)
  int _currentIndex = 0; // 현재 진행 중인 가족 구성원 인덱스 (0: 시작 전, 1~6: 진행 중)
  // PageController 등을 사용하여 페이지 전환을 관리할 수도 있음 (현재는 Navigator push/pushReplacement 사용)

  // --- 네비게이션 함수 ---

  /// 2. 성별 선택 페이지로 이동하는 함수
  void _goToGenderSelect() {
    debugPrint('[Level2 Story1 Host] Navigating to Gender Select.');
    Navigator.push(
      context,
      MaterialPageRoute(
        // GenderSelectPage를 직접 호출하는 대신 Wrapper 사용 (구조 유지)
        builder: (_) => GenderSelectPageWrapper(
          childId: widget.childId, // ✅ childId 전달
          onSelected: (gender) {
            // 성별 선택 완료 콜백
            debugPrint(
                '[Level2 Story1 Host] Gender selected: $gender. Starting keywords.');
            setState(() => _selectedGender = gender); // 선택된 성별 상태 업데이트
            _startNextStep(); // 다음 단계(키워드/스토리) 시작
          },
        ),
      ),
    );
  }

  /// 3. 다음 키워드/스토리 단계로 진행하는 함수
  void _startNextStep() {
    // 현재 인덱스(_currentIndex)가 6 미만이면 다음 가족 구성원 학습 진행
    if (_currentIndex < 6) {
      final nextIndex = _currentIndex + 1; // 다음 학습할 가족 구성원 인덱스 (1~6)
      debugPrint('[Level2 Story1 Host] Starting Keyword $nextIndex.');

      // MainKeywordPage 표시 (Navigator.push 사용)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MainKeywordPage(
            index: nextIndex, // 현재 가족 구성원 번호
            gender: _selectedGender!, // 선택된 성별 (null 아님 보장)
            childId: widget.childId, // ✅ childId 전달
            onNext: () {
              // MainKeywordPage 탭 완료 콜백
              debugPrint(
                  '[Level2 Story1 Host] Keyword finished. Showing Story $nextIndex.');
              // StoryPage로 교체 (Navigator.pushReplacement 사용)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryPage(
                    index: nextIndex, // 현재 가족 구성원 번호
                    gender: _selectedGender!, // 선택된 성별
                    childId: widget.childId, // ✅ childId 전달
                    onFinished: () {
                      // StoryPage 완료 콜백
                      debugPrint(
                          '[Level2 Story1 Host] Story finished. Moving to next keyword.');
                      setState(() => _currentIndex++); // 현재 인덱스 증가
                      _startNextStep(); // 다음 단계 재귀 호출
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // 모든 구성원(6명) 학습 완료 시 종료 다이얼로그 표시
      debugPrint(
          '[Level2 Story1 Host] All keywords finished. Showing finish dialog.');
      _showFinishDialog();
      // _showFinishDialog 내부에서 showApplePopup 호출
    }
  }

  /// 4. 학습 완료 시 팝업을 표시하는 함수 (showApplePopup 호출)
  void _showFinishDialog() {
    // 팝업 표시 (기존 showDialog 대신 showApplePopup 사용)
    showApplePopup(
      context,
      isGold: widget.isGold,
      childId: widget.childId, // ✅ childId 전달
    );
    // showApplePopup 내부에서 5초 후 자동으로 팝업 닫고 ListenAppleSelect로 이동함
  }

  // --- 빌드 함수 ---
  @override
  Widget build(BuildContext context) {
    // 1. 첫 화면으로 인트로 페이지 래퍼 표시
    //    onNext 콜백으로 _goToGenderSelect 함수 연결
    return Level2IntroPageWrapper(
      childId: widget.childId, // ✅ childId 전달
      onNext: _goToGenderSelect,
    );
  }
}

// ======================================================
// Helper Wrapper Widgets (기존 구조 유지)
// ======================================================

/// ✅ 인트로 페이지 래퍼 (Wrapper)
///   - Level2IntroPage를 감싸서 필요한 파라미터(onFinished, childId)를 전달합니다.
class Level2IntroPageWrapper extends StatelessWidget {
  final VoidCallback onNext;
  final String childId; // ✅ childId 추가

  const Level2IntroPageWrapper({
    super.key,
    required this.onNext,
    required this.childId, // ✅ 생성자에서 받기
  });

  @override
  Widget build(BuildContext context) {
    // Level2IntroPage 생성 시 onFinished 콜백과 childId 전달
    return Level2IntroPage(
      onFinished: onNext,
      childId: childId, // ✅ childId 전달
    );
  }
}

/// ✅ 성별 선택 페이지 래퍼 (Wrapper)
///   - GenderSelectPage를 감싸서 필요한 파라미터(onSelected, childId)를 전달합니다.
class GenderSelectPageWrapper extends StatelessWidget {
  final ValueChanged<Gender> onSelected;
  final String childId; // ✅ childId 추가

  const GenderSelectPageWrapper({
    super.key,
    required this.onSelected,
    required this.childId, // ✅ 생성자에서 받기
  });

  @override
  Widget build(BuildContext context) {
    // GenderSelectPage 생성 시 onSelected 콜백과 childId 전달
    return GenderSelectPage(
      onSelected: onSelected,
      childId: childId, // ✅ childId 전달
    );
  }
}
