import 'package:flutter/material.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main2.dart';
import 'package:sinabro/main/gameView/writeGame/page/write_game_main3.dart';

import 'package:sinabro/main/gameView/tree_progress.dart';
import 'package:sinabro/main/gameView/tree_progress_loader.dart';
import 'package:sinabro/main/gameView/tree_fruit_renderer.dart';

// 자녀별 캐릭터 사진 띄우기
import 'package:sinabro/main/gameView/common/data/character_data.dart';
import 'package:sinabro/main/gameView/common/api/child_game_api.dart';

/// ✏️ 쓰기 게임 챕터 선택 화면
/// - 챕터 1~3 (=나무 1~3) 섬 선택 가능
/// - 각 섬을 누르면 캐릭터가 이동하며 다음 단계로 전환
class GameWriteChapterScreen extends StatefulWidget {
  final String childId; // ✅ 자녀 ID 추가

  const GameWriteChapterScreen({
    super.key,
    required this.childId,
  });

  @override
  State<GameWriteChapterScreen> createState() => _GameWriteChapterScreenState();
}

class _GameWriteChapterScreenState extends State<GameWriteChapterScreen>
    with SingleTickerProviderStateMixin {

  // 💡 캐릭터 폴더명 상태 필드 추가 (기본값 설정)
  String _characterFolderName = defaultCharacter.folderName;

  bool _isVisible = false;
  Offset _charPosition = const Offset(60, 520);
  late AnimationController _controller;

  // ✅ TreeProgress 추가
  late Future<TreeProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();


    // ✅ 쓰기게임 진행도 로드
    _progressFuture = TreeProgressLoader.load('writing_game');

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
          progress.debugPrintStatus(); // ✅ 디버깅용

          return Stack(
            children: [
              // ────────────────────────────────
              // 🏝️ 챕터 섬 1 (나무1=ST010)
              Positioned(
                left: size.width * 0.08,
                top: size.height * 0.18,
                child: GestureDetector(
                  onTap: progress.isStageUnlocked('ST010')
                    ? () => _moveCharacterTo(
                    Offset(size.width * 0.18, size.height * 0.35),
                    WriteGameMainPage(childId: widget.childId),
                    ) 
                    : null, // 🔒 잠긴 상태면 터치 비활성화
                  child: Image.asset(
                    progress.isStageUnlocked('ST010')
                            ? 'assets/img/contents/gameWrite/chapter/level1.png'
                            : 'assets/img/contents/gameWrite/chapter/theme_1_deactivation.png',
                    width: size.width * 0.25,
                  ),
                ),
              ),

              // 🏝️ 챕터 섬 2 (나무2=ST011)
              Positioned(
                left: size.width * 0.38,
                top: size.height * 0.38,
                child: GestureDetector(
                  onTap: progress.isStageUnlocked('ST011')
                    ? () => _moveCharacterTo(
                      Offset(size.width * 0.48, size.height * 0.4),
                      WriteGameMain2Page(childId: widget.childId),
                    )
                    : null,
                  child: Image.asset(
                    progress.isStageUnlocked('ST011')
                            ? 'assets/img/contents/gameWrite/chapter/level2.png'
                            : 'assets/img/contents/gameWrite/chapter/theme_2_deactivation.png',
                    width: size.width * 0.25,
                  ),
                ),
              ),

              // 🏝️ 챕터 섬 3 (나무3=ST012)
              Positioned(
                right: size.width * 0.08,
                top: size.height * 0.28,
                child: GestureDetector(
                  onTap: progress.isStageUnlocked('ST012')
                    ? () => _moveCharacterTo(
                        Offset(size.width * 0.78, size.height * 0.35),
                        WriteGameMain3Page(childId: widget.childId),
                      )
                    : null,
                  child: Image.asset(
                    progress.isStageUnlocked('ST012')
                            ? 'assets/img/contents/gameWrite/chapter/level3.png'
                            : 'assets/img/contents/gameWrite/chapter/theme_3_deactivation.png',
                    width: size.width * 0.25,
                  ),
                ),
              ),

              // 🎈 캐릭터 (토숨)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                left: _charPosition.dx,
                top: _charPosition.dy,
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                    ),
                    child: Image.asset(
                      // 💡 로드된 폴더명을 사용하여 경로 구성. 
                      // 로딩 중에는 기본값(default_char) 사용
                      'assets/img/pageMain/$_characterFolderName.png',
                      width: size.width * 0.13,
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
}
