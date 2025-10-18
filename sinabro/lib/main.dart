import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';
import 'package:sinabro/config.dart'; //추가
import 'package:sinabro/login/social_info_page.dart'; // 네 SocialExtraInfoPage 파일 경로 맞게 수정! 테스트용
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

// ✨ Provider와 TranslationService import 추가
import 'package:provider/provider.dart';
import 'package:sinabro/main/parentView/services/translation_service.dart';

//듣기학습
//import 'package:sinabro/main/studyView/listenStudy/page/listen_study_page.dart';
//import 'package:sinabro/main/studyView/writeStudy/page/write_study_page.dart';
//import 'package:sinabro/selvy_example_view/handwriting_screen.dart';

//재미나이가 준 코드
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_entry_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animals_intro_page1.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/dog_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/dog_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/dog_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/cat_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/cat_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/cat_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/duck_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/duck_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/duck_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/bird_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/bird_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/bird_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/flog_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/flog_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/flog_outro_page.dart';

import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animals_intro_page2.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/sheep_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/sheep_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/sheep_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/tiger_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/tiger_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/tiger_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/monkey_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/monkey_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/monkey_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/rabbit_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/rabbit_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/rabbit_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/elephant_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/elephant_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/elephant_outro_page.dart';

import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animals_intro_page3.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/chicken_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/chicken_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/chicken_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/penguin_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/penguin_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/penguin_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/turtle_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/turtle_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/turtle_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/mouse_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/mouse_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/mouse_outro_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/pig_reveal_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/pig_story_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/pig_outro_page.dart';

// ✅ JWT 자동부착 클라이언트 (부팅 시 토큰 복구용)
import 'package:sinabro/common/auth_client.dart';

/// 앱 시작점
Future<void> main() async {
  // ✅ 네이티브 앱 키로 초기화 (Kakao Developers 콘솔의 "네이티브 앱 키")
  KakaoSdk.init(
    nativeAppKey: 'ca5d66d22c4255e3dced6bc1a2d4fdcd',
  );

  // 1) 플러터 엔진-플랫폼 채널 준비
  WidgetsFlutterBinding.ensureInitialized();

  // 2) ⬇️ 부팅 시 저장돼 있던 JWT를 메모리로 복구 (AuthClient가 이후 모든 요청에 자동 부착)
  try {
    await AuthClient.hydrateFromPrefs();
    print('[main] 부팅 토큰 복구 완료');
  } catch (e) {
    print('[main][경고] 토큰 복구 중 오류: $e');
  }

  // 3) 앱 실행
  // ✨ runApp 부분을 ChangeNotifierProvider로 감싸줍니다.
  runApp(
    ChangeNotifierProvider(
      create: (context) => TranslationService.instance,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시나브로',
      debugShowCheckedModeBanner: false, // 앱 화면 오른쪽 위 debug 배너 제거!
      home: CloudAnimationScreen(),
      //home: const HandwritingScreen(),
      //home: ListenStudyPage(),
      //home: WriteStudyPage(),

      routes: {
        AnimalsIntroPage1.routeName: (context) => const AnimalsIntroPage1(),
        DogRevealPage.routeName: (context) => const DogRevealPage(),
        DogStoryPage.routeName: (context) => const DogStoryPage(),
        DogOutroPage.routeName: (context) => const DogOutroPage(),
        CatRevealPage.routeName: (context) => const CatRevealPage(),
        CatStoryPage.routeName: (context) => const CatStoryPage(),
        CatOutroPage.routeName: (context) => const CatOutroPage(),
        DuckRevealPage.routeName: (context) => const DuckRevealPage(),
        DuckStoryPage.routeName: (context) => const DuckStoryPage(),
        DuckOutroPage.routeName: (context) => const DuckOutroPage(),
        BirdRevealPage.routeName: (context) => const BirdRevealPage(),
        BirdStoryPage.routeName: (context) => const BirdStoryPage(),
        BirdOutroPage.routeName: (context) => const BirdOutroPage(),
        FlogRevealPage.routeName: (context) => const FlogRevealPage(),
        FlogStoryPage.routeName: (context) => const FlogStoryPage(),
        FlogOutroPage.routeName: (context) => const FlogOutroPage(),

        AnimalsIntroPage2.routeName: (context) => const AnimalsIntroPage2(),
        SheepRevealPage.routeName: (context) => const SheepRevealPage(),
        SheepStoryPage.routeName: (context) => const SheepStoryPage(),
        SheepOutroPage.routeName: (context) => const SheepOutroPage(),
        TigerRevealPage.routeName: (context) => const TigerRevealPage(),
        TigerStoryPage.routeName: (context) => const TigerStoryPage(),
        TigerOutroPage.routeName: (context) => const TigerOutroPage(),
        MonkeyRevealPage.routeName: (context) => const MonkeyRevealPage(),
        MonkeyStoryPage.routeName: (context) => const MonkeyStoryPage(),
        MonkeyOutroPage.routeName: (context) => const MonkeyOutroPage(),
        RabbitRevealPage.routeName: (context) => const RabbitRevealPage(),
        RabbitStoryPage.routeName: (context) => const RabbitStoryPage(),
        RabbitOutroPage.routeName: (context) => const RabbitOutroPage(),
        ElephantRevealPage.routeName: (context) => const ElephantRevealPage(),
        ElephantStoryPage.routeName: (context) => const ElephantStoryPage(),
        ElephantOutroPage.routeName: (context) => const ElephantOutroPage(),
        AnimalsIntroPage3.routeName: (context) => const AnimalsIntroPage3(),
        ChickenRevealPage.routeName: (context) => const ChickenRevealPage(),
        ChickenStoryPage.routeName: (context) => const ChickenStoryPage(),
        ChickenOutroPage.routeName: (context) => const ChickenOutroPage(),
        PenguinRevealPage.routeName: (context) => const PenguinRevealPage(),
        PenguinStoryPage.routeName: (context) => const PenguinStoryPage(),
        PenguinOutroPage.routeName: (context) => const PenguinOutroPage(),
        TurtleRevealPage.routeName: (context) => const TurtleRevealPage(),
        TurtleStoryPage.routeName: (context) => const TurtleStoryPage(),
        TurtleOutroPage.routeName: (context) => const TurtleOutroPage(),
        MouseRevealPage.routeName: (context) => const MouseRevealPage(),
        MouseStoryPage.routeName: (context) => const MouseStoryPage(),
        MouseOutroPage.routeName: (context) => const MouseOutroPage(),
        PigRevealPage.routeName: (context) => const PigRevealPage(),
        PigStoryPage.routeName: (context) => const PigStoryPage(),
        PigOutroPage.routeName: (context) => const PigOutroPage(),

        //.routeName: (context) => const
      },

      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        MaterialPageRoute error(String msg) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('라우팅 오류: $msg')),
              ),
              settings: settings,
            );

        switch (settings.name) {
          case ColorEntryPage.routeName:
            {
              final list = args?['lessonsToShow'];
              if (list is List<ColorLessonData>) {
                return MaterialPageRoute(
                  builder: (_) => ColorEntryPage(lessonsToShow: list),
                  settings: settings,
                );
              }
              return error('lessonsToShow 누락/타입 오류');
            }
          default:
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다.'))),
              settings: settings,
            );
        }
      },
    );
  }
}
