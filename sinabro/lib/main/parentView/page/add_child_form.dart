import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/config.dart';

class AddChildFormPage extends StatefulWidget {
  final String parentUserId;
  const AddChildFormPage({super.key, required this.parentUserId});

  @override
  State<AddChildFormPage> createState() => _AddChildFormPageState();
}

class _AddChildFormPageState extends State<AddChildFormPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  // 생년월일 Dropdown 값
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;

  // 제한시간
  String? selectedLimitTime;

  final List<String> yearList = List.generate(20, (index) => (2010 + index).toString());
  final List<String> monthList = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> dayList = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> limitTimes = ['30분', '45분', '1시간', '1시간 30분', '제한없음'];

  @override
  void initState() {
    super.initState();
    selectedYear = yearList.first;
    selectedMonth = monthList.first;
    selectedDay = dayList.first;
    selectedLimitTime = limitTimes.first;
  }

  Future<void> _registerChild() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = 'g/api/child/register'; // ✅ const → final

    // 생년월일 조합
    final childBirth = '${selectedYear!}-${selectedMonth!}-${selectedDay!}';

    // 제한시간 숫자 변환
    int? timeLimitMinutes;
    if (selectedLimitTime == '30분') timeLimitMinutes = 30;
    else if (selectedLimitTime == '45분') timeLimitMinutes = 45;
    else if (selectedLimitTime == '1시간') timeLimitMinutes = 60;
    else if (selectedLimitTime == '1시간 30분') timeLimitMinutes = 90;
    else timeLimitMinutes = null; // 제한없음 → null (서버에서 0으로 기본값 처리)

    try {
      // ✅ 서버 DTO 필드명/타입과 정확히 맞춤
      final payload = {
        'childId': idController.text.trim(),
        'childPw': passwordController.text.trim(),
        'childName': nameController.text.trim(),
        'childNickname': nicknameController.text.trim(), // ✅ 키 수정 (NickName → Nickname)
        'childBirth': childBirth,
        'childAge': _calcAge(selectedYear!, selectedMonth!, selectedDay!),
        // 'childLevel':  null,  // ✅ 초기 레벨 없으면 아예 보내지 말기 (주석)
        'role': 'child',
        'userId': widget.parentUserId,
        'timeLimitMinutes': timeLimitMinutes, // null이면 서버에서 0으로 처리
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('등록 성공'),
            content: const Text('자녀 계정이 성공적으로 추가되었습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 폼 페이지 닫기
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 409) {
        setState(() => _message = '이미 존재하는 아이디입니다.');
      } else {
        setState(() => _message = '등록 실패: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => _message = '에러 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  int _calcAge(String year, String month, String day) {
    final now = DateTime.now();
    final birth = DateTime(int.parse(year), int.parse(month), int.parse(day));
    int age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자녀 정보 입력'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: Row(
        children: [
          const ParentSidebar(activeMenu: '마이페이지'),
          Expanded(
            child: Container(
              color: const Color(0xFFE4F1FA),
              child: Center(
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 246, 225),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '추가할 자녀의 정보를 입력해주세요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('아이디', idController),
                      const SizedBox(height: 16),
                      _buildTextField('비밀번호', passwordController, isObscure: true),
                      const SizedBox(height: 16),
                      _buildTextField('이름', nameController),
                      const SizedBox(height: 16),
                      _buildTextField('닉네임', nicknameController),
                      const SizedBox(height: 16),
                      _buildBirthSelector(),
                      const SizedBox(height: 16),
                      _buildLimitTimeDropdown(),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _registerChild,
                              child: const Text('저장하기'),
                            ),
                      if (_message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(_message, style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthSelector() {
    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Text('생년월일', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedYear,
          items: yearList
              .map((val) => DropdownMenuItem(value: val, child: Text('$val년')))
              .toList(),
          onChanged: (val) => setState(() => selectedYear = val),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedMonth,
          items: monthList
              .map((val) => DropdownMenuItem(value: val, child: Text('$val월')))
              .toList(),
          onChanged: (val) => setState(() => selectedMonth = val),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedDay,
          items: dayList
              .map((val) => DropdownMenuItem(value: val, child: Text('$val일')))
              .toList(),
          onChanged: (val) => setState(() => selectedDay = val),
        ),
      ],
    );
  }

  Widget _buildLimitTimeDropdown() {
    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Text('제한시간', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedLimitTime,
          items: limitTimes
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (val) => setState(() => selectedLimitTime = val),
        ),
      ],
    );
  }
}
