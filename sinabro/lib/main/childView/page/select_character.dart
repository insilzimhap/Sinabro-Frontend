/**
 * @file lib/main/childView/page/select_character.dart
 * 역할: 캐릭터 선택 화면. 목록 조회는 permitAll(http.get) 유지.
 *      선택 저장은 authenticated → AuthClient.post 사용.
 */
///

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinabro/main/childView/page/lobby_child.dart'; // lobby_child.dart의 경로에 맞게 수정하세요
import 'package:sinabro/config.dart';
import 'package:flutter/foundation.dart'; // debugPrint

// 🔐 JWT 자동 부착
import 'package:sinabro/common/auth_client.dart';

class SelectCharacterPage extends StatefulWidget {
  final String childId; // 반드시 로그인 시 받아와서 넘겨줘야 함!
  const SelectCharacterPage({super.key, required this.childId});

  @override
  State<SelectCharacterPage> createState() => _SelectCharacterPageState();
}

class _SelectCharacterPageState extends State<SelectCharacterPage> {
  // ✅ 서버에서 내려주는 캐릭터 목록
  late Future<List<_CharacterItem>> _futureCharacters;

  int selectedIndex = 0;
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    debugPrint('[CHAR] init: childId=${widget.childId}, baseUrl=$baseUrl');
    _futureCharacters = _fetchCharacters();  //목록은 permitAll
  }

  // 📥 캐릭터 목록 조회 (permitAll)
  Future<List<_CharacterItem>> _fetchCharacters() async {
    final url = '$baseUrl/api/characters';
    debugPrint('[CHAR] GET $url');
    try {
      final res = await http.get(Uri.parse(url));
      debugPrint('[CHAR] GET /api/characters -> ${res.statusCode}');
      if (res.statusCode != 200) {
        debugPrint('[CHAR] body=${res.body}');
        throw Exception('캐릭터 목록 로드 실패: ${res.statusCode}');
      }
      final raw = res.body;
      final list = jsonDecode(raw) as List<dynamic>;
      final parsed = list.map((e) => _CharacterItem.fromJson(e as Map<String, dynamic>)).toList();
      debugPrint('[CHAR] parsed ${parsed.length} items');
      return parsed;
    } catch (e, st) {
      debugPrint('[CHAR][ERR] fetchCharacters: $e\n$st');
      rethrow;
    }
  }

  // 💾 캐릭터 선택 저장 (authenticated)
  Future<void> _saveCharacterSelection(_CharacterItem character) async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final uri = Uri.parse('$baseUrl/api/character/selection'); // ✅ 프론트 경로 유지 -> 수정함
    final payload = {
      'childId': widget.childId,
      'characterId': character.characterId, // ✅ 서버 ID를 그대로 전송
    };

    debugPrint('[CHAR] POST $uri');
    debugPrint('[CHAR] payload=$payload');

    try {
      final response = await AuthClient().post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('[CHAR] POST /api/character/selection -> ${response.statusCode}');
      debugPrint('[CHAR] response body=${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        debugPrint('[CHAR] selection saved. go LobbyChild(childId=${widget.childId})');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyChildScreen(childId: widget.childId),
          ),
        );
      } else if (response.statusCode == 409) {
        setState(() => _message = '이미 캐릭터를 선택하셨습니다!');
      } else {
        String serverMsg = response.body;
        try {
          final json = jsonDecode(response.body);
          if (json is Map && json['message'] != null) {
            serverMsg = json['message'].toString();
          }
        } catch (_) {}
        setState(() => _message = '오류: ${response.statusCode}\n$serverMsg');
      }
    } catch (e, st) {
      debugPrint('[CHAR][ERR] saveSelection: $e\n$st');
      setState(() => _message = '네트워크 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showConfirmDialog(_CharacterItem character) {
    debugPrint('[CHAR] confirm select ${character.characterId} / ${character.characterName}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF2B3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFE07A), width: 2),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ 이미지 표시: $baseUrl + imageUrl
              if (character.imageUrl != null && character.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '$baseUrl${character.imageUrl!}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 100,
                  width: 100,
                  color: const Color(0xFFF7F0D3),
                  child: Center(
                    child: Text(
                      '${character.characterName}\n이미지',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                '정말 이 친구를 선택할까요?',
                style: TextStyle(fontSize: 16, color: Colors.brown),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('예'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 팝업 닫기
                      _saveCharacterSelection(character);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('아니오'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 팝업만 닫기
                    },
                  ),
                ],
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_message, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: FutureBuilder<List<_CharacterItem>>(
          future: _futureCharacters,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              debugPrint('[CHAR][ERR] FutureBuilder: ${snap.error}');
              return Center(child: Text('로드 실패: ${snap.error}'));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              debugPrint('[CHAR] characters empty');
              return const Center(child: Text('선택할 캐릭터가 없습니다.'));
            }

            return Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  '함께 여정을 나아갈 친구를 선택해주세요!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: PageView.builder(
                    itemCount: items.length,
                    controller: PageController(viewportFraction: 0.7),
                    onPageChanged: (index) {
                      debugPrint('[CHAR] page changed: $index');
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      final character = items[index];
                      return GestureDetector(
                        onTap: () => _showConfirmDialog(character),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isSelected ? 20 : 40,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (character.imageUrl != null && character.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    '$baseUrl${character.imageUrl!}',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                const CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Icon(Icons.person, size: 48, color: Colors.white),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                character.characterName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.brown : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_message, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ✅ 서버 응답 모델과 정확히 매칭
class _CharacterItem {
  final String characterId;
  final String characterName;
  final String? imageUrl;

  _CharacterItem({
    required this.characterId,
    required this.characterName,
    this.imageUrl,
  });

  factory _CharacterItem.fromJson(Map<String, dynamic> json) {
    return _CharacterItem(
      characterId: json['characterId'] as String,
      characterName: json['characterName'] as String,
      imageUrl: json['imageUrl'] as String?, // null 허용
    );
  }
}
