import 'novel_model.dart';

class HomeDataModel {
  final List<NovelModel> newNovels;
  final List<NovelModel> hotNovels;

  const HomeDataModel({required this.newNovels, required this.hotNovels});
}
