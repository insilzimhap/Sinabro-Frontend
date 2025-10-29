// lib/main/parentView/widgets/translated_text.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sinabro/main/parentView/services/translation_service.dart';

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines; // ✨ maxLines 파라미터 추가
  final TextOverflow? overflow; // ✨ overflow 파라미터 추가

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines, // ✨ 생성자에 추가
    this.overflow, // ✨ 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);

    if (translationService.targetLanguage == 'ko') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines, // ✨ Text 위젯에 전달
        overflow: overflow, // ✨ Text 위젯에 전달
      );
    }

    return FutureBuilder<String>(
      future: translationService.translate(text),
      initialData: '...',
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines, // ✨ Text 위젯에 전달
          overflow: overflow, // ✨ Text 위젯에 전달
        );
      },
    );
  }
}