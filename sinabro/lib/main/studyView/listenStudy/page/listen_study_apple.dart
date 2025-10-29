/*
 * ----------------------------------------------------------------
 * [듣기 학습 - 사과나무 선택 페이지]
 *
 * 이 페이지는 '듣기 학습' (listening_study) 카테고리의
 * 모든 스테이지(나무)와 열매(사과)를 표시합니다.
 *
 * - 백엔드 API (stage/ui/current)를 호출하여 자녀의 현재 진척도
 * (unlockedUntilByStage)를 받아옵니다.
 * - 'stageFruitMap'을 기준으로 각 나무(Stage)에 정의된 'fruitId' 목록을 가져옵니다.
 * - 진척도와 fruitId를 비교하여 사과의 활성화(available) /
 * 비활성화(locked) 상태를 결정합니다. (학습 모드: 비활성화는 숨김)
 * - 'fruitImageMap'을 사용하여 각 fruitId에 맞는 사과 이미지를 표시합니다.
 * - 사과를 탭하면 'listen_study_router'를 통해 학습 콘텐츠가 실행됩니다.
 * ----------------------------------------------------------------
 */
import 'dart:convert';
import 'package:flutter/material.dart';

// 공통 위젯 및 모델 (절대 경로)
import 'package:sinabro/main/studyView/common/widget/apple_popup.dart';
import 'package:sinabro/main/studyView/common/models/tree_progress.dart';

// API 연동 (절대 경로)
import 'package:sinabro/config.dart'; // baseUrl
import 'package:sinabro/common/auth_client.dart'; // AuthClient

// 데이터 매핑 (절대 경로)
import 'package:sinabro/main/studyView/common/data/study_data_maps.dart'; // stageFruitMap
import 'package:sinabro/main/studyView/common/data/fruit_assets.dart'; // fruitImageMap, defaultAppleAsset

// 네비게이션 라우터 (절대 경로)
import 'package:sinabro/main/studyView/listenStudy/navigation/listen_study_router.dart'; // navigateToListenStudy

// 라우트 이름 상수 (임시 정의, AppConstants로 옮기는 것 권장)
const routeNameListenAppleSelect = '/listen-apple-select';

/// 사과 상태 (학습 모드에서는 locked는 숨겨짐)
enum ContentStatus { locked, available }

/// UI 좌표와 백엔드 데이터를 연결하는 내부 헬퍼 클래스
class _ListenStageUIData {
  final String stageId;
  final List<String> fruitIds;
  final List<Offset> spots; // UI 좌표 목록

  _ListenStageUIData({
    required this.stageId,
    required this.fruitIds,
    required this.spots,
  });
}

class ListenAppleSelect extends StatefulWidget {
  // 페이지 라우트 이름 정의 (Navigator.popUntil 등에서 사용)
  static const routeName = routeNameListenAppleSelect;
  final String childId; // 이 페이지를 호출하는 곳에서 전달받는 자녀 ID
  const ListenAppleSelect({super.key, required this.childId});

  @override
  State<ListenAppleSelect> createState() => _ListenAppleSelectState();
}

class _ListenAppleSelectState extends State<ListenAppleSelect> {
  // --- 상태 변수 ---
  final AuthClient _authClient = AuthClient(); // API 호출용 클라이언트
  TreeProgress? _progressData; // API 응답 데이터 (자녀 학습 진척도)
  bool _isLoading = true; // 데이터 로딩 중 상태 플래그
  String _errorMsg = ''; // 오류 메시지 저장용

  // --- UI 구성 데이터 ---
  // 이 화면에 표시할 나무(Stage) ID 목록
  final List<String> _stageIds = const ['ST001', 'ST002', 'ST003'];
  // 각 나무별 UI 데이터 (좌표, Fruit ID 목록) - initState에서 채워짐
  final List<_ListenStageUIData> _stageUIData = [];

