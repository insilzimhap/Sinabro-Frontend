import 'package:flutter/material.dart';
import 'dart:math';

class LobbyChildScreen extends StatefulWidget {
  const LobbyChildScreen({super.key});

  @override
  State<LobbyChildScreen> createState() => _LobbyChildScreenState();
}

class _LobbyChildScreenState extends State<LobbyChildScreen> {
  final String characterName = '토끔'; // DB 연동 예정
  final String nickname = '유저123';

  final List<String> messages = [
    "오늘도 멋진 하루야!",
    "실수해도 괜찮아!",
    "할 수 있어, 넌 최고야!",
    "조금씩 함께 해보자!",
    "너라면 잘할 수 있어!",
  ];

  late String currentMessage;

  @override
  void initState() {
    super.initState();
    _setRandomMessage();
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
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 캐릭터명 탭
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2B3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      characterName,
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 응원 메시지 대화창
                  GestureDetector(
                    onTap: _setRandomMessage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0D9B8)),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        currentMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 캐릭터 이미지 + 버튼들
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 캐릭터 이미지
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E1CD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('캐릭터')),
                      ),

                      // 2x2 버튼
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildActionButton('쓰기 학습'),
                                const SizedBox(width: 10),
                                _buildActionButton('듣기 학습'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildActionButton('쓰기 게임'),
                                const SizedBox(width: 10),
                                _buildActionButton('듣기 게임'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 닉네임
                  Text(
                    '$nickname님',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ),

            // 환경설정 아이콘
            Positioned(
              bottom: 24,
              right: 24,
              child: IconButton(
                icon: const Icon(Icons.settings, size: 32, color: Colors.brown),
                onPressed: () {
                  // 설정 화면 이동 등 추후 구현
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2B3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
