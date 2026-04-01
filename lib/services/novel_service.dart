import '../models/home_data_model.dart';
import '../models/novel_detail_model.dart';
import '../models/novel_model.dart';
import 'novel_http_service.dart';
import 'novel_parser.dart';

class NovelService {
  final _http = NovelHttpService();
  final _parser = NovelParser();

  Future<HomeDataModel> getHome() async {
    final html = await _http.fetchHome();
    return _parser.parseHome(html);
  }

  Future<List<NovelModel>> getList(String listUrl, int pageIndex) async {
    final html = await _http.fetchList(listUrl, pageIndex);
    return _parser.parseList(html);
  }

  Future<NovelDetailModel> getNovel(String novelUrl) async {
    final html = await _http.fetchNovel(novelUrl);
    return _parser.parseNovel(html);
  }

  Future<({String title, String content})> getContent(
    String contentUrl,
  ) async {
    final html = await _http.fetchContent(contentUrl);
    return _parser.parseContent(html);
  }

  Future<List<NovelModel>> search(String keyword) async {
    final html = await _http.search(keyword);
    return _parser.parseSearch(html);
  }
}
