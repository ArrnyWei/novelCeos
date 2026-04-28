/// 首頁「繼續閱讀」卡片所需的最少資訊。
///
/// [chapterIndex] 為 0-based，可直接餵給 `ReaderPage(initialChapterIndex:)`。
/// [totalChapters] 為 0 表示尚未抓過章節列表（不顯示百分比）。
/// [hasStarted] 區分「曾經讀過」與「只加入書架還沒打開」。
class ContinueReadingInfo {
  final String novelUrl;
  final String title;
  final String? imageUrl;
  final int chapterIndex;
  final int totalChapters;
  final String? lastChapterName;
  final bool hasStarted;

  const ContinueReadingInfo({
    required this.novelUrl,
    required this.title,
    this.imageUrl,
    required this.chapterIndex,
    required this.totalChapters,
    this.lastChapterName,
    required this.hasStarted,
  });

  /// 0..1 章節進度（章節序號 / 總章數）。totalChapters 為 0 時回傳 null。
  double? get progress {
    if (totalChapters <= 0) return null;
    return ((chapterIndex + 1) / totalChapters).clamp(0.0, 1.0);
  }
}
