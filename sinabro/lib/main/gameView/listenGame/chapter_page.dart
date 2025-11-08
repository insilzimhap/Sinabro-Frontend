/*
 * ------------------------------------------------------------------------------
 * [듣기 게임 - 챕터 선택 페이지]
 * ------------------------------------------------------------------------------
 */
import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/tree_fruit_renderer.dart';

// 각 레벨의 Flow
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_flow.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_flow.dart';

// 각 레벨 인트로
import 'package:sinabro/main/gameView/listenGame/page/level1/level1_intro_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level2/level2_intro_page.dart';
import 'package:sinabro/main/gameView/listenGame/page/level3/level3_intro_page.dart';

// 자녀별 캐릭터 사진 띄우기
import 'package:sinabro/main/gameView/common/data/character_data.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';


class GameListenChapterScreen extends StatefulWidget {
  final String childId; // ✅ childId 필드 추가

  const GameListenChapterScreen({
    super.key,
    required this.childId, // ✅ 생성자에 required 추가
  });

  @override
  State<GameListenChapterScreen> createState() =>
      _GameListenChapterScreenState();
}

class _GameListenChapterScreenState extends State<GameListenChapterScreen>
    with SingleTickerProviderStateMixin {


    // 💡 캐릭터 폴더명 상태 필드 추가 (기본값 설정)
  String _characterFolderName = defaultCharacter.folderName;

  bool _isVisible = false;
  Offset _charPosition = const Offset(60, 520);
  late AnimationController _controller;

  late Future<TreeProgress> _progressFuture; // ✅ 진행도 Future 추가

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    // ✅ 듣기게임 진행도 로드
    _progressFuture = TreeProgressLoader.load('listening_game');

    // 💡 캐릭터 정보 로드 시작 (진행도 Future와 별개로 처리)
    _fetchChildCharacter();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 💡 [새 함수] 자녀 캐릭터 정보 로드 (폴더명 가져오기)
  Future<void> _fetchChildCharacter() async {
    final info = await ChildGameApi.fetchChildCharacterInfo();

    if (info != null) {
      final characterId = info['characterId'] as String?;
      
      // characterId를 폴더명으로 매핑
      final characterEntry = characterMap[characterId] ?? defaultCharacter;
      
      if (mounted) {
        setState(() {
          _characterFolderName = characterEntry.folderName;
        });
      }
    } else {
      // API 호출 실패 시 기본 캐릭터 폴더명 유지
      if (mounted) {
        setState(() {
          // 상태를 업데이트하여 로딩 완료 처리 (기본값 사용)
        });
      }
    }
  }

  Future<void> _moveCharacterTo(Offset target, Widget nextPage) async {
    // 이동 시작 전에 캐릭터를 보이도록
    if (!_isVisible) {
      setState(() => _isVisible = true);
      await Future.delayed(const Duration(milliseconds: 50)); 

      await _controller.reverse(from: 1);

      setState(() => _charPosition = target);

      await _controller.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _isVisible = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      body: FutureBuilder<TreeProgress>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snapshot.data!;
          progress.debugPrintStatus(); // 필요 시 디버깅용
          return Stack(
            children: [
              // ────────────────────────────────
              // 🏝️ 챕터 1 (나무1=ST007)
              _buildChapterIcon(
                context,
                size,
                stageId: 'ST007', // ✅ 추가

                left: size.width * 0.08,
                top: size.height * 0.18,
                activeImage: 'assets/img/contents/gameListen/chapter/level1.png',
                lockedImage:
                    'assets/img/contents/gameListen/chapter/level1_deactivation.png',
                targetOffset: Offset(size.width * 0.21, size.height * 0.33),
                nextPage: Level1IntroPage(
                  onNext: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Level1Flow(childId: widget.childId,),
                    ),
                  ),
                ),
                progress: progress,
              ),

              // 🏝️ 챕터 2 (나무2=ST008)
              _buildChapterIcon(
                context,
                size,
                stageId: 'ST008', // ✅ 추가
                left: size.width * 0.38,
                top: size.height * 0.18,

                activeImage: 'assets/img/contents/gameListen/chapter/level2.png',
                lockedImage:
                    'assets/img/contents/gameListen/chapter/level2_deactivation.png',

                targetOffset: Offset(size.width * 0.41, size.height * 0.36),
                nextPage: Level2IntroPage(
                  onNext: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Level2Flow(childId: widget.childId,),
                      ), 
                  ),
                ),
                progress: progress,
              ),

              // 🏝️ 챕터 3 (나무3=ST009)
              _buildChapterIcon(
                context,
                size,
                stageId: 'ST009', // ✅ 추가

                right: size.width * 0.08,
                top: size.height * 0.28,
                activeImage: 'assets/img/contents/gameListen/chapter/level3.png',
                lockedImage:
                    'assets/img/contents/gameListen/chapter/level3_deactivation.png',
                targetOffset: Offset(size.width * 0.78, size.height * 0.38),
                nextPage: Level3IntroPage(
                  onNext: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Level3Flow(childId: widget.childId,),
                      ),
                  ),
                ),
                progress: progress,
              ),

              // 🐣 캐릭터
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                left: _charPosition.dx,
                top: _charPosition.dy,
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: Image.asset(
                      // 💡 로드된 폴더명을 사용하여 경로 구성. 
                      // 로딩 중에는 기본값(default_char) 사용
                      'assets/img/pageMain/$_characterFolderName.png',
                      width: size.width * 0.12,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapterIcon(
    BuildContext context,
    Size size, {
    double? left,
    double? right,
    required double top,
    required String activeImage,
    required String lockedImage, // ✅  추가
    required Offset targetOffset,
    required Widget nextPage,
    required TreeProgress progress, // ✅ 진행도 추가
    required String stageId, // ✅ stageId 추가
  }) {
      return Positioned(
      left: left,
      right: right,
      top: top,
      child: SizedBox(
        width: size.width * 0.23, // ← 아이콘 크기 조절 (기존보다 큼)
        child: buildStageTree(
          stageId: stageId,
          progress: progress,
          activeImage: activeImage,
          lockedImage: lockedImage,
          onTap: (_) => _moveCharacterTo(targetOffset, nextPage),
        ),
      ),
    );
  }
}
