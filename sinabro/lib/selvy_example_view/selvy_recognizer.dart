/**
 * WritingView에서 발생한 좌표/획 종료 이벤트들을
 * WritingRecognizer.java에 전달할 수 있도록 중간에서 MethodChannel 통신을 담당하는 역할
 * 다시 말해, WritingView는 필기 화면이고,
    selvy_recognizer.dart는 그 화면에서 네이티브로 요청을 전달하는 브리지임
 */

import 'package:flutter/services.dart';

class SelvyRecognizer {
    static const MethodChannel _channel =
    MethodChannel('com.example.please2_selvy/selvy');

    /// 좌표 점 추가
    static Future<void> addPoint(int x, int y) async {
      await _channel.invokeMethod('addPoint', {
        'x': x,
        'y': y,
      });
    }

    /// 획 종료
    static Future<void> endStroke() async {
      await _channel.invokeMethod('endStroke');
    }

    /// 잉크 초기화
    static Future<void> clearInk() async {
      await _channel.invokeMethod('clearInk');
    }

    /// 필기 인식 요청 → 후보 문자열 반환
    static Future<String> recognize() async {
      final result = await _channel.invokeMethod<String>('recognize');
      return result ?? "No result";
    }

    /// 언어 설정
    /// [language]: Selvy SDK 언어 코드 (ex. DLANG_KOREAN = 101)
    /// [type]: 언어 타입 비트마스크 (ex. DTYPE_KOREAN | DTYPE_NUMERIC 등)
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
