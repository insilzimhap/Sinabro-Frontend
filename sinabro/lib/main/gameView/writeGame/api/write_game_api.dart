// 백엔드가 실제 구현 채울 예정. 지금은 컴파일용 시그니처만 제공.
class WriteGameApi {
  static Future<String> start({
    required String childId,
    required String stageCode,
  }) => Future.error(UnimplementedError('WriteGameApi.start'));

  static Future<void> sendChoice({
    required String resultId,
    required String questionId,
    required String childWrittenText,
    required bool isCorrect,
  }) => Future.error(UnimplementedError('WriteGameApi.sendChoice'));

  static Future<_CompleteResponse> complete({required String resultId}) =>
      Future.error(UnimplementedError('WriteGameApi.complete'));
}

class _CompleteResponse {
  final bool success;
  _CompleteResponse({required this.success});
}