  // ----------------------------------------------------------------
  // 초기화 (initState)
  // ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    debugPrint(
        '[ListenAppleSelect] initState called for child: ${widget.childId}');
    // 1. UI 데이터 구성: 각 나무(Stage)의 좌표와 Fruit ID 목록 매핑
    _setupUIData();
    // 2. API 호출: 백엔드에서 자녀의 학습 진척도 불러오기
    _loadProgress();
  }

  /// 백엔드 API를 호출하여 자녀의 듣기 학습 진척도를 불러옵니다.
  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final uri = Uri.parse(
          '$baseUrl/api/app/child/${widget.childId}/stage/ui/current?category=listening_study');
      debugPrint('[ListenAppleSelect] Loading progress from: $uri');
      final response = await _authClient.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[ListenAppleSelect] Progress loaded successfully: $data');
        setState(() {
          _progressData = TreeProgress.fromJson(data);
          _isLoading = false;
        });
      } else {
        _errorMsg = '진행도 로딩 실패: (${response.statusCode})';
        debugPrint(
            '[ListenAppleSelect] Failed to load progress (${response.statusCode}): ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _errorMsg = '데이터 로딩 중 오류 발생: $e';
      debugPrint('[ListenAppleSelect] Error loading progress: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// UI 좌표와 Stage/Fruit ID 데이터를 결합하여 `_stageUIData` 리스트를 구성합니다.
  void _setupUIData() {
    // 화면 디자인에 따른 각 사과의 고정 위치 (비율 기준 0.0 ~ 1.0)
    const List<Offset> allSpots = [
      // 나무 1 (ST001) - 5개
      Offset(0.12, 0.35), Offset(0.21, 0.38), Offset(0.07, 0.48),
      Offset(0.16, 0.53), Offset(0.25, 0.50),
      // 나무 2 (ST002) - 5개
      Offset(0.46, 0.35), Offset(0.55, 0.38), Offset(0.41, 0.48),
      Offset(0.50, 0.53), Offset(0.59, 0.50),
      // 나무 3 (ST003) - 4개
      Offset(0.82, 0.35), Offset(0.91, 0.41), Offset(0.79, 0.50),
      Offset(0.89, 0.56),
    ];

    // 각 나무(Stage)별로 데이터(_ListenStageUIData 객체) 생성하여 리스트에 추가
    // 'stageFruitMap' 변수는 study_data_maps.dart 파일에 정의되어 있음
    _stageUIData.add(_ListenStageUIData(
      stageId: 'ST001',
      fruitIds: stageFruitMap['ST001']!, // study_data_maps.dart 참조
      spots: allSpots.sublist(0, 5), // 좌표 목록에서 해당 범위 추출
    ));
    _stageUIData.add(_ListenStageUIData(
      stageId: 'ST002',
      fruitIds: stageFruitMap['ST002']!,
      spots: allSpots.sublist(5, 10),
    ));
    _stageUIData.add(_ListenStageUIData(
      stageId: 'ST003',
      fruitIds: stageFruitMap['ST003']!,
      spots: allSpots.sublist(10, 14),
    ));
    debugPrint(
        '[ListenAppleSelect] UI Data setup complete for ${_stageUIData.length} stages.');
  }

  // ----------------------------------------------------------------
  // 사용자 액션 (탭)
  // ----------------------------------------------------------------

  /// 사과를 탭했을 때 호출되는 공통 핸들러
  /// - `MapsToListenStudy` 라우터 함수를 호출하여 실제 학습 콘텐츠 실행
  ///
  /// @param fruitId 탭한 사과의 ID.
  /// @param stageId 탭한 사과가 속한 나무(Stage)의 ID.
  /// @param sequenceInStage 탭한 사과의 나무 내 순번 (1부터 시작).
  /// @param isGold 탭한 사과가 황금 사과인지 여부 (라우터 전달용).
  Future<void> _tap(
      String fruitId, String stageId, int sequenceInStage, bool isGold) async {
    // API 데이터 기준 활성화 여부 재확인 (필수!)
    final bool isActive =
        _progressData?.isActive(stageId, sequenceInStage) ?? false;
    // 비활성화(잠긴) 사과는 아무 동작 안 함
    if (!isActive) {
      debugPrint(
          '[ListenAppleSelect] Tap ignored: Fruit $fruitId ($stageId-$sequenceInStage) is locked.');
      return;
    }

    // 활성화된 사과 -> 라우터 함수 호출하여 학습 시작
    debugPrint(
        '[ListenAppleSelect] Tapped active fruit: $fruitId ($stageId-$sequenceInStage)');
    // isGold 값은 라우터 내부에서 학습 완료 시 팝업 종류를 결정하는 데 사용될 수 있음
    navigateToListenStudy(context, fruitId, isGold, widget.childId);
  }

  // ----------------------------------------------------------------
  // 빌드 (UI 렌더링)
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 기본 배경색
      body: LayoutBuilder(
        // 화면 크기 변경 감지 및 대응
        builder: (context, constraints) {
          // --- 로딩 상태 표시 ---
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('학습 정보를 불러오는 중...'),
                ],
              ),
            );
          }

          // --- 오류 상태 표시 ---
          if (_errorMsg.isNotEmpty) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('오류: $_errorMsg',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('앱을 재시작하거나 네트워크 연결을 확인해주세요.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                    onPressed: _loadProgress, // 재시도 버튼
                  )
                ],
              ),
            ));
          }

          // --- 데이터 로드 실패 (API 응답은 정상이나 데이터가 null인 경우) ---
          if (_progressData == null) {
            return const Center(
                child: Text('학습 정보를 표시할 수 없습니다.\n관리자에게 문의하세요.'));
          }

          // --- 정상 상태: UI 렌더링 ---
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          final appleWidgetSize = screenSize.width * 0.06; // 사과 위젯 크기 계산

          // Stack을 사용하여 배경 위에 사과들을 겹쳐서 표시
          return Stack(
            fit: StackFit.expand, // 자식 위젯들이 Stack 전체 크기를 채우도록 함
            children: [
              // 1. 배경 이미지
              Positioned.fill(
                // 전체 화면 채우기
                child: Image.asset(
                  'assets/img/contents/studyListen/apple_tree.jpg', // TODO: AppConstants 사용 권장
                  fit: BoxFit.cover, // 화면 비율에 맞게 이미지 채우기
                ),
              ),

              // 2. 사과 동적 생성
              // `_stageUIData` (나무 목록)를 순회하며 각 나무의 사과들을 배치
              ..._stageUIData.expand((stageData) {
                // `expand`로 모든 사과 위젯을 하나의 리스트로 통합
                final fruitIds = stageData.fruitIds; // 현재 나무의 Fruit ID 목록
                final stageSpots = stageData.spots; // 현재 나무의 사과 좌표(비율) 목록

                // 현재 나무의 사과 개수만큼 반복하여 _Apple 위젯 생성
                return List.generate(fruitIds.length, (i) {
                  final fruitId = fruitIds[i]; // 현재 사과의 Fruit ID
                  final spot = stageSpots[i]; // 현재 사과의 좌표 (비율)
                  final sequenceInStage = i + 1; // 현재 사과의 순번 (1부터 시작)

                  // API 데이터(_progressData)를 기반으로 사과 상태(활성/비활성) 계산
                  final bool isActive = _progressData!
                      .isActive(stageData.stageId, sequenceInStage);
                  final status =
                      isActive ? ContentStatus.available : ContentStatus.locked;
                  // isGold 계산 (라우터 전달용)
                  final bool isGold = (sequenceInStage == fruitIds.length);

                  // Positioned 위젯으로 사과 위치 지정
                  return Positioned(
                    // 비율 좌표(spot)를 실제 화면 좌표(px)로 변환
                    left: spot.dx * screenSize.width -
                        appleWidgetSize / 2, // 중앙 정렬
                    top: spot.dy * screenSize.height - appleWidgetSize / 2,
                    // _Apple 위젯 생성 및 필요한 데이터 전달
                    child: _Apple(
                      sequenceInStage: sequenceInStage, // 사과 위 숫자
                      size: appleWidgetSize, // 사과 크기
                      status: status, // 활성/잠금 상태
                      fruitId: fruitId, // ✅ fruitId 전달 (이미지 결정용)
                      onTap: () => _tap(
                          // 탭 시 실행될 함수 연결
                          fruitId,
                          stageData.stageId,
                          sequenceInStage,
                          isGold), // isGold 계산 결과 전달
                    ),
                  );
                });
              }), // `expand` 끝

              // 3. (선택 사항) 뒤로가기 버튼 등 추가 UI 요소
              Positioned(
                top: MediaQuery.of(context).padding.top + 10, // 상태 표시줄 아래 여백
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20), // 아이콘 크기 조절
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      padding: const EdgeInsets.all(8)), // 패딩 조절
                  onPressed: () {
                    // TODO: 뒤로가기 동작 정의 (예: 홈 화면으로 이동)
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // 홈 화면 경로로 이동하는 로직 (예시)
                      debugPrint(
                          "[ListenAppleSelect] Cannot pop, maybe go to home?");
                      // Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  tooltip: '뒤로가기',
                ),
              ),
            ], // Stack children 끝
          );
        }, // LayoutBuilder builder 끝
      ), // LayoutBuilder 끝
    ); // Scaffold 끝
  } // build 끝
} // _ListenAppleSelectState 끝

