import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinabro/main/childView/page/lobby_child.dart';
import 'package:sinabro/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

// ──────────────────────────────
// 캐릭터 ID/이름 → 폴더 매핑
const _idToFolder = <String, String>{
  'C001': 'tosoon', // 토숨
  'C002': 'meongji', // 멍지
  'C003': 'gomjae', // 곰재
  'C004': 'gonyam', // 고냠
  'C005': 'ojjang', // 오짱
};
const _nameToFolder = <String, String>{
  '토숨': 'tosoon',
  '멍지': 'meongji',
  '곰재': 'gomjae',
  '고냠': 'gonyam',
  '오짱': 'ojjang',
};

// 지원 확장자(대소문자 포함)
const _assetExts = [
  '.png',
  '.PNG',
  '.webp',
  '.WEBP',
  '.jpg',
  '.JPG',
  '.jpeg',
  '.JPEG',
];

/// 번들(AssetManifest)에서 실제 존재하는 clear.* 경로를 찾아 반환
Future<String?> _resolveCharacterAsset(String folder) async {
  if (folder.isEmpty) return null;
  final manifest = await rootBundle.loadString('AssetManifest.json');
  for (final ext in _assetExts) {
    final candidate = 'assets/img/character/$folder/clear$ext';
    if (manifest.contains(candidate)) {
      debugPrint('[CHAR][RESOLVE] $folder -> $candidate');
      return candidate;
    }
  }
  debugPrint('[CHAR][RESOLVE] $folder -> NOT FOUND');
  return null;
}
// ──────────────────────────────

class SelectCharacterPage extends StatefulWidget {
  final String childId;
  const SelectCharacterPage({super.key, required this.childId});

  @override
  State<SelectCharacterPage> createState() => _SelectCharacterPageState();
}

class _SelectCharacterPageState extends State<SelectCharacterPage> {
  late Future<List<_CharacterItem>> _futureCharacters;

  int selectedIndex = 0;
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    debugPrint('[CHAR] init: childId=${widget.childId}, baseUrl=$baseUrl');
    _futureCharacters = _fetchCharacters();
  }

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
      final list = jsonDecode(res.body) as List<dynamic>;
      final parsed = list
          .map((e) => _CharacterItem.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[CHAR] parsed ${parsed.length} items');
      return parsed;
    } catch (e, st) {
      debugPrint('[CHAR][ERR] fetchCharacters: $e\n$st');
      rethrow;
    }
  }

  Future<void> _saveCharacterSelection(_CharacterItem character) async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = '$baseUrl/api/character/selection';
    final payload = {
      'childId': widget.childId,
      'characterId': character.characterId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint(
          '[CHAR] POST /api/character/selection -> ${response.statusCode}');
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LobbyChildScreen(childId: widget.childId)),
        );
      } else if (response.statusCode == 409) {
        setState(() => _message = '이미 캐릭터를 선택하셨습니다!');
      } else {
        String serverMsg = response.body;
        try {
          final json = jsonDecode(response.body);
          if (json is Map && json['message'] != null)
            serverMsg = json['message'].toString();
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
    debugPrint(
        '[CHAR] confirm select ${character.characterId} / ${character.characterName}');
    final folder = _idToFolder[character.characterId] ??
        _nameToFolder[character.characterName] ??
        '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF2B3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFE07A), width: 2),
          ),
          content: FutureBuilder<String?>(
            future: _resolveCharacterAsset(folder),
            builder: (context, snap) {
              final localAsset = snap.data;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (snap.connectionState == ConnectionState.waiting)
                    const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else if (localAsset != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(localAsset,
                          width: 120, height: 120, fit: BoxFit.contain),
                    )
                  else if (character.imageUrl != null &&
                      character.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network('$baseUrl${character.imageUrl!}',
                          width: 120, height: 120, fit: BoxFit.contain),
                    )
                  else
                    const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFE0E0E0),
                        child:
                            Icon(Icons.person, size: 48, color: Colors.white)),
                  const SizedBox(height: 20),
                  const Text('정말 이 친구를 선택할까요?',
                      style: TextStyle(fontSize: 16, color: Colors.brown)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _saveCharacterSelection(character);
                        },
                        child: const Text('예'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[300],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('아니오'),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator()),
                  if (_message.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_message,
                            style: const TextStyle(color: Colors.red))),
                ],
              );
            },
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
            if (items.isEmpty)
              return const Center(child: Text('선택할 캐릭터가 없습니다.'));

            return Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  '함께 여정을 나아갈 친구를 선택해주세요!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: PageView.builder(
                    itemCount: items.length,
                    controller: PageController(viewportFraction: 0.7),
                    onPageChanged: (index) =>
                        setState(() => selectedIndex = index),
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      final character = items[index];
                      final folder = _idToFolder[character.characterId] ??
                          _nameToFolder[character.characterName] ??
                          '';

                      return GestureDetector(
                        onTap: () => _showConfirmDialog(character),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: isSelected ? 16 : 28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8))
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0C9),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color: const Color(0xFFFFE07A),
                                          width: 2),
                                    ),
                                    child: FutureBuilder<String?>(
                                      future: _resolveCharacterAsset(folder),
                                      builder: (context, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2));
                                        }
                                        final localAsset = snap.data;
                                        if (localAsset != null) {
                                          return Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Image.asset(localAsset,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.contain),
                                          );
                                        }
                                        if (character.imageUrl != null &&
                                            character.imageUrl!.isNotEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Image.network(
                                                '$baseUrl${character.imageUrl!}',
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.contain),
                                          );
                                        }
                                        return const Icon(Icons.person,
                                            size: 96, color: Color(0xFFBDBDBD));
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  character.characterName,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isSelected ? Colors.brown : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_message.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_message,
                          style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

// 서버 응답 모델
class _CharacterItem {
  final String characterId;
  final String characterName;
  final String? imageUrl;

  _CharacterItem(
      {required this.characterId, required this.characterName, this.imageUrl});

  factory _CharacterItem.fromJson(Map<String, dynamic> json) {
    return _CharacterItem(
      characterId: json['characterId'] as String,
      characterName: json['characterName'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
