import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentLayout(
      activeMenu: '설정',
      content: SettingsContent(),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool isMusicOn = true;
  String limitType = '시간 설정';
  int? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시나브로 설정을 변경할 수 있어요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle('로그인 정보'),
          const Text('seongminkong'),
          const SizedBox(height: 24),
          _buildSectionTitle('배경음악'),
          SwitchListTile(
            value: isMusicOn,
            onChanged: (value) {
              setState(() {
                isMusicOn = value;
              });
            },
            title: Text(isMusicOn ? 'ON' : 'OFF'),
            activeColor: Colors.green,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('콘텐츠 제한 설정'),
          const Text('아이와 학습한 시간을 설정해 주세요. 시간이 지나면 더이상 플레이할 수 없어요'),
          const SizedBox(height: 16),
          Row(
            children: [
              ChoiceChip(
                label: const Text('횟수 설정'),
                selected: limitType == '횟수 설정',
                onSelected: (_) => setState(() => limitType = '횟수 설정'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('시간 설정'),
                selected: limitType == '시간 설정',
                onSelected: (_) => setState(() => limitType = '시간 설정'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [10, 15, 20, 30, 60].map((minute) {
              return ChoiceChip(
                label: Text('$minute분'),
                selected: selectedTime == minute,
                onSelected: (_) => setState(() => selectedTime = minute),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() => selectedTime = null);
                },
                child: const Text('설정해제'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: selectedTime != null ? () {} : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('확인'),
              ),
            ],
          ),
          const Divider(height: 40),
          _buildSimpleItem('개인정보처리방침'),
          _buildSimpleItem('오픈소스 라이선스'),
          _buildSimpleItem('버전 정보', trailing: '1.15.3.5'),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('로그아웃'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('시나브로 회원탈퇴'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildSimpleItem(String title, {String? trailing}) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        trailing:
            trailing != null ? Text(trailing) : const Icon(Icons.chevron_right),
        onTap: () {},
      );
}
