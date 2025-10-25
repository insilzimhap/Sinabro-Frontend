import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ 학습 페이지 import
import 'package:sinabro/main/studyView/writeStudy/page/write_study_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_page.dart';
import 'package:sinabro/main/studyView/writeStudy/page/main_apple_tree.dart';

// ✅ 게임 페이지 import
import 'package:sinabro/main/gameView/writeGame/page/write_game_main.dart';

// ✅ 한 곳에서 서버 주소 관리 (추가)
import 'package:sinabro/config.dart';

class LobbyChildScreen extends StatefulWidget {
  final String childId;
  const LobbyChildScreen({super.key, required this.childId});

  @override
  State<LobbyChildScreen> createState() => _LobbyChildScreenState();
}

class _LobbyChildScreenState extends State<LobbyChildScreen> {
  String characterName = '';
  String nickname = '';
  String level = '';
  bool _isLoading = true;

  final Map<String, String> characterNameMap = {
    'C001': '토끔',
    'C002': '멍지',
    'C003': '곰재',
    'C004': '고냥',
    'C005': '오쟁',
  };

  final List<String> messages = [
    "오늘도 멋진 하루야!",
    "실수해도 괜찮아!",
    "할 수 있어, 넌 최고야!",
    "조금씩 함께 해보자!",
    "너라면 잘할 수 있어!",
  ];

  late String currentMessage;

  // 🎨 팔레트 & 공통 스타일
  static const _bg = Color(0xFFFDF5E6); // 배경
  static const _chip = Color(0xFFFFE38A); // 칩 배경
  static const _accent = Color(0xFFFFD24D); // 포커스/테두리
  static const _panel = Color(0xFFFFF2B3); // 버튼 패널
  static const _charCard = Color(0xFFEDEAE0); // 캐릭터 카드
  static const _textMain = Color(0xFF7B5E4A); // 본문 텍스트(브라운)

  // 🔧 레이아웃 상수
  static const double kLeftCardHeight = 360; // 좌측 캐릭터 카드 높이
  static const double kButtonsRowHeight = 360; // 우측 영역 높이
  static const double kButtonHeight = 170; // 각 버튼 세로 고정
  static const double kRowsGap = 20; // 두 줄 사이 간격
  static const double kColsGap = 24; // 좌/우 버튼 사이 간격

  @override
  void initState() {
    super.initState();
    _fetchChildInfo();
    _setRandomMessage();
  }

  Future<void> _fetchChildInfo() async {
    final url = '$baseUrl/api/child/info?childId=${widget.childId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nickname = data['nickname'] ?? '';
          final characterId = data['characterId'];
          characterName = characterNameMap[characterId] ?? '';
          level = (data['level'] ?? '').toString();
          _isLoading = false;
        });
      } else {
        setState(_resetInfo);
      }
    } catch (_) {
      setState(_resetInfo);
    }
  }

  void _resetInfo() {
    nickname = '';
    characterName = '';
    level = '';
    _isLoading = false;
  }

  void _setRandomMessage() {
    final random = Random();
    setState(() {
      currentMessage = messages[random.nextInt(messages.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // ===== 메인 콘텐츠 =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== 상단: 캐릭터명 칩 + 응원말풍선 + 도감 버튼 =====
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: _setRandomMessage,
                                    child: Container(
                                      height: 64,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          18,
                                        ),
                                        border: Border.all(
                                          color: _accent,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        currentMessage,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: _textMain,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -18,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _chip,
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        characterName.isNotEmpty
                                            ? characterName
                                            : '캐릭터명',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _textMain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            _pillButton(label: '도감', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ===== 본문: 좌(캐릭터) / 우(2x2 버튼) =====
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // -- Left: 캐릭터 카드 + 닉네임
                              SizedBox(
                                width: 260,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: kLeftCardHeight,
                                      decoration: BoxDecoration(
                                        color: _charCard,
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        characterName.isNotEmpty
                                            ? characterName
                                            : '캐릭터',
                                        style: const TextStyle(
                                          color: Color(0xFF7D7D7D),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      nickname.isNotEmpty ? '$nickname님' : '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: _textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'ID: ${widget.childId}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: _textMain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '레벨: ${level.isNotEmpty ? level : "-"}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: _textMain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: kColsGap),

                              // -- Right: 2x2 버튼 그리드
                              Expanded(
                                child: SizedBox(
                                  height: kButtonsRowHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          _bigAction('쓰기 학습', () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => AppleGarden(
                                                  childId: widget.childId,
                                                ),
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: kColsGap),
                                          _bigAction('듣기 학습', () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ListenStudyPage(
                                                  childId: widget.childId,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      const SizedBox(height: kRowsGap),
                                      Row(
                                        children: [
                                          _bigAction('쓰기 게임', () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    WriteGameMainPage(
                                                  childId: widget.childId,
                                                ),
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: kColsGap),
                                          _bigAction('듣기 게임', () {
                                            // TODO
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // ===== 우하단: 로그아웃 버튼 =====
                  Positioned(
                    right: 36,
                    bottom: 28,
                    child: _pillButton(
                      label: '로그아웃',
                      onTap: () {
                        // TODO: 로그아웃 로직
                      },
                      width: 140,
                      height: 56,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // 고정 높이 + 가로는 Expanded로 퍼지는 카드형 버튼
  Widget _bigAction(
    String text,
    VoidCallback onTap, {
    double height = kButtonHeight,
  }) {
    return Expanded(
      child: SizedBox(
        height: height,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textMain,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 우측 상단/하단 캡슐 버튼(도감/로그아웃 공용)
  Widget _pillButton({
    required String label,
    required VoidCallback onTap,
    double width = 180,
    double height = 64,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _textMain,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
