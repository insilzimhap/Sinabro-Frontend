// lib/main/parentView/services/translation_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinabro/main/parentView/api/parent_api.dart';
import 'package:html_unescape/html_unescape.dart';

class TranslationService extends ChangeNotifier {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  String _targetLanguageCode = 'ko';
  bool _isLoading = false;
  bool _isInitialized = false; // ✨ 초기화 여부를 추적하는 플래그
  final Map<String, String> _translationCache = {};

  final htmlUnescape = HtmlUnescape();

  bool get isLoading => _isLoading;
  String get targetLanguage => _targetLanguageCode;
  bool get isInitialized => _isInitialized; // ✨ getter 추가

  Future<void> initialize(String userId, {bool force = false}) async {
    // force가 false이고 이미 초기화되었거나 로딩 중이면 중복 실행 방지
    if (!force && (_isInitialized || _isLoading)) return;


    if (userId.isEmpty) {
      print('[TranslationService] 초기화 실패: userId가 없습니다.');
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final apiLang = await ParentApi.fetchParentLanguage(userId);

      // NOTE: 언어 설정이 변경되었을 경우, 캐시를 지우고 새로운 언어 코드를 설정합니다.
      final newLanguageCode = _mapApiLangToGoogleCode(apiLang);

      // 언어 코드가 변경되었거나 강제 업데이트 시에만 캐시를 초기화합니다.
      if (force || _targetLanguageCode != newLanguageCode) {
        _targetLanguageCode = newLanguageCode;
        _translationCache.clear();
      }

      print(
          '[TranslationService] 언어 설정 완료: $_targetLanguageCode (Force: $force)');

      // NOTE: 설정 페이지에서 언어를 변경했을 때도 캐시가 지워지므로,
      // 메뉴 항목에 대한 초기 번역 요청을 시작하여 UI가 즉시 번역되도록 합니다.
      await _fetchInitialTranslations(
          ['announcement', 'My Page', "Children's Page", 'inquiry', 'setting']);

    } catch (e) {
      print('[TranslationService] 언어 설정 로드 실패: $e');
      _targetLanguageCode = 'ko';
    } finally {
      _isLoading = false;
      _isInitialized = true; // ✨ 초기화가 끝났음을 표시
      notifyListeners();
    }
  }

  // 메뉴 항목 키에 대한 초기 번역을 미리 캐시하는 함수
  Future<void> _fetchInitialTranslations(List<String> keys) async {
    if (_targetLanguageCode == 'ko') return;

    // 비동기적으로 모든 번역을 요청하고 캐시에 저장합니다.
    final textsToTranslate =
        keys.where((key) => !_translationCache.containsKey(key)).toList();

    if (textsToTranslate.isEmpty) return;

    // 개별적으로 translate를 호출하여 캐시에 저장합니다.
    for (var key in textsToTranslate) {
      // NOTE: translate 함수가 내부적으로 캐시에 저장합니다.
      await translate(key);
    }
  }

  Future<String> translate(String sourceText) async {
    if (_targetLanguageCode == 'ko' || sourceText.trim().isEmpty) {
      return sourceText;
    }
    if (_translationCache.containsKey(sourceText)) {
      return _translationCache[sourceText]!;
    }

    const apiKey = 'AIzaSyBRSdDSFargBqKLoxvib54hCi7DhIYvnN0'; //Google API 키 값 넣는 곳

    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'q': sourceText,
          'target': _targetLanguageCode,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        final rawText = body['data']['translations'][0]['translatedText'];
        final translatedText = htmlUnescape.convert(rawText);

        _translationCache[sourceText] = translatedText;
        return translatedText;
      } else {
        print('[TranslationService] 번역 API 오류: ${response.statusCode}');
        return sourceText;
      }
    } catch (e) {
      print('[TranslationService] 번역 요청 중 예외 발생: $e');
      return sourceText;
    }
  }

  String _mapApiLangToGoogleCode(String apiLang) {
    switch (apiLang) {
      case 'Korea':
        return 'ko';
      case 'English':
        return 'en';
      case 'Japanese':
        return 'ja';
      case 'Vietnamese':
        return 'vi';
      case 'Chinese':
        return 'zh-CN';
      case 'Thai':
        return 'th';
      default:
        return 'ko';
    }
  }

  // 동기 조회. 캐시에 없으면 원문 반환.
  String get(String key) {
    if (_targetLanguageCode == 'ko') return key == 'no_record' ? '기록 없음' : key;
    final cached = _translationCache[key];
    return cached ?? key;
  }
}
