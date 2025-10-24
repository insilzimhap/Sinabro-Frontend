// lib/main/studyView/listenStudy/level2/story3/data/routine_data_2.dart
import 'package:sinabro/main/studyView/listenStudy/page/level2/story3/model/number_story_item.dart';

/// 인트로
final NumberStoryItem introData = const NumberStoryItem(
  text: "숫자 친구들이 찾아왔어요!",
  imagePath: "assets/img/contents/studyListen/level2/num_hi_2.png",
  audioPath: "audio/tts/studyListen/level2/numbers/num_intro2.mp3",
);

/// 숫자 루틴 (6~10)
final List<Map<String, dynamic>> numberRoutine = [
  {
    "keyword": const NumberStoryItem(
      text: "이건 숫자 6이에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-1-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_06_title.mp3",
    ),
    "stories": const [
      NumberStoryItem(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-1-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      NumberStoryItem(
        text: "쭈욱쭈욱~ 오징어가 6마리!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-1-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_06_example.mp3",
      ),
    ]
  },
  {
    "keyword": const NumberStoryItem(
      text: "이건 숫자 7!",
      imagePath: "assets/img/contents/studyListen/level2/story/5-2-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_07_title.mp3",
    ),
    "stories": const [
      NumberStoryItem(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-2-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      NumberStoryItem(
        text: "팔딱!팔딱! 물고기 7마리!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-2-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_07_example.mp3",
      ),
    ]
  },
  {
    "keyword": const NumberStoryItem(
      text: "이건 숫자 8이네요?",
      imagePath: "assets/img/contents/studyListen/level2/story/5-3-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_08_title.mp3",
    ),
    "stories": const [
      NumberStoryItem(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-3-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      NumberStoryItem(
        text: "따닥따닥! 꽃게가 8마리!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-3-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_08_example.mp3",
      ),
    ]
  },
  {
    "keyword": const NumberStoryItem(
      text: "이건 숫자 9에요",
      imagePath: "assets/img/contents/studyListen/level2/story/5-4-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_09_title.mp3",
    ),
    "stories": const [
      NumberStoryItem(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-4-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      NumberStoryItem(
        text: "통통~! 새우가 9마리!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-4-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_09_example.mp3",
      ),
    ]
  },
  {
    "keyword": const NumberStoryItem(
      text: "숫자 10까지 전부 찾아냈어요!",
      imagePath: "assets/img/contents/studyListen/level2/story/5-5-1.png",
      audioPath: "audio/tts/studyListen/level2/numbers/num_10_title.mp3",
    ),
    "stories": const [
      NumberStoryItem(
        text: "이렇게도 보여요!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-5-2.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_alt.mp3",
      ),
      NumberStoryItem(
        text: "똑똑 또독~ 조개가 10마리!",
        imagePath: "assets/img/contents/studyListen/level2/story/5-5-3.png",
        audioPath: "audio/tts/studyListen/level2/numbers/num_10_example.mp3",
      ),
    ]
  },
];
