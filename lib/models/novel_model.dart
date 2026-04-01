class NovelModel {
  final int? id;
  final String url;
  final String imageUrl;
  final String title;
  final String author;
  final String desc;

  const NovelModel({
    this.id,
    required this.url,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.desc,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'url': url,
        'imageUrl': imageUrl,
        'title': title,
        'author': author,
        'desc': desc,
      };

  factory NovelModel.fromMap(Map<String, dynamic> map) => NovelModel(
        id: map['id'] as int?,
        url: map['url'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        title: map['title'] as String? ?? '',
        author: map['author'] as String? ?? '',
        desc: map['desc'] as String? ?? '',
      );
}
