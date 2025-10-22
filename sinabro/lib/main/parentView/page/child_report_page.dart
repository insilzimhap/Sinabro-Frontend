// lib/main/parentView/page/child_report_page.dart
/*
 * 파일: lib/main/parentView/page/child_report_page.dart
 * 개요: 자녀의 학습 리포트를 보여주는 화면(뷰 전용, 서버 미연동).
 */

import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

// ✅ 프로필 수정 페이지 import
import 'package:sinabro/main/parentView/page/child_profile_edit.dart';

/// 자녀 학습 리포트 페이지 (뷰 전용 / 서버 미연동)
class ChildReportPage extends StatelessWidget {
  final String? parentUserId;

  // 화면에 표시할 정보들
  final String childName; // 예: 박쑥일
  final int childAge; // 예: 7
  final int level; // 예: 2
  final double progressToNext; // 0.0 ~ 1.0 (예: 0.57 -> 57%)

  // 카드에 보여줄 텍스트(데모)
  final String studyRecent; // 최근 학습 기록
  final String studyBest; // 최고 학습 기록
  final String gameRecent; // 최근 게임 기록
  final String gameBest; // 최고 게임 기록

  const ChildReportPage({
    super.key,
    this.parentUserId,
    required this.childName,
    required this.childAge,
    required this.level,
    required this.progressToNext,
    this.studyRecent = '1나무 5열매',
    this.studyBest = '1나무 3열매',
    this.gameRecent = '1나무 5열매',
    this.gameBest = '1나무 3열매',
  });

  @override
  Widget build(BuildContext context) {
    return ParentLayout(
      activeMenu: '자녀페이지',
      parentUserId: parentUserId,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            // ✅ 스크롤 가능
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerBar(),
                  const SizedBox(height: 16),
                  _childHeadline(context),
                  const SizedBox(height: 18),
                  _cardsArea(context),

                  // ▼▼ 스크롤 아래에 AI 리포트 섹션 추가 ▼▼
                  const SizedBox(height: 28),
                  _aiReportSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 상단 큰 녹색 바
  Widget _headerBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF6DBF73),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Text(
        '자녀 페이지',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  /// 이름/나이/레벨/프로필수정 버튼 / 진행도
  Widget _childHeadline(BuildContext context) {
    final percent = (progressToNext * 100).clamp(0, 100).toStringAsFixed(0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 7세 · lv.2  |  프로필 수정
            Row(
              children: [
                Text(
                  '$childAge세  ·  lv.$level',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChildProfileEditPage(
                                parentUserId: parentUserId,
                                childId: 'Sung1_park', // TODO: 실제 값으로 교체
                                childName: childName,
                                childPhone: '010-0000-0000', // TODO: 실제 값으로 교체
                              ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6DBF73)),
                      foregroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('프로필 수정'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$childName 님의 학습 리포트',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            // 진행도
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (progressToNext.clamp(0.0, 1.0)) as double,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFECECEC),
                      color: const Color(0xFF6DBF73),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('다음 레벨까지 $percent%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 좌측: 학습 / 우측: 게임 카드
  Widget _cardsArea(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isNarrow = c.maxWidth < 860;
        final cards = [
          _statCard(
            title: '학습',
            progressLabel:
                '$level 레벨의 ${(progressToNext * 100).toStringAsFixed(0)}% 완료!',
            recent: studyRecent,
            best: studyBest,
          ),
          _statCard(
            title: '게임',
            progressLabel:
                '$level 레벨의 ${(progressToNext * 100).toStringAsFixed(0)}% 완료!',
            recent: gameRecent,
            best: gameBest,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              cards
                  .map(
                    (w) => SizedBox(
                      width: isNarrow ? c.maxWidth : (c.maxWidth - 16) / 2,
                      child: w,
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String progressLabel,
    required String recent,
    required String best,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 탭처럼 보이는 머릿글 + 우측 진행도 텍스트
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EDE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  progressLabel,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 최근 기록
            const Text('최근 학습 기록', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              recent,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(height: 14),

            // 최고 기록
            const Text('최고 학습 기록', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              best,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ▼▼ 스크롤해서 내려오면 보이는 AI 학습 리포트(두 번째 스샷 느낌) ▼▼
  Widget _aiReportSection() {
    final body = '''
현재 $childName는 $childAge세에 받은 나이에 레벨 $level를 획득하며, 자신만의 멋진 성장을 이어가고 있어요.

아직 듣기와 쓰기 학습을 시작하지 않았지만, 앞으로의 가능성에 대해 기대가 큽니다! 오늘은 ‘색상’ 듣기 게임에서 도전해보았는데요, 처음에는 어려움이 있었지만 ${progressToNext >= 0.8 ? '정말 훌륭한 집중력으로 빠르게 적응했어요.' : '점차 리듬을 찾으며 성장하고 있어요.'}

최근 기록은 <${studyRecent}>으로, 스티커 수는 1개입니다. 스티커는 학습의 즐거움을 더해주고, 꾸준함과 성취를 매회마다 주어지는 보상이에요. 앞으로도 작은 성공을 함께 쌓아가 볼 거예요!

매번 조금씩 성장하는 $childName의 모습을 응원할게요! 앞으로도 시나브로와 함께 더 많은 모험을 떠나 보세요. 항상 곁에서 응원할게요.
''';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 배지
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EDE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI 학습 리포트',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 본문
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
