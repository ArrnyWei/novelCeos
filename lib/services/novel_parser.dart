import 'package:html/parser.dart' as html_parser;

import '../models/chapter_model.dart';
import '../models/home_data_model.dart';
import '../models/novel_detail_model.dart';
import '../models/novel_model.dart';

class NovelParser {
  static const _imageHost = 'https://image.uukanshu.cc';

  // ---------------------------------------------------------------------------
  // Home page — translates Swift getHome()
  // ---------------------------------------------------------------------------
  HomeDataModel parseHome(String htmlString) {
    final doc = html_parser.parse(htmlString);

    // New novels — Swift: //div[@id='gengxin']/ul/li
    final newNovels = doc.querySelectorAll('#gengxin ul li').map((li) {
      final titleAnchor = li.querySelector('span.s2 a');
      final latestAnchor = li.querySelector('span.s3 a');
      final title = titleAnchor?.text.trim() ?? '';
      final url = titleAnchor?.attributes['href'] ?? '';
      final author = li.querySelector('span.s4')?.text.trim() ?? '';
      // Derive image from url (no image in list, use cover derivation)
      return NovelModel(
        url: url,
        imageUrl: _imageUrlFromBookUrl(url),
        title: title,
        author: author,
        desc: latestAnchor?.text.trim() ?? '',
      );
    }).toList();

    // Hot novels — Swift: //div[@id='fengtui']/div
    final hotNovels = doc.querySelectorAll('#fengtui > div').map((div) {
      final imgEl = div.querySelector('div.image a img');
      final anchor = div.querySelector('div.image a');
      return NovelModel(
        url: anchor?.attributes['href'] ?? '',
        imageUrl: imgEl?.attributes['src'] ?? '',
        title: imgEl?.attributes['alt'] ?? '',
        author: div.querySelector('dl dt span')?.text.trim() ?? '',
        desc: div.querySelector('dl dd')?.text.trim() ?? '',
      );
    }).toList();

    return HomeDataModel(newNovels: newNovels, hotNovels: hotNovels);
  }

  // ---------------------------------------------------------------------------
  // Category list — translates Swift getList()
  // ---------------------------------------------------------------------------
  List<NovelModel> parseList(String htmlString) {
    final doc = html_parser.parse(htmlString);
    return doc.querySelectorAll('.content.book .bookbox').map((box) {
      final href =
          box.querySelector('.p10 .delbutton a')?.attributes['href'] ?? '';
      final url = href.replaceAll('https://uukanshu.cc', '');
      String author = '';
      for (final el in box.querySelectorAll('.p10 .bookinfo .author')) {
        if (el.text.contains('作者：')) {
          author = el.text.trim();
          break;
        }
      }
      return NovelModel(
        url: url,
        imageUrl: _imageUrlFromBookUrl(url),
        title:
            box
                .querySelector('.p10 .bookinfo h4.bookname a')
                ?.text
                .trim() ??
            '',
        author: author,
        desc:
            (box.querySelector('.p10 .bookinfo .update')?.text ?? '')
                .replaceAll('簡介： ', '')
                .trim(),
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Novel detail — translates Swift getNovel()
  // ---------------------------------------------------------------------------
  NovelDetailModel parseNovel(String htmlString) {
    final doc = html_parser.parse(htmlString);

    final img = doc.querySelector('.book.pt10 .bookcover.hidden-xs img');
    final title = img?.attributes['title'] ?? '';
    final imageUrl = img?.attributes['src'] ?? '';
    final state =
        doc
            .querySelector('.book.pt10 .bookinfo p.booktag span.red')
            ?.text
            .trim() ??
        '';
    final author =
        doc.querySelector('.book.pt10 .bookinfo p.booktag a')?.text.trim() ??
        '';
    final desc =
        doc
            .querySelector('.book.pt10 .bookinfo p.bookintro')
            ?.text
            .trim() ??
        '';

    // Chapter list — Swift inserts at index 0 to reverse order
    final rawChapters =
        doc
            .querySelectorAll(
              'dl.book.chapterlist #list-chapterAll div dd',
            )
            .map((dd) {
              final a = dd.querySelector('a');
              return ChapterModel(
                url: a?.attributes['href'] ?? '',
                title: a?.text.trim() ?? '',
              );
            })
            .toList();

    // Reverse to match Swift behaviour (oldest chapter first)
    final chapters = rawChapters.reversed.toList();

    return NovelDetailModel(
      title: title,
      imageUrl: imageUrl,
      state: state,
      author: author,
      desc: desc,
      chapters: chapters,
    );
  }

  // ---------------------------------------------------------------------------
  // Chapter content — translates Swift getContent()
  // ---------------------------------------------------------------------------
  /// Returns a record with the chapter title and cleaned text content.
  ({String title, String content}) parseContent(String htmlString) {
    final doc = html_parser.parse(htmlString);

    final title =
        doc.querySelector('.book.read h1.pt10')?.text.trim() ?? '';

    // Get raw innerHTML of content element (website changed <p> to <div>)
    var content =
        doc.querySelector('.readcotent.bbb.font-normal')?.innerHtml ?? '';

    // Remove script tags (e.g. <script>loadAdv(5,0);</script>)
    content = content.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');

    // Remove Google ad blocks (repeat until none remain — mirrors Swift loop)
    const adStart = '<div class="google-auto-placed ap_container">';
    const adEnd = '</div>';
    bool hasAd = true;
    while (hasAd) {
      final startIdx = content.indexOf(adStart);
      if (startIdx == -1) {
        hasAd = false;
      } else {
        final endIdx = content.indexOf(adEnd, startIdx);
        if (endIdx == -1) {
          hasAd = false;
        } else {
          content = content.substring(0, startIdx) +
              content.substring(endIdx + adEnd.length);
        }
      }
    }

    // Clean HTML tags
    content = content
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n')
        .replaceAll('&nbsp;', ' ');

    // Normalize newlines: collapse 3+ consecutive \n into \n\n (paragraph spacing)
    content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return (title: title, content: content.trim());
  }

  // ---------------------------------------------------------------------------
  // Search results — translates Swift parseSearchResult()
  // ---------------------------------------------------------------------------
  List<NovelModel> parseSearch(String htmlString) {
    final doc = html_parser.parse(htmlString);
    return doc.querySelectorAll('.keywords .bookbox').map((box) {
      // Title & URL from .bookname a (website uses <div>, not <h4>)
      final titleAnchor = box.querySelector('.p10 .bookinfo .bookname a');
      final href = titleAnchor?.attributes['href'] ?? '';
      final url = href.replaceAll('https://uukanshu.cc', '');
      String author = '';
      for (final el in box.querySelectorAll('.p10 .bookinfo .author')) {
        if (el.text.contains('作者：')) {
          author = el.text.trim();
          break;
        }
      }
      return NovelModel(
        url: url,
        imageUrl: _imageUrlFromBookUrl(url),
        title: titleAnchor?.text.trim() ?? '',
        author: author,
        desc:
            (box.querySelector('.p10 .bookinfo .update')?.text ?? '')
                .replaceAll('簡介：', '')
                .trim(),
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Image URL helper — translates Swift getImageUrlFromBookUrl()
  // Input:  /book/12345/
  // Output: https://image.uukanshu.cc/12/12345/12345s.jpg
  // ---------------------------------------------------------------------------
  String _imageUrlFromBookUrl(String novelUrl) {
    final id = novelUrl.replaceAll('/', '').replaceAll('book', '');
    if (id.length < 3) return '';
    final prefix = id.substring(0, id.length - 3);
    return '$_imageHost/$prefix/$id/${id}s.jpg';
  }
}
