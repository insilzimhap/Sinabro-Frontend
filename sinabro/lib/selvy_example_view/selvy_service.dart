/**
 * @file lib/selvy_example_view/selvy_recognizer.dart
 * @author 문채영
 * 
 * Flutter ↔ Android MethodChannel 통신을 담당하는 클래스.
 * HandwritingScreen 위젯에서 발생한 이벤트들을 네이티브로 전달한다.
 * 
 * 네이티브 채널 이름: com.example.sinabro/selvy
 * - MainActivity.kt에서 해당 채널을 처리함
 */
///

import 'package:flutter/services.dart';

class SelvyRecognizer {
  static const MethodChannel _channel = MethodChannel(
    'com.example.sinabro/selvy',
  );

  /// 좌표 점 추가
  /// 네이티브의 WritingRecognizer.addPoint(x, y) 호출
  static Future<void> addPoint(int x, int y) async {
    await _channel.invokeMethod('addPoint', {'x': x, 'y': y});
  }

  /// (추가) 캔버스 시작 정보 전달
  /// 네이티브의 beginInk(w,h,dpr) 호출
  /// - 화면 크기/해상도 정보를 엔진에 전달하여 스케일 안정화
  static Future<void> beginInk({
    required double width,
    required double height,
    required double devicePixelRatio,
  }) async {
    await _channel.invokeMethod('beginInk', {
      'w': width,
      'h': height,
      'dpr': devicePixelRatio,
    });
  } // changed

  /// (추가) 포인트 배치 전송 (권장)
  /// 여러 좌표를 한 번에 전달하여 성능 향상
  static Future<void> addPoints(List<Map<String, dynamic>> points) async {
    if (points.isEmpty) return;
    await _channel.invokeMethod('addPoints', {'points': points});
  } // changed

  /// (추가) 후보셋 제한
  /// 네이티브의 setCandidateSet(chars) 호출
  static Future<void> setCandidateSet(List<String> chars) async {
    await _channel.invokeMethod('setCandidateSet', {'chars': chars});
  } // changed

  /// 획 종료
  /// 네이티브의 WritingRecognizer.endStroke() 호출
  static Future<void> endStroke() async {
    await _channel.invokeMethod('endStroke');
  }

  /// 잉크 초기화
  /// 네이티브의 WritingRecognizer.clearInk() 호출
  static Future<void> clearInk() async {
    await _channel.invokeMethod('clearInk');
  }

  /// 필기 인식 요청 → 후보 문자열 반환
  /// 네이티브의 WritingRecognizer.recognize() 호출
  /// 결과 문자열을 반환 (후보가 없으면 "No result")
  static Future<String> recognize({String? target}) async {
    print('📡 [Flutter] SelvyRecognizer.recognize() 호출됨'); // ✅ 로그

    final result = await _channel.invokeMethod<String>('recognize', {
      'target': target, // changed
    });

    print('📡 [Flutter] 네이티브에서 받은 인식 결과: $result'); // ✅ 로그

    return result ?? "No result";
  }

  /// 언어 설정
  /// 한국어 + 자모 + 숫자 + 기호 등 다양한 조합 가능
  /// WritingRecognizer.setLanguage(language, type) 호출
  static Future<void> setLanguage(int language, int type) async {
    await _channel.invokeMethod('setLanguage', {
      'language': language,
      'type': type,
    });
  }

  /// 버전 확인
  static Future<String> getVersion() async {
    final version = await _channel.invokeMethod<String>('getVersion');
    return version ?? "";
  }

  /// 만료일 확인 (정수 형태)
  static Future<int> getDueDate() async {
    final due = await _channel.invokeMethod<int>('getDueDate');
    return due ?? -1;
  }
}
