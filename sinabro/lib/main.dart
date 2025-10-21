import 'package:flutter/material.dart';
import 'package:sinabro/main/mainView/page/home_screen.dart';
import 'package:sinabro/config.dart'; //추가
import 'package:sinabro/login/social_info_page.dart'; // 네 SocialExtraInfoPage 파일 경로 맞게 수정! 테스트용
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

// Provider와 TranslationService import 추가
import 'package:provider/provider.dart';
import 'package:sinabro/main/parentView/services/translation_service.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/animal_study_entry.dart';

// 색상 임포트
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/color_entry_page.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/colors/models/color_lesson_model.dart';

//  ListenAppleSelect 페이지를 import 합니다.
import 'package:sinabro/main/studyView/listenStudy/page/listen_study_apple.dart';

void main() {
  // ✅ 네이티브 앱 키로 초기화 (Kakao Developers 콘솔의 "네이티브 앱 키")
  KakaoSdk.init(
    nativeAppKey: 'ca5d66d22c4255e3dced6bc1a2d4fdcd',
  );

  // runApp(MyApp()); // 기존 코드
  // Provider를 유지하여 앱 전체에서 상태 관리가 가능하도록 합니다.
  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslationService.instance,
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

      // 앱의 첫 화면을 ListenAppleSelect로 변경합니다.
      // 테스트를 위해 임시 childId를 전달합니다.
      home: const ListenAppleSelect(childId: 'test-child'),

      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        MaterialPageRoute error(String msg) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('라우팅 오류: $msg')),
              ),
              settings: settings,
            );

        switch (settings.name) {
          // ✨ [추가] ListenAppleSelect 페이지의 routeName을 등록합니다.
          case ListenAppleSelect.routeName:
            {
              // ListenAppleSelect는 home에서 직접 호출되거나
              // 다른 페이지에서 arguments 없이 이름으로만 호출될 수 있습니다.
              // 만약 childId를 arguments로 받아야 한다면 로직 추가가 필요합니다.
              // 지금은 ListenAppleSelect.routeName을 인식하는 것이 주목적이므로,
              // home에서 설정된 childId를 사용하도록 기본 빌더만 반환합니다.
              // (실제로는 popUntil을 위한 '이름표' 역할이 더 큽니다.)

              // 만약 arguments로 childId를 받아야 한다면:
              // final childId = args?['childId'];
              // if (childId is String) {
              //   return MaterialPageRoute(
              //     builder: (_) => ListenAppleSelect(childId: childId),
              //     settings: settings,
              //   );
              // }
              // return error('ListenAppleSelect: childId가 전달되지 않았습니다.');

              // 지금 당장 popUntil을 위해 필요한 최소한의 코드:
              // (home에서 이미 ListenAppleSelect를 로드했으므로,
              // popUntil은 이 이름표(settings)를 보고 멈출 수 있습니다.)
              // 이 케이스가 직접 호출될 일은 거의 없지만, 완전성을 위해 추가합니다.
              return MaterialPageRoute(
                builder: (_) =>
                    const ListenAppleSelect(childId: 'default-test-child'),
                settings: settings,
              );
            }
          case ColorEntryPage.routeName:
            {
              final list = args?['lessonsToShow'];
              final isGold = args?['isGold'];

              if (list is List<ColorLessonData> && isGold is bool) {
                return MaterialPageRoute(
                  builder: (_) => ColorEntryPage(
                    lessonsToShow: list,
                    isGold: isGold,
                  ),
                  settings: settings,
                );
              }
              return error('lessonsToShow 누락/타입 오류');
            }
          case AnimalStudyEntry.routeName:
            {
              final fruitId = args?['fruitId'];
              final isGold = args?['isGold'];

              if (fruitId is String && isGold is bool) {
                return MaterialPageRoute(
                  builder: (_) => AnimalStudyEntry(
                    fruitId: fruitId,
                    isGold: isGold,
                  ),
                  settings: settings,
                );
              }
              return error('AnimalStudyEntry: 데이터 전달 오류');
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
