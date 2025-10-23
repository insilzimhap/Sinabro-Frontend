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

// 듣기 학습 라우터 임포트
import 'package:sinabro/main/studyView/listenStudy/navigation/listen_study_router.dart';

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
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김

      // 앱 시작 화면 설정
      home: CloudAnimationScreen(),
      /* 듣기 학습 테스트용
      home: const ListenAppleSelect(
          childId: 'test-child'), // TODO: 실제 로그인/자녀 선택 로직 연결
      */

      // Named Route 생성 로직 정의
      onGenerateRoute: (settings) {
        // arguments를 Map<String, dynamic> 타입으로 안전하게 캐스팅
        final args = settings.arguments as Map<String, dynamic>? ??
            {}; // null일 경우 빈 맵 사용

        // 오류 발생 시 표시할 기본 에러 페이지 생성 함수
        MaterialPageRoute error(String msg) => MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('오류')),
                body: Center(
                    child: Text('라우팅 오류: $msg\nRoute: ${settings.name}')),
              ),
              settings: settings, // 디버깅 위해 settings 전달
            );

        // 요청된 route 이름(settings.name)에 따라 분기
        switch (settings.name) {
          // --- ListenAppleSelect ---
          // listen_study_apple.dart 에 정의된 routeName 사용
          case ListenAppleSelect.routeName:
            {
              // popUntil 등에서 이름으로 참조하기 위한 케이스.
              // home에서 이미 생성되므로, 여기서 직접 생성할 일은 거의 없음.
              // 만약 arguments로 childId를 받아야 한다면 아래 주석 해제 및 수정.
              final childId =
                  args['childId'] as String? ?? 'default-pop-child'; // 기본값 설정
              return MaterialPageRoute(
                builder: (_) => ListenAppleSelect(childId: childId),
                settings: settings,
              );
            }

          // --- ColorEntryPage ---
          // listen_study_router.dart 에 정의된 routeName 상수 사용 (또는 ColorEntryPage.routeName)
          case routeNameColorEntry: // ColorEntryPage.routeName
            {
              // arguments에서 필요한 데이터 추출 및 타입 확인
              final list = args['lessonsToShow'];
              final isGold = args['isGold'];
              final childId = args['childId']; // ✅ childId 추출

              // 데이터 타입이 모두 맞는지 확인
              if (list is List<ColorLessonData> &&
                  isGold is bool &&
                  childId is String) {
                // ColorEntryPage 생성 및 반환
                return MaterialPageRoute(
                  builder: (_) => ColorEntryPage(
                    lessonsToShow: list,
                    isGold: isGold,
                    childId: childId, // ✅ 생성자에 childId 전달
                  ),
                  settings: settings,
                );
              }
              // 데이터가 없거나 타입이 틀리면 에러 페이지 반환
              return error(
                  'ColorEntryPage: arguments (lessonsToShow, isGold, childId) 누락 또는 타입 오류');
            }

          // --- AnimalStudyEntry ---
          // listen_study_router.dart 에 정의된 routeName 상수 사용 (또는 AnimalStudyEntry.routeName)
          case routeNameAnimalEntry: // AnimalStudyEntry.routeName
            {
              // arguments에서 필요한 데이터 추출 및 타입 확인
              final fruitId = args['fruitId'];
              final isGold = args['isGold'];
              final childId = args['childId']; // ✅ childId 추출

              // 데이터 타입이 모두 맞는지 확인
              if (fruitId is String && isGold is bool && childId is String) {
                // AnimalStudyEntry 생성 및 반환
                return MaterialPageRoute(
                  builder: (_) => AnimalStudyEntry(
                    fruitId: fruitId,
                    isGold: isGold,
                    childId: childId, // ✅ 생성자에 childId 전달
                  ),
                  settings: settings,
                );
              }
              // 데이터가 없거나 타입이 틀리면 에러 페이지 반환
              return error(
                  'AnimalStudyEntry: arguments (fruitId, isGold, childId) 누락 또는 타입 오류');
            }

          // --- 기타 정의되지 않은 Route 처리 ---
          default:
            // 일치하는 routeName이 없으면 '페이지 없음' 화면 표시
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body:
                      Center(child: Text('페이지를 찾을 수 없습니다: ${settings.name}'))),
              settings: settings,
            );
        }
      }, // onGenerateRoute 끝
    ); // MaterialApp 끝
  } // build 끝
} // MyApp 끝
