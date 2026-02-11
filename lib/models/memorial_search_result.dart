/// Элемент результата поиска мемориалов (API /api/v1/memorials/search).
class MemorialSearchResult {
  final int memorialId;
  final String fullName;

  const MemorialSearchResult({
    required this.memorialId,
    required this.fullName,
  });

  factory MemorialSearchResult.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['memorial_id'];
    final name = json['full_name'] ?? json['fullName'] ?? '';
    return MemorialSearchResult(
      memorialId: (id as num?)?.toInt() ?? 0,
      fullName: name is String ? name : '',
    );
  }
}
