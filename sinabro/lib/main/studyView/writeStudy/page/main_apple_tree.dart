// lib/main/studyView/writeStudy/page/main_apple_tree.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // jsonDecode
import 'package:http/http.dart' as http; // API 호출
import 'package:sinabro/config.dart'; // baseUrl 사용

// ⭐ 별잇기 — 프리픽스 제거, show만 사용
import 'package:sinabro/main/studyView/writeStudy/page/level1/star_write.dart'
    show ConstellationDrawPage;

// 🍓🍇🥝 잼
import 'package:sinabro/main/studyView/writeStudy/page/level1/jam_write.dart'
    as jam;

// ✈️ 비행기
import 'package:sinabro/main/studyView/writeStudy/page/level1/plane_write.dart'
    as plane;

// 🍭 달고나/캔디
import 'package:sinabro/main/studyView/writeStudy/page/level1/candy_write.dart';

// ─ level2
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_1.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_2.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_3.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level2/writing_2_4.dart';

// ─ level3
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_1.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_2.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_3.dart';
import 'package:sinabro/main/studyView/writeStudy/page/level3/writing_3_4.dart'
    as w34 show Writing3_4_IntroPage;

// ──────────────────────────────────────────────────────────────────────────────
// ⭐⭐ [1] 상수 및 모델 추가 (요구사항 1 & 2 기반) ⭐⭐
// ──────────────────────────────────────────────────────────────────────────────

// ✅ Fruit ID 순서 (쓰기 학습: ST004, ST005, ST006)
// Stage ID를 키로, 해당 Stage에 속한 Fruit ID 리스트를 값으로 가집니다.
const Map<String, List<String>> stageFruitMap = {
  "ST004": ["FR_WR_001", "FR_WR_002", "FR_WR_003", "FR_WR_004"],
  "ST005": ["FR_WR_005", "FR_WR_006", "FR_WR_007", "FR_WR_008"],
  "ST006": ["FR_WR_009", "FR_WR_010", "FR_WR_011", "FR_WR_012"],
};

// ✅ TreeProgress 모델 (unlockedUntilByStage 파싱)
class TreeProgress {
  final Map<String, int> unlockedUntilByStage;

  TreeProgress({required this.unlockedUntilByStage});

  factory TreeProgress.fromJson(Map<String, dynamic> json) {
    return TreeProgress(
      unlockedUntilByStage: Map<String, int>.from(json['unlockedUntilByStage']),
    );
  }

  // 주어진 Stage의 n번째 Fruit이 활성화 상태인지 확인
  bool isActive(String stageId, int sequence) {
    final unlocked = unlockedUntilByStage[stageId] ?? 0;
    return sequence <= unlocked;
  }
}

// ✅ Fruit ID 순서와 Apple UI 순서 매핑
// AppleGarden의 spots 순서(0~11)와 Fruit ID를 매핑합니다.
const List<String> ALL_WRITING_FRUITS_ORDER = [
  // ST004 (Level 1, 3세)
  "FR_WR_001", // index 0
  "FR_WR_002", // index 1
  "FR_WR_003", // index 2
  "FR_WR_004", // index 3 (Gold)
  // ST005 (Level 2, 4세)
  "FR_WR_005", // index 4
  "FR_WR_006", // index 5
  "FR_WR_007", // index 6
  "FR_WR_008", // index 7 (Gold)
  // ST006 (Level 3, 5세)
  "FR_WR_009", // index 8
  "FR_WR_010", // index 9
  "FR_WR_011", // index 10
  "FR_WR_012", // index 11 (Gold)
];

// ✅ Fruit ID -> Stage ID 및 Sequence 헬퍼
(String, int) getStageAndSequence(String fruitId) {
  for (final entry in stageFruitMap.entries) {
    final stageId = entry.key;
    final fruitIds = entry.value;
    final index = fruitIds.indexOf(fruitId);
    if (index != -1) {
      return (stageId, index + 1); // Sequence는 1부터 시작
    }
  }
  return ('unknown', 0);
}

