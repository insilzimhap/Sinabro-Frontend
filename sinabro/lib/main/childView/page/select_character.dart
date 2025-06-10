import 'package:flutter/material.dart';
import 'lobby_child.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinabro/main/childView/page/lobby_child.dart'; // lobby_child.dart의 경로에 맞게 수정하세요

class SelectCharacterPage extends StatefulWidget {
  final String childId; // 반드시 로그인 시 받아와서 넘겨줘야 함!
  const SelectCharacterPage({super.key, required this.childId});

  @override
  State<SelectCharacterPage> createState() => _SelectCharacterPageState();
}

class _SelectCharacterPageState extends State<SelectCharacterPage> {
  final List<String> characters = ['토끔', '멍지', '곰재', '고냥', '오쟁'];
  int selectedIndex = 0;
  bool _isLoading = false;
  String _message = '';

  Future<void> _saveCharacterSelection(String characterName) async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    // characterName → characterId로 변환 (예: '토끔' → 'C001')
    final characterIdMap = {
      '토끔': 'C001',
      '멍지': 'C002',
      '곰재': 'C003',
      '고냥': 'C004',
      '오쟁': 'C005',
    };
    final characterId = characterIdMap[characterName];

    final url = 'http://10.0.2.2:8090/api/character/selection';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'childId': widget.childId,
          'characterId': characterId,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LobbyChildScreen()),
        );
      } else if (response.statusCode == 409) {
        setState(() {
          _message = '이미 캐릭터를 선택하셨습니다!';
        });
      } else {
        setState(() {
          _message = '오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '네트워크 오류: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showConfirmDialog(String characterName) {
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
              Container(
                height: 100,
                width: 100,
                color: const Color(0xFFF7F0D3),
                child: Center(
                  child: Text(
                    '$characterName\n이미지',
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
                      _saveCharacterSelection(characterName);
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
              if (_isLoading) const Padding(
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
        child: Column(
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
                itemCount: characters.length,
                controller: PageController(viewportFraction: 0.7),
                onPageChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () => _showConfirmDialog(characters[index]),
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
                      child: Center(
                        child: Text(
                          characters[index],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.brown : Colors.grey,
                          ),
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
                child: Text(_message, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