// ----------------------------------------------------------------
// [_Apple 위젯] - 사과 하나를 표시하는 위젯
// ----------------------------------------------------------------
class _Apple extends StatefulWidget {
  final int sequenceInStage; // 스테이지 내 순번 (1부터 시작), 숫자로 표시됨
  final double size; // 위젯의 크기 (가로/세로 동일)
  final ContentStatus status; // 상태 (available / locked)
  final String fruitId; // ✅ fruitId 추가됨 (이미지 결정용)
  final VoidCallback onTap; // 탭했을 때 실행될 함수

  const _Apple({
    required this.sequenceInStage,
    required this.size,
    required this.status,
    required this.fruitId, // ✅ 추가
    required this.onTap,
    super.key,
  });

  @override
  State<_Apple> createState() => _AppleState();
}

class _AppleState extends State<_Apple> {
  bool _pressed = false; // 탭 시각적 피드백(크기 축소)을 위한 상태

  @override
  Widget build(BuildContext context) {
    // 학습 모드: 비활성(locked) 상태의 사과는 화면에 렌더링하지 않음
    if (widget.status == ContentStatus.locked) {
      // 빈 SizedBox를 반환하여 공간만 차지하도록 함
      return SizedBox(width: widget.size, height: widget.size);
    }

    // fruitId를 사용하여 fruitImageMap에서 이미지 경로 조회
    // map에 해당 fruitId가 없거나 값이 null이면 defaultAppleAsset 사용
    final asset = fruitImageMap[widget.fruitId] ?? defaultAppleAsset;

    // 사과 위에 표시될 숫자 (스테이지 내 순번)
    final int number = widget.sequenceInStage;

    // GestureDetector: 탭 관련 이벤트 감지
    return GestureDetector(
      // 탭 시작 시 _pressed = true (애니메이션 시작)
      onTapDown: (_) => setState(() => _pressed = true),
      // 탭 취소 시 _pressed = false (애니메이션 원복)
      onTapCancel: () => setState(() => _pressed = false),
      // 탭 종료 시 _pressed = false (애니메이션 원복)
      onTapUp: (_) => setState(() => _pressed = false),
      // 실제 탭 액션 실행 (상위 위젯에서 전달받은 onTap 함수 호출)
      onTap: widget.onTap,
      // AnimatedScale: _pressed 상태 변화에 따라 부드러운 크기 변화 효과
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120), // 애니메이션 지속 시간
        scale: _pressed ? 0.95 : 1.0, // 눌렸을 때 95% 크기로 작아짐
        // Stack: 이미지 위에 숫자를 겹쳐서 표시
        child: Stack(
          alignment: Alignment.center, // 자식(이미지, 텍스트)을 중앙에 정렬
          clipBehavior: Clip.none, // 자식(그림자 등)이 경계를 벗어나도 보이도록 함
          children: [
            // 1. 사과 이미지
            Image.asset(
              asset, // fruitImageMap에서 가져온 경로 사용
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain, // 위젯 크기에 맞춰 이미지 비율 유지
              // 이미지 로딩 오류 시 대체 위젯 (선택 사항)
              errorBuilder: (context, error, stackTrace) {
                debugPrint("Error loading apple image: $asset, error: $error");
                // 기본 이미지 또는 아이콘 표시
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle, // 원형 배경
                  ),
                  child: Icon(Icons.apple,
                      size: widget.size * 0.6,
                      color: Colors.grey.shade600), // 사과 아이콘
                );
              },
            ),
            // 2. 숫자 텍스트
            Text(
              '$number', // 순번 표시
              style: TextStyle(
                color: Colors.white, // 텍스트 색상: 흰색
                fontWeight: FontWeight.w900, // 폰트 두께: 가장 두껍게
                fontSize: widget.size * 0.45, // 사과 크기에 비례하여 폰트 크기 조절
                // 텍스트 그림자 효과
                shadows: const [
                  Shadow(
                    blurRadius: 4, // 그림자 번짐 정도
                    color: Colors.black45, // 그림자 색상 (더 명확하게 수정)
                    offset: Offset(0, 1.5), // 그림자 위치 (약간 아래로)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} // _AppleState 끝