// ✅ Fruit Image Map (요구사항 2)
// 이 예시에서는 임시로 기본 이미지 경로만 사용하며,
// 실제로는 lib/common/constants/fruit_assets.dart에서 import 해야 합니다.
const Map<String, String> fruitImageMap = {
  // Level 1 (ST004)
  "FR_WR_001": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_002": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_003": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_004": "assets/img/contents/studyWrite/gold_apple.png", // Gold

  // Level 2 (ST005)
  "FR_WR_005": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_006": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_007": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_008": "assets/img/contents/studyWrite/gold_apple.png", // Gold

  // Level 3 (ST006)
  "FR_WR_009": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_010": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_011": "assets/img/contents/studyWrite/apple.png",
  "FR_WR_012": "assets/img/contents/studyWrite/gold_apple.png", // Gold
};

// ──────────────────────────────────────────────────────────────────────────────
// AppleGarden State 수정 (API 호출 및 상태 관리)
// ──────────────────────────────────────────────────────────────────────────────
enum ContentStatus { locked, available, done }

class AppleGarden extends StatefulWidget {
  final String childId;
  const AppleGarden({super.key, required this.childId});

  @override
  State<AppleGarden> createState() => _AppleGardenState();
}

class _AppleGardenState extends State<AppleGarden> {
  // ⭐ API로 가져온 진행 상태를 저장할 변수
  TreeProgress? _progress;
  bool _isLoading = true;

  // 배경 기준 비율 좌표
  final List<Offset> spots = const [
    // Tree 1 (ST004)
    Offset(0.13, 0.38), // 0: FR_WR_001
    Offset(0.23, 0.41), // 1: FR_WR_002
    Offset(0.11, 0.52), // 2: FR_WR_003
    Offset(0.21, 0.55), // 3: FR_WR_004 (Gold)
    // Tree 2 (ST005)
    Offset(0.45, 0.38), // 4: FR_WR_005
    Offset(0.55, 0.41), // 5: FR_WR_006
    Offset(0.43, 0.52), // 6: FR_WR_007
    Offset(0.53, 0.55), // 7: FR_WR_008 (Gold)
    // Tree 3 (ST006)
    Offset(0.75, 0.38), // 8: FR_WR_009
    Offset(0.85, 0.41), // 9: FR_WR_010
    Offset(0.73, 0.52), // 10: FR_WR_011
    Offset(0.83, 0.55), // 11: FR_WR_012 (Gold)
  ];

  @override
  void initState() {
    super.initState();
    _loadTreeProgress();
  }

