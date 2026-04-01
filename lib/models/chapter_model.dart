class ChapterModel {
  final int? id;
  final int? novelId;
  final String url;
  final String title;

  const ChapterModel({
    this.id,
    this.novelId,
    required this.url,
    required this.title,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (novelId != null) 'novelId': novelId,
        'url': url,
        'name': title,
      };

  factory ChapterModel.fromMap(Map<String, dynamic> map) => ChapterModel(
        id: map['id'] as int?,
        novelId: map['novelId'] as int?,
        url: map['url'] as String? ?? '',
        title: (map['name'] ?? map['title']) as String? ?? '',
      );
}
