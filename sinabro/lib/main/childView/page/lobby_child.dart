/**
 * @file lib/main/childView/page/lobby_child.dart
 * 역할: 자녀 로비. 자녀 정보 조회는 authenticated → AuthClient 사용.
 */
///

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ 학습 페이지 import
import 'package:sinabro/main/studyView/writeStudy/page/write_study_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_page.dart';
import 'package:sinabro/config.dart';

// 🔐 JWT 자동 부착
import 'package:sinabro/common/auth_client.dart';

class LobbyChildScreen extends StatefulWidget {
  final String childId;
  const LobbyChildScreen({super.key, required this.childId});

  @override
  State<LobbyChildScreen> createState() => _LobbyChildScreenState();
}

class _LobbyChildScreenState extends State<LobbyChildScreen> {
  String characterName = '';
  String nickname = '';
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

  @override
  void initState() {
    super.initState();
    _fetchChildInfo();   // ✅ AuthClient 사용
    _setRandomMessage();
  }

  Future<void> _fetchChildInfo() async {

    final uri = Uri.parse('$baseUrl/api/child/info')
        .replace(queryParameters: {'childId': widget.childId});
    try {
      final response = await AuthClient().get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nickname = data['nickname'] ?? '';
          final characterId = data['characterId'];
          characterName = characterNameMap[characterId] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          nickname = '';
          characterName = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nickname = '';
        characterName = '';
        _isLoading = false;
      });
    }
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
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
                            characterName.isNotEmpty ? characterName : '캐릭터 없음',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              child: Center(child: Text(characterName.isNotEmpty ? characterName : '캐릭터')),
                            ),

                            // 2x2 버튼
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      _buildActionButton('쓰기 학습', () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => WriteStudyPage(childId: widget.childId),
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 10),
                                      _buildActionButton('듣기 학습', () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ListenStudyPage(childId: widget.childId),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _buildActionButton('쓰기 게임', () {
                                        // TODO: 추후 연결
                                      }),
                                      const SizedBox(width: 10),
                                      _buildActionButton('듣기 게임', () {
                                        // TODO: 추후 연결
                                      }),
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
                          nickname.isNotEmpty ? '$nickname님' : '',
                          style: const TextStyle(fontSize: 16, color: Colors.brown),
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

  // ✅ onTap 추가됨
  Widget _buildActionButton(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }
}
