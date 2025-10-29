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

  Future<void> initialize(String userId) async {
    // ✨ 이미 초기화가 진행 중이거나 완료되었다면 중복 실행 방지
    if (_isInitialized || _isLoading) return;

    if (userId.isEmpty) {
      print('[TranslationService] 초기화 실패: userId가 없습니다.');
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final apiLang = await ParentApi.fetchParentLanguage(userId);
      _targetLanguageCode = _mapApiLangToGoogleCode(apiLang);
      _translationCache.clear();
      print('[TranslationService] 언어 설정 완료: $_targetLanguageCode');
    } catch (e) {
      print('[TranslationService] 언어 설정 로드 실패: $e');
      _targetLanguageCode = 'ko';
    } finally {
      _isLoading = false;
      _isInitialized = true; // ✨ 초기화가 끝났음을 표시
      notifyListeners();
    }
  }

  Future<String> translate(String sourceText) async {
    if (_targetLanguageCode == 'ko' || sourceText.trim().isEmpty) {
      return sourceText;
    }
    if (_translationCache.containsKey(sourceText)) {
      return _translationCache[sourceText]!;
    }

    const apiKey = 'GOOGLE_API_KEY'; //Google API 키 값 넣는 곳

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
