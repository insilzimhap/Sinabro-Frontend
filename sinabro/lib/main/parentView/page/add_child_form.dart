import 'package:flutter/material.dart';
import '../layout/parent_layout.dart';

class AddChildFormPage extends StatefulWidget {
  const AddChildFormPage({super.key});

  @override
  State<AddChildFormPage> createState() => _AddChildFormPageState();
}

class _AddChildFormPageState extends State<AddChildFormPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // ✅ 생년월일 Dropdown 값
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;

  // ✅ 제한시간
  String? selectedLimitTime;

  final List<String> yearList = List.generate(
    20,
    (index) => (2010 + index).toString(),
  ); // 2010~2029
  final List<String> monthList = List.generate(
    12,
    (index) => (index + 1).toString().padLeft(2, '0'),
  );
  final List<String> dayList = List.generate(
    31,
    (index) => (index + 1).toString().padLeft(2, '0'),
  );

  final List<String> limitTimes = ['30분', '45분', '1시간', '1시간 30분', '제한없음'];

  @override
  void initState() {
    super.initState();
    selectedYear = yearList.first;
    selectedMonth = monthList.first;
    selectedDay = dayList.first;
    selectedLimitTime = limitTimes.first;
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
                      _buildTextField(
                        '비밀번호',
                        passwordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        '재입력',
                        confirmPasswordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('이름', nameController),
                      const SizedBox(height: 16),
                      _buildBirthSelector(),
                      const SizedBox(height: 16),
                      _buildLimitTimeDropdown(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: 제출 처리
                        },
                        child: const Text('저장하기'),
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
          items:
              yearList
                  .map(
                    (val) => DropdownMenuItem(value: val, child: Text('$val년')),
                  )
                  .toList(),
          onChanged: (val) => setState(() => selectedYear = val),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedMonth,
          items:
              monthList
                  .map(
                    (val) => DropdownMenuItem(value: val, child: Text('$val월')),
                  )
                  .toList(),
          onChanged: (val) => setState(() => selectedMonth = val),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedDay,
          items:
              dayList
                  .map(
                    (val) => DropdownMenuItem(value: val, child: Text('$val일')),
                  )
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
          items:
              limitTimes
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
          onChanged: (val) => setState(() => selectedLimitTime = val),
        ),
      ],
    );
  }
}
