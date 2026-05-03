import 'reading_status.dart';

class FavoriteModel {
  final int? id;
  final int novelId;
  final int? listId;
  final double frame;
  final String date;
  final ReadingStatus status;

  // Joined fields (from novel table)
  final String? title;
  final String? author;
  final String? imageUrl;
  final String? url;
  final String? lastChapterName;

  const FavoriteModel({
    this.id,
    required this.novelId,
    this.listId,
    this.frame = 0.0,
    required this.date,
    this.status = ReadingStatus.reading,
    this.title,
    this.author,
    this.imageUrl,
    this.url,
    this.lastChapterName,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'novelId': novelId,
        'listId': listId,
        'frame': frame,
        'date': date,
        'status': status.dbValue,
      };

  factory FavoriteModel.fromMap(Map<String, dynamic> map) => FavoriteModel(
        id: map['id'] as int?,
        novelId: map['novelId'] as int,
        listId: map['listId'] as int?,
        frame: (map['frame'] as num?)?.toDouble() ?? 0.0,
        date: map['date'] as String? ?? '',
        status: ReadingStatus.fromDb(map['status'] as int?),
        title: map['title'] as String?,
        author: map['author'] as String?,
        imageUrl: map['imageUrl'] as String?,
        url: map['url'] as String?,
        lastChapterName: map['lastChapterName'] as String?,
      );
}
