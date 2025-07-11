class FilterWords {
  /// 한글 욕설 필터링용 리스트
  static const List<String> blockedKorean = [
    '시발',
    '씨발',
    '병신',
    'ㅄ',
    '개새끼',
    '좆',
    '쌍놈',
    '꺼져',
    '죽어',
    '멍청이',
    'fuck',
    'fuxx',
    'ㅅㅂ',
    'ㅂㅅ',
    'ㅄ',
    'ㄲㅈ',
    'ㅈㄹ',
  ];

  /// 영어 욕설 필터링용 리스트
  static const List<String> blockedEnglish = [
    'fuck',
    'shit',
    'bitch',
    'asshole',
    'bastard',
    'damn',
    'dick',
    'pussy',
    'nigger',
    'faggot',
    'retard',
  ];

  /// 전체 통합 리스트
  static const List<String> all = [...blockedKorean, ...blockedEnglish];

  /// 특정 단어가 금칙어에 포함되는지 검사
  static bool containsBlockedWord(String text) {
    final lower = text.toLowerCase();
    return all.any((word) => lower.contains(word));
  }
}
