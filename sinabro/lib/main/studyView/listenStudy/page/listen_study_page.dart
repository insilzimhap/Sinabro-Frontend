import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sinabro/main/studyView/listenStudy/controller/listen_study_controller.dart';
import 'package:sinabro/main/studyView/listenStudy/widget/sound_button.dart';

import 'package:sinabro/main/childView/page/lobby_child.dart';

class ListenStudyPage extends StatefulWidget {
  final String childId;
  const ListenStudyPage({super.key, required this.childId});

  @override
  State<ListenStudyPage> createState() => _ListenStudyPageState();
}

class _ListenStudyPageState extends State<ListenStudyPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playIntroTTS();
  }

  Future<void> _playIntroTTS() async {
    await _audioPlayer.play(
      AssetSource('audio/tts/studyListen/soundWords/listenStart.mp3'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListenStudyController(),
      child: Consumer<ListenStudyController>(
        builder: (context, controller, child) {
          return Scaffold(
            body: Stack(
              children: [
                // 배경 이미지
                Image.asset(
                  'assets/img/contents/studyListen/testSound01.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),

                // 버튼들 (isPlayed가 false인 경우만 보여줌)
                ...controller.soundItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  if (item.isPlayed) return const SizedBox.shrink();

                  return Positioned(
                    left: item.left,
                    top: item.top,
                    child: SoundButton(
                      onPressed: () async {
                        await controller.playSound(index);

                        // 모든 버튼이 눌렸는지 체크
                        if (controller.isAllPlayed) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('학습 완료 🎉'),
                                    content: const Text('모든 소리를 다 들었어요!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      LobbyChildScreen(childId: widget.childId),
                                            ),
                                          );
                                        },
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  ),
                            );
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
