// lib/main/gameView/common/data/character_data.dart

class CharacterFolderEntry {
  final String name;      // 한글 캐릭터 이름 (예: '토끔')
  final String folderName; // 이미지 폴더명 (예: 'tosoom')

  const CharacterFolderEntry({ 
    required this.name,
    required this.folderName,
  });
}

// ℹ️ 서버에서 오는 ID (C001, C002 등)를 키로 사용
final Map<String, CharacterFolderEntry> characterMap = {
  'C001': const CharacterFolderEntry(
    name: '토숨',
    folderName: 'tosoom',
  ),
  'C002': const CharacterFolderEntry(
    name: '멍지',
    folderName: 'meongji',
  ),
  'C003': const CharacterFolderEntry(
    name: '곰재',
    folderName: 'gomjae',
  ),
  'C004': const CharacterFolderEntry(
    name: '고냠',
    folderName: 'gonyam',
  ),
  'C005': const CharacterFolderEntry(
    name: '오짱', 
    folderName: 'ojjang',
  ),
};

// 기본값
final CharacterFolderEntry defaultCharacter = const CharacterFolderEntry(
  name: '캐릭터',
  folderName: 'tosoom', // 'assets/img/character/default_char/' 폴더에 기본 이미지가 있다고 가정
);