class ListenGameContent {
  final String characterName;       // 캐릭터명 (예: 양지)
  final String dialogueText;        // 캐릭터 대사
  final String characterImagePath;  // 캐릭터 이미지 경로
  final String audioPath;           // 음성 파일 경로
  final List<String> optionImages;  // 보기 1~3 이미지 경로
  final int correctIndex;           // 정답 보기 인덱스 (0, 1, 2)

  ListenGameContent({
    required this.characterName,
    required this.dialogueText,
    required this.characterImagePath,
    required this.audioPath,
    required this.optionImages,
    required this.correctIndex,
  });
}