  // ⭐⭐ API 호출 함수 (요구사항 1) ⭐⭐
  Future<void> _loadTreeProgress() async {
    setState(() => _isLoading = true);

    const category = 'writing_study';
    final childId = widget.childId;
    final url = Uri.parse(
        '$baseUrl/api/app/child/$childId/stage/ui/current?category=$category');

    try {
      // NOTE: JWT 인증이 필요하면 헤더에 'Authorization' 추가 필요
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _progress = TreeProgress.fromJson(data);
            _isLoading = false;
          });
        }
      } else {
        debugPrint('API 호출 실패: ${response.statusCode}');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('API 통신 오류: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ⭐ index를 기반으로 현재 상태를 가져오는 헬퍼
  ContentStatus _getAppleStatus(int index) {
    if (_progress == null || index >= ALL_WRITING_FRUITS_ORDER.length) {
      return ContentStatus.locked;
    }

    final fruitId = ALL_WRITING_FRUITS_ORDER[index];
    final (stageId, sequence) = getStageAndSequence(fruitId);

    // ✅ 활성화 로직: unlockedUntilByStage 기반으로 확인
    if (_progress!.isActive(stageId, sequence)) {
      // TODO: 추후 클리어 여부(done)를 별도 API에서 가져와 판단
      return ContentStatus.available;
    }
    return ContentStatus.locked;
  }

  // ⭐ 콘텐츠 라우팅 함수 (Fruit ID 연결)
  Future<void> _tap(int index) async {
    final status = _getAppleStatus(index);
    if (status == ContentStatus.locked) return;

    final fruitId = ALL_WRITING_FRUITS_ORDER[index];
    late final Widget page;

    // 3세 학습 (ST004)
    if (index >= 0 && index <= 3) {
      switch (index) {
        case 0:
          page = ConstellationDrawPage(childId: widget.childId); // FR_WR_001
          break;
        case 1:
          page = jam.JamSpreadFlowPage(childId: widget.childId); // FR_WR_002
          break;
        case 2:
          page = plane.PlaneWritePage(childId: widget.childId); // FR_WR_003
          break;
        case 3:
          page = CandyWritePage(childId: widget.childId); // FR_WR_004 (Gold)
          break;
      }
    }
    // 4세 학습 (ST005)
    else if (index >= 4 && index <= 7) {
      switch (index) {
        case 4:
          // FR_WR_005는 writing_2_1의 첫 레슨인 'giyeok'에 해당
          page = Writing21Page(
              childId: widget.childId, lesson: 'giyeok', fruitId: fruitId);
          break;
        case 5:
          // FR_WR_006은 writing_2_2의 첫 레슨인 'nieun'에 해당
          page = Writing22Page(
              childId: widget.childId, lesson: 'nieun', fruitId: fruitId);
          break;
        case 6:
          // FR_WR_007은 writing_2_3의 첫 레슨인 'a'에 해당
          page = Writing23Page(
              childId: widget.childId, lesson: 'a', fruitId: fruitId);
          break;
        case 7:
          // FR_WR_008은 writing_2_4의 첫 레슨인 'ya'에 해당
          page = Writing24Page(
              childId: widget.childId, lesson: 'ya', fruitId: fruitId);
          break;
      }
    }
    // 5세 학습 (ST006)
    else if (index >= 8 && index <= 11) {
      switch (index) {
        case 8:
          page = Writing3_IntroPage(
              childId: widget.childId, fruitId: fruitId); // FR_WR_009
          break;
        case 9:
          page = Writing3_2_IntroPage(
              childId: widget.childId, fruitId: fruitId); // FR_WR_010
          break;
        case 10:
          page = Writing3_3_IntroPage(
              childId: widget.childId, fruitId: fruitId); // FR_WR_011
          break;
        case 11:
          page = w34.Writing3_4_IntroPage(
              childId: widget.childId, fruitId: fruitId); // FR_WR_012
          break;
        default:
          return;
      }
    } else {
      return;
    }

    // 새 페이지로 이동 후, 복귀 시 UI 갱신
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _loadTreeProgress(); // 복귀 시 상태 갱신
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final appleSize = size.width * 0.065;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 배경
              Positioned.fill(
                child: Image(
                  image: ResizeImage(
                    const AssetImage(
                      'assets/img/contents/studyWrite/apple_tree.png',
                    ),
                    width: (size.width * dpr).clamp(0, 4096).toInt(),
                    height: (size.height * dpr).clamp(0, 4096).toInt(),
                  ),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),

              // 사과들 (총 12개)
              for (int i = 0; i < spots.length; i++)
                Positioned(
                  left: spots[i].dx * size.width - appleSize / 2,
                  top: spots[i].dy * size.height - appleSize / 2,
                  child: _Apple(
                    index: i,
                    size: appleSize,
                    status: _getAppleStatus(i), // ⭐ API 상태 반영
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

// ──────────────────────────────────────────────────────────────────────────────
// _Apple 위젯 수정 (활성화/비활성화 시 숨기기 로직 반영)
// ──────────────────────────────────────────────────────────────────────────────

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
    // ⭐ 학습 모드 (writing_study)는 Locked 시 숨기기 (요구사항 1)
    if (widget.status == ContentStatus.locked) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    // ⭐ Fruit ID로 이미지 경로 가져오기 (요구사항 2)
    final fruitId = ALL_WRITING_FRUITS_ORDER[widget.index];
    final isGold = (widget.index % 4) == 3;

    // ✅ 기본 이미지 경로 (fruitImageMap 사용)
    final baseAsset =
        fruitImageMap[fruitId] ?? 'assets/img/contents/studyWrite/apple.png';

    // TODO: Cleared 상태를 반영하려면 getFruitImage 헬퍼 함수가 필요합니다.
    final asset = baseAsset; // 현재는 normal/cleared 구분 없이 기본 이미지 사용

    // TODO: 추후 `FruitStateType.cleared` 상태를 받아와서 `_cleared.png`를 적용해야 함

    final color =
        widget.status == ContentStatus.done ? Colors.green : Colors.red;

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
              '${(widget.index % 4) + 1}',
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
            if (isGold)
              Positioned(
                right: -widget.size * 0.12,
                bottom: -widget.size * 0.10,
                child: Icon(
                  Icons.auto_awesome,
                  size: widget.size * 0.35,
                  color: Colors.amberAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
