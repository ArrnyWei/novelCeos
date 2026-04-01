import 'chapter_model.dart';

class NovelDetailModel {
  final String title;
  final String imageUrl;
  final String state;
  final String author;
  final String desc;
  final List<ChapterModel> chapters;

  const NovelDetailModel({
    required this.title,
    required this.imageUrl,
    required this.state,
    required this.author,
    required this.desc,
    required this.chapters,
  });
}
