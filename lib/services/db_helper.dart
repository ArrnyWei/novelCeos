import 'package:sqflite/sqflite.dart';

import '../models/chapter_model.dart';
import '../models/continue_reading_info.dart';
import '../models/favorite_model.dart';
import '../models/novel_model.dart';

/// SQLite database helper — translates Swift's DBHelper.h/.m.
///
/// Tables mirror the Swift schema:
///   novel, list, content, favNovel
class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      '$dbPath/ceos.db',
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS novel (
            id INTEGER PRIMARY KEY,
            title TEXT,
            author TEXT,
            desc TEXT,
            url TEXT,
            imageUrl TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            novelId INTEGER,
            name TEXT,
            url TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS content (
            listId INTEGER PRIMARY KEY,
            content TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS favNovel (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            novelId INTEGER,
            listId INTEGER,
            frame REAL DEFAULT 0,
            date TEXT,
            status INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v1 → v2：favNovel 加上閱讀狀態
          await db.execute(
            'ALTER TABLE favNovel ADD COLUMN status INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> initDB() async {
    await db;
  }

  // ---------------------------------------------------------------------------
  // Novel
  // ---------------------------------------------------------------------------

  /// Inserts or replaces a novel. Returns the novel's id.
  Future<int> insertNovel(NovelModel novel) async {
    final d = await db;
    // Check if already exists by url
    final existing =
        await d.query('novel', where: 'url = ?', whereArgs: [novel.url]);
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return d.insert('novel', novel.toMap());
  }

  Future<NovelModel?> getNovelByUrl(String url) async {
    final d = await db;
    final rows = await d.query('novel', where: 'url = ?', whereArgs: [url]);
    if (rows.isEmpty) return null;
    return NovelModel.fromMap(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Chapters (list table)
  // ---------------------------------------------------------------------------

  Future<void> insertChapters(int novelId, List<ChapterModel> chapters) async {
    final d = await db;
    final batch = d.batch();
    for (final ch in chapters) {
      batch.insert('list', {
        'novelId': novelId,
        'name': ch.title,
        'url': ch.url,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<ChapterModel>> getChapters(int novelId) async {
    final d = await db;
    final rows = await d.query('list',
        where: 'novelId = ?', whereArgs: [novelId], orderBy: 'id ASC');
    return rows.map((r) => ChapterModel.fromMap(r)).toList();
  }

  // ---------------------------------------------------------------------------
  // Content (offline chapter text)
  // ---------------------------------------------------------------------------

  Future<void> insertContent(int listId, String content) async {
    final d = await db;
    await d.insert(
      'content',
      {'listId': listId, 'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete all cached chapter content. Used by the settings "clear cache" action.
  Future<int> clearAllContent() async {
    final d = await db;
    return d.delete('content');
  }

  Future<String?> getOfflineContent(int listId) async {
    final d = await db;
    final rows =
        await d.query('content', where: 'listId = ?', whereArgs: [listId]);
    if (rows.isEmpty) return null;
    return rows.first['content'] as String?;
  }

  /// Returns all list IDs that have offline content for a given novel.
  Future<Set<int>> getDownloadedListIds(int novelId) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT content.listId FROM content
      INNER JOIN list ON list.id = content.listId
      WHERE list.novelId = ?
    ''', [novelId]);
    return rows.map((r) => r['listId'] as int).toSet();
  }

  // ---------------------------------------------------------------------------
  // Favorites (favNovel table)
  // ---------------------------------------------------------------------------

  Future<bool> isNovelFavorited(String novelUrl) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT favNovel.id FROM favNovel
      INNER JOIN novel ON novel.id = favNovel.novelId
      WHERE novel.url = ?
    ''', [novelUrl]);
    return rows.isNotEmpty;
  }

  Future<void> addFavorite(int novelId) async {
    final d = await db;
    final existing = await d.query('favNovel',
        where: 'novelId = ?', whereArgs: [novelId]);
    if (existing.isNotEmpty) return;
    await d.insert('favNovel', {
      'novelId': novelId,
      'listId': 0,
      'frame': 0.0,
      'date': DateTime.now().toIso8601String(),
      'status': 0,
    });
  }

  /// 更新某本收藏小說的閱讀狀態（B1）。不動 date / progress。
  Future<void> updateFavoriteStatus(int novelId, int statusValue) async {
    final d = await db;
    await d.update(
      'favNovel',
      {'status': statusValue},
      where: 'novelId = ?',
      whereArgs: [novelId],
    );
  }

  Future<void> removeFavorite(int novelId) async {
    final d = await db;
    await d.delete('favNovel', where: 'novelId = ?', whereArgs: [novelId]);
  }

  Future<List<FavoriteModel>> getFavorites() async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT favNovel.*, novel.title, novel.author, novel.imageUrl, novel.url,
             list.name as lastChapterName
      FROM favNovel
      INNER JOIN novel ON novel.id = favNovel.novelId
      LEFT JOIN list ON list.id = favNovel.listId
      ORDER BY favNovel.date DESC
    ''');
    return rows.map((r) => FavoriteModel.fromMap(r)).toList();
  }

  Future<void> updateReadingProgress({
    required int novelId,
    required int listId,
    required double frame,
  }) async {
    final d = await db;
    await d.update(
      'favNovel',
      {
        'listId': listId,
        'frame': frame,
        'date': DateTime.now().toIso8601String(),
      },
      where: 'novelId = ?',
      whereArgs: [novelId],
    );
  }

  Future<FavoriteModel?> getReadingProgress(int novelId) async {
    final d = await db;
    final rows = await d.query('favNovel',
        where: 'novelId = ?', whereArgs: [novelId]);
    if (rows.isEmpty) return null;
    return FavoriteModel.fromMap(rows.first);
  }

  /// 取出「最近一次更新（加入書架或閱讀進度寫入）」的收藏小說摘要。
  /// 章節序號透過 list 表中該 novelId 的 id 排序計算（1-based），
  /// 用 (id <= savedListId) 的 count 推得。
  Future<ContinueReadingInfo?> getContinueReading() async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT
        favNovel.listId AS savedListId,
        novel.title AS title,
        novel.imageUrl AS imageUrl,
        novel.url AS url,
        list.name AS lastChapterName,
        (SELECT COUNT(*) FROM list l2
           WHERE l2.novelId = favNovel.novelId
             AND l2.id <= favNovel.listId) AS chapterPos,
        (SELECT COUNT(*) FROM list l3
           WHERE l3.novelId = favNovel.novelId) AS totalChapters
      FROM favNovel
      INNER JOIN novel ON novel.id = favNovel.novelId
      LEFT JOIN list ON list.id = favNovel.listId
      ORDER BY favNovel.date DESC
      LIMIT 1
    ''');
    if (rows.isEmpty) return null;
    final r = rows.first;
    final url = r['url'] as String?;
    final title = r['title'] as String?;
    if (url == null || title == null) return null;
    final savedListId = (r['savedListId'] as int?) ?? 0;
    final pos = (r['chapterPos'] as int?) ?? 0;
    final total = (r['totalChapters'] as int?) ?? 0;
    final hasStarted = savedListId > 0 && pos > 0;
    return ContinueReadingInfo(
      novelUrl: url,
      title: title,
      imageUrl: r['imageUrl'] as String?,
      chapterIndex: hasStarted ? pos - 1 : 0,
      totalChapters: total,
      lastChapterName: r['lastChapterName'] as String?,
      hasStarted: hasStarted,
    );
  }
}
